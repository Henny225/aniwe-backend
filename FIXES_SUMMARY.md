# Bug Fixes Summary

## Issue 1: Broken Customer Dashboard Links

**Error:** Customer dashboard menu links returned `#` or `404` when clicked. Routes like "Products", "My Orders", "My Outfits" pointed to placeholders that didn't work.

**Code with Error:** [app.py](app.py#L68-L82) – home() function menu_links for all user roles

**Before:**
```python
if user_role == 'CONSUMER':
    menu_links = [
        {'name': 'Products', 'url': '#'},
        {'name': 'My Wardrobe', 'url': '/wardrobe'},
        {'name': 'My Orders', 'url': '#'},
        {'name': 'My Outfits', 'url': '/outfits'}
    ]
elif user_role == 'RETAIL_PARTNER':
    menu_links = [
        {'name': 'My Products', 'url': '/products'},
        {'name': 'My Orders', 'url': '#'}
    ]
elif user_role == 'ADMINISTRATOR':
    menu_links = [
        {'name': 'All Products', 'url': '/products'},
        {'name': 'All Orders', 'url': '#'},
        {'name': 'All Users', 'url': '#'}
    ]
```

**Fix:** Replaced hardcoded paths and placeholders with `url_for()` calls to dynamically generate URLs from route names:

```python
if user_role == 'CONSUMER':
    menu_links = [
        {'name': 'Products', 'url': url_for('catalog.products')},
        {'name': 'My Wardrobe', 'url': url_for('wardrobe.wardrobe_page')},
        {'name': 'My Orders', 'url': url_for('orders.orders')},
        {'name': 'My Outfits', 'url': url_for('wardrobe.outfits_page')}
    ]
elif user_role == 'RETAIL_PARTNER':
    menu_links = [
        {'name': 'My Products', 'url': url_for('catalog.products')},
        {'name': 'My Orders', 'url': url_for('orders.orders')}
    ]
elif user_role == 'ADMINISTRATOR':
    menu_links = [
        {'name': 'All Products', 'url': url_for('catalog.products')},
        {'name': 'All Orders', 'url': url_for('orders.orders')},
        {'name': 'All Users', 'url': url_for('orders.profile')}
    ]
```

---

## Issue 2: Orders Blueprint Not Registered

**Error:** `GET /orders HTTP/1.1" 404` – Orders route returned 404 because the blueprint was never attached to the Flask app.

**Code with Error:** [app.py](app.py#L9) and [app.py](app.py#L22) – Blueprint import and registration section

**Before:**
```python
# Missing import:
# from orders.routes import orders_bp

# Inside create_app():
app.register_blueprint(auth_bp)
register_web_auth_routes(app)
app.register_blueprint(catalog)
# orders_bp never registered
app.register_blueprint(wardrobe)
```

**Fix:** Added the missing import at line 9 and blueprint registration at line 22:

```python
# Line 9 - Added:
from orders.routes import orders_bp

# Inside create_app() at line 22:
app.register_blueprint(auth_bp)
register_web_auth_routes(app)
app.register_blueprint(catalog)
app.register_blueprint(orders_bp)  # ← Added
app.register_blueprint(wardrobe)
```

---

## Issue 3: Role Normalization Mismatch – Missing Data & 302 Redirects

**Error:** Customer was redirected away from `/wardrobe` and `/orders` (HTTP 302), or pages loaded but showed no data. Silent failures in `orders/profile` and `orders/orders` routes due to role string mismatches.

**Root Cause:** Database stores roles as mixed-case (`'Consumer'`, `'Retailer'`, `'Admin'`), but code checked for uppercase (`'CONSUMER'`, `'RETAIL_PARTNER'`, `'ADMINISTRATOR'`). Login sets `session['role']` directly from the database without normalization.

**Files with Error:**
- [wardrobe/routes.py](wardrobe/routes.py#L12) – consumer_required decorator
- [orders/routes.py](orders/routes.py) – Multiple role checks (lines 34, 87, 174, 210)
- [templates/orders/orders.html](templates/orders/orders.html#L11-L37) – Role comparisons in Jinja2
- [templates/orders/profile.html](templates/orders/profile.html#L30-L46) – Role conditionals

**Before (wardrobe/routes.py):**
```python
def consumer_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        if session.get('role') != 'CONSUMER':  # ← Fails for 'Consumer' from DB
            return redirect('/')
        return f(*args, **kwargs)
    return decorated_function
```

**Before (orders/routes.py lines 34, 87, 174, 210):**
```python
role = session.get('role')  # Returns 'Consumer' from DB
if role == 'Consumer':  # ← Inconsistent casing
    # Query logic
elif role == 'Retailer':  # ← Inconsistent casing
    # Query logic
elif role == 'Admin':  # ← Inconsistent casing
    # Query logic
```

**Before (templates/orders/orders.html):**
```html
{% if role == 'Consumer' %}My Orders
{% elif role == 'Retailer' %}Orders for My Products
{% else %}All Orders{% endif %}
```

**Fix:** Added `normalize_account_type()` import and calls to standardize roles to uppercase before comparison:

**[wardrobe/routes.py](wardrobe/routes.py#L1-L14):**
```python
from utils import normalize_account_type

def consumer_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        if normalize_account_type(session.get('role')) != 'CONSUMER':  # ← Fixed
            return redirect('/')
        return f(*args, **kwargs)
    return decorated_function
```

**[orders/routes.py](orders/routes.py) – Examples at lines 34, 87, 174, 210:**
```python
from utils import normalize_account_type

# In orders() function
role = normalize_account_type(session.get('role'))  # ← Normalize first

if role == 'CONSUMER':  # ← Uppercase constant
    cursor.execute(...)
elif role == 'RETAIL_PARTNER':  # ← Uppercase constant
    cursor.execute(...)
elif role == 'ADMINISTRATOR':  # ← Uppercase constant
    cursor.execute(...)

# In new_order() function
if normalize_account_type(session.get('role')) != 'CONSUMER':  # ← Normalize
    return redirect('/orders')

# In profile() function
role = normalize_account_type(session.get('role'))  # ← Normalize
# All subsequent role checks use uppercase 'CONSUMER', 'RETAIL_PARTNER', 'ADMINISTRATOR'

# Return statement
return render_template('orders/profile.html',
                       user=user, role=normalize_account_type(session.get('role')),
                       error=error, success=success)
```

**[templates/orders/orders.html](templates/orders/orders.html#L11):**
```html
<!-- Before -->
{% if role == 'Consumer' %}...
{% elif role == 'Retailer' %}...

<!-- After -->
{% if role == 'CONSUMER' %}...
{% elif role == 'RETAIL_PARTNER' %}...
```

**[templates/orders/profile.html](templates/orders/profile.html#L30, #L45):**
```html
<!-- Before -->
{% if role == 'Consumer' and user %}
...
{% elif role == 'Retailer' and user %}
...
{% elif role == 'Admin' and user %}

<!-- After -->
{% if role == 'CONSUMER' and user %}
...
{% elif role == 'RETAIL_PARTNER' and user %}
...
{% elif role == 'ADMINISTRATOR' and user %}
```

---

## Issue 4: Template Not Found – auth and orders templates

**Error:** `jinja2.exceptions.TemplateNotFound: index.html` and `jinja2.exceptions.TemplateNotFound: login.html` when accessing `/` and `/login`.

**Code with Error:** [app.py](app.py#L14) – Flask app initialization

**Before:**
```python
app = Flask(__name__, template_folder='templates')  # ← Wrong folder (plural)
```

**Root Cause:** The app was configured to look in `templates/` (plural) but auth templates and orders templates are located in:
- `template/` (singular) for auth templates: login.html, register.html, base.html, index.html
- `template/orders/` for orders templates: orders.html, new_order.html, profile.html

**Fix:** Changed app template folder back to `template/` (singular):

```python
app = Flask(__name__, template_folder='template')  # ← Correct folder (singular)
```

**Template Configuration:**
- **App** (`template_folder='template'`): Looks in `template/` folder for auth templates and app-level templates, with orders routes accessing `'orders/orders.html'` → `template/orders/orders.html`
- **Catalog blueprint** (`template_folder='templates'`): Has own template folder at `catalog/templates/` for products.html, product_detail.html, add_product.html
- **Wardrobe blueprint** (`template_folder='templates'`): Has own template folder at `wardrobe/templates/` for wardrobe.html, add_item.html, outfits.html, create_outfit.html

---

## Issue 5: New Order Insert Error – Unknown column 'unit_price' in STOCKS

**Error:** `1054 (42S22): Unknown column 'unit_price' in 'field list'` when submitting the new order form via POST to `/orders/new`.

**Code with Error:** [orders/routes.py](orders/routes.py#L116-L127) – new_order() function, stock query

**Before:**
```python
cursor.execute("""
    SELECT stock_quantity, unit_price
    FROM STOCKS s
    JOIN PRODUCT p ON p.product_ID = s.product_id
    WHERE s.product_id = %s
    LIMIT 1
""", (product_id,))
```

**Root Cause:** The query tried to select `unit_price` from the STOCKS table, but the STOCKS table schema only has `stock_quantity`, `restock_threshold`, `last_updated`, and foreign keys. The `price` column exists in the PRODUCT table, not STOCKS.

**Fix:** Updated the SELECT to get `price` from PRODUCT instead of trying to get it from STOCKS:

```python
cursor.execute("""
    SELECT s.stock_quantity, p.price as unit_price
    FROM STOCKS s
    JOIN PRODUCT p ON p.product_ID = s.product_id
    WHERE s.product_id = %s
    LIMIT 1
""", (product_id,))
```

**Database Schema Reference:**
- `STOCKS` table: `retailer_id, product_id, stock_quantity, restock_threshold, last_updated`
- `PRODUCT` table: `product_ID, name, price, ...`
- `ORDER_ITEM` table: `order_id, line_num, product_id, quantity, unit_price` (requires unit_price for each line item)

---

## Issue 6: Admin Profile – Unread Result Error

**Error:** `mysql.connector.errors.InternalError: Unread result found` when accessing `/profile` as an admin user.

**Code with Error:** [orders/routes.py](orders/routes.py#L209) – profile() function, cursor fetchall/fetchone logic

**Before:**
```python
if role == 'ADMINISTRATOR':
    cursor.execute("""
        SELECT user_id, first_name, last_name, email,
               account_type, account_status
        FROM USER
    """)

user = cursor.fetchall() if role == 'Admin' else cursor.fetchone()
```

**Root Cause:** The condition checked for `role == 'Admin'` (old mixed-case value) but the normalized role is `'ADMINISTRATOR'` (uppercase). This caused `cursor.fetchone()` to be called instead of `cursor.fetchall()`, leaving multiple unread rows in the result set. When the cursor closed, MySQL raised an error about unread results.

**Fix:** Changed the condition to match the normalized uppercase role value:

```python
user = cursor.fetchall() if role == 'ADMINISTRATOR' else cursor.fetchone()
```

Now when an admin accesses `/profile`, the code correctly calls `cursor.fetchall()` to consume all rows before closing the cursor.

---

## Summary of Changes

| Issue | Severity | Fixed In | Status |
|-------|----------|----------|--------|
| Broken dashboard links | High | app.py | ✅ Fixed |
| Orders blueprint not registered | Critical | app.py | ✅ Fixed |
| Role mismatch – redirects & missing data | High | wardrobe/routes.py, orders/routes.py, templates | ✅ Fixed |
| Template folder configuration | High | app.py | ✅ Fixed |
| New order insert – missing unit_price | High | orders/routes.py | ✅ Fixed |
| Admin profile – unread result error | High | orders/routes.py | ✅ Fixed |

**No files were copied or moved between folders. All original templates remain in their original locations:**
- `template/` (singular) contains auth and app-level templates
- `template/orders/` contains orders templates
- `catalog/templates/` contains catalog templates
- `wardrobe/templates/` contains wardrobe templates

All routes now work correctly for all user roles after login.
