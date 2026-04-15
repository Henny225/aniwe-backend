from flask import Blueprint, render_template, session, redirect, request, jsonify
import mysql.connector

orders_bp = Blueprint('orders', __name__)

DB_CONFIG = {
    "host": "35.233.192.65",
    "user": "aniwe_admin",
    "password": "Aniwe2024!",
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

    db = get_db()
    cursor = db.cursor(dictionary=True)

    try:
        role = session.get('role')

        if role == 'Consumer':
            cursor.execute("""
                SELECT o.order_id, o.order_date, o.status, o.total_amount,
                       oi.quantity, oi.unit_price, p.name AS product_name
                FROM `ORDER` o
                JOIN ORDER_ITEM oi ON oi.order_id = o.order_id
                JOIN PRODUCT p ON p.product_ID = oi.product_id
                WHERE o.consumer_id = %s
                ORDER BY o.order_date DESC
            """, (session['user_id'],))

        elif role == 'Retailer':
            cursor.execute("""
                SELECT o.order_id, o.order_date, o.status,
                       oi.quantity, oi.unit_price, p.name AS product_name
                FROM `ORDER` o
                JOIN ORDER_ITEM oi ON oi.order_id = o.order_id
                JOIN PRODUCT p ON p.product_ID = oi.product_id
                WHERE p.retailer_ID = %s
                ORDER BY o.order_date DESC
            """, (session['user_id'],))

        elif role == 'Admin':
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

    return render_template('orders/orders.html', orders=rows, role=session.get('role'))


# ── Place new order ───────────────────────────────────────────
@orders_bp.route('/orders/new', methods=['GET', 'POST'])
def new_order():
    check = login_required()
    if check: return check

    # Only consumers can place orders
    if session.get('role') != 'Consumer':
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
        product_id = request.form.get('product_id')
        quantity = request.form.get('quantity')

        # Error handling: empty fields
        if not product_id or not quantity:
            error = "Please fill in all fields."
        elif int(quantity) < 1:
            error = "Please enter a valid quantity."
        else:
            db = get_db()
            cursor = db.cursor(dictionary=True)
            try:
                # Check stock
                cursor.execute("""
                    SELECT stock_quantity, unit_price
                    FROM STOCKS s
                    JOIN PRODUCT p ON p.product_ID = s.product_id
                    WHERE s.product_id = %s
                    LIMIT 1
                """, (product_id,))
                stock = cursor.fetchone()

                if not stock or stock['stock_quantity'] < int(quantity):
                    error = "This product is out of stock or insufficient quantity available."
                else:
                    unit_price = stock['unit_price']

                    # Insert ORDER
                    cursor.execute("""
                        INSERT INTO `ORDER` (consumer_id, status, total_amount)
                        VALUES (%s, 'pending', 0)
                    """, (session['user_id'],))
                    order_id = cursor.lastrowid

                    # Insert ORDER_ITEM (trigger auto-updates total)
                    cursor.execute("""
                        INSERT INTO ORDER_ITEM (order_id, line_num, product_id, quantity, unit_price)
                        VALUES (%s, 1, %s, %s, %s)
                    """, (order_id, product_id, quantity, unit_price))

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
        role = session.get('role')

        if role == 'Consumer':
            cursor.execute("""
                SELECT u.first_name, u.last_name, u.email, u.phone_number,
                       c.street_address, c.city, c.postal_code, c.country
                FROM USER u
                JOIN CONSUMER c ON c.consumer_ID = u.user_id
                WHERE u.user_id = %s
            """, (session['user_id'],))

        elif role == 'Retailer':
            cursor.execute("""
                SELECT u.first_name, u.last_name, u.email, u.phone_number,
                       r.brand_name, r.website_url, r.store_description
                FROM USER u
                JOIN RETAIL_PARTNER r ON r.retailer_ID = u.user_id
                WHERE u.user_id = %s
            """, (session['user_id'],))

        elif role == 'Admin':
            cursor.execute("""
                SELECT user_id, first_name, last_name, email,
                       account_type, account_status
                FROM USER
            """)

        user = cursor.fetchall() if role == 'Admin' else cursor.fetchone()

    except Exception as e:
        print("Profile fetch error:", e)
    finally:
        cursor.close()
        db.close()

    if request.method == 'POST':
        role = session.get('role')

        if role == 'Consumer':
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

        elif role == 'Retailer':
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
                           user=user, role=session.get('role'),
                           error=error, success=success)