from flask import Blueprint, request, jsonify, render_template, redirect, url_for, session
from database import execute_query, execute_query_single, execute_insert_update
from utils import hash_password, verify_password, normalize_account_type
from datetime import datetime

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')


def register_web_auth_routes(app):
    """Register web authentication routes on the Flask app."""

    @app.route('/register', methods=['GET', 'POST'])
    def register():
        """Register a new user"""
        error = None
        if request.method == 'POST':
            email = request.form.get('email', '').strip().lower()
            password = request.form.get('password', '').strip()
            first_name = request.form.get('first_name', '').strip()
            last_name = request.form.get('last_name', '').strip()
            role = normalize_account_type(request.form.get('role', 'CONSUMER'))

            if not email or not password or not first_name or not last_name:
                error = "Please fill in all fields"
            else:
                existing_user = execute_query_single('SELECT user_id FROM USER WHERE email = %s', (email,))
                if existing_user:
                    error = "Email already in use"
                else:
                    password_hash = hash_password(password)
                    insert_query = """
                    INSERT INTO USER (email, password_hash, first_name, last_name, account_status, account_type)
                    VALUES (%s, %s, %s, %s, 'Active', %s)
                    """

                    if execute_insert_update(insert_query, (email, password_hash, first_name, last_name, role)):
                        user = execute_query_single('SELECT user_id FROM USER WHERE email = %s', (email,))
                        user_id = user['user_id']

                        if role == 'CONSUMER':
                            role_insert = "INSERT INTO CONSUMER (consumer_ID) VALUES (%s)"
                            execute_insert_update(role_insert, (user_id,))
                        elif role == 'RETAIL_PARTNER':
                            role_insert = "INSERT INTO RETAIL_PARTNER (retailer_ID) VALUES (%s)"
                            execute_insert_update(role_insert, (user_id,))
                        elif role == 'ADMINISTRATOR':
                            role_insert = "INSERT INTO ADMINISTRATOR (admin_ID) VALUES (%s)"
                            execute_insert_update(role_insert, (user_id,))

                        session['success_message'] = 'Registration successful! Please sign in with your credentials.'
                        return redirect(url_for('login'))
                    else:
                        error = "Error creating account"

        return render_template('register.html', error=error)

    @app.route('/login', methods=['GET', 'POST'])
    def login():
        """Login user"""
        error = None
        if request.method == 'POST':
            email = request.form.get('email', '').strip().lower()
            password = request.form.get('password', '').strip()

            if not email or not password:
                error = "Please fill in all fields"
            else:
                user = execute_query_single(
                    'SELECT user_id, email, password_hash, first_name, last_name, account_status, account_type FROM USER WHERE email = %s',
                    (email,)
                )

                if not user:
                    error = "Invalid email or password"
                elif user['account_status'] != 'Active':
                    error = f"Account is {user['account_status']}"
                elif not verify_password(password, user['password_hash']):
                    error = "Invalid email or password"
                else:
                    execute_insert_update('UPDATE USER SET last_login = %s WHERE user_id = %s', (datetime.now(), user['user_id']))

                    session['user_id'] = user['user_id']
                    session['role'] = normalize_account_type(user['account_type'])
                    session['first_name'] = user['first_name']
                    session['last_name'] = user['last_name']
                    session['email'] = user['email']

                    return redirect(url_for('home'))

        return render_template('login.html', error=error)

    @app.route('/logout')
    def logout():
        """Logout user"""
        session.clear()
        return redirect(url_for('login'))


@auth_bp.route('/signup', methods=['POST'])
def signup():
    """Register a new user"""
    data = request.get_json()
    
    if not data:
        return jsonify({'message': 'No data provided'}), 400
    
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')
    first_name = data.get('first_name', '').strip()
    last_name = data.get('last_name', '').strip()
    account_type = normalize_account_type(data.get('account_type', 'CONSUMER'))
    
    # Check if required fields are present
    if not email or not password or not first_name or not last_name:
        return jsonify({'message': 'Email, password, first_name, and last_name are required'}), 400
    
    # Check if user already exists
    existing_user = execute_query_single('SELECT user_id FROM USER WHERE email = %s', (email,))
    if existing_user:
        return jsonify({'message': 'Email already registered'}), 409
    
    # Hash password
    password_hash = hash_password(password)
    
    # Insert user into database
    insert_query = """
    INSERT INTO USER (email, password_hash, first_name, last_name, account_status, account_type)
    VALUES (%s, %s, %s, %s, 'Active', %s)
    """
    
    if execute_insert_update(insert_query, (email, password_hash, first_name, last_name, account_type)):
        # Get the newly created user
        user = execute_query_single('SELECT user_id, email, first_name, last_name, account_type FROM USER WHERE email = %s', (email,))
        return jsonify({
            'message': 'User registered successfully',
            'user': {
                'user_id': user['user_id'],
                'email': user['email'],
                'first_name': user['first_name'],
                'last_name': user['last_name'],
                'account_type': user['account_type']
            }
        }), 201
    else:
        return jsonify({'message': 'Error creating user account'}), 500


@auth_bp.route('/login', methods=['POST'])
def login():
    """Login user with email and password"""
    data = request.get_json()
    
    if not data:
        return jsonify({'message': 'No data provided'}), 400
    
    email = data.get('email', '').strip().lower()
    password = data.get('password', '')
    
    if not email or not password:
        return jsonify({'message': 'Email and password are required'}), 400
    
    # Get user from database
    user = execute_query_single(
        'SELECT user_id, email, password_hash, first_name, last_name, account_status, account_type FROM USER WHERE email = %s',
        (email,)
    )
    
    if not user:
        return jsonify({'message': 'Invalid email or password'}), 401
    
    # Check account status
    if user['account_status'] != 'Active':
        return jsonify({'message': f"Account is {user['account_status']}"}), 403
    
    # Verify password
    if not verify_password(password, user['password_hash']):
        return jsonify({'message': 'Invalid email or password'}), 401
    
    # Update last login
    execute_insert_update('UPDATE USER SET last_login = %s WHERE user_id = %s', (datetime.now(), user['user_id']))
    
    return jsonify({
        'message': 'Login successful',
        'user': {
            'user_id': user['user_id'],
            'email': user['email'],
            'first_name': user['first_name'],
            'last_name': user['last_name'],
            'account_type': user['account_type']
        }
    }), 200


@auth_bp.route('/profile/<int:user_id>', methods=['GET'])
def get_profile(user_id):
    """Get user profile by user ID"""
    user = execute_query_single(
        """
        SELECT user_id, email, first_name, last_name, phone_number, 
               account_status, account_type, created_at, last_login 
        FROM USER WHERE user_id = %s
        """,
        (user_id,)
    )
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    return jsonify({
        'message': 'Profile retrieved successfully',
        'user': user
    }), 200
