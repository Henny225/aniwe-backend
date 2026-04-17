from flask import Blueprint, render_template, session, redirect, request, jsonify
import mysql.connector
from utils import normalize_account_type
from database import get_connection

orders_bp = Blueprint('orders', __name__)

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "admin123",
    "database": "AniweDB"
}

def get_db():
    config = DB_CONFIG.copy()
    config["connection_timeout"] = 10
    return mysql.connector.connect(**config)

# ── helper: check login ────────────────────────────────────────
def login_required():
    if 'user_id' not in session:
        return redirect('/login')
    return None

# ── Orders page ───────────────────────────────────────────────
@orders_bp.route('/orders')
def orders():
    check = login_required()
    if check: return check

    db = get_connection()
    if not db:
        return render_template('orders/orders.html', orders=[], role=normalize_account_type(session.get('role')), error="Database connection failed")
    
    cursor = db.cursor(dictionary=True)

    try:
        role = normalize_account_type(session.get('role'))

        if role == 'CONSUMER':
            cursor.execute("""
                SELECT o.order_id, o.order_date, o.status, o.total_amount,
                       oi.quantity, oi.unit_price, p.name AS product_name
                FROM `ORDER` o
                JOIN ORDER_ITEM oi ON oi.order_id = o.order_id
                JOIN PRODUCT p ON p.product_ID = oi.product_id
                WHERE o.consumer_id = %s
                ORDER BY o.order_date DESC
            """, (session['user_id'],))

        elif role == 'RETAIL_PARTNER':
            cursor.execute("""
                SELECT o.order_id, o.order_date, o.status,
                       oi.quantity, oi.unit_price, p.name AS product_name
                FROM `ORDER` o
                JOIN ORDER_ITEM oi ON oi.order_id = o.order_id
                JOIN PRODUCT p ON p.product_ID = oi.product_id
                WHERE p.retailer_ID = %s
                ORDER BY o.order_date DESC
            """, (session['user_id'],))

        elif role == 'ADMINISTRATOR':
            cursor.execute("""
                SELECT o.order_id, o.order_date, o.status, o.total_amount,
                       oi.quantity, oi.unit_price, p.name AS product_name
                FROM `ORDER` o
                JOIN ORDER_ITEM oi ON oi.order_id = o.order_id
                JOIN PRODUCT p ON p.product_ID = oi.product_id
                ORDER BY o.order_date DESC
            """)

        rows = cursor.fetchall()

    except Exception as e:
        rows = []
        print("Orders error:", e)
    finally:
        cursor.close()
        db.close()

    return render_template('orders/orders.html', orders=rows, role=role)


# ── Place new order ───────────────────────────────────────────
@orders_bp.route('/orders/new', methods=['GET', 'POST'])
def new_order():
    check = login_required()
    if check: return check

    if normalize_account_type(session.get('role')) != 'CONSUMER':
        return redirect('/orders')

    error = None
    products = []

    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        cursor.execute("SELECT product_ID, name, price FROM PRODUCT")
        products = cursor.fetchall()
    except Exception as e:
        print("Products fetch error:", e)
    finally:
        cursor.close()
        db.close()

    if request.method == 'POST':
        # Получаем списки — product_id[] и quantity[] из формы
        product_ids = request.form.getlist('product_id[]')
        quantities  = request.form.getlist('quantity[]')

        # Error handling: нет ни одного товара
        if not product_ids or all(p == '' for p in product_ids):
            error = "Please select at least one product."
            return render_template('orders/new_order.html', products=products, error=error)

        # Убираем пустые строки
        items = [(pid, qty) for pid, qty in zip(product_ids, quantities) if pid]

        if not items:
            error = "Please select at least one product."
            return render_template('orders/new_order.html', products=products, error=error)

        db = get_db()
        cursor = db.cursor(dictionary=True)
        try:
            # Создаём один ORDER для всех товаров
            cursor.execute("""
                INSERT INTO `ORDER` (consumer_id, status, total_amount)
                VALUES (%s, 'pending', 0)
            """, (session['user_id'],))
            order_id = cursor.lastrowid

            # Добавляем каждый товар как отдельную строку в ORDER_ITEM
            for line_num, (product_id, quantity) in enumerate(items, start=1):

                if int(quantity) < 1:
                    error = "Quantity must be at least 1."
                    db.rollback()
                    return render_template('orders/new_order.html', products=products, error=error)

                # Проверяем stock и берём цену
                cursor.execute("""
                    SELECT s.stock_quantity, p.price AS unit_price
                    FROM STOCKS s
                    JOIN PRODUCT p ON p.product_ID = s.product_id
                    WHERE s.product_id = %s
                    LIMIT 1
                """, (product_id,))
                stock = cursor.fetchone()

                if not stock or stock['stock_quantity'] < int(quantity):
                    error = f"Product #{product_id} is out of stock or insufficient quantity."
                    db.rollback()
                    return render_template('orders/new_order.html', products=products, error=error)

                unit_price = stock['unit_price']

                # INSERT в ORDER_ITEM → триггеры срабатывают автоматически:
                # trg_order_total_insert → пересчитывает total_amount в ORDER
                # trg_stocks_decrement  → уменьшает stock_quantity в STOCKS
                cursor.execute("""
                    INSERT INTO ORDER_ITEM (order_id, line_num, product_id, quantity, unit_price)
                    VALUES (%s, %s, %s, %s, %s)
                """, (order_id, line_num, product_id, quantity, unit_price))

            db.commit()
            return redirect('/orders')

        except Exception as e:
            db.rollback()
            error = "Something went wrong. Please try again."
            print("Order insert error:", e)
        finally:
            cursor.close()
            db.close()

    return render_template('orders/new_order.html', products=products, error=error)


# ── Cancel order ──────────────────────────────────────────────
@orders_bp.route('/orders/cancel/<int:order_id>', methods=['POST'])
def cancel_order(order_id):
    check = login_required()
    if check: return check

    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        # Проверяем что этот заказ принадлежит залогиненному пользователю
        cursor.execute("""
            SELECT order_id, status, consumer_id
            FROM `ORDER`
            WHERE order_id = %s
        """, (order_id,))
        order = cursor.fetchone()

        # Error handling: заказ не найден
        if not order:
            return redirect('/orders')

        # Error handling: чужой заказ
        if order['consumer_id'] != session['user_id']:
            return redirect('/orders')

        # Error handling: нельзя отменить не-pending заказ
        if order['status'] != 'pending':
            return redirect('/orders')

        # Возвращаем stock обратно
        cursor.execute("""
            SELECT oi.product_id, oi.quantity, p.retailer_ID
            FROM ORDER_ITEM oi
            JOIN PRODUCT p ON p.product_ID = oi.product_id
            WHERE oi.order_id = %s
        """, (order_id,))
        items = cursor.fetchall()

        for item in items:
            cursor.execute("""
                UPDATE STOCKS
                SET stock_quantity = stock_quantity + %s,
                    last_updated = CURRENT_TIMESTAMP
                WHERE product_id = %s AND retailer_id = %s
            """, (item['quantity'], item['product_id'], item['retailer_ID']))


        # Меняем статус на cancelled (DELETE операция через UPDATE)
        cursor.execute("""
            UPDATE `ORDER`
            SET status = 'cancelled'
            WHERE order_id = %s
        """, (order_id,))
        db.commit()

    except Exception as e:
        db.rollback()
        print("Cancel order error:", e)
    finally:
        cursor.close()
        db.close()

    return redirect('/orders')

# ── Profile page ──────────────────────────────────────────────
@orders_bp.route('/profile', methods=['GET', 'POST'])
def profile():
    check = login_required()
    if check: return check

    error = None
    success = None
    user = None

    db = get_db()
    cursor = db.cursor(dictionary=True)

    try:
        role = normalize_account_type(session.get('role'))

        if role == 'CONSUMER':
            cursor.execute("""
                SELECT u.first_name, u.last_name, u.email, u.phone_number,
                       c.street_address, c.city, c.postal_code, c.country
                FROM USER u
                JOIN CONSUMER c ON c.consumer_ID = u.user_id
                WHERE u.user_id = %s
            """, (session['user_id'],))

        elif role == 'RETAIL_PARTNER':
            cursor.execute("""
                SELECT u.first_name, u.last_name, u.email, u.phone_number,
                       r.brand_name, r.website_url, r.store_description
                FROM USER u
                JOIN RETAIL_PARTNER r ON r.retailer_ID = u.user_id
                WHERE u.user_id = %s
            """, (session['user_id'],))

        elif role == 'ADMINISTRATOR':
            cursor.execute("""
                SELECT user_id, first_name, last_name, email,
                       account_type, account_status
                FROM USER
            """)

        user = cursor.fetchall() if role == 'ADMINISTRATOR' else cursor.fetchone()

    except Exception as e:
        print("Profile fetch error:", e)
    finally:
        cursor.close()
        db.close()

    if request.method == 'POST':
        role = normalize_account_type(session.get('role'))

        if role == 'CONSUMER':
            first_name = request.form.get('first_name')
            last_name = request.form.get('last_name')
            phone = request.form.get('phone_number')
            address = request.form.get('street_address')
            city = request.form.get('city')
            postal = request.form.get('postal_code')
            country = request.form.get('country')

            if not first_name or not last_name:
                error = "Please fill in all fields."
            else:
                db = get_db()
                cursor = db.cursor()
                try:
                    cursor.execute("""
                        UPDATE USER SET first_name=%s, last_name=%s, phone_number=%s
                        WHERE user_id=%s
                    """, (first_name, last_name, phone, session['user_id']))
                    cursor.execute("""
                        UPDATE CONSUMER SET street_address=%s, city=%s,
                        postal_code=%s, country=%s
                        WHERE consumer_ID=%s
                    """, (address, city, postal, country, session['user_id']))
                    db.commit()
                    success = "Profile updated successfully."
                except Exception as e:
                    db.rollback()
                    error = "Something went wrong. Please try again."
                    print("Profile update error:", e)
                finally:
                    cursor.close()
                    db.close()

        elif role == 'RETAIL_PARTNER':
            brand = request.form.get('brand_name')
            website = request.form.get('website_url')
            description = request.form.get('store_description')

            if not brand:
                error = "Please fill in all fields."
            else:
                db = get_db()
                cursor = db.cursor()
                try:
                    cursor.execute("""
                        UPDATE RETAIL_PARTNER SET brand_name=%s, website_url=%s,
                        store_description=%s WHERE retailer_ID=%s
                    """, (brand, website, description, session['user_id']))
                    db.commit()
                    success = "Profile updated successfully."
                except Exception as e:
                    db.rollback()
                    error = "Something went wrong. Please try again."
                    print("Retailer profile error:", e)
                finally:
                    cursor.close()
                    db.close()

    return render_template('orders/profile.html',
                           user=user, role=normalize_account_type(session.get('role')),
                           error=error, success=success)


# ── Low Stock for Retailers ───────────────────────────────────
@orders_bp.route('/low-stock')
def low_stock():
    check = login_required()
    if check: return check

    role = normalize_account_type(session.get('role'))
    if role not in ('RETAIL_PARTNER', 'ADMINISTRATOR'):
        return redirect('/')

    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        if role == 'RETAIL_PARTNER':
            cursor.execute("""
                SELECT * FROM vw_low_stock_alerts
                WHERE retailer_id = %s
            """, (session['user_id'],))
        else:
            cursor.execute("SELECT * FROM vw_low_stock_alerts")
        rows = cursor.fetchall()
    except Exception as e:
        rows = []
        print("Low stock error:", e)
    finally:
        cursor.close()
        db.close()

    return render_template('orders/low_stock.html', items=rows, role=role)


# ── Update Order Status (Retailer) ────────────────────────────
@orders_bp.route('/orders/update-status/<int:order_id>', methods=['POST'])
def update_order_status(order_id):
    check = login_required()
    if check: return check

    role = normalize_account_type(session.get('role'))
    if role != 'RETAIL_PARTNER':
        return redirect('/orders')

    new_status = request.form.get('status')
    allowed = ['pending', 'processing', 'shipped', 'delivered', 'cancelled']

    if new_status not in allowed:
        return redirect('/orders')

    db = get_db()
    cursor = db.cursor(dictionary=True)
    try:
        # Получаем текущий статус заказа
        cursor.execute("""
            SELECT o.status FROM `ORDER` o
            JOIN ORDER_ITEM oi ON oi.order_id = o.order_id
            JOIN PRODUCT p ON p.product_ID = oi.product_id
            WHERE o.order_id = %s AND p.retailer_ID = %s
            LIMIT 1
        """, (order_id, session['user_id']))
        order = cursor.fetchone()

        # Error handling: заказ не найден или чужой
        if not order:
            return redirect('/orders')

        old_status = order['status']

        # Меняем статус
        cursor.execute("""
            UPDATE `ORDER` SET status = %s
            WHERE order_id = %s
        """, (new_status, order_id))

        # Если отменяется заказ который был pending или processing
        # возвращаем stock обратно
        if new_status == 'cancelled' and old_status in ('pending', 'processing'):
            cursor.execute("""
                SELECT oi.product_id, oi.quantity, p.retailer_ID
                FROM ORDER_ITEM oi
                JOIN PRODUCT p ON p.product_ID = oi.product_id
                WHERE oi.order_id = %s AND p.retailer_ID = %s
            """, (order_id, session['user_id']))
            items = cursor.fetchall()

            for item in items:
                cursor.execute("""
                    UPDATE STOCKS
                    SET stock_quantity = stock_quantity + %s,
                        last_updated = CURRENT_TIMESTAMP
                    WHERE product_id = %s AND retailer_id = %s
                """, (item['quantity'], item['product_id'], item['retailer_ID']))

        db.commit()

    except Exception as e:
        db.rollback()
        print("Update status error:", e)
    finally:
        cursor.close()
        db.close()

    return redirect('/orders')


# ── Update Profile (from settings dropdown) ────────────────────
@orders_bp.route('/update-profile', methods=['GET', 'POST'])
def update_profile():
    check = login_required()
    if check: return check

    error = None
    success = None
    user = None

    db = get_connection()
    if not db:
        error = "Database connection failed"
        return render_template('orders/update_profile.html', user=user, role=normalize_account_type(session.get('role')), error=error, success=success)
    
    cursor = db.cursor(dictionary=True)

    try:
        role = normalize_account_type(session.get('role'))
        user_id = session.get('user_id')

        if role == 'CONSUMER':
            cursor.execute("""
                SELECT u.first_name, u.last_name, u.email, u.phone_number,
                       c.street_address, c.city, c.postal_code, c.country
                FROM USER u
                JOIN CONSUMER c ON c.consumer_ID = u.user_id
                WHERE u.user_id = %s
            """, (user_id,))

        elif role == 'RETAIL_PARTNER':
            cursor.execute("""
                SELECT u.first_name, u.last_name, u.email, u.phone_number,
                       r.brand_name, r.website_url, r.store_description
                FROM USER u
                JOIN RETAIL_PARTNER r ON r.retailer_ID = u.user_id
                WHERE u.user_id = %s
            """, (user_id,))

        elif role == 'ADMINISTRATOR':
            cursor.execute("""
                SELECT user_id, first_name, last_name, email,
                       account_type, account_status
                FROM USER
                WHERE user_id = %s
            """, (user_id,))

        user = cursor.fetchone()

    except Exception as e:
        print("Update profile fetch error:", e)
        import traceback
        traceback.print_exc()
    finally:
        cursor.close()
        db.close()

    if request.method == 'POST':
        role = normalize_account_type(session.get('role'))

        if role == 'CONSUMER':
            first_name = request.form.get('first_name')
            last_name = request.form.get('last_name')
            phone = request.form.get('phone_number')
            address = request.form.get('street_address')
            city = request.form.get('city')
            postal = request.form.get('postal_code')
            country = request.form.get('country')

            if not first_name or not last_name:
                error = "Please fill in all fields."
            else:
                db = get_connection()
                cursor = db.cursor()
                try:
                    cursor.execute("""
                        UPDATE USER SET first_name=%s, last_name=%s, phone_number=%s
                        WHERE user_id=%s
                    """, (first_name, last_name, phone, session['user_id']))
                    cursor.execute("""
                        UPDATE CONSUMER SET street_address=%s, city=%s,
                        postal_code=%s, country=%s
                        WHERE consumer_ID=%s
                    """, (address, city, postal, country, session['user_id']))
                    db.commit()
                    success = "Profile updated successfully."
                    session['first_name'] = first_name
                except Exception as e:
                    db.rollback()
                    error = "Something went wrong. Please try again."
                    print("Profile update error:", e)
                finally:
                    cursor.close()
                    db.close()

        elif role == 'RETAIL_PARTNER':
            first_name = request.form.get('first_name')
            last_name = request.form.get('last_name')
            phone = request.form.get('phone_number')
            brand = request.form.get('brand_name')
            website = request.form.get('website_url')
            description = request.form.get('store_description')

            if not brand:
                error = "Please fill in all fields."
            else:
                db = get_connection()
                cursor = db.cursor()
                try:
                    cursor.execute("""
                        UPDATE USER SET first_name=%s, last_name=%s, phone_number=%s
                        WHERE user_id=%s
                    """, (first_name, last_name, phone, session['user_id']))
                    cursor.execute("""
                        UPDATE RETAIL_PARTNER SET brand_name=%s, website_url=%s,
                        store_description=%s WHERE retailer_ID=%s
                    """, (brand, website, description, session['user_id']))
                    db.commit()
                    success = "Profile updated successfully."
                    session['first_name'] = first_name
                except Exception as e:
                    db.rollback()
                    error = "Something went wrong. Please try again."
                    print("Retailer profile update error:", e)
                finally:
                    cursor.close()
                    db.close()

        elif role == 'ADMINISTRATOR':
            first_name = request.form.get('first_name')
            last_name = request.form.get('last_name')
            phone = request.form.get('phone_number')

            if not first_name or not last_name:
                error = "Please fill in all fields."
            else:
                db = get_connection()
                cursor = db.cursor()
                try:
                    cursor.execute("""
                        UPDATE USER SET first_name=%s, last_name=%s, phone_number=%s
                        WHERE user_id=%s
                    """, (first_name, last_name, phone, session['user_id']))
                    db.commit()
                    success = "Profile updated successfully."
                    session['first_name'] = first_name
                except Exception as e:
                    db.rollback()
                    error = "Something went wrong. Please try again."
                    print("Admin profile update error:", e)
                finally:
                    cursor.close()
                    db.close()

    return render_template('orders/update_profile.html',
                           user=user, role=normalize_account_type(session.get('role')),
                           error=error, success=success)


# ── Change Password ────────────────────────────────────────────
@orders_bp.route('/change-password', methods=['GET', 'POST'])
def change_password():
    check = login_required()
    if check: return check

    error = None
    success = None

    if request.method == 'POST':
        from utils import verify_password, hash_password
        
        old_password = request.form.get('old_password')
        new_password = request.form.get('new_password')
        confirm_password = request.form.get('confirm_password')

        if not old_password or not new_password or not confirm_password:
            error = "Please fill in all fields."
        elif new_password != confirm_password:
            error = "New passwords do not match."
        elif len(new_password) < 6:
            error = "Password must be at least 6 characters."
        else:
            db = get_db()
            cursor = db.cursor(dictionary=True)
            try:
                # Get current user password hash
                cursor.execute("SELECT password_hash FROM USER WHERE user_id = %s", (session['user_id'],))
                user = cursor.fetchone()

                if not user:
                    error = "User not found."
                elif not verify_password(old_password, user['password_hash']):
                    error = "Current password is incorrect."
                else:
                    # Update password
                    new_hash = hash_password(new_password)
                    cursor.execute("""
                        UPDATE USER SET password_hash=%s WHERE user_id=%s
                    """, (new_hash, session['user_id']))
                    db.commit()
                    success = "Password changed successfully."
            except Exception as e:
                db.rollback()
                error = "Something went wrong. Please try again."
                print("Password change error:", e)
            finally:
                cursor.close()
                db.close()

    return render_template('orders/change_password.html', error=error, success=success)


# ── Delete Account ────────────────────────────────────────────
@orders_bp.route('/delete-account', methods=['POST'])
def delete_account():
    check = login_required()
    if check: 
        return jsonify({'success': False, 'message': 'Not authenticated'}), 401

    user_id = session.get('user_id')

    db = get_db()
    cursor = db.cursor()

    try:
        # Get user role to delete from role-specific tables
        role = normalize_account_type(session.get('role'))

        # Delete from role-specific tables first (due to foreign keys)
        if role == 'CONSUMER':
            cursor.execute("DELETE FROM CONSUMER WHERE consumer_ID = %s", (user_id,))
        elif role == 'RETAIL_PARTNER':
            cursor.execute("DELETE FROM RETAIL_PARTNER WHERE retailer_ID = %s", (user_id,))
        elif role == 'ADMINISTRATOR':
            cursor.execute("DELETE FROM ADMINISTRATOR WHERE admin_ID = %s", (user_id,))

        # Delete from USER table
        cursor.execute("DELETE FROM USER WHERE user_id = %s", (user_id,))
        db.commit()

        # Clear session
        session.clear()

        return jsonify({'success': True, 'message': 'Account deleted successfully'}), 200
    except Exception as e:
        db.rollback()
        print("Account deletion error:", e)
        return jsonify({'success': False, 'message': 'Error deleting account'}), 500
    finally:
        cursor.close()
        db.close()
