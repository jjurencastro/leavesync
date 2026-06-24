<?php
/**
 * Digital Signature for Secure Document Approval
 * Uses RSA-based digital signatures with cryptographic signing
 */

class DigitalSignature {

    private static $algorithm = 'sha256WithRSAEncryption';

    /**
     * Generate RSA key pair for user
     * @return array ['public_key' => string, 'private_key' => string]
     */
    public static function generateKeyPair() {
        $config = [
            "digest_alg" => "sha256",
            "private_key_bits" => 4096,
            "private_key_type" => OPENSSL_KEYTYPE_RSA,
        ];

        // Create private key
        $private_key = openssl_pkey_new($config);
        
        if ($private_key === false) {
            throw new Exception("Failed to generate private key");
        }

        // Export private key
        openssl_pkey_export($private_key, $private_key_pem);

        // Get public key
        $public_key_details = openssl_pkey_get_details($private_key);
        $public_key = $public_key_details['key'];

        return [
            'public_key' => $public_key,
            'private_key' => $private_key_pem
        ];
    }

    /**
     * Sign a document with user's private key
     * @param string $document_content Document content to sign
     * @param string $user_private_key User's private key
     * @return string Digital signature (base64 encoded)
     */
    public static function sign($document_content, $user_private_key) {
        $signature = '';
        
        $private_key = openssl_pkey_get_private($user_private_key);
        
        if ($private_key === false) {
            throw new Exception("Invalid private key");
        }

        $result = openssl_sign(
            $document_content,
            $signature,
            $private_key,
            OPENSSL_ALGO_SHA256
        );

        if (!$result) {
            throw new Exception("Failed to sign document");
        }

        openssl_pkey_free($private_key);

        return base64_encode($signature);
    }

    /**
     * Verify document signature with public key
     * @param string $document_content Document content
     * @param string $signature Digital signature (base64 encoded)
     * @param string $public_key User's public key
     * @return bool Is signature valid
     */
    public static function verify($document_content, $signature, $public_key) {
        try {
            $public_key_res = openssl_pkey_get_public($public_key);
            
            if ($public_key_res === false) {
                return false;
            }

            $decoded_signature = base64_decode($signature);
            
            $result = openssl_verify(
                $document_content,
                $decoded_signature,
                $public_key_res,
                OPENSSL_ALGO_SHA256
            );

            openssl_free_key($public_key_res);

            return $result === 1;
        } catch (Exception $e) {
            error_log("Signature verification error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Create and store digital signature for leave request
     * @param int $leave_request_id Leave request ID
     * @param string $approver_private_key Approver's private key
     * @param int $approver_id Approver's user ID
     * @return string Signature hash
     */
    public static function signLeaveRequest($leave_request_id, $approver_private_key, $approver_id) {
        $db = Database::getInstance();
        
        // Get leave request details
        $leave_request = $db->getRow(
            "SELECT * FROM leave_requests WHERE id = ?",
            [$leave_request_id]
        );

        if (!$leave_request) {
            throw new Exception("Leave request not found");
        }

        // Create document content to sign
        $document_content = self::createLeaveRequestDocument($leave_request);

        // Sign the document
        $signature = self::sign($document_content, $approver_private_key);
        $signature_hash = hash('sha256', $signature);

        // Store digital signature
        $sql = "INSERT INTO digital_signatures 
                (document_id, document_type, signer_id, signature_hash, timestamp, is_valid) 
                VALUES (?, ?, ?, ?, NOW(), 1)";
        
        $db->execute($sql, [
            $leave_request_id,
            'leave_request',
            $approver_id,
            $signature_hash
        ]);

        // Update leave request with signature
        $update_sql = "UPDATE leave_requests 
                      SET digital_signature = ?, signature_timestamp = NOW() 
                      WHERE id = ?";
        $db->execute($update_sql, [$signature_hash, $leave_request_id]);

        return $signature_hash;
    }

    /**
     * Verify leave request signature
     * @param int $leave_request_id Leave request ID
     * @return bool Is signature valid
     */
    public static function verifyLeaveRequestSignature($leave_request_id) {
        $db = Database::getInstance();
        
        $leave_request = $db->getRow(
            "SELECT lr.*, ds.signature_hash, u.public_key 
             FROM leave_requests lr
             LEFT JOIN digital_signatures ds ON lr.id = ds.document_id
             LEFT JOIN users u ON lr.manager_id = u.id
             WHERE lr.id = ?",
            [$leave_request_id]
        );

        if (!$leave_request || !$leave_request['signature_hash'] || !$leave_request['public_key']) {
            return false;
        }

        $document_content = self::createLeaveRequestDocument($leave_request);
        
        return self::verify(
            $document_content,
            $leave_request['signature_hash'],
            $leave_request['public_key']
        );
    }

    /**
     * Create document content for leave request
     * @param array $leave_request Leave request data
     * @return string Document content
     */
    private static function createLeaveRequestDocument($leave_request) {
        return sprintf(
            "LEAVE REQUEST APPROVAL DOCUMENT\n" .
            "Request ID: %d\n" .
            "User ID: %d\n" .
            "Leave Type: %d\n" .
            "Start Date: %s\n" .
            "End Date: %s\n" .
            "Number of Days: %s\n" .
            "Reason: %s\n" .
            "Status: %s\n" .
            "Created: %s\n",
            $leave_request['id'],
            $leave_request['user_id'],
            $leave_request['leave_type_id'],
            $leave_request['start_date'],
            $leave_request['end_date'],
            $leave_request['number_of_days'],
            $leave_request['reason'],
            $leave_request['status'],
            $leave_request['created_at']
        );
    }

    /**
     * Get signature information
     * @param int $leave_request_id Leave request ID
     * @return array Signature details
     */
    public static function getSignatureInfo($leave_request_id) {
        $db = Database::getInstance();
        
        return $db->getRow(
            "SELECT ds.*, u.full_name 
             FROM digital_signatures ds
             LEFT JOIN users u ON ds.signer_id = u.id
             WHERE ds.document_id = ? AND ds.document_type = 'leave_request'",
            [$leave_request_id]
        );
    }
}
?>
