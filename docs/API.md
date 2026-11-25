# API Documentation

## Base URL
All API endpoints are prefixed with `/api/`

## Authentication
All endpoints (except `/api/auth.php?action=register` and `?action=login`) require a valid session token in cookies.
The read-only HRIS integration below uses a separate bearer token instead.

## Response Format
All responses are in JSON format:
```json
{
    "success": true/false,
    "message": "Description of result",
    "data": {}
}
```

## HRIS integration

The HRIS API is disabled until configured. It is a read-only server-to-server
integration; it does not use a LeaveSync user's login, session, or MFA.

### LeaveSync administrator setup

1. Apply `src/database/migration_hris_api.sql` to the LeaveSync MySQL database.
   The table is also included in the schema for new installations.
2. Generate a dedicated token on a trusted machine, for example:

   ```sh
   php -r '$token = bin2hex(random_bytes(32)); echo "Token: ", $token, PHP_EOL, "SHA-256: ", hash("sha256", $token), PHP_EOL;'
   ```

3. Set Railway's `HRIS_API_KEY_SHA256` variable to the **SHA-256 hash**, not
   the token. Deploy this version of LeaveSync and apply the variable change.
   Never commit either value or paste the token into chat, tickets, or logs.
4. Give the HRIS administrator the token through an approved secure channel.
   HRIS must store it in its server-side secret manager. Do not put it in
   browser code, URLs, source control, or logs.

To revoke access, remove the variable. To rotate the token, generate a new
token and hash, update the variable, and securely deliver the new token to
HRIS. Changing or removing the variable takes effect when the service
receives the new environment; the previous token then stops working. A
rotation requires coordination because only one token is accepted at a time.

### HRIS administrator: access

- Base URL: `https://<leavesync-host>/api/hris.php`
- Method: `GET`
- Header: `Authorization: Bearer <64-character-token>`
- Actions: `employees`, `leave_requests`, `leave_balances`, `leave_types`.
- Example URL: `/api/hris.php?action=employees&limit=100`
- Authentication is required even for an empty result. Never send the token
  as a query parameter.

Successful responses have this shape:

```json
{
  "success": true,
  "data": [{"id": 12, "email": "employee@example.org", "full_name": "Example Employee", "department": "CCS", "position": "Instructor", "role": "employee", "is_active": 1, "created_at": "2026-01-01 00:00:00", "updated_at": "2026-01-01 00:00:00"}],
  "next_cursor": "12"
}
```

Records are ordered by numeric LeaveSync `id`. Start with no `cursor`, then
send the returned `next_cursor` as `cursor` until it is `null`. `limit` is an
integer from 1 to 100 and defaults to 100. IDs and numeric database fields
may be represented as JSON strings; decimal quantities must be interpreted
as decimals, not binary floating point. Timestamps are in UTC.

Fields exposed:

| Action | Fields |
|---|---|
| `employees` | `id`, `email`, `full_name`, `department`, `position`, `role`, `is_active`, `created_at`, `updated_at` |
| `leave_requests` | `id`, `user_id`, `leave_type_id`, `start_date`, `end_date`, `number_of_days`, `status`, `supervisor_status`, `hr_status`, `created_at`, `updated_at` |
| `leave_balances` | `id`, `user_id`, `leave_type_id`, `total_days`, `used_days`, `pending_days`, `balance`, `fiscal_year`, `created_at`, `updated_at` |
| `leave_types` | `id`, `name`, `days_per_year`, `is_paid`, `requires_documentation`, `created_at`, `updated_at` |

Employees include all roles and active/inactive accounts. Match HRIS accounts
initially by email, then retain the LeaveSync `id` to handle email changes.
Use `user_id` and `leave_type_id` to associate records with employees and
leave types. No password hashes, MFA secrets, leave reasons, comments, or
attachments are exposed.

Poll all pages of each action periodically. Only use a **complete successful**
scan for reconciliation. Scans are not transactional snapshots: records can
change or disappear while pages are being read, and a changed record with an
already-read ID will not appear again until the next scan. There are no
deletion events or incremental `updated_since` feed. Before deleting or
deactivating HRIS data because it is absent, confirm absence across multiple
complete scans or use an administrator review. Never reconcile an incomplete
or failed scan. LeaveSync user deletion can cascade to associated leave data.

Errors use `{"success":false,"message":"..."}`. Status codes include 400
(invalid parameters), 401 (invalid token), 405 (not GET), 429 (rate limit),
500 (server/database failure), and 503 (integration not configured). The
limit is 120 authenticated requests per fixed minute across all HRIS actions
and service replicas; on 429 wait for `Retry-After` seconds. Failed
authentication is logged but not included in this application-level limit;
use an edge/WAF rate limit for unauthenticated traffic. Access is logged
without tokens or response data.

## Authentication API (`/api/auth.php`)

### Register User
- **URL**: `/api/auth.php?action=register`
- **Method**: POST
- **Parameters**:
  - `username` (string, required) - Unique username (min 3 chars)
  - `email` (string, required) - Valid email address
  - `password` (string, required) - Password (min 8 chars)
  - `full_name` (string, required) - Full name
  - `department` (string, optional) - Department
- **Response**: User ID and success message

### Login User
- **URL**: `/api/auth.php?action=login`
- **Method**: POST
- **Parameters**:
  - `email` (string, required)
  - `password` (string, required)
  - `totp_code` (string, optional) - 6-digit TOTP code if MFA enabled
  - `screen_resolution` (string) - Device fingerprint data
  - `timezone` (string) - Device fingerprint data
- **Response**: Authentication token and user info

### Forgot Password
- **URL**: `/api/auth.php?action=forgot_password`
- **Method**: POST
- **Parameters**:
  - `username` (string, required) - Username or email address
- **Response**: Always a generic success message (never reveals whether the account exists).
  If the account exists and is activated, a temporary password is emailed to its registered
  address, all existing sessions are invalidated, and the user is forced to set a new
  password via the activation page on next login. Repeat requests within 5 minutes are ignored.

### Logout
- **URL**: `/api/auth.php?action=logout`
- **Method**: GET
- **Response**: Success message

### Get Profile
- **URL**: `/api/auth.php?action=profile`
- **Method**: GET
- **Response**: Current user data

### Setup MFA
- **URL**: `/api/auth.php?action=mfa_setup`
- **Method**: GET
- **Response**: Secret and QR code URL

### Enable MFA
- **URL**: `/api/auth.php?action=mfa_enable`
- **Method**: POST
- **Parameters**:
  - `totp_code` (string, required) - 6-digit verification code
- **Response**: Success message

### Disable MFA
- **URL**: `/api/auth.php?action=mfa_disable`
- **Method**: GET
- **Response**: Success message

### Get Trusted Devices
- **URL**: `/api/auth.php?action=devices`
- **Method**: GET
- **Response**: List of trusted devices

### Remove Device
- **URL**: `/api/auth.php?action=remove_device`
- **Method**: POST
- **Parameters**:
  - `device_id` (int, required)
- **Response**: Success message

## Leave Requests API (`/api/leave_requests.php`)

### Create Leave Request
- **URL**: `/api/leave_requests.php?action=create`
- **Method**: POST
- **Parameters**:
  - `leave_type_id` (int, required)
  - `start_date` (date, required) - Format: YYYY-MM-DD
  - `end_date` (date, required) - Format: YYYY-MM-DD
  - `reason` (string, required)
- **Response**: Request ID and success message

### List Leave Requests
- **URL**: `/api/leave_requests.php?action=list`
- **Method**: GET
- **Response**: Array of leave requests (filtered by user role)

### Get Leave Request Details
- **URL**: `/api/leave_requests.php?action=get&id={id}`
- **Method**: GET
- **Parameters**:
  - `id` (int, required) - Request ID
- **Response**: Detailed request information

### Update Leave Request
- **URL**: `/api/leave_requests.php?action=update&id={id}`
- **Method**: PUT
- **Parameters**:
  - `reason` (string) - Updated reason
- **Response**: Success message

### Approve Leave Request
- **URL**: `/api/leave_requests.php?action=approve`
- **Method**: POST
- **Parameters**:
  - `id` (int, required) - Request ID
  - `comments` (string, optional)
- **Response**: Success message (includes digital signature)

### Reject Leave Request
- **URL**: `/api/leave_requests.php?action=reject`
- **Method**: POST
- **Parameters**:
  - `id` (int, required) - Request ID
  - `comments` (string, required) - Rejection reason
- **Response**: Success message

### Get Leave Balance
- **URL**: `/api/leave_requests.php?action=balance`
- **Method**: GET
- **Response**: Array of leave balances by type

## Admin API (`/api/admin.php`)

### Get All Users
- **URL**: `/api/admin.php?action=users`
- **Method**: GET
- **Response**: Array of all users

### Get User Details
- **URL**: `/api/admin.php?action=user_details&id={id}`
- **Method**: GET
- **Parameters**:
  - `id` (int, required)
- **Response**: Detailed user information

### Create User
- **URL**: `/api/admin.php?action=create_user`
- **Method**: POST
- **Parameters**:
  - `username` (string, required)
  - `email` (string, required)
  - `password` (string, required)
  - `full_name` (string, required)
  - `department` (string, optional)
  - `role` (string, optional) - 'employee', 'manager', or 'admin'
- **Response**: User ID and success message

### Update User
- **URL**: `/api/admin.php?action=update_user&id={id}`
- **Method**: PUT
- **Parameters**:
  - `full_name` (string, optional)
  - `department` (string, optional)
  - `role` (string, optional)
  - `is_active` (boolean, optional)
- **Response**: Success message

### Delete User
- **URL**: `/api/admin.php?action=delete_user&id={id}`
- **Method**: DELETE
- **Response**: Success message

### Get Leave Types
- **URL**: `/api/admin.php?action=leave_types`
- **Method**: GET
- **Response**: Array of all leave types

### Create Leave Type
- **URL**: `/api/admin.php?action=create_leave_type`
- **Method**: POST
- **Parameters**:
  - `name` (string, required)
  - `days_per_year` (int, required)
  - `description` (string, optional)
  - `is_paid` (boolean, optional)
  - `requires_documentation` (boolean, optional)
- **Response**: Success message

### Update Leave Type
- **URL**: `/api/admin.php?action=update_leave_type&id={id}`
- **Method**: PUT
- **Parameters**:
  - `name` (string, optional)
  - `days_per_year` (int, optional)
  - `is_paid` (boolean, optional)
- **Response**: Success message

### Get Audit Log
- **URL**: `/api/admin.php?action=audit_log`
- **Method**: GET
- **Response**: Array of audit log entries (last 1000)

### Get Statistics
- **URL**: `/api/admin.php?action=statistics`
- **Method**: GET
- **Response**: System statistics (user count, request counts, etc.)

## Error Responses

All error responses include:
```json
{
    "success": false,
    "message": "Error description"
}
```

## Status Codes
- 200 - OK
- 400 - Bad Request
- 401 - Unauthorized
- 404 - Not Found
- 500 - Internal Server Error

## Rate Limiting
API requests are rate limited to 100 requests per hour per IP address.

## CORS
CORS is enabled for the configured APP_URL. Cross-origin requests from other domains will be rejected.
