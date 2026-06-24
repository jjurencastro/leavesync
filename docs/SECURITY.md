# Security Guidelines

## Encryption & Hashing

### Password Hashing
- Uses bcrypt with automatic salt generation
- Never store plain text passwords
- Passwords are hashed on registration and verified on login

### Session Tokens
- 256-bit random tokens generated with `random_bytes()`
- Tokens are hashed before storage in database
- Comparison uses `hash_equals()` to prevent timing attacks

### Encryption Keys
- Recommended key size: 32 bytes (256 bits) for AES-256
- Store in environment variables, not in code
- Rotate keys periodically

## Digital Signatures

### RSA Key Pair
- 4096-bit RSA key pair generated per user
- Public key stored in database
- Private key should be stored securely on user's device (not implemented in this version)

### Signing Process
1. Document content is normalized
2. SHA-256 hash of content is created
3. Hash is signed with user's private RSA key
4. Signature is stored with digital_signatures table

### Verification
1. Retrieve stored signature and public key
2. Verify signature against document content
3. Confirm signature is valid and recent

## Device Fingerprinting

### Data Collected
- User-Agent string
- Screen resolution
- Timezone
- Browser language
- IP address
- Operating system

### Hash Method
- SHA-256 hash of JSON-encoded device data
- Collision-resistant and deterministic
- Cannot be reversed to recover original data

### Trust Mechanism
- Users can mark devices as "trusted"
- Trusted devices bypass additional verification
- Devices can be untrustworthy at any time

## Multi-Factor Authentication (MFA)

### TOTP Implementation
- RFC 6238 compliant Time-based One-Time Password
- 30-second time window
- 6-digit codes generated using HMAC-SHA1

### Backup Codes
- 10 randomly generated 8-character codes
- Stored encrypted in database
- Each code can be used only once
- Used for account recovery if authenticator is lost

### Verification Window
- Current code accepted
- Previous and next code accepted (±1 window)
- Prevents timing issues with slow users

## Database Security

### SQL Injection Prevention
- All queries use prepared statements
- User input is bound as parameters
- Never concatenate user input into queries

Example:
```php
// ✓ Safe
$stmt = $db->prepare("SELECT * FROM users WHERE email = ?");
$stmt->bind_param("s", $email);

// ✗ Unsafe
$query = "SELECT * FROM users WHERE email = '$email'";
```

### Input Validation
- All user inputs are validated
- Type checking enforced
- Length limits applied
- Format validation (email, date, etc.)

### Data Protection
- Sensitive data encrypted before storage
- Database user has minimal required permissions
- Regular backups with encryption
- Audit logs track all modifications

## Session Security

### Cookie Settings
- `HttpOnly` flag: Prevents JavaScript access
- `Secure` flag: Sent only over HTTPS
- `SameSite=Strict`: Prevents CSRF attacks
- Domain and path restrictions applied

### Session Storage
- Sessions stored in database with hash
- Expires after SESSION_LIFETIME seconds
- Cleanup of expired sessions

### Session Validation
- Device fingerprint verified on each request
- IP address checked for changes
- User agent validated

## HTTP Security Headers

### HSTS (HTTP Strict Transport Security)
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
```
Enforces HTTPS for 1 year.

### X-Content-Type-Options
```
X-Content-Type-Options: nosniff
```
Prevents MIME type sniffing attacks.

### X-Frame-Options
```
X-Frame-Options: DENY
```
Prevents clickjacking attacks.

### Content Security Policy
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'
```
Prevents XSS and injection attacks.

### CORS
```
Access-Control-Allow-Origin: https://leavesync.local
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Credentials: true
```
Only allows requests from configured domain.

## API Security

### Authentication Required
- All API endpoints require valid session except login/register
- Session token checked on every request
- Unauthorized requests return 401 status

### Role-Based Access Control
- Employee: Can only view/modify own requests
- Manager: Can view/approve team requests
- Admin: Can view/modify all data

### Rate Limiting
- 100 requests per hour per IP address
- Prevents brute force attacks
- Prevents resource exhaustion

### Input Validation
- All POST/PUT parameters validated
- Type checking enforced
- Size limits applied

## Audit Logging

### Logged Events
- User registration and login
- Failed login attempts
- Data modifications
- Approval/rejection actions
- Digital signature operations
- MFA enable/disable
- Device trust changes

### Log Contents
- User ID (if applicable)
- Action performed
- Entity type and ID
- Old and new values
- IP address
- Device fingerprint
- Timestamp

### Log Protection
- Logs stored in database
- Cannot be modified without detection
- Retained for 90 days minimum
- Exported regularly for archival

## Development Best Practices

### Secure Coding
1. Never trust user input
2. Use parameterized queries
3. Escape output appropriately
4. Use HTTPS everywhere
5. Keep dependencies updated

### Key Management
- Never commit secrets to version control
- Use environment variables for secrets
- Rotate keys periodically
- Use separate keys for development/production

### Dependency Management
- Keep PHP updated
- Use stable library versions
- Monitor for security updates
- Regularly audit dependencies

### Testing
- Test authentication flows
- Test authorization boundaries
- Test input validation
- Test error handling
- Penetration testing recommended

## Deployment Checklist

- [ ] Enable HTTPS with valid certificate
- [ ] Set APP_ENV=production
- [ ] Set APP_DEBUG=false
- [ ] Generate strong encryption keys
- [ ] Secure .env file (restricted permissions)
- [ ] Enable database encryption
- [ ] Configure firewall rules
- [ ] Set up SSL/TLS for database connection
- [ ] Enable audit logging
- [ ] Regular backup automation
- [ ] Monitor error logs
- [ ] Implement WAF (Web Application Firewall)

## Incident Response

### If Password Compromised
1. Force password reset for user
2. Review audit log for suspicious activity
3. Check device fingerprints for unauthorized devices
4. Review leave request approvals

### If Private Key Compromised
1. Generate new key pair
2. Revoke old signatures
3. Re-approve important documents
4. Notify affected users

### If Database Breached
1. Immediately notify users
2. Force password reset for all users
3. Disable all active sessions
4. Review backups for recovery point
5. Monitor for unauthorized access

## References
- OWASP Top 10: https://owasp.org/www-project-top-ten/
- PHP Security: https://www.php.net/manual/en/security.php
- NIST Cybersecurity Framework: https://www.nist.gov/cyberframework/
- RFC 6238 (TOTP): https://tools.ietf.org/html/rfc6238

---

**Last Updated**: June 25, 2026
