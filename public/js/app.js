/**
 * Main Application JavaScript
 */

const API_BASE = '/api';
const LEAVE_TYPE_ORDER = {
    'Vacation Leave': 1,
    'Sick Leave': 2,
    'Paternity Leave': 3,
    'Maternity Leave': 4,
    'Bereavement Leave': 5,
};

function sortLeaveTypes(items, nameKey = 'name') {
    return [...items].sort((a, b) => {
        const aName = a[nameKey] || a.name || '';
        const bName = b[nameKey] || b.name || '';
        const aOrder = LEAVE_TYPE_ORDER[aName] ?? Number.MAX_SAFE_INTEGER;
        const bOrder = LEAVE_TYPE_ORDER[bName] ?? Number.MAX_SAFE_INTEGER;
        return aOrder - bOrder;
    });
}

// Device Fingerprinting
class DeviceFingerprintManager {
    static async getFingerprint() {
        return {
            screen_resolution: `${window.innerWidth}x${window.innerHeight}`,
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            language: navigator.language,
            platform: navigator.platform,
            hardware_concurrency: navigator.hardwareConcurrency || 'unknown',
            device_memory: navigator.deviceMemory || 'unknown'
        };
    }

    static async sendFingerprint() {
        const fingerprint = await this.getFingerprint();
        const formData = new FormData();
        Object.entries(fingerprint).forEach(([key, value]) => {
            formData.append(key, value);
        });
        return fingerprint;
    }
}

// API Client
class APIClient {
    static async request(endpoint, method = 'GET', data = null) {
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            }
        };

        if (data && (method === 'POST' || method === 'PUT')) {
            options.body = JSON.stringify(data);
        }

        try {
            const response = await fetch(`${API_BASE}/${endpoint}`, options);
            const responseText = await response.text();
            let result;

            if (responseText.trim() === '') {
                result = { success: response.ok };
            } else {
                try {
                    result = JSON.parse(responseText);
                } catch (parseError) {
                    console.error('Invalid API response:', responseText);
                    return {
                        success: false,
                        message: response.ok
                            ? 'The server returned an invalid response.'
                            : `Request failed (${response.status}).`
                    };
                }
            }

            if (!response.ok && response.status === 401) {
                window.location.href = '/login';
            }

            return result;
        } catch (error) {
            console.error('API Error:', error);
            return { success: false, message: 'Unable to reach the server. Please try again.' };
        }
    }

    static async get(endpoint) {
        return this.request(endpoint, 'GET');
    }

    static async post(endpoint, data) {
        return this.request(endpoint, 'POST', data);
    }

    static async put(endpoint, data) {
        return this.request(endpoint, 'PUT', data);
    }

    static async delete(endpoint) {
        return this.request(endpoint, 'DELETE');
    }
}

// Authentication
class AuthManager {
    static async login(username, password, totpCode = null) {
        const fingerprint = await DeviceFingerprintManager.getFingerprint();
        return APIClient.post('auth.php?action=login', {
            username, password, totp_code: totpCode,
            ...fingerprint
        });
    }

    static async getActivationInfo() {
        return APIClient.get('auth.php?action=activation_info');
    }

    static async setPassword(data) {
        const fingerprint = await DeviceFingerprintManager.getFingerprint();
        return APIClient.post('auth.php?action=set_password', { ...data, ...fingerprint });
    }

    static async cancelActivation() {
        return APIClient.post('auth.php?action=cancel_activation', {});
    }

    static async logout() {
        return APIClient.get('auth.php?action=logout');
    }

    static async googleLogin() {
        return APIClient.post('auth.php?action=google_login', { redirect_uri: `${window.location.origin}/api/auth.php?action=google_callback` });
    }

    static async getProfile() {
        return APIClient.get('auth.php?action=profile');
    }

    static async setupMFA() {
        return APIClient.get('auth.php?action=mfa_setup');
    }

    static async getMFAStatus() {
        return APIClient.get('auth.php?action=mfa_status');
    }

    static async enableMFA(totpCode) {
        return APIClient.post('auth.php?action=mfa_enable', { totp_code: totpCode });
    }

    static async disableMFA() {
        return APIClient.get('auth.php?action=mfa_disable');
    }

    static async getTrustedDevices() {
        return APIClient.get('auth.php?action=devices');
    }

    static async updateProfile(data) {
        return APIClient.post('auth.php?action=update_profile', data);
    }

    static async getNotifications() {
        return APIClient.get('auth.php?action=notifications');
    }

    static async getAllNotifications() {
        return APIClient.get('auth.php?action=notifications&all=1');
    }

    static async markAllNotificationsRead() {
        return APIClient.post('auth.php?action=mark_all_notifications_read', {});
    }

    static async markNotificationRead(id) {
        return APIClient.post('auth.php?action=mark_notification_read', { id: id });
    }

    static async removeDevice(deviceId) {
        return APIClient.post('auth.php?action=remove_device', { device_id: deviceId });
    }

    static async changePassword(currentPassword, newPassword) {
        return APIClient.post('auth.php?action=change_password', {
            current_password: currentPassword,
            new_password: newPassword
        });
    }

    static async forgotPassword(username) {
        return APIClient.post('auth.php?action=forgot_password', { username });
    }
}

// Leave Requests
class LeaveRequestManager {
    static async createRequest(leaveTypeId, startDate, endDate, reason) {
        const fingerprint = await DeviceFingerprintManager.getFingerprint();
        return APIClient.post('leave_requests.php?action=create', {
            leave_type_id: leaveTypeId,
            start_date: startDate,
            end_date: endDate,
            reason: reason,
            ...fingerprint
        });
    }

    static async listRequests(status = 'all', search = '') {
        return APIClient.get(`leave_requests.php?action=list_filtered&status=${encodeURIComponent(status)}&search=${encodeURIComponent(search)}`);
    }

    static async getRequest(id) {
        return APIClient.get(`leave_requests.php?action=get&id=${id}`);
    }

    static async updateRequest(id, reason) {
        return APIClient.put(`leave_requests.php?action=update&id=${id}`, { reason });
    }

    static async cancelRequest(id) {
        return APIClient.post('leave_requests.php?action=cancel', { id: id });
    }

    static async approveRequest(id, comments = '', webauthnResponse = null) {
        const fingerprint = await DeviceFingerprintManager.getFingerprint();
        return APIClient.post('leave_requests.php?action=approve', {
            id: id,
            comments: comments,
            webauthn_response: webauthnResponse,
            ...fingerprint
        });
    }

    static async rejectRequest(id, comments = '') {
        return APIClient.post('leave_requests.php?action=reject', {
            id: id,
            comments: comments
        });
    }

    static async getLeaveBalance() {
        return APIClient.get('leave_requests.php?action=balance');
    }

    static async getLeaveTypes() {
        return APIClient.get('leave_requests.php?action=leave_types');
    }
}

// WebAuthn passkeys (Windows Hello / Face ID / Touch ID), used for manager/hr/admin approvals
class WebAuthnManager {
    static base64urlToBuffer(base64url) {
        const padding = '='.repeat((4 - (base64url.length % 4)) % 4);
        const base64 = (base64url + padding).replace(/-/g, '+').replace(/_/g, '/');
        const raw = atob(base64);
        const buffer = new Uint8Array(raw.length);
        for (let i = 0; i < raw.length; i++) buffer[i] = raw.charCodeAt(i);
        return buffer.buffer;
    }

    static bufferToBase64url(buffer) {
        const bytes = new Uint8Array(buffer);
        let str = '';
        bytes.forEach(b => { str += String.fromCharCode(b); });
        return btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
    }

    static isSupported() {
        return !!(window.PublicKeyCredential && navigator.credentials);
    }

    static async register(label) {
        if (!this.isSupported()) {
            return { success: false, message: 'This browser does not support passkeys' };
        }

        const optionsResult = await APIClient.get('webauthn.php?action=register_options');
        if (!optionsResult.success) return optionsResult;

        const o = optionsResult.options;
        const publicKey = {
            rp: o.rp,
            user: {
                id: this.base64urlToBuffer(o.user.id),
                name: o.user.name,
                displayName: o.user.displayName
            },
            challenge: this.base64urlToBuffer(o.challenge),
            pubKeyCredParams: o.pubKeyCredParams,
            authenticatorSelection: o.authenticatorSelection,
            attestation: o.attestation,
            excludeCredentials: o.excludeCredentials.map(c => ({
                type: c.type,
                id: this.base64urlToBuffer(c.id),
                transports: c.transports
            })),
            timeout: o.timeout
        };

        let credential;
        try {
            credential = await navigator.credentials.create({ publicKey });
        } catch (err) {
            return { success: false, message: err.message || 'Passkey registration was cancelled or failed' };
        }

        const response = {
            id: credential.id,
            rawId: this.bufferToBase64url(credential.rawId),
            type: credential.type,
            response: {
                clientDataJSON: this.bufferToBase64url(credential.response.clientDataJSON),
                attestationObject: this.bufferToBase64url(credential.response.attestationObject)
            }
        };

        return APIClient.post('webauthn.php?action=register_verify', { response, label });
    }

    static async listCredentials() {
        return APIClient.get('webauthn.php?action=credentials');
    }

    static async deleteCredential(id) {
        return APIClient.delete(`webauthn.php?action=delete_credential&id=${id}`);
    }

    /**
     * Prompts for a passkey (Windows Hello/Face ID/etc.) scoped to a specific leave request
     * or device-change request, and returns the response payload ready to submit for approval.
     */
    static async getApprovalAssertion(contextType, contextId) {
        if (!this.isSupported()) {
            throw new Error('This browser does not support passkeys');
        }

        const challengeResult = await APIClient.get(`webauthn.php?action=approval_challenge&type=${contextType}&id=${contextId}`);
        if (!challengeResult.success) {
            throw new Error(challengeResult.message || 'Failed to get passkey challenge');
        }

        const o = challengeResult.options;
        const publicKey = {
            challenge: this.base64urlToBuffer(o.challenge),
            rpId: o.rpId,
            userVerification: o.userVerification,
            allowCredentials: o.allowCredentials.map(c => ({
                type: c.type,
                id: this.base64urlToBuffer(c.id)
            })),
            timeout: o.timeout
        };

        const assertion = await navigator.credentials.get({ publicKey });

        return {
            id: assertion.id,
            rawId: this.bufferToBase64url(assertion.rawId),
            type: assertion.type,
            response: {
                clientDataJSON: this.bufferToBase64url(assertion.response.clientDataJSON),
                authenticatorData: this.bufferToBase64url(assertion.response.authenticatorData),
                signature: this.bufferToBase64url(assertion.response.signature),
                userHandle: assertion.response.userHandle ? this.bufferToBase64url(assertion.response.userHandle) : null
            }
        };
    }
}

// UI Utilities
class UIManager {
    static showAlert(message, type = 'info') {
        const container = document.body;

        document.querySelectorAll('.toast-notification').forEach(el => el.remove());
        clearTimeout(UIManager._alertTimeout);

        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type} toast-notification`;
        alertDiv.textContent = message;

        container.appendChild(alertDiv);

        UIManager._alertTimeout = setTimeout(() => alertDiv.remove(), 5000);
    }

    static showModal(content, title = 'Modal') {
        const modal = document.getElementById('modal') || this.createModal();
        modal.querySelector('.modal-header h2').textContent = title;
        modal.querySelector('.modal-body').innerHTML = content;
        modal.classList.add('active');
    }

    static hideModal() {
        const modal = document.getElementById('modal');
        if (modal) modal.classList.remove('active');
    }

    static createModal() {
        const modal = document.createElement('div');
        modal.id = 'modal';
        modal.className = 'modal';
        modal.innerHTML = `
            <div class="modal-content">
                <div class="modal-header">
                    <h2></h2>
                    <button type="button" class="modal-close" aria-label="Close">&times;</button>
                </div>
                <div class="modal-body"></div>
            </div>
        `;
        
        modal.querySelector('.modal-close').addEventListener('click', () => {
            this.hideModal();
        });

        modal.addEventListener('click', (e) => {
            if (e.target === modal) this.hideModal();
        });

        document.body.appendChild(modal);
        return modal;
    }

    static formatDate(dateString) {
        const date = new Date(dateString);
        if (Number.isNaN(date.getTime())) {
            return dateString || '';
        }

        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const year = String(date.getFullYear());

        return `${month}/${day}/${year}`;
    }

    static getStatusBadge(status) {
        const badges = {
            pending: '<span class="badge badge-pending">Pending</span>',
            approved: '<span class="badge badge-approved">Approved</span>',
            rejected: '<span class="badge badge-rejected">Rejected</span>',
            cancelled: '<span class="badge badge-cancelled">Cancelled</span>',
            not_required: '<span class="badge">N/A</span>'
        };
        return badges[status] || `<span class="badge">${status}</span>`;
    }

    // Two-stage leave approval status: Supervisor stage (skipped for Tier 2/manager requesters) then HR stage
    static getApprovalStageBadges(req) {
        const stageLabels = {
            supervisor_review: 'Awaiting Supervisor Review',
            hr_review: 'Awaiting HR Review',
            completed: 'Completed',
            rejected: 'Rejected',
            cancelled: 'Cancelled'
        };
        const overallStatus = req.overall_status || req.status;
        const stage = stageLabels[req.approval_stage] || 'In Progress';
        const supervisorStatus = overallStatus === 'cancelled' ? 'not_required' : req.supervisor_status;
        const hrStatus = overallStatus === 'cancelled' ? 'not_required' : req.hr_status;

        return `Outcome: ${this.getStatusBadge(overallStatus)}<br><small>Current Stage: ${stage}</small><br>Supervisor: ${this.getStatusBadge(supervisorStatus)} &nbsp; HR: ${this.getStatusBadge(hrStatus)}`;
    }
}

// Check Authentication
async function checkAuth() {
    const result = await AuthManager.getProfile();
    if (!result.success) {
        window.location.href = '/login';
        return null;
    }

    // Periodically re-validate the session so it auto-logs-out (without needing
    // a manual reload) if the device/network changes or a device-change request
    // gets approved elsewhere and invalidates this session server-side.
    if (!window.__sessionWatcherStarted) {
        window.__sessionWatcherStarted = true;
        setInterval(async () => {
            const check = await AuthManager.getProfile();
            if (!check.success) {
                window.location.href = '/login';
            }
        }, 15000);
    }

    return result.data;
}

function getUserInitials(user) {
    const name = (user.full_name || user.username || '').trim();
    const parts = name.split(/\s+/).filter(Boolean);
    if (parts.length > 1) {
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.slice(0, 2).toUpperCase() || '?';
}

function createUserAvatar(user) {
    const avatar = document.createElement('span');
    avatar.className = 'user-avatar';
    avatar.setAttribute('aria-hidden', 'true');

    const initials = getUserInitials(user);
    const useInitials = () => {
        avatar.classList.add('user-avatar-fallback');
        avatar.textContent = initials;
    };

    if (user.profile_picture_url) {
        const image = document.createElement('img');
        image.src = '/api/auth.php?action=profile_picture';
        image.alt = '';
        image.className = 'user-avatar-image';
        image.referrerPolicy = 'no-referrer';
        image.decoding = 'async';
        image.addEventListener('error', useInitials, { once: true });
        avatar.appendChild(image);
    } else {
        useInitials();
    }

    return avatar;
}

// Wire up the top-right user menu (avatar, full name + Settings/Logout dropdown) shared by every authenticated page
function initUserMenu(user) {
    initNotificationBell();
    const nameEl = document.getElementById('user-fullname');
    if (nameEl) {
        nameEl.textContent = user.full_name || user.username;

        const toggle = document.getElementById('user-menu-toggle');
        if (toggle) {
            toggle.querySelectorAll('.user-avatar').forEach(avatar => avatar.remove());
            toggle.insertBefore(createUserAvatar(user), nameEl);
        }
    }

    const toggle = document.getElementById('user-menu-toggle');
    const dropdown = document.getElementById('user-menu-dropdown');
    if (toggle && dropdown) {
        toggle.addEventListener('click', (e) => {
            e.stopPropagation();
            dropdown.classList.toggle('open');
        });
        document.addEventListener('click', () => dropdown.classList.remove('open'));
    }
}

// Wire up collapsible sidebar sections (e.g. Manage Users, Leave Requests)
function initSidebarMenu() {
    document.querySelectorAll('[data-toggle-target]').forEach(toggle => {
        toggle.addEventListener('click', (e) => {
            e.preventDefault();
            const target = document.getElementById(toggle.dataset.toggleTarget);
            if (!target) return;
            target.classList.toggle('open');
            toggle.classList.toggle('open');
        });
    });
}

// Managers get extra "Team Leave Requests" (in the dropdown) and "Device Change
// Requests" (before My Info) links; call after checkAuth on shared employee/manager pages
function applyManagerSidebarLinks(role, activePage) {
    if (role !== 'manager') return;

    const submenu = document.getElementById('leave-requests-submenu');
    if (submenu) {
        const activeClass = activePage === 'team-requests' ? ' active' : '';
        submenu.insertAdjacentHTML('beforeend', `<a href="/team-requests" class="sidebar-sublink${activeClass}">Team Leave Requests</a>`);
    }

    const myInfoLink = document.querySelector('.sidebar-nav > a[href="/my-info"]');
    if (myInfoLink) {
        const activeClass = activePage === 'device-requests' ? ' active' : '';
        myInfoLink.insertAdjacentHTML('beforebegin', `<a href="/device-requests" class="sidebar-link${activeClass}">Device Change Requests</a>`);
    }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', async () => {
    // Send device fingerprint on page load
    const fingerprint = await DeviceFingerprintManager.getFingerprint();
    console.log('Device Fingerprint:', fingerprint);
});

// Logout
async function logout() {
    if (confirm('Are you sure you want to logout?')) {
        await AuthManager.logout();
        window.location.href = '/login';
    }
}


// ---------------------------------------------------------------------------
// Notification bell (top header, before the profile menu)
// ---------------------------------------------------------------------------
function escapeNotificationText(value) {
    return String(value === null || value === undefined ? '' : value)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

function initNotificationBell() {
    const topbar = document.querySelector('.topbar');
    if (!topbar || document.getElementById('notification-bell')) return;

    const wrapper = document.createElement('div');
    wrapper.className = 'notification-menu';
    wrapper.innerHTML = `
        <button type="button" class="notification-bell" id="notification-bell" aria-label="Notifications" aria-haspopup="true">
            <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"></path>
                <path d="M13.7 21a2 2 0 0 1-3.4 0"></path>
            </svg>
            <span class="notification-badge" id="notification-badge" hidden>0</span>
        </button>
        <div class="notification-dropdown" id="notification-dropdown">
            <div class="notification-dropdown-header">
                <strong>Notifications</strong>
                <button type="button" class="notification-link-button" id="notification-mark-all">Mark all as read</button>
            </div>
            <div class="notification-dropdown-list" id="notification-dropdown-list"></div>
            <button type="button" class="notification-dropdown-footer" id="notification-view-all">View all</button>
        </div>
    `;

    const userMenu = topbar.querySelector('.user-menu');
    topbar.insertBefore(wrapper, userMenu);

    const bell = wrapper.querySelector('#notification-bell');
    const dropdown = wrapper.querySelector('#notification-dropdown');
    const list = wrapper.querySelector('#notification-dropdown-list');

    const render = (result) => {
        const badge = document.getElementById('notification-badge');
        const unread = result && result.success ? Number(result.summary?.unread || 0) : 0;
        badge.textContent = unread > 99 ? '99+' : String(unread);
        badge.hidden = unread === 0;
        wrapper.querySelector('#notification-mark-all').disabled = unread === 0;

        const items = result && result.success && Array.isArray(result.data) ? result.data.slice(0, 8) : [];
        if (!items.length) {
            list.innerHTML = '<p class="notification-empty">No notifications yet.</p>';
            return;
        }
        list.innerHTML = items.map(n => `
            <button type="button" class="notification-entry ${n.read_state === 'unread' ? 'unread' : ''}" data-id="${Number(n.id)}" data-unread="${n.read_state === 'unread' ? '1' : '0'}">
                <span class="notification-entry-title">${escapeNotificationText(n.title || 'Notification')}</span>
                <span class="notification-entry-message">${escapeNotificationText(n.message || '')}</span>
                <span class="notification-entry-time">${escapeNotificationText(UIManager.formatDate(n.created_at))}</span>
            </button>
        `).join('');
    };

    const refresh = async () => render(await AuthManager.getNotifications());
    window.refreshNotificationBell = refresh;

    bell.addEventListener('click', (e) => {
        e.stopPropagation();
        document.getElementById('user-menu-dropdown')?.classList.remove('open');
        dropdown.classList.toggle('open');
        if (dropdown.classList.contains('open')) refresh();
    });
    dropdown.addEventListener('click', (e) => e.stopPropagation());
    document.addEventListener('click', () => dropdown.classList.remove('open'));

    list.addEventListener('click', async (e) => {
        const entry = e.target.closest('.notification-entry');
        if (!entry || entry.dataset.unread !== '1') return;
        await AuthManager.markNotificationRead(entry.dataset.id);
        refresh();
    });

    wrapper.querySelector('#notification-mark-all').addEventListener('click', async () => {
        const result = await AuthManager.markAllNotificationsRead();
        if (result.success) {
            await refresh();
        }
    });

    const openAllModal = async () => {
        dropdown.classList.remove('open');
        let modal = document.getElementById('notification-modal');
        if (!modal) {
            modal = document.createElement('div');
            modal.className = 'modal notification-modal';
            modal.id = 'notification-modal';
            modal.innerHTML = `
                <div class="modal-content">
                    <div class="modal-header">
                        <h2>All Notifications</h2>
                        <button type="button" class="modal-close" aria-label="Close">&times;</button>
                    </div>
                    <div class="modal-body">
                        <div class="notification-modal-actions"><button type="button" class="btn btn-secondary btn-small" id="notification-modal-mark-all">Mark all as read</button></div>
                        <div id="notification-modal-list"></div>
                    </div>
                </div>`;
            document.body.appendChild(modal);
            const close = () => modal.classList.remove('active');
            modal.querySelector('.modal-close').addEventListener('click', close);
            modal.addEventListener('click', (e) => { if (e.target === modal) close(); });
            document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });
            modal.querySelector('#notification-modal-mark-all').addEventListener('click', async () => {
                const r = await AuthManager.markAllNotificationsRead();
                if (r.success) { await renderModal(); refresh(); }
            });
        }
        modal.classList.add('active');
        await renderModal();
    };

    const renderModal = async () => {
        const result = await AuthManager.getAllNotifications();
        const box = document.getElementById('notification-modal-list');
        const btn = document.getElementById('notification-modal-mark-all');
        const items = result.success && Array.isArray(result.data) ? result.data : [];
        btn.disabled = Number(result.summary?.unread || 0) === 0;
        box.innerHTML = items.length ? items.map(n => `
            <div class="notification-page-item ${n.read_state === 'unread' ? 'unread' : ''}">
                <div class="flex-between" style="gap: 0.75rem; flex-wrap: wrap;">
                    <strong>${escapeNotificationText(n.title || 'Notification')}</strong>
                    <small class="text-muted">${escapeNotificationText(UIManager.formatDate(n.created_at))}</small>
                </div>
                <p style="margin: 0.25rem 0 0;">${escapeNotificationText(n.message || '')}</p>
            </div>`).join('') : '<p class="notification-empty">No notifications yet.</p>';
    };

    wrapper.querySelector('#notification-view-all').addEventListener('click', openAllModal);

    refresh();
    setInterval(refresh, 60000);
}

// ---------------------------------------------------------------------------
// Responsive shell: device classes, mobile drawer / iPhone tab bar, table cards
// ---------------------------------------------------------------------------
function detectDeviceClasses() {
    const ua = navigator.userAgent || '';
    const touchMac = /Macintosh/.test(ua) && navigator.maxTouchPoints > 1;
    const isIPhone = /iPhone|iPod/.test(ua);
    const isIPad = /iPad/.test(ua) || touchMac;
    const isAndroid = /Android/.test(ua);
    const isAndroidTablet = isAndroid && !/Mobile/.test(ua);

    const classes = [];
    if (isIPhone) classes.push('device-iphone');
    if (isIPad) classes.push('device-tablet', 'device-ipad');
    if (isAndroid) classes.push('device-android');
    if (isAndroidTablet) classes.push('device-tablet');
    if (!isIPhone && !isIPad && !isAndroid) classes.push('device-desktop');
    return classes;
}

function labelResponsiveTables() {
    document.querySelectorAll('table.table').forEach(table => {
        const headers = Array.from(table.querySelectorAll('thead th')).map(th => th.textContent.trim());
        if (!headers.length) return;
        table.querySelectorAll('tbody tr').forEach(row => {
            Array.from(row.children).forEach((cell, index) => {
                if (cell.tagName !== 'TD') return;
                if (cell.colSpan > 1) {
                    cell.classList.add('td-full');
                } else if (!cell.hasAttribute('data-label') && headers[index]) {
                    cell.setAttribute('data-label', headers[index]);
                }
            });
        });
    });
}

function buildMobileNavigation() {
    const sidebar = document.querySelector('.sidebar');
    const topbar = document.querySelector('.topbar');
    if (!sidebar || !topbar || document.getElementById('mobile-nav-toggle')) return;

    const toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.id = 'mobile-nav-toggle';
    toggle.className = 'mobile-nav-toggle';
    toggle.setAttribute('aria-label', 'Open menu');
    toggle.innerHTML = '<svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="M3 6h18M3 12h18M3 18h18"></path></svg>';
    topbar.insertBefore(toggle, topbar.firstChild);

    const backdrop = document.createElement('div');
    backdrop.className = 'sidebar-backdrop';
    document.body.appendChild(backdrop);

    const setOpen = (open) => {
        document.body.classList.toggle('nav-open', open);
        toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    };
    toggle.addEventListener('click', () => setOpen(!document.body.classList.contains('nav-open')));
    backdrop.addEventListener('click', () => setOpen(false));
    sidebar.addEventListener('click', (e) => {
        if (e.target.closest('a[href]')) setOpen(false);
    });

    // iPhone gets an iOS-style bottom tab bar built from the sidebar links
    const tabBar = document.createElement('nav');
    tabBar.className = 'iphone-tabbar';
    tabBar.setAttribute('aria-label', 'Primary');
    document.body.appendChild(tabBar);

    const buildTabs = () => {
        const here = window.location.pathname.replace(/\/+$/, '') || '/';
        tabBar.innerHTML = Array.from(sidebar.querySelectorAll('a[href]'))
            .filter(a => a.getAttribute('href').startsWith('/') && !a.classList.contains('sidebar-brand'))
            .map(a => {
                const href = a.getAttribute('href');
                const active = href === here ? ' active' : '';
                return `<a href="${escapeNotificationText(href)}" class="iphone-tab${active}">${escapeNotificationText(a.textContent.trim())}</a>`;
            }).join('');
    };
    buildTabs();
    new MutationObserver(buildTabs).observe(sidebar, { childList: true, subtree: true });
}

function initResponsiveShell() {
    detectDeviceClasses().forEach(cls => document.documentElement.classList.add(cls));
    buildMobileNavigation();
    labelResponsiveTables();

    let pending = null;
    new MutationObserver(() => {
        if (pending) return;
        pending = requestAnimationFrame(() => {
            pending = null;
            labelResponsiveTables();
        });
    }).observe(document.body, { childList: true, subtree: true });
}

document.addEventListener('DOMContentLoaded', initResponsiveShell);
