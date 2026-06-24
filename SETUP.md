# SETUP GUIDE - Leave Management System

## Quick Start (5 minutes)

### 1. Database Setup

#### MySQL
```bash
# Connect to MySQL
mysql -u root -p

# Create database
CREATE DATABASE leavesync;
USE leavesync;
source /path/to/leavesync/src/database/schema.sql;

# Create user (optional)
CREATE USER 'leavesync'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON leavesync.* TO 'leavesync'@'localhost';
FLUSH PRIVILEGES;
```

#### PostgreSQL
```bash
# Create database
createdb leavesync

# Import schema
psql -U postgres -d leavesync -f /path/to/leavesync/src/database/schema.sql
```

### 2. Configuration

```bash
# Copy environment file
cp .env.example .env

# Edit .env with your credentials
nano .env
```

### 3. Generate Security Keys

```bash
# Generate 32-byte encryption key
php -r "echo 'ENCRYPTION_KEY=' . base64_encode(random_bytes(32)) . PHP_EOL;"

# Generate 64-byte JWT secret
php -r "echo 'JWT_SECRET=' . base64_encode(random_bytes(64)) . PHP_EOL;"

# Generate 32-byte app secret
php -r "echo 'APP_SECRET=' . bin2hex(random_bytes(32)) . PHP_EOL;"
```

### 4. Start the Application

#### Option A: PHP Built-in Server (Development)
```bash
cd /path/to/leavesync
php -S 0.0.0.0:8000 -t public/ index.php
```
Access: `http://localhost:8000/views/login.html`

#### Option B: Apache
Configure in Apache:
```apache
<VirtualHost *:80>
    ServerName leavesync.local
    DocumentRoot /path/to/leavesync
    
    <Directory /path/to/leavesync>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

#### Option C: Nginx
Configure in Nginx:
```nginx
server {
    listen 80;
    server_name leavesync.local;
    root /path/to/leavesync;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
```

### 5. Create First User

1. Navigate to `/views/register.html`
2. Fill in registration form
3. Test login with credentials

## Features Overview

### For Employees
- **Dashboard**: View leave balance and recent requests
- **New Request**: Submit leave requests with reason
- **My Requests**: Track all submitted requests
- **Settings**: Enable 2FA, manage trusted devices

### For Managers
- **Dashboard**: Same as employees
- **Review Requests**: Approve/reject team member requests
- **Digital Signatures**: Cryptographically sign approvals

### For Administrators
- **Admin Dashboard**: View all leave requests
- **User Management**: Create and manage users
- **Leave Type Management**: Configure available leave types
- **Reports**: Generate leave usage reports

## Security Features

### Device Fingerprinting
- Automatically detects new devices
- Warns on suspicious login attempts
- Allows users to trust specific devices

### Multi-Factor Authentication
1. Enable in settings
2. Scan QR code with authenticator app
3. Enter code on login
4. Save backup codes for recovery

### Digital Signatures
- Leave approvals are cryptographically signed
- Signatures are verified for authenticity
- Complete audit trail maintained

### Audit Logging
- All actions are logged
- Track who, what, when, and where
- Review security events

## Configuration Files

### .env
Main configuration file with database credentials and security keys.

### config/config.php
Application settings, security headers, and database setup.

### src/database/schema.sql
Database tables and relationships.

## Troubleshooting

### Database Connection Error
```
Error: Connection refused
Solution: Verify MySQL is running and credentials are correct
```

### Permission Denied
```
Error: Permission denied writing to config/
Solution: chmod 755 config/ && chmod 644 config/config.php
```

### CORS Issues
```
Error: CORS policy error
Solution: Update APP_URL in .env to match your domain
```

### MFA Not Working
```
Error: Invalid TOTP code
Solution: Ensure server time is synchronized (ntpdate -u pool.ntp.org)
```

## Performance Optimization

### Database Indexes
All important columns are indexed for fast queries.

### Caching
Consider implementing Redis for session caching:
```php
// Use Redis for sessions
session.save_handler=redis
session.save_path="tcp://localhost:6379"
```

### Compression
Enable gzip compression in PHP:
```php
ini_set('zlib.output_compression', 'On');
```

## Backup & Recovery

### Database Backup
```bash
# MySQL
mysqldump -u root -p leavesync > backup.sql

# PostgreSQL
pg_dump leavesync > backup.sql
```

### Restore
```bash
# MySQL
mysql -u root -p leavesync < backup.sql

# PostgreSQL
psql leavesync < backup.sql
```

## SSL/HTTPS Setup

### Generate Self-Signed Certificate
```bash
openssl req -x509 -newkey rsa:4096 \
  -keyout key.pem -out cert.pem \
  -days 365 -nodes
```

### Apache Configuration
```apache
<VirtualHost *:443>
    ServerName leavesync.local
    DocumentRoot /path/to/leavesync
    
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem
</VirtualHost>
```

## Development Tips

1. Enable debug mode in .env for detailed error messages
2. Use browser developer tools to inspect API calls
3. Check PHP logs for errors: `tail -f /var/log/php-errors.log`
4. Use `php -l` to check PHP syntax

## Production Deployment

1. Set `APP_ENV=production` in .env
2. Set `APP_DEBUG=false`
3. Use strong encryption keys
4. Enable HTTPS with valid certificate
5. Set appropriate file permissions
6. Configure firewall rules
7. Set up automated backups
8. Monitor system logs

## Support & Documentation

- README.md - Project overview and features
- API documentation in code comments
- Security guidelines in README.md

---

**Questions?** Check the README.md or create an issue in the repository.
