# LeaveSync - Leave Management System

## Project Overview
A secure, enterprise-grade leave management system built with PHP and MySQL, featuring device fingerprinting, digital signatures, multi-factor authentication, and comprehensive audit logging.

## Technology Stack
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Backend**: PHP 7.4+
- **Database**: MySQL 5.7+ / PostgreSQL
- **Security**: OpenSSL, RSA-4096, SHA-256, TOTP

## Key Features Implemented
1. **User Authentication** - Secure login with password hashing
2. **Multi-Factor Authentication** - TOTP-based 2FA with backup codes
3. **Device Fingerprinting** - Browser and device identification for security
4. **Digital Signatures** - RSA-based cryptographic signing for approvals
5. **Leave Management** - Request, approve, and track leave
6. **Role-Based Access** - Employee, Manager, Admin roles
7. **Audit Logging** - Complete activity tracking
8. **Secure Communication** - HTTPS, secure cookies, CORS protection

## Project Structure
```
leavesync/
├── config/              # Configuration files
├── src/                # Source code
│   ├── auth/          # Authentication modules
│   ├── database/      # Database classes
│   └── security/      # Security modules
├── api/               # API endpoints
├── public/            # Frontend assets
│   ├── css/
│   └── js/
├── views/             # HTML pages
└── README.md          # Documentation
```

## Setup Instructions
1. Copy `.env.example` to `.env` and configure
2. Import database schema: `mysql < src/database/schema.sql`
3. Start PHP server: `php -S localhost:8000 -t public/`
4. Access: `https://localhost:8443/login`

## Security Considerations
- All passwords are hashed with bcrypt
- Device fingerprints prevent unauthorized access
- Digital signatures ensure approval authenticity
- MFA adds additional security layer
- Audit logs track all modifications
- HTTPS/TLS enforced for all communications

## Development Guidelines
- Always use prepared statements for database queries
- Sanitize and validate all user inputs
- Log security-related events
- Use secure headers
- Keep dependencies updated

## Testing
- Test authentication flows (login, MFA, device trust)
- Verify leave request workflows
- Validate digital signatures
- Test audit logging
- Check security headers
