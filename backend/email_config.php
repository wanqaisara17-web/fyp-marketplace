<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
use PHPMailer\PHPMailer\SMTP;

/**
 * PATH CORRECTION:
 * Based on your folder structure: C:\xampp\htdocs\demo\phpmailer\PHPMailer-master\src
 * We use __DIR__ to point to 'demo', then navigate into your subfolders.
 */
$path = __DIR__ . '/phpmailer/PHPMailer-master/src/'; 

require $path . 'Exception.php';
require $path . 'PHPMailer.php';
require $path . 'SMTP.php';

class EmailConfig {
    // Gmail SMTP Settings
    const SMTP_HOST = 'smtp.gmail.com';
    const SMTP_PORT = 587;
    
    // IMPORTANT: Enter your real Gmail and App Password here
    const SMTP_USERNAME = 'your-email@gmail.com'; 
    const SMTP_PASSWORD = 'your-app-password-here'; 
    
    const FROM_EMAIL = 'noreply@uitm_marketplace.com';
    const FROM_NAME = 'UiTM Jasin Marketplace';

    public static function sendOTP($toEmail, $otp) {
        // Domain validation: Ensures email is 10 digits @student.uitm.edu.my
        if (!preg_match('/^\d{10}@student\.uitm\.edu\.my$/', $toEmail)) {
            return ['success' => false, 'message' => 'Only UiTM Jasin student emails are permitted.'];
        }

        $mail = new PHPMailer(true);
        try {
            // Server settings
            $mail->isSMTP();
            $mail->Host       = self::SMTP_HOST;
            $mail->SMTPAuth   = true;
            $mail->Username   = self::SMTP_USERNAME;
            $mail->Password   = self::SMTP_PASSWORD;
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port       = self::SMTP_PORT;

            // Recipients
            $mail->setFrom(self::FROM_EMAIL, self::FROM_NAME);
            $mail->addAddress($toEmail);

            // Content
            $mail->isHTML(true);
            $mail->Subject = 'Verify Your Marketplace Account';
            $mail->Body    = "
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2 style='color: #007bff;'>UiTM Marketplace Verification</h2>
                    <p>Your One-Time Password (OTP) is:</p>
                    <div style='background: #f4f4f4; padding: 15px; font-size: 24px; font-weight: bold; text-align: center; border: 1px solid #ddd;'>
                        $otp
                    </div>
                    <p>This code will expire in 10 minutes.</p>
                    <p>If you did not request this, please ignore this email.</p>
                </body>
                </html>";

            $mail->send();
            return ['success' => true];
        } catch (Exception $e) {
            /**
             * FALLBACK LOGGING:
             * If the email fails to send (due to Wi-Fi block or wrong App Password),
             * the OTP is saved to 'email_log.txt' so you can still test your app.
             */
            $logEntry = date('Y-m-d H:i:s') . " - OTP for $toEmail: $otp (Error: {$mail->ErrorInfo})\n";
            file_put_contents(__DIR__ . '/email_log.txt', $logEntry, FILE_APPEND);
            
            return [
                'success' => false, 
                'message' => 'Email could not be sent, but OTP was logged to email_log.txt for testing.'
            ];
        }
    }
}
?>