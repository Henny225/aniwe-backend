from mysql.connector import Error, pooling
from config import Config

_pool = None

def _get_pool():
    global _pool
    if _pool is None:
        _pool = pooling.MySQLConnectionPool(
            pool_name="aniwe_pool",
            pool_size=5,
            host=Config.MYSQL_HOST,
            user=Config.MYSQL_USER,
            password=Config.MYSQL_PASSWORD,
            database=Config.MYSQL_DB,
            port=Config.MYSQL_PORT,
        )
    return _pool

def get_connection():
    """Get a connection from the pool"""
    try:
        return _get_pool().get_connection()
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
        return result
    except Error as e:
        print(f"Query error: {e}")
        return None
    finally:
        connection.close()


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
        return result
    except Error as e:
        print(f"Query error: {e}")
        return None
    finally:
        connection.close()


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
        return True
    except Error as e:
        print(f"Insert/Update error: {e}")
        return False
    finally:
        connection.close()
