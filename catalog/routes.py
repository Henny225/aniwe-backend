from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from database import get_connection, execute_query, execute_query_single, execute_insert_update
from utils import normalize_account_type

catalog = Blueprint("catalog", __name__, template_folder="templates")

def login_required(f):
    from functools import wraps
    @wraps(f)
    def decorated(*args, **kwargs):
        if "user_id" not in session:
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    return decorated

def get_role():
    return normalize_account_type(session.get("role", ""))


@catalog.route("/products")
@login_required
def products():
    role = get_role()
    user_id = session.get("user_id")
    first_name = session.get("first_name", "User")

    if role == "RETAIL_PARTNER":
        products = execute_query("""
            SELECT p.*, s.subcategory_name, s.category
            FROM PRODUCT p
            JOIN SUBCATEGORY s ON s.subcategory_ID = p.subcategory_ID
            WHERE p.retailer_ID = %s
        """, (user_id,))
    else:
        products = execute_query("""
            SELECT p.*, rp.brand_name, s.subcategory_name, s.category
            FROM PRODUCT p
            JOIN RETAIL_PARTNER rp ON rp.retailer_ID = p.retailer_ID
            JOIN SUBCATEGORY s ON s.subcategory_ID = p.subcategory_ID
        """)

    if products:
        product_ids = [p["product_ID"] for p in products]
        fmt = ",".join(["%s"] * len(product_ids))
        all_seasons = execute_query(f"SELECT product_ID, season FROM PRODUCT_SEASON WHERE product_ID IN ({fmt})", tuple(product_ids))
        seasons_map = {}
        for row in (all_seasons or []):
            seasons_map.setdefault(row["product_ID"], []).append(row["season"])
        all_sizes = execute_query(f"SELECT product_ID, size FROM PRODUCT_SIZE WHERE product_ID IN ({fmt})", tuple(product_ids))
        sizes_map = {}
        for row in (all_sizes or []):
            sizes_map.setdefault(row["product_ID"], []).append(row["size"])
        for product in products:
            product["seasons"] = seasons_map.get(product["product_ID"], [])
            product["sizes"] = sizes_map.get(product["product_ID"], [])
    else:
        products = []

    return render_template("products.html", products=products, role=role, first_name=first_name, user_id=user_id)


@catalog.route("/products/<int:product_id>")
@login_required
def product_detail(product_id):
    role = get_role()
    user_id = session.get("user_id")
    first_name = session.get("first_name", "User")

    product = execute_query_single("""
        SELECT p.*, rp.brand_name, s.subcategory_name, s.category
        FROM PRODUCT p
        JOIN RETAIL_PARTNER rp ON rp.retailer_ID = p.retailer_ID
        JOIN SUBCATEGORY s ON s.subcategory_ID = p.subcategory_ID
        WHERE p.product_ID = %s
    """, (product_id,))

    if not product:
        flash("Product not found", "error")
        return redirect(url_for("catalog.products"))

    seasons = execute_query("SELECT season FROM PRODUCT_SEASON WHERE product_ID = %s", (product_id,))
    product["seasons"] = [r["season"] for r in seasons] if seasons else []

    sizes = execute_query(
        "SELECT size FROM PRODUCT_SIZE WHERE product_ID = %s ORDER BY FIELD(size,'XS','S','M','L','XL','XXL','One Size')",
        (product_id,)
    )
    product["sizes"] = [r["size"] for r in sizes] if sizes else []

    reviews = execute_query("""
        SELECT r.rating, r.review_text, r.review_date, u.first_name, u.last_name
        FROM REVIEW r
        JOIN CONSUMER c ON c.consumer_ID = r.consumer_id
        JOIN USER u ON u.user_id = c.consumer_ID
        WHERE r.product_id = %s ORDER BY r.review_date DESC
    """, (product_id,))
    if not reviews:
        reviews = []

    already_reviewed = False
    if role == "CONSUMER":
        check = execute_query_single("SELECT review_id FROM REVIEW WHERE consumer_id = %s AND product_id = %s", (user_id, product_id))
        already_reviewed = check is not None

    return render_template("product_detail.html", product=product, reviews=reviews, role=role, first_name=first_name, user_id=user_id, already_reviewed=already_reviewed)


@catalog.route("/products/<int:product_id>/review", methods=["POST"])
@login_required
def submit_review(product_id):
    role = get_role()
    if role != "CONSUMER":
        return redirect(url_for("catalog.products"))

    user_id = session.get("user_id")
    rating = request.form.get("rating")
    review_text = request.form.get("review_text")

    if not rating:
        flash("Please select a rating", "error")
        return redirect(url_for("catalog.product_detail", product_id=product_id))

    check = execute_query_single("SELECT review_id FROM REVIEW WHERE consumer_id = %s AND product_id = %s", (user_id, product_id))
    if check:
        flash("You have already reviewed this product", "error")
        return redirect(url_for("catalog.product_detail", product_id=product_id))

    execute_insert_update("INSERT INTO REVIEW (consumer_id, product_id, rating, review_text) VALUES (%s, %s, %s, %s)", (user_id, product_id, int(rating), review_text))
    flash("Review submitted successfully!", "success")
    return redirect(url_for("catalog.product_detail", product_id=product_id))


@catalog.route("/products/add", methods=["GET", "POST"])
@login_required
def add_product():
    role = get_role()
    if role not in ("RETAIL_PARTNER", "ADMINISTRATOR"):
        flash("Only retailers can add products", "error")
        return redirect(url_for("catalog.products"))

    user_id = session.get("user_id")
    first_name = session.get("first_name", "User")
    subcategories = execute_query("SELECT * FROM SUBCATEGORY")
    retailers = execute_query("SELECT retailer_ID, brand_name FROM RETAIL_PARTNER") if role == "ADMINISTRATOR" else []

    if request.method == "POST":
        name = request.form.get("name", "").strip()
        description = request.form.get("description", "").strip()
        price = request.form.get("price", "").strip()
        tag = request.form.get("tag", "").strip()
        image_url = request.form.get("image_url", "").strip() or None
        subcategory_id = request.form.get("subcategory_id", "").strip()
        seasons = request.form.getlist("seasons")
        sizes = request.form.getlist("sizes")

        if role == "ADMINISTRATOR":
            retailer_id = request.form.get("retailer_id", "").strip()
        else:
            retailer_id = str(user_id)

        if not name or not price or not subcategory_id or not retailer_id:
            flash("Please fill in all required fields", "error")
            return render_template("add_product.html", role=role, first_name=first_name, subcategories=subcategories or [], retailers=retailers)

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("INSERT INTO PRODUCT (retailer_ID, subcategory_ID, name, description, price, tag, image_url) VALUES (%s, %s, %s, %s, %s, %s, %s)", (int(retailer_id), int(subcategory_id), name, description, float(price), tag, image_url))
        product_id = cursor.lastrowid
        for season in seasons:
            cursor.execute("INSERT INTO PRODUCT_SEASON (product_ID, season) VALUES (%s, %s)", (product_id, season))
        for size in sizes:
            cursor.execute("INSERT INTO PRODUCT_SIZE (product_ID, size) VALUES (%s, %s)", (product_id, size))
        
        # Togzhan's changes - necessary for STOCKS table 
        stock_quantity = int(request.form.get("stock_quantity", 0))
        restock_threshold = int(request.form.get("restock_threshold", 10))
        cursor.execute("""
            INSERT INTO STOCKS (retailer_id, product_id, stock_quantity, restock_threshold)
            VALUES (%s, %s, %s, %s)
        """, (int(retailer_id), product_id, stock_quantity, restock_threshold))
        # end of STOCKS table
        
        conn.commit()
        cursor.close()
        conn.close()

        flash("Product added successfully!", "success")
        return redirect(url_for("catalog.products"))

    return render_template("add_product.html", role=role, first_name=first_name, subcategories=subcategories or [], retailers=retailers)


@catalog.route("/products/<int:product_id>/delete", methods=["POST"])
@login_required
def delete_product(product_id):
    role = get_role()
    if role != "ADMINISTRATOR":
        return redirect(url_for("catalog.products"))

    execute_insert_update("DELETE FROM PRODUCT WHERE product_ID = %s", (product_id,))
    flash("Product deleted", "success")
    return redirect(url_for("catalog.products"))
