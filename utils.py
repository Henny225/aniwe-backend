import hashlib
import logging

logger = logging.getLogger(__name__)


def hash_password(password):
    """Hash password using SHA-256"""
    return hashlib.sha256(password.encode()).hexdigest()


def verify_password(password, password_hash):
    """Verify password against hash"""
    return hash_password(password) == password_hash


def normalize_account_type(account_type):
    """Normalize account type values from DB/forms to canonical role names."""
    value = (account_type or '').strip().upper()
    if value in ('CONSUMER', 'CUSTOMER'):
        return 'CONSUMER'
    if value in ('RETAIL_PARTNER', 'RETAILER'):
        return 'RETAIL_PARTNER'
    if value in ('ADMINISTRATOR', 'ADMIN'):
        return 'ADMINISTRATOR'
    return value


def validate_email(email):
    """Basic email validation"""
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


def validate_password(password):
    """Validate password strength"""
    if len(password) < 8:
        return False, "Password must be at least 8 characters long"
    if not any(char.isupper() for char in password):
        return False, "Password must contain at least one uppercase letter"
    if not any(char.isdigit() for char in password):
        return False, "Password must contain at least one digit"
    return True, "Password is valid"
