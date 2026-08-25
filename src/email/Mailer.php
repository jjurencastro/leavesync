<?php
/**
 * Minimal SMTP mail client (no external dependencies).
 * Supports STARTTLS/SSL + AUTH LOGIN, which covers Gmail, Outlook, and most
 * transactional SMTP providers.
 */

class Mailer {

    /**
     * Send a plain-text email via SMTP.
     * @return bool True on success, false on failure (errors are logged, never thrown to the caller)
     */
    public static function send($to, $subject, $body) {
        if (empty(MAIL_HOST) || empty(MAIL_USER) || empty(MAIL_PASSWORD)) {
            error_log("Mailer: MAIL_HOST/MAIL_USER/MAIL_PASSWORD not configured; email to {$to} not sent");
            return false;
        }

        $transport = MAIL_ENCRYPTION === 'ssl' ? 'ssl://' : '';
        $socket = @stream_socket_client(
            "{$transport}" . MAIL_HOST . ':' . MAIL_PORT,
            $errno,
            $errstr,
            10
        );

        if (!$socket) {
            error_log("Mailer: connection failed - {$errstr} ({$errno})");
            return false;
        }

        try {
            self::expect($socket, '220');
            self::command($socket, 'EHLO ' . parse_url(APP_URL, PHP_URL_HOST) ?: 'localhost', '250');

            if (MAIL_ENCRYPTION === 'tls') {
                self::command($socket, 'STARTTLS', '220');
                if (!stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
                    throw new Exception('STARTTLS negotiation failed');
                }
                self::command($socket, 'EHLO ' . (parse_url(APP_URL, PHP_URL_HOST) ?: 'localhost'), '250');
            }

            self::command($socket, 'AUTH LOGIN', '334');
            self::command($socket, base64_encode(MAIL_USER), '334');
            self::command($socket, base64_encode(MAIL_PASSWORD), '235');

            self::command($socket, 'MAIL FROM:<' . MAIL_FROM . '>', '250');
            self::command($socket, 'RCPT TO:<' . $to . '>', '250');
            self::command($socket, 'DATA', '354');

            $headers = "From: LeaveSync <" . MAIL_FROM . ">\r\n";
            $headers .= "To: <{$to}>\r\n";
            $headers .= "Subject: {$subject}\r\n";
            $headers .= "MIME-Version: 1.0\r\n";
            $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

            $message = $headers . "\r\n" . str_replace("\n.", "\n..", $body) . "\r\n.";
            self::command($socket, $message, '250');

            self::command($socket, 'QUIT', '221');
            fclose($socket);
            return true;
        } catch (Exception $e) {
            error_log("Mailer: send failed - " . $e->getMessage());
            if (is_resource($socket)) {
                fclose($socket);
            }
            return false;
        }
    }

    private static function command($socket, $line, $expectedCode) {
        fwrite($socket, $line . "\r\n");
        self::expect($socket, $expectedCode);
    }

    private static function expect($socket, $expectedCode) {
        $response = '';
        while ($chunk = fgets($socket, 512)) {
            $response .= $chunk;
            // Multi-line SMTP replies use "code-" for continuation, "code " for the final line
            if (preg_match('/^\d{3} /', substr($chunk, 0, 4)) || strlen($chunk) < 4) {
                break;
            }
        }

        if (strpos($response, $expectedCode) !== 0) {
            throw new Exception("Unexpected SMTP response (expected {$expectedCode}): {$response}");
        }

        return $response;
    }
}
