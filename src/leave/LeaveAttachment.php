<?php
/**
 * Supporting-document attachments for leave requests.
 *
 * Upload is optional (soft): a leave type flagged requires_documentation never
 * blocks filing, but approvers can see whether proof was attached. Files are
 * stored in the leave_attachments table (LONGBLOB) so they survive ephemeral
 * filesystems. Allowed types: PDF/JPEG/PNG up to MAX_BYTES.
 *
 * Access: the request owner and anyone LeaveRequestAccess::canView() grants
 * (assigned/supervising manager, HR, admin) may list and download.
 */
class LeaveAttachment {

    const MAX_BYTES = 5242880; // 5 MB

    const ALLOWED_MIME = [
        'application/pdf' => 'pdf',
        'image/jpeg'      => 'jpg',
        'image/png'       => 'png',
    ];

    /**
     * Attach an uploaded file to a leave request owned by the user.
     *
     * @param array $file  A $_FILES['...'] entry
     * @param int   $leaveRequestId
     * @param array $user  The authenticated request owner
     * @return array ['success' => bool, 'message' => string, 'id' => int]
     */
    public static function attach(array $file, $leaveRequestId, array $user) {
        $db = Database::getInstance();

        if (empty($file) || ($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            throw new Exception('No file was uploaded');
        }

        $request = $db->getRow(
            "SELECT id, user_id, status FROM leave_requests WHERE id = ?",
            [$leaveRequestId]
        );
        if (!$request) {
            throw new Exception('Leave request not found');
        }
        // Only the owner may attach a document, and only while it can still change.
        if ((int) $request['user_id'] !== (int) $user['id']) {
            throw new Exception('You can only attach documents to your own leave requests');
        }
        if (in_array($request['status'], ['cancelled', 'rejected'], true)) {
            throw new Exception('Cannot attach a document to a ' . $request['status'] . ' request');
        }

        if (!is_uploaded_file($file['tmp_name'])) {
            throw new Exception('Invalid upload');
        }
        if ((int) $file['size'] <= 0 || (int) $file['size'] > self::MAX_BYTES) {
            throw new Exception('File must be a non-empty PDF or image up to 5 MB');
        }

        // Sniff the real type from content rather than trusting the client header.
        $mime = self::detectMime($file['tmp_name']);
        if (!isset(self::ALLOWED_MIME[$mime])) {
            throw new Exception('Only PDF, JPG, and PNG files are allowed');
        }

        $contents = file_get_contents($file['tmp_name']);
        if ($contents === false) {
            throw new Exception('Could not read the uploaded file');
        }

        $name = self::sanitizeName($file['name'] ?? 'document');

        $db->execute(
            "INSERT INTO leave_attachments (leave_request_id, user_id, original_name, mime_type, file_size, file_data)
             VALUES (?, ?, ?, ?, ?, ?)",
            [$leaveRequestId, $user['id'], $name, $mime, (int) $file['size'], $contents]
        );

        $id = (int) $db->lastInsertId();
        AuditLogger::log($user['id'], 'attach_document', 'leave_request', $leaveRequestId, [
            'attachment_id' => $id,
            'name' => $name,
            'mime' => $mime,
            'size' => (int) $file['size'],
        ]);

        return ['success' => true, 'message' => 'Document attached', 'id' => $id];
    }

    /**
     * List an request's attachments (metadata only, no file bytes) for a viewer
     * who is allowed to see the request.
     */
    public static function listForRequest($leaveRequestId, array $viewer) {
        $db = Database::getInstance();
        self::assertCanView($leaveRequestId, $viewer);
        return $db->getResults(
            "SELECT id, leave_request_id, original_name, mime_type, file_size, created_at
             FROM leave_attachments WHERE leave_request_id = ? ORDER BY id",
            [$leaveRequestId]
        );
    }

    /**
     * Fetch a single attachment (including bytes) for streaming, if the viewer
     * is allowed to see the parent request. Returns the row or throws.
     */
    public static function getForDownload($attachmentId, array $viewer) {
        $db = Database::getInstance();
        $attachment = $db->getRow(
            "SELECT * FROM leave_attachments WHERE id = ?",
            [$attachmentId]
        );
        if (!$attachment) {
            throw new Exception('Attachment not found');
        }
        self::assertCanView((int) $attachment['leave_request_id'], $viewer);
        return $attachment;
    }

    /**
     * Delete an attachment. Only the owner may delete, and only while the
     * request is still pending.
     */
    public static function remove($attachmentId, array $user) {
        $db = Database::getInstance();
        $attachment = $db->getRow(
            "SELECT a.*, lr.status AS request_status
             FROM leave_attachments a JOIN leave_requests lr ON a.leave_request_id = lr.id
             WHERE a.id = ?",
            [$attachmentId]
        );
        if (!$attachment) {
            throw new Exception('Attachment not found');
        }
        if ((int) $attachment['user_id'] !== (int) $user['id']) {
            throw new Exception('You can only remove your own attachments');
        }
        if ($attachment['request_status'] !== 'pending') {
            throw new Exception('Documents can only be removed while the request is pending');
        }
        $db->execute("DELETE FROM leave_attachments WHERE id = ?", [$attachmentId]);
        AuditLogger::log($user['id'], 'remove_document', 'leave_request', (int) $attachment['leave_request_id'], [
            'attachment_id' => $attachmentId,
        ]);
        return ['success' => true, 'message' => 'Document removed'];
    }

    /** Throw unless the viewer may see the given leave request. */
    private static function assertCanView($leaveRequestId, array $viewer) {
        $db = Database::getInstance();
        $request = $db->getRow(
            "SELECT lr.*, u.supervisor_id AS requester_supervisor_id
             FROM leave_requests lr JOIN users u ON lr.user_id = u.id WHERE lr.id = ?",
            [$leaveRequestId]
        );
        if (!$request) {
            throw new Exception('Leave request not found');
        }
        if (!LeaveRequestAccess::canView($request, $viewer)) {
            throw new Exception('Unauthorized');
        }
    }

    /** Detect the real MIME type from file contents (finfo), not the client header. */
    private static function detectMime($tmpPath) {
        if (function_exists('finfo_open')) {
            $finfo = finfo_open(FILEINFO_MIME_TYPE);
            $mime = finfo_file($finfo, $tmpPath);
            finfo_close($finfo);
            return is_string($mime) ? $mime : 'application/octet-stream';
        }
        $info = @getimagesize($tmpPath);
        if ($info && !empty($info['mime'])) {
            return $info['mime'];
        }
        return 'application/octet-stream';
    }

    /** Keep a safe, display-only filename (basename, stripped of control chars). */
    private static function sanitizeName($name) {
        $name = basename((string) $name);
        $name = preg_replace('/[\x00-\x1F\x7F]/', '', $name);
        $name = trim($name);
        return $name === '' ? 'document' : substr($name, 0, 255);
    }
}
