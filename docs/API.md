# API Documentation

## Base URL
All API endpoints are prefixed with `/api/`

## Authentication
All endpoints (except `/api/auth.php?action=register` and `?action=login`) require a valid session token in cookies.

## Response Format
All responses are in JSON format:
```json
{
    "success": true/false,
    "message": "Description of result",
    "data": {}
}
```

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
