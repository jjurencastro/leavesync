<?php
/**
 * Central mail sender. Two transports:
 *   - MAIL_TRANSPORT=api  → Brevo HTTP API (HTTPS/443). Use on hosts like
 *     Railway that block outbound SMTP ports. Requires BREVO_API_KEY.
 *   - MAIL_TRANSPORT=smtp (default) → PHPMailer over SMTP via MAIL_* settings.
 *     Fine for local dev with Gmail app passwords.
 *
 * Every outbound email in the app goes through Mailer::send(). Failures are
 * logged and reported as `false` — they never bubble up as exceptions, so a
 * mail outage can never break leave filing, password resets, or any other flow.
 * If no transport is configured, send() no-ops (logs and returns false).
 */

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception as PHPMailerException;

class Mailer {

    /**
     * @return bool True when a transport is configured enough to attempt sending.
     */
    public static function isConfigured() {
        if (MAIL_TRANSPORT === 'api') {
            return BREVO_API_KEY !== '' && MAIL_FROM !== '';
        }
        return MAIL_HOST !== '' && MAIL_USER !== '' && MAIL_PASSWORD !== '';
    }

    /**
     * Send an email.
     *
     * @param string      $toEmail Recipient address
     * @param string      $toName  Recipient display name (may be empty)
     * @param string      $subject Subject line
     * @param string      $html    HTML body
     * @param string|null $text    Plain-text fallback (derived from $html when null)
     * @return bool True when the message was accepted by the provider
     */
    public static function send($toEmail, $toName, $subject, $html, $text = null) {
        if (!self::isConfigured()) {
            error_log("Mailer: mail transport not configured; skipping email '{$subject}' to {$toEmail}");
            return false;
        }

        if (!filter_var($toEmail, FILTER_VALIDATE_EMAIL)) {
            error_log("Mailer: invalid recipient address '{$toEmail}'; skipping email '{$subject}'");
            return false;
        }

        if ($text === null) {
            $text = trim(preg_replace('/\s+/', ' ', strip_tags(str_replace(['<br>', '<br/>', '<br />', '</p>'], "\n", $html))));
        }

        return MAIL_TRANSPORT === 'api'
            ? self::sendViaBrevoApi($toEmail, $toName, $subject, $html, $text)
            : self::sendViaSmtp($toEmail, $toName, $subject, $html, $text);
    }

    /**
     * Brevo transactional email over HTTPS (port 443) — works on hosts that
     * block outbound SMTP ports. https://developers.brevo.com/reference/sendtransacemail
     */
    private static function sendViaBrevoApi($toEmail, $toName, $subject, $html, $text) {
        $payload = json_encode([
            'sender' => ['email' => MAIL_FROM, 'name' => MAIL_FROM_NAME],
            'to' => [['email' => $toEmail, 'name' => (string)$toName]],
            'subject' => $subject,
            'htmlContent' => $html,
            'textContent' => $text,
        ]);

        $ch = curl_init('https://api.brevo.com/v3/smtp/email');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'accept: application/json',
                'api-key: ' . BREVO_API_KEY,
                'content-type: application/json',
            ],
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_CONNECTTIMEOUT => 10,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_USERAGENT => 'LeaveSync mailer',
        ]);
        $response = curl_exec($ch);
        $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($response === false) {
            error_log("Mailer: Brevo API request failed for '{$subject}' to {$toEmail} — {$curlError}");
            return false;
        }
        if ($status >= 200 && $status < 300) {
            return true;
        }

        error_log("Mailer: Brevo API rejected '{$subject}' to {$toEmail} — HTTP {$status}: {$response}");
        return false;
    }

    /**
     * TEMP DIAGNOSTIC: raw Brevo call that returns the full HTTP response
     * instead of swallowing it. Remove after debugging.
     */
    public static function debugBrevo($toEmail) {
        $payload = json_encode([
            'sender' => ['email' => MAIL_FROM, 'name' => MAIL_FROM_NAME],
            'to' => [['email' => $toEmail, 'name' => 'Test']],
            'subject' => 'LeaveSync debug',
            'htmlContent' => '<p>debug</p>',
            'textContent' => 'debug',
        ]);
        $ch = curl_init('https://api.brevo.com/v3/smtp/email');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'accept: application/json',
                'api-key: ' . BREVO_API_KEY,
                'content-type: application/json',
            ],
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_CONNECTTIMEOUT => 10,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_SSL_VERIFYPEER => true,
        ]);
        $response = curl_exec($ch);
        $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);
        return ['http_status' => $status, 'response' => $response, 'curl_error' => $curlError, 'from' => MAIL_FROM];
    }

    /**
     * PHPMailer over SMTP (Gmail app password etc.). Short timeouts so a blocked
     * port fails fast instead of hanging the request.
     */
    private static function sendViaSmtp($toEmail, $toName, $subject, $html, $text) {
        $mail = new PHPMailer(true);
        try {
            $mail->isSMTP();
            $mail->Host = MAIL_HOST;
            $mail->Port = MAIL_PORT;
            $mail->SMTPAuth = true;
            $mail->Username = MAIL_USER;
            $mail->Password = MAIL_PASSWORD;
            $mail->Timeout = 10;
            if (MAIL_SECURE === 'ssl') {
                $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
            } elseif (MAIL_SECURE === 'tls') {
                $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            }
            $mail->CharSet = 'UTF-8';

            // Gmail rewrites From to the authenticated account anyway; default keeps
            // behavior consistent across providers.
            $mail->setFrom(MAIL_FROM !== '' ? MAIL_FROM : MAIL_USER, MAIL_FROM_NAME);
            $mail->addAddress($toEmail, (string)$toName);

            $mail->isHTML(true);
            $mail->Subject = $subject;
            $mail->Body = $html;
            $mail->AltBody = $text;

            $mail->send();
            return true;
        } catch (PHPMailerException $e) {
            error_log("Mailer: failed to send '{$subject}' to {$toEmail} — " . $mail->ErrorInfo);
            return false;
        }
    }
}
?>
