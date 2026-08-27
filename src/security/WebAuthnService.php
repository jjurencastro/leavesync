<?php
/**
 * WebAuthn (FIDO2) passkey registration and approval-assertion verification,
 * used to replace the private-key digital-signature step for manager/hr/admin
 * approvals (Windows Hello, Face ID, Touch ID, etc.).
 */

require_once __DIR__ . '/../database/Database.php';
require_once __DIR__ . '/../auth/AuditLogger.php';

use Webauthn\PublicKeyCredentialCreationOptions;
use Webauthn\PublicKeyCredentialRequestOptions;
use Webauthn\PublicKeyCredentialRpEntity;
use Webauthn\PublicKeyCredentialUserEntity;
use Webauthn\PublicKeyCredentialParameters;
use Webauthn\PublicKeyCredentialDescriptor;
use Webauthn\AuthenticatorSelectionCriteria;
use Webauthn\AuthenticatorAttestationResponseValidator;
use Webauthn\AuthenticatorAssertionResponseValidator;
use Webauthn\AuthenticatorAttestationResponse;
use Webauthn\AuthenticatorAssertionResponse;
use Webauthn\CeremonyStep\CeremonyStepManagerFactory;
use Webauthn\Denormalizer\WebauthnSerializerFactory;
use Webauthn\AttestationStatement\AttestationStatementSupportManager;
use Webauthn\AttestationStatement\NoneAttestationStatementSupport;
use Webauthn\CredentialRecord;
use Webauthn\TrustPath\EmptyTrustPath;
use Symfony\Component\Uid\Uuid;
use ParagonIE\ConstantTime\Base64UrlSafe;

class WebAuthnService {

    const ALLOWED_ROLES = ['manager', 'hr', 'admin'];
    const CHALLENGE_TTL_SECONDS = 300;

    private static function rpId() {
        return parse_url(rtrim(APP_URL, '/'), PHP_URL_HOST);
    }

    private static function origin() {
        return rtrim(APP_URL, '/');
    }

    private static function serializer() {
        $supportManager = new AttestationStatementSupportManager([new NoneAttestationStatementSupport()]);
        return (new WebauthnSerializerFactory($supportManager))->create();
    }

    private static function ceremonyFactory() {
        $factory = new CeremonyStepManagerFactory();
        $factory->setAllowedOrigins([self::origin()]);
        return $factory;
    }

    private static function assertApproverRole($user) {
        if (!in_array($user['role'], self::ALLOWED_ROLES, true)) {
            throw new Exception('Only supervisors, HR, and administrators can use passkeys');
        }
    }

    /**
     * Options for navigator.credentials.create(), plus stores the challenge for later verification.
     */
    public static function getRegistrationOptions($user) {
        self::assertApproverRole($user);

        $db = Database::getInstance();
        $challenge = random_bytes(32);

        $existingCredentials = $db->getResults(
            "SELECT credential_id, transports FROM webauthn_credentials WHERE user_id = ?",
            [$user['id']]
        );

        self::storeChallenge($user['id'], $challenge, 'registration', null, null);

        return [
            'rp' => ['id' => self::rpId(), 'name' => 'LeaveSync'],
            'user' => [
                'id' => Base64UrlSafe::encodeUnpadded((string) $user['id']),
                'name' => $user['username'],
                'displayName' => $user['full_name'],
            ],
            'challenge' => Base64UrlSafe::encodeUnpadded($challenge),
            'pubKeyCredParams' => [
                ['type' => 'public-key', 'alg' => -7],   // ES256
                ['type' => 'public-key', 'alg' => -257],  // RS256
            ],
            'authenticatorSelection' => [
                'authenticatorAttachment' => 'platform',
                'residentKey' => 'preferred',
                'userVerification' => 'required',
            ],
            'attestation' => 'none',
            'excludeCredentials' => array_map(function ($row) {
                return ['type' => 'public-key', 'id' => $row['credential_id'], 'transports' => json_decode($row['transports'] ?: '[]', true)];
            }, $existingCredentials),
            'timeout' => 60000,
        ];
    }

    /**
     * Verify the browser's navigator.credentials.create() response and store the new credential.
     */
    public static function verifyRegistration($user, array $responseData, $label = null) {
        self::assertApproverRole($user);

        $challengeRow = self::consumeChallenge($user['id'], 'registration', null, null);
        if (!$challengeRow) {
            throw new Exception('Registration challenge expired or not found; please try again');
        }

        $publicKeyCredential = self::serializer()->deserialize(
            json_encode($responseData),
            \Webauthn\PublicKeyCredential::class,
            'json'
        );

        if (!$publicKeyCredential->response instanceof AuthenticatorAttestationResponse) {
            throw new Exception('Invalid passkey registration response');
        }

        $options = new PublicKeyCredentialCreationOptions(
            new PublicKeyCredentialRpEntity('LeaveSync', self::rpId()),
            new PublicKeyCredentialUserEntity($user['username'], (string) $user['id'], $user['full_name']),
            Base64UrlSafe::decodeNoPadding($challengeRow['challenge']),
            [
                new PublicKeyCredentialParameters('public-key', -7),
                new PublicKeyCredentialParameters('public-key', -257),
            ],
            new AuthenticatorSelectionCriteria('platform', 'required', 'preferred')
        );

        $validator = AuthenticatorAttestationResponseValidator::create(self::ceremonyFactory()->creationCeremony());
        $credentialRecord = $validator->check($publicKeyCredential->response, $options, self::rpId());

        $db = Database::getInstance();
        $db->execute(
            "INSERT INTO webauthn_credentials
                (user_id, credential_id, public_key, attestation_type, aaguid, transports, sign_count, label)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            [
                $user['id'],
                Base64UrlSafe::encodeUnpadded($credentialRecord->publicKeyCredentialId),
                base64_encode($credentialRecord->credentialPublicKey),
                $credentialRecord->attestationType,
                (string) $credentialRecord->aaguid,
                json_encode($credentialRecord->transports),
                $credentialRecord->counter,
                $label ?: 'Passkey',
            ]
        );

        AuditLogger::log($user['id'], 'webauthn_credential_registered', 'user', $user['id']);

        return ['success' => true, 'message' => 'Passkey registered'];
    }

    public static function listCredentials($user_id) {
        $db = Database::getInstance();
        return $db->getResults(
            "SELECT id, label, created_at, last_used_at FROM webauthn_credentials WHERE user_id = ? ORDER BY created_at DESC",
            [$user_id]
        );
    }

    public static function deleteCredential($id, $user_id) {
        $db = Database::getInstance();
        $db->execute("DELETE FROM webauthn_credentials WHERE id = ? AND user_id = ?", [$id, $user_id]);
        AuditLogger::log($user_id, 'webauthn_credential_removed', 'user', $user_id);
        return ['success' => true, 'message' => 'Passkey removed'];
    }

    /**
     * Options for navigator.credentials.get(), scoped to this approver's own passkeys and
     * tied to a specific request so the resulting assertion can't be replayed elsewhere.
     */
    public static function getApprovalOptions($user, $contextType, $contextId) {
        self::assertApproverRole($user);

        $credentials = self::listAllCredentialIds($user['id']);
        if (empty($credentials)) {
            throw new Exception('Register a passkey in Settings before approving requests');
        }

        $challenge = random_bytes(32);
        self::storeChallenge($user['id'], $challenge, 'approval', $contextType, $contextId);

        return [
            'challenge' => Base64UrlSafe::encodeUnpadded($challenge),
            'rpId' => self::rpId(),
            'userVerification' => 'required',
            'allowCredentials' => array_map(function ($credentialId) {
                return ['type' => 'public-key', 'id' => $credentialId];
            }, $credentials),
            'timeout' => 60000,
        ];
    }

    /**
     * Verify the browser's navigator.credentials.get() response for a specific approval action.
     * Returns the base64url assertion signature (for the audit trail) on success, throws on failure.
     */
    public static function verifyApproval($user, array $responseData, $contextType, $contextId) {
        self::assertApproverRole($user);

        $challengeRow = self::consumeChallenge($user['id'], 'approval', $contextType, $contextId);
        if (!$challengeRow) {
            throw new Exception('Approval challenge expired or not found; please try again');
        }

        $publicKeyCredential = self::serializer()->deserialize(
            json_encode($responseData),
            \Webauthn\PublicKeyCredential::class,
            'json'
        );

        if (!$publicKeyCredential->response instanceof AuthenticatorAssertionResponse) {
            throw new Exception('Invalid passkey approval response');
        }

        $credentialIdEncoded = Base64UrlSafe::encodeUnpadded($publicKeyCredential->rawId);
        $db = Database::getInstance();
        $storedCredential = $db->getRow(
            "SELECT * FROM webauthn_credentials WHERE user_id = ? AND credential_id = ?",
            [$user['id'], $credentialIdEncoded]
        );

        if (!$storedCredential) {
            throw new Exception('Passkey not recognized');
        }

        $credentialRecord = new CredentialRecord(
            Base64UrlSafe::decodeNoPadding($storedCredential['credential_id']),
            'public-key',
            json_decode($storedCredential['transports'] ?: '[]', true),
            $storedCredential['attestation_type'],
            EmptyTrustPath::create(),
            Uuid::fromString($storedCredential['aaguid']),
            base64_decode($storedCredential['public_key']),
            (string) $user['id'],
            (int) $storedCredential['sign_count']
        );

        $options = PublicKeyCredentialRequestOptions::create(
            Base64UrlSafe::decodeNoPadding($challengeRow['challenge']),
            self::rpId(),
            [],
            'required'
        );

        $validator = AuthenticatorAssertionResponseValidator::create(self::ceremonyFactory()->requestCeremony());
        $updatedRecord = $validator->check(
            $credentialRecord,
            $publicKeyCredential->response,
            $options,
            self::rpId(),
            (string) $user['id']
        );

        $db->execute(
            "UPDATE webauthn_credentials SET sign_count = ?, last_used_at = NOW() WHERE id = ?",
            [$updatedRecord->counter, $storedCredential['id']]
        );

        return Base64UrlSafe::encodeUnpadded($publicKeyCredential->response->signature);
    }

    private static function listAllCredentialIds($user_id) {
        $db = Database::getInstance();
        $rows = $db->getResults("SELECT credential_id FROM webauthn_credentials WHERE user_id = ?", [$user_id]);
        return array_map(function ($row) {
            return $row['credential_id'];
        }, $rows);
    }

    private static function storeChallenge($user_id, $challenge, $purpose, $contextType, $contextId) {
        $db = Database::getInstance();
        $expiresAt = date('Y-m-d H:i:s', time() + self::CHALLENGE_TTL_SECONDS);
        $db->execute(
            "INSERT INTO webauthn_challenges (user_id, challenge, purpose, context_type, context_id, expires_at) VALUES (?, ?, ?, ?, ?, ?)",
            [$user_id, Base64UrlSafe::encodeUnpadded($challenge), $purpose, $contextType, $contextId, $expiresAt]
        );
    }

    /**
     * Fetch and delete (single-use) the most recent matching, unexpired challenge.
     */
    private static function consumeChallenge($user_id, $purpose, $contextType, $contextId) {
        $db = Database::getInstance();
        $params = [$user_id, $purpose];
        $sql = "SELECT * FROM webauthn_challenges WHERE user_id = ? AND purpose = ? AND expires_at > NOW()";

        if ($contextType === null) {
            $sql .= " AND context_type IS NULL AND context_id IS NULL";
        } else {
            $sql .= " AND context_type = ? AND context_id = ?";
            $params[] = $contextType;
            $params[] = $contextId;
        }

        $sql .= " ORDER BY created_at DESC LIMIT 1";
        $row = $db->getRow($sql, $params);

        if ($row) {
            $db->execute("DELETE FROM webauthn_challenges WHERE id = ?", [$row['id']]);
        }

        return $row;
    }
}
