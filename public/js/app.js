/**
 * Main Application JavaScript
 */

const API_BASE = '/api';

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
            const result = await response.json();

            if (!response.ok && response.status === 401) {
                window.location.href = '/login';
            }

            return result;
        } catch (error) {
            console.error('API Error:', error);
            return { success: false, message: 'Network error' };
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
        return APIClient.post('auth.php?action=set_password', data);
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

    static async enableMFA(totpCode) {
        return APIClient.post('auth.php?action=mfa_enable', { totp_code: totpCode });
    }

    static async disableMFA() {
        return APIClient.get('auth.php?action=mfa_disable');
    }

    static async getTrustedDevices() {
        return APIClient.get('auth.php?action=devices');
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

    static async listRequests() {
        return APIClient.get('leave_requests.php?action=list');
    }

    static async getRequest(id) {
        return APIClient.get(`leave_requests.php?action=get&id=${id}`);
    }

    static async updateRequest(id, reason) {
        return APIClient.put(`leave_requests.php?action=update&id=${id}`, { reason });
    }

    static async approveRequest(id, comments = '', privateKey = '') {
        const fingerprint = await DeviceFingerprintManager.getFingerprint();
        return APIClient.post('leave_requests.php?action=approve', {
            id: id,
            comments: comments,
            private_key: privateKey,
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

// UI Utilities
class UIManager {
    static showAlert(message, type = 'info') {
        const container = document.getElementById('alert-container') || document.querySelector('.container') || document.body;

        // Replace any existing alert instead of stacking duplicates on top of each other
        container.querySelectorAll(':scope > .alert').forEach(el => el.remove());
        clearTimeout(UIManager._alertTimeout);

        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type}`;
        alertDiv.textContent = message;

        container.insertBefore(alertDiv, container.firstChild);

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
                    <span class="modal-close">&times;</span>
                </div>
                <div class="modal-body"></div>
            </div>
        `;
        
        modal.querySelector('.modal-close').addEventListener('click', () => {
            this.hideModal();
        });

        document.body.appendChild(modal);
        return modal;
    }

    static formatDate(dateString) {
        return new Date(dateString).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric'
        });
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
        return `Supervisor: ${this.getStatusBadge(req.supervisor_status)} &nbsp; HR: ${this.getStatusBadge(req.hr_status)}`;
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

// Wire up the top-right user menu (full name + Settings/Logout dropdown) shared by every authenticated page
function initUserMenu(user) {
    const nameEl = document.getElementById('user-fullname');
    if (nameEl) {
        nameEl.textContent = user.full_name || user.username;
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
