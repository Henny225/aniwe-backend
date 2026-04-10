import mysql.connector
from mysql.connector import Error
from config import Config


def get_connection():
    """Connect to MySQL database"""
    try:
        connection = mysql.connector.connect(
            host=Config.MYSQL_HOST,
            user=Config.MYSQL_USER,
            password=Config.MYSQL_PASSWORD,
            database=Config.MYSQL_DB,
            port=Config.MYSQL_PORT
        )
        return connection
    except Error as e:
        print(f"Error connecting to database: {e}")
        return None


def execute_query(query, params=None):
    """Execute a query and return results"""
    connection = get_connection()
    if not connection:
        return None
    
    try:
        cursor = connection.cursor(dictionary=True)
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        result = cursor.fetchall()
        cursor.close()
        connection.close()
        return result
    except Error as e:
        print(f"Query error: {e}")
        return None


def execute_query_single(query, params=None):
    """Execute a query and return single row"""
    connection = get_connection()
    if not connection:
        return None
    
    try:
        cursor = connection.cursor(dictionary=True)
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        result = cursor.fetchone()
        cursor.close()
        connection.close()
        return result
    except Error as e:
        print(f"Query error: {e}")
        return None


def execute_insert_update(query, params=None):
    """Execute insert/update query"""
    connection = get_connection()
    if not connection:
        return False
    
    try:
        cursor = connection.cursor()
        if params:
            cursor.execute(query, params)
        else:
            cursor.execute(query)
        
        connection.commit()
        cursor.close()
        connection.close()
        return True
    except Error as e:
        print(f"Insert/Update error: {e}")
        return False
