from flask import Flask, jsonify, render_template, redirect, url_for, session
from functools import wraps
import sys
from config import Config
from database import get_connection
from auth_routes import auth_bp, register_web_auth_routes
from utils import normalize_account_type
from wardrobe.routes import wardrobe

def create_app():
    """Create Flask application"""
    app = Flask(__name__, template_folder='template')
    app.config.from_object(Config)
    app.secret_key = Config.SECRET_KEY

    # Register auth routes from module
    app.register_blueprint(auth_bp)
    register_web_auth_routes(app)
    app.register_blueprint(wardrobe)
    
    # Decorator to check if user is logged in
    def login_required(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if 'user_id' not in session:
                return redirect(url_for('login'))
            return f(*args, **kwargs)
        return decorated_function
    
    # Health check endpoint
    @app.route('/api/health', methods=['GET'])
    def health_check():
        """Check if server and database are working"""
        connection = get_connection()
        if connection:
            connection.close()
            return jsonify({'message': 'Server and database are running', 'status': 'OK'}), 200
        else:
            return jsonify({'message': 'Database connection failed', 'status': 'ERROR'}), 500
    
    # API information endpoint
    @app.route('/api', methods=['GET'])
    def api_info():
        """API information"""
        return jsonify({
            'message': 'Inventory Management API',
            'endpoints': {
                'health': 'GET /api/health',
                'signup': 'POST /api/auth/signup',
                'login': 'POST /api/auth/login',
                'profile': 'GET /api/auth/profile/<user_id>'
            }
        }), 200
    
    # Home route (role-based)
    @app.route('/')
    @login_required
    def home():
        """Role-based homepage"""
        user_role = normalize_account_type(session.get('role', 'CONSUMER'))
        first_name = session.get('first_name', 'User')
        
        menu_links = []
        if user_role == 'CONSUMER':
            menu_links = [
                {'name': 'Products', 'url': '#'},
                {'name': 'My Wardrobe', 'url': '/wardrobe'},
                {'name': 'My Orders', 'url': '#'},
                {'name': 'My Outfits', 'url': '/outfits'}
            ]
        elif user_role == 'RETAIL_PARTNER':
            menu_links = [
                {'name': 'My Products', 'url': '#'},
                {'name': 'My Orders', 'url': '#'}
            ]
        elif user_role == 'ADMINISTRATOR':
            menu_links = [
                {'name': 'All Products', 'url': '#'},
                {'name': 'All Orders', 'url': '#'},
                {'name': 'All Users', 'url': '#'}
            ]
        
        return render_template('index.html', first_name=first_name, role=user_role, menu_links=menu_links)
    
    return app


if __name__ == '__main__':
    # Usage: python app.py -dev OR python app.py -gcp
    profile = 'dev'
    if len(sys.argv) > 1:
        if sys.argv[1] == '-dev':
            profile = 'dev'
        elif sys.argv[1] == '-gcp':
            profile = 'gcp'
        else:
            raise ValueError("Invalid argument. Use -dev or -gcp")

    Config.load_profile(profile)
    app = create_app()
    app.run(debug=Config.DEBUG, host=Config.HOST, port=Config.PORT)
