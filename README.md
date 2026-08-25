# LeaveSync - Leave Management System

A comprehensive, secure leave management system built with PHP and MySQL, featuring advanced security technologies including device fingerprinting, digital signatures, MFA, and encrypted communications.

## 🎯 Features

### Core Functionality
- **Leave Request Management** - Employees can request and track leave
- **Manager Dashboard** - Managers can review and approve/reject leave requests
- **Admin Panel** - Administrators manage leave types, balances, and user roles
- **Leave Balance Tracking** - Automatic calculation of leave balances

### Security Features
- **Device Fingerprinting** - Enhanced security with browser and device identification
- **Digital Signatures** - Cryptographic signing for leave approvals
- **Multi-Factor Authentication (MFA)** - TOTP-based two-factor authentication
- **Secure Authentication** - Password hashing with bcrypt
- **Session Management** - Secure session tokens and management
- **Audit Logging** - Complete audit trail of all actions
- **HTTPS/TLS** - Secure communication protocols
- **CORS Protection** - Cross-origin request validation
- **Security Headers** - HSTS, X-Frame-Options, CSP, and more

## 🛠️ Technology Stack

- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Backend**: PHP 8.2+
- **Database**: Railway MySQL 9+
- **Cryptography**: OpenSSL (RSA-4096, SHA-256)
- **Authentication**: TOTP (RFC 6238), JWT, Digital Signatures
- **Security**: Device Fingerprinting, Encrypted Sessions, Secure Cookies

## 📋 Prerequisites

- PHP 8.2 or higher
- MySQL 9+
- OpenSSL library (for digital signatures)
- Modern web browser with JavaScript enabled
- HTTPS certificate (self-signed for development)

## 🚀 Installation

### 1. Clone the Repository
```bash
cd /path/to/leavesync
```

### 2. Configure Environment
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=leavesync
APP_URL=https://localhost:8443
```

### 3. Create Database
```bash
mysql -u root -p leavesync < src/database/schema.sql
```

### 4. Set Permissions
```bash
chmod 755 config/
chmod 644 config/config.php
chmod 755 public/
chmod 755 src/
```

### 5. Generate Application Keys
```bash
# Generate encryption key (32 bytes)
php -r "echo base64_encode(random_bytes(32));"

# Generate JWT secret
php -r "echo base64_encode(random_bytes(64));"
```

Update these in your `.env` file.

### 6. Start Development Server

#### PHP Built-in Server (Development Only)
```bash
php -S localhost:8000 -t public/
```

#### Using Apache
Configure VirtualHost:
```apache
<VirtualHost *:443>
    ServerName leavesync.local
    DocumentRoot /path/to/leavesync/public
    
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem
    
    <Directory /path/to/leavesync/public>
        Allow from all
        Require all granted
        
        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteBase /
            RewriteRule ^index\.php$ - [L]
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule . /index.php [L]
        </IfModule>
    </Directory>
</VirtualHost>
```

#### Using Nginx
```nginx
server {
    listen 443 ssl;
    server_name leavesync.local;
    root /path/to/leavesync/public;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

### 7. Create Test User
Access the application and register a test account.

## 📊 Project Structure

```
leavesync/
├── config/
│   └── config.php           # Application configuration
├── src/
│   ├── auth/
│   │   ├── Auth.php         # Authentication handler
│   │   └── MFA.php          # Multi-factor authentication
│   ├── database/
│   │   ├── Database.php     # Database connection
│   │   └── schema.sql       # Database schema
│   └── security/
│       ├── DeviceFingerprint.php  # Device fingerprinting
│       └── DigitalSignature.php   # Digital signatures
├── api/
│   ├── auth.php             # Authentication API
│   └── leave_requests.php   # Leave requests API
├── public/
│   ├── css/
│   │   └── style.css        # Application styles
│   └── js/
│       └── app.js           # Main JavaScript
├── views/
│   ├── login.html           # Login page
│   ├── register.html        # Registration page
│   ├── dashboard.html       # Dashboard
│   ├── new_request.html     # New leave request
│   └── settings.html        # User settings
├── .env.example             # Environment configuration template
├── index.php                # Main router
└── README.md                # This file
```

## 🔐 Security Architecture

### Device Fingerprinting
- Collects browser characteristics (User-Agent, screen resolution, timezone, etc.)
- Generates SHA-256 hash of device data
- Identifies suspicious login attempts from new devices
- Allows users to trust/untrust devices

### Digital Signatures
- RSA-4096 key pairs for each user
- SHA-256 cryptographic signing of leave approvals
- Verification of approval authenticity
- Complete approval audit trail

### Multi-Factor Authentication (MFA)
- Time-based One-Time Password (TOTP) implementation
- 30-second time window
- Backup codes for account recovery
- Compatible with Google Authenticator, Microsoft Authenticator, etc.

### Secure Communication
- HTTPS/TLS enforcement
- Secure session cookies (HttpOnly, Secure, SameSite=Strict)
- CORS protection
- Security headers (HSTS, X-Frame-Options, CSP)

### Database Security
- Prepared statements to prevent SQL injection
- Password hashing with bcrypt
- Sensitive data encryption
- Audit logging of all modifications

## 📋 API Endpoints

### Authentication (`/api/auth.php`)
- `POST ?action=register` - Register new user
- `POST ?action=login` - User login
- `GET ?action=logout` - User logout
- `GET ?action=profile` - Get current user profile
- `GET ?action=mfa_setup` - Setup MFA
- `POST ?action=mfa_enable` - Enable MFA
- `POST ?action=mfa_disable` - Disable MFA
- `GET ?action=devices` - Get trusted devices
- `POST ?action=remove_device` - Remove trusted device

### Leave Requests (`/api/leave_requests.php`)
- `POST ?action=create` - Create new leave request
- `GET ?action=list` - List leave requests
- `GET ?action=get&id={id}` - Get leave request details
- `PUT ?action=update&id={id}` - Update leave request
- `POST ?action=approve` - Approve leave request
- `POST ?action=reject` - Reject leave request
- `GET ?action=balance` - Get leave balance

## 🧪 Testing

### Test Credentials
- Admin: admin@example.com / password
- Manager: manager@example.com / password
- Employee: employee@example.com / password

## 📝 Database Schema

### Key Tables
- **users** - User accounts with roles and cryptographic keys
- **mfa_secrets** - TOTP secrets and backup codes
- **device_fingerprints** - Trusted devices
- **sessions** - Active user sessions
- **leave_requests** - Leave requests with approval status
- **digital_signatures** - Cryptographic signatures
- **leave_balances** - Leave balance tracking
- **audit_log** - Complete audit trail

## 🔧 Configuration

### Environment Variables
```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=password
DB_NAME=leavesync

# Application
APP_ENV=production
APP_DEBUG=false
APP_URL=https://leavesync.local:8443
APP_SECRET=your-secret-key

# Security
ENCRYPTION_KEY=your-encryption-key
JWT_SECRET=your-jwt-secret
SESSION_LIFETIME=3600

# MFA
MFA_ENABLED=true
MFA_WINDOW=30

# Security Headers
SESSION_SECURE=true
SESSION_HTTPONLY=true
```

## 🚀 Deployment

### Production Checklist
- [ ] Set `APP_ENV=production`
- [ ] Set `APP_DEBUG=false`
- [ ] Configure SSL certificates
- [ ] Update database credentials
- [ ] Generate strong encryption keys
- [ ] Set up HTTPS on web server
- [ ] Configure firewall rules
- [ ] Enable CORS for specific domains
- [ ] Set up logging and monitoring
- [ ] Regular database backups
- [ ] Disable file uploads if not needed

### Docker Deployment (Optional)
```dockerfile
FROM php:7.4-fpm
RUN docker-php-ext-install mysqli pdo pdo_mysql
COPY . /var/www/html
WORKDIR /var/www/html
```

## 📚 Documentation

- [API Documentation](docs/API.md)
- [Security Guidelines](docs/SECURITY.md)

## 🐛 Troubleshooting

### Database Connection Issues
- Verify the Railway MySQL service is running
- Check database credentials in `.env`
- Ensure database user has proper permissions
- Check firewall rules

### SSL/HTTPS Issues
- Generate self-signed certificate for development:
  ```bash
  openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
  ```
- Ensure PHP has OpenSSL extension enabled
- Check certificate expiration date

### MFA Issues
- Ensure server time is synchronized (NTP)
- Check timezone configuration
- Verify authenticator app is on device
- Use backup codes if TOTP fails

## 📧 Support

For issues and questions, please create an issue in the repository.

## 📄 License

This project is open source and available under the MIT License.

## 👥 Contributors

- Development Team

## 🔄 Version History

### v1.0.0
- Initial release
- Core leave management functionality
- Device fingerprinting
- Digital signatures
- Multi-factor authentication
- Admin dashboard

---

**Last Updated**: June 25, 2026
