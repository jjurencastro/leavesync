<?php
/**
 * Thin facade preserving existing Auth::method() call sites across the app.
 * The actual logic lives in focused classes: AuthSession, GoogleAuth,
 * DeviceChangeRequest, UserRegistration, AuditLogger.
 */

require_once __DIR__ . '/AuthSession.php';
require_once __DIR__ . '/GoogleAuth.php';
require_once __DIR__ . '/DeviceChangeRequest.php';
require_once __DIR__ . '/UserRegistration.php';
require_once __DIR__ . '/AuditLogger.php';

class Auth {

    public static function isAllowedEmailDomain($email) {
        return GoogleAuth::isAllowedEmailDomain($email);
    }

    public static function buildGoogleAuthUrl($redirectUri) {
        return GoogleAuth::buildAuthUrl($redirectUri);
    }

    public static function handleGoogleCallback($code, $redirectUri) {
        return GoogleAuth::handleCallback($code, $redirectUri);
    }

    public static function getPendingDeviceChangeInfo() {
        return DeviceChangeRequest::getPendingInfo();
    }

    public static function confirmPendingDeviceChange() {
        return DeviceChangeRequest::confirmPending();
    }

    public static function cancelPendingDeviceChange() {
        return DeviceChangeRequest::cancelPending();
    }

    public static function register($data) {
        return UserRegistration::register($data);
    }

    public static function login($username, $password, $totp_code = null, $confirm_device_change = false) {
        return AuthSession::login($username, $password, $totp_code, $confirm_device_change);
    }

    public static function logout() {
        return AuthSession::logout();
    }

    public static function getCurrentUser() {
        return AuthSession::getCurrentUser();
    }

    public static function isAuthenticated() {
        return AuthSession::isAuthenticated();
    }

    public static function setPassword($user_id, $password, array $data = []) {
        return UserRegistration::setPassword($user_id, $password, $data);
    }

    public static function changePassword($user_id, $currentPassword, $newPassword) {
        return UserRegistration::changePassword($user_id, $currentPassword, $newPassword);
    }

    public static function getActivationInfo($user_id) {
        return UserRegistration::getActivationInfo($user_id);
    }

    public static function reserveNextUserId() {
        return UserRegistration::reserveNextUserId();
    }

    /**
     * Check if user has specific role
     * @param string $role Role to check
     * @return bool Has role
     */
    public static function hasRole($role) {
        return AuthSession::hasRole($role);
    }

    public static function auditLog($user_id, $action, $entity_type, $entity_id = null, $changes = []) {
        AuditLogger::log($user_id, $action, $entity_type, $entity_id, $changes);
    }
}

