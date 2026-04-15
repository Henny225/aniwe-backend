# aniwe - Backend API and Admin Dashboard

AI-powered fashion stylist platform. This is the Flask backend that connects to the AniweDB MySQL database hosted on Google Cloud Platform.

## Team
- Henny Guiesso
- Togzhan Usseiin
- Sakshi Ranade
- Caroline Zhang

## Tech Stack
- Backend: Flask 3.1.3 (Python)
- Database: MySQL 8.0 on GCP Compute Engine
- OS: Ubuntu 22.04 LTS
- Region: us-west1-a (Oregon)

## Prerequisites
- Python 3.10+
- MySQL Workbench (optional, for direct DB access)

## Setup Instructions

### 1. Create Virtual Environment

A virtual environment keeps your project dependencies isolated.

**On macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

**On Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

After activation, your terminal prompt should show `(venv)` at the beginning.

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Database

Edit `.env` file with your MySQL credentials:

```
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_DB=AniweDB
MYSQL_PORT=3306
```

### 4. Create Database and Tables

Run the SQL script in your MySQL to create the database and tables.

### 5. Run the Application

**Default port (5000):**
```bash
python app.py
```

**Using a different port:**
```bash
PORT=8000 python app.py
```

On Windows:
```bash
set PORT=8000 && python app.py
```

The API will run at `http://localhost:5000` (or your custom port)

## API Endpoints

### Health Check
```
GET /api/health
```
Verify that the server and database connection are operational.

**Response (200 OK):**
```json
{
  "message": "Server and database are running",
  "status": "OK"
}
```

### API Information
```
GET /api
```
Get list of available API endpoints.

**Response (200 OK):**
```json
{
  "message": "Inventory Management API",
  "endpoints": {
    "health": "GET /api/health",
    "signup": "POST /api/auth/signup",
    "login": "POST /api/auth/login",
    "profile": "GET /api/auth/profile/<user_id>"
  }
}
```

### User Signup (Create new user)
```
POST /api/auth/signup
```
Register a new user with email, password, and profile information.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "first_name": "John",
  "last_name": "Doe",
  "account_type": "CONSUMER"
}
```

**Success Response (201 Created):**
```json
{
  "message": "User registered successfully",
  "user": {
    "user_id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "account_type": "CONSUMER"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Missing required fields or no data provided
- `409 Conflict` - Email already registered
- `500 Internal Server Error` - Database error

### User Login
```
POST /api/auth/login
```
Authenticate user and retrieve user information.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Success Response (200 OK):**
```json
{
  "message": "Login successful",
  "user": {
    "user_id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "account_type": "CONSUMER"
  }
}
```

**Error Responses:**
- `400 Bad Request` - Missing email or password
- `401 Unauthorized` - Invalid email or password
- `403 Forbidden` - Account is not Active

### Get User Profile
```
GET /api/auth/profile/<user_id>
```
Retrieve complete user profile information by user ID.

**Path Parameter:**
- `user_id` (integer) - The ID of the user

**Success Response (200 OK):**
```json
{
  "message": "Profile retrieved successfully",
  "user": {
    "user_id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone_number": null,
    "account_status": "Active",
    "account_type": "CONSUMER",
    "created_at": "2026-04-08 10:30:00",
    "last_login": "2026-04-08 11:00:00"
  }
}
```

**Error Response:**
- `404 Not Found` - User not found

## Database Connection
- Host: 34.11.203.137
- Port: 3306
- Database: AniweDB
- User: aniwe_admin

## SQL Scripts
- dbDDL.sql: Creates AniweDB with 20 tables, 2 triggers, 2 views, 1 function
- dbDML.sql: Sample data (10 users, 6 products, 4 outfits)
- dbDROP.sql: Cleanup script

## GCP Infrastructure
- Project: DB-GROUP2
- VM: aniwe-db-server (e2-micro, Ubuntu 22.04 LTS)
- Firewall: allow-mysql (TCP 3306)
- Billing: Education account
