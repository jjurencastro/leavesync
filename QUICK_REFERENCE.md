# LeaveSync Project - Quick Reference Guide

## 📁 File Inventory

### Core Configuration
- `.env` - Environment variables (DATABASE, APP_SECRET, ENCRYPTION_KEY)
- `.env.example` - Environment template
- `config/config.php` - Application configuration & security headers
- `autoload.php` - Autoloader for PHP classes

### Backend - Authentication & Security
- `src/auth/Auth.php` - User registration, login, logout, session management
- `src/auth/MFA.php` - TOTP generation, verification, backup codes
- `src/security/DeviceFingerprint.php` - Device identification & trust management
- `src/security/DigitalSignature.php` - RSA signing & verification

### Database
- `src/database/Database.php` - MySQL connection & query builder
- `src/database/schema.sql` - Complete database schema with 9 tables

### API Endpoints
- `api/auth.php` - 8 authentication endpoints
- `api/leave_requests.php` - 7 leave management endpoints
- `api/admin.php` - 11 admin/management endpoints

### Frontend - Views
- `views/login.html` - User login with MFA support
- `views/register.html` - New user registration
- `views/dashboard.html` - Employee dashboard with leave balance
- `views/new_request.html` - Submit new leave request
- `views/my_requests.html` - View & manage requests
- `views/admin.html` - Admin dashboard
- `views/settings.html` - User settings, MFA, device management

### Frontend - Assets
- `public/css/style.css` - Responsive CSS (1000+ lines, 40+ components)
- `public/js/app.js` - Main JavaScript (API client, auth, UI utilities)

### Documentation
- `README.md` - Project overview, setup, features
- `SETUP.md` - Detailed setup guide with examples
- `docs/API.md` - Complete API documentation
- `docs/SECURITY.md` - Security guidelines & best practices

### Other Files
- `index.php` - Main router
- `.gitignore` - Git ignore file
- `.github/copilot-instructions.md` - Project instructions

## 🚀 Quick Start

### 1. Setup (2 minutes)
```bash
cp .env.example .env
# Edit .env with your database credentials
mysql < src/database/schema.sql
```

### 2. Start (1 minute)
```bash
php -S localhost:8000 -t public/ index.php
```

### 3. Access
- Login: http://localhost:8000/views/login.html
- Register: http://localhost:8000/views/register.html

## 🔑 Key Functions

### Authentication
- `Auth::register()` - Create new user
- `Auth::login()` - User login with MFA
- `Auth::getCurrentUser()` - Get session user
- `Auth::auditLog()` - Log security events

### MFA
- `MFA::generateSecret()` - Generate TOTP secret
- `MFA::verifyTOTP()` - Verify 6-digit code
- `MFA::generateBackupCodes()` - Create recovery codes
- `MFA::enableMFA()` - Activate 2FA

### Device Fingerprinting
- `DeviceFingerprint::generate()` - Create device hash
- `DeviceFingerprint::store()` - Save device
- `DeviceFingerprint::getTrustedDevices()` - List trusted devices

### Digital Signatures
- `DigitalSignature::generateKeyPair()` - Create RSA keys
- `DigitalSignature::sign()` - Sign document
- `DigitalSignature::verify()` - Verify signature
- `DigitalSignature::signLeaveRequest()` - Approve with signature

## 📊 Database Schema

### Key Tables
1. **users** - Stores user info with RSA public key
2. **mfa_secrets** - TOTP secrets & backup codes
3. **device_fingerprints** - Trusted devices with fingerprint hash
4. **sessions** - Active user sessions
5. **leave_requests** - Leave requests with signature
6. **digital_signatures** - Cryptographic signatures
7. **leave_types** - Available leave types
8. **leave_balances** - Leave balance per user/type
9. **audit_log** - Complete activity log

## 🔐 Security Features

| Feature | Implementation |
|---------|-----------------|
| Password Hashing | Bcrypt with auto salt |
| 2FA | TOTP (RFC 6238) with backup codes |
| Device Fingerprinting | SHA-256 hash of device data |
| Digital Signatures | RSA-4096 with SHA-256 |
| Session Security | Secure cookies, hashed tokens |
| SQL Injection Prevention | Prepared statements |
| XSS Protection | Content-Security-Policy header |
| CSRF Protection | SameSite=Strict cookies |
| Audit Logging | Complete activity trail |

## 🔗 API Examples

### Register User
```bash
curl -X POST http://localhost:8000/api/auth.php?action=register \
  -d "username=john&email=john@example.com&password=SecurePass123&full_name=John Doe"
```

### Login
```bash
curl -X POST http://localhost:8000/api/auth.php?action=login \
  -d "email=john@example.com&password=SecurePass123"
```

### Create Leave Request
```bash
curl -X POST http://localhost:8000/api/leave_requests.php?action=create \
  -d "leave_type_id=1&start_date=2026-07-01&end_date=2026-07-05&reason=Vacation"
```

## 👥 User Roles

### Employee
- Submit leave requests
- View own requests
- Enable 2FA
- Manage trusted devices

### Manager
- View team requests
- Approve/reject requests
- Digitally sign approvals
- View department leave balance

### Admin
- View all users & requests
- Create/manage users
- Create/manage leave types
- View audit logs
- System statistics

## ✅ Testing Checklist

- [ ] User registration with validation
- [ ] Login with password verification
- [ ] MFA setup and verification
- [ ] Create leave request
- [ ] Manager approval with digital signature
- [ ] Device fingerprinting on login
- [ ] Trusted device management
- [ ] Audit log entries
- [ ] Leave balance calculation
- [ ] HTTPS security headers

## 🔄 File Dependencies

```
index.php
├── config/config.php
├── src/database/Database.php
├── src/auth/Auth.php
├── src/auth/MFA.php
├── src/security/DeviceFingerprint.php
└── src/security/DigitalSignature.php

views/*.html
├── public/css/style.css
└── public/js/app.js
    ├── api/auth.php
    ├── api/leave_requests.php
    └── api/admin.php
```

## 📈 Performance Tips

1. **Database Indexes** - All important columns indexed
2. **Prepared Statements** - Pre-compiled queries
3. **Caching** - Implement Redis for sessions
4. **Compression** - gzip enabled in config.php
5. **Lazy Loading** - AJAX for data fetching

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Database connection failed | Check DB credentials in .env |
| MFA code invalid | Sync server time with NTP |
| CORS error | Update APP_URL in .env |
| Permission denied | Set proper file permissions |
| Session expired | Check SESSION_LIFETIME setting |

## 📚 Documentation Files

- **README.md** - Main documentation
- **SETUP.md** - Installation guide
- **docs/API.md** - API endpoints reference
- **docs/SECURITY.md** - Security best practices
- **This file** - Quick reference guide

## 🌐 Deployment

### Production Requirements
- PHP 8.2+ with OpenSSL
- Railway MySQL 9+
- HTTPS certificate
- Strong encryption keys
- Firewall configuration
- Regular backups
- Monitoring & logging

### Environment Setting
```env
APP_ENV=production
APP_DEBUG=false
SESSION_SECURE=true
```

---

**Version**: 1.0.0
**Last Updated**: June 25, 2026
**Total Files**: 30+
**Lines of Code**: 5000+

For more information, see README.md or SETUP.md
