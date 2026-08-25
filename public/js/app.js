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
                window.location.href = '/views/login.html';
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
    static async login(username, password, totpCode = null, deviceCode = null) {
        const fingerprint = await DeviceFingerprintManager.getFingerprint();
        return APIClient.post('auth.php?action=login', {
            username, password, totp_code: totpCode, device_code: deviceCode,
            ...fingerprint
        });
    }

    static async verifyDevice(code) {
        const fingerprint = await DeviceFingerprintManager.getFingerprint();
        return APIClient.post('auth.php?action=verify_device', { code, ...fingerprint });
    }

    static async setPassword(password) {
        return APIClient.post('auth.php?action=set_password', { password });
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
}

// UI Utilities
class UIManager {
    static showAlert(message, type = 'info') {
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type}`;
        alertDiv.textContent = message;
        
        const container = document.querySelector('.container') || document.body;
        container.insertBefore(alertDiv, container.firstChild);

        setTimeout(() => alertDiv.remove(), 5000);
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
            cancelled: '<span class="badge badge-cancelled">Cancelled</span>'
        };
        return badges[status] || `<span class="badge">${status}</span>`;
    }
}

// Check Authentication
async function checkAuth() {
    const result = await AuthManager.getProfile();
    if (!result.success) {
        window.location.href = '/views/login.html';
    }
    return result.data;
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
        window.location.href = '/views/login.html';
    }
}
