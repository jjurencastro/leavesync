<?php
/**
 * Central mail sender (PHPMailer over SMTP).
 *
 * Every outbound email in the app goes through Mailer::send(). Failures are
 * logged and reported as `false` — they never bubble up as exceptions, so a
 * mail outage can never break leave filing, password resets, or any other flow.
 *
 * Configuration comes from MAIL_* constants defined in config/config.php.
 * If SMTP is not configured, send() no-ops (logs and returns false).
 */

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception as PHPMailerException;

class Mailer {

    /**
     * @return bool True when enough SMTP settings exist to attempt sending.
     */
    public static function isConfigured() {
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
     * @return bool True when the message was accepted by the SMTP server
     */
    public static function send($toEmail, $toName, $subject, $html, $text = null) {
        if (!self::isConfigured()) {
            error_log("Mailer: SMTP not configured; skipping email '{$subject}' to {$toEmail}");
            return false;
        }

        if (!filter_var($toEmail, FILTER_VALIDATE_EMAIL)) {
            error_log("Mailer: invalid recipient address '{$toEmail}'; skipping email '{$subject}'");
            return false;
        }

        $mail = new PHPMailer(true);
        try {
            $mail->isSMTP();
            $mail->Host = MAIL_HOST;
            $mail->Port = MAIL_PORT;
            $mail->SMTPAuth = true;
            $mail->Username = MAIL_USER;
            $mail->Password = MAIL_PASSWORD;
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
            $mail->AltBody = $text !== null
                ? $text
                : trim(preg_replace('/\s+/', ' ', strip_tags(str_replace(['<br>', '<br/>', '<br />', '</p>'], "\n", $html))));

            $mail->send();
            return true;
        } catch (PHPMailerException $e) {
            error_log("Mailer: failed to send '{$subject}' to {$toEmail} — " . $mail->ErrorInfo);
            return false;
        }
    }
}
?>
