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

## Setup
1. Clone the repo and cd into it
2. Create a virtual environment and install dependencies:
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
3. Run the app:
   python app.py
4. Open http://localhost:8080 in your browser

## API Endpoints
- GET /            Admin dashboard
- GET /api/products    All products
- GET /api/outfits     All outfits
- GET /api/users       All users
- GET /api/occasions   Outfit occasions
- GET /api/access-logs Access log entries

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
