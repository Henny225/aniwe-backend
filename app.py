import os
from flask import Flask, render_template_string, jsonify, request
import mysql.connector

app = Flask(__name__)

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

HOME_PAGE = """
<!DOCTYPE html>
<html>
<head>
    <title>aniwe dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@300;400;500;600&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Inter, sans-serif; background: linear-gradient(135deg, #f8f6f3 0%, #ede7e0 100%); color: #2c2828; min-height: 100vh; font-weight: 300; }
        nav { text-align: center; padding: 3rem 0 1rem; }
        nav h1 { font-family: Cormorant Garamond, serif; font-size: 2.8rem; font-weight: 300; color: #1a1817; letter-spacing: 3px; }
        nav p { font-size: 0.75rem; color: #8b7f7a; letter-spacing: 4px; text-transform: uppercase; margin-top: 0.3rem; }
        .divider { width: 50px; height: 1px; background: #d4c4b0; margin: 2rem auto; }
        .container { max-width: 900px; margin: 0 auto; padding: 0 24px 4rem; }
        .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 2.5rem; }
        .stat { background: rgba(255,255,255,0.6); backdrop-filter: blur(10px); border: 1px solid rgba(212,196,176,0.3); border-radius: 12px; padding: 2rem; text-align: center; transition: all 0.3s ease; }
        .stat:hover { background: rgba(255,255,255,0.85); transform: translateY(-2px); box-shadow: 0 8px 30px rgba(0,0,0,0.04); }
        .stat .number { font-family: Cormorant Garamond, serif; font-size: 2.8rem; font-weight: 400; color: #1a1817; line-height: 1; }
        .stat .label { font-size: 0.65rem; color: #8b7f7a; text-transform: uppercase; letter-spacing: 3px; margin-top: 0.5rem; }
        h2 { font-family: Cormorant Garamond, serif; font-size: 1.5rem; font-weight: 400; color: #1a1817; margin-bottom: 1rem; letter-spacing: 1px; }
        .endpoints { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 2.5rem; }
        .endpoints a { background: #1a1817; color: #f8f6f3; padding: 8px 20px; border-radius: 50px; text-decoration: none; font-size: 0.7rem; letter-spacing: 1.5px; text-transform: uppercase; font-weight: 400; transition: all 0.3s ease; }
        .endpoints a:hover { background: #3a3837; transform: translateY(-1px); }
        .card { background: rgba(255,255,255,0.6); backdrop-filter: blur(10px); border: 1px solid rgba(212,196,176,0.3); border-radius: 12px; padding: 2rem; margin-bottom: 1.5rem; transition: all 0.3s ease; }
        .card:hover { background: rgba(255,255,255,0.85); }
        .card h3 { font-family: Cormorant Garamond, serif; font-size: 1.2rem; font-weight: 400; margin-bottom: 1rem; color: #1a1817; letter-spacing: 0.5px; }
        table { width: 100%; border-collapse: collapse; }
        th { text-align: left; padding: 8px 12px; font-size: 0.6rem; color: #8b7f7a; text-transform: uppercase; letter-spacing: 2px; font-weight: 500; border-bottom: 1px solid rgba(212,196,176,0.3); }
        td { padding: 10px 12px; font-size: 0.85rem; color: #2c2828; border-bottom: 1px solid rgba(212,196,176,0.15); font-weight: 300; }
        tr:last-child td { border-bottom: none; }
        footer { text-align: center; padding: 2rem 0 3rem; font-size: 0.7rem; color: #8b7f7a; letter-spacing: 2px; }
    </style>
</head>
<body>
    <nav><h1>aniwe</h1><p>Admin Dashboard</p></nav>
    <div class="divider"></div>
    <div class="container">
        <div class="stats">
            <div class="stat"><div class="number" id="productCount">&mdash;</div><div class="label">Products</div></div>
            <div class="stat"><div class="number" id="outfitCount">&mdash;</div><div class="label">Outfits</div></div>
            <div class="stat"><div class="number" id="userCount">&mdash;</div><div class="label">Users</div></div>
        </div>
        <h2>Endpoints</h2>
        <div class="endpoints">
            <a href="/api/products">Products</a>
            <a href="/api/outfits">Outfits</a>
            <a href="/api/users">Users</a>
            <a href="/api/occasions">Occasions</a>
            <a href="/api/access-logs">Access Logs</a>
        </div>
        <div class="divider"></div>
        <div class="card"><h3>Recent Products</h3>
            <table><thead><tr><th>ID</th><th>Name</th><th>Price</th><th>Retailer</th></tr></thead>
            <tbody id="productsTable"><tr><td colspan="4" style="color:#8b7f7a;font-style:italic">No products yet</td></tr></tbody></table>
        </div>
        <div class="card"><h3>Recent Outfits</h3>
            <table><thead><tr><th>ID</th><th>Name</th><th>Public</th><th>Created</th></tr></thead>
            <tbody id="outfitsTable"><tr><td colspan="4" style="color:#8b7f7a;font-style:italic">No outfits yet</td></tr></tbody></table>
        </div>
        <div class="card"><h3>Users</h3>
            <table><thead><tr><th>Name</th><th>Email</th><th>Type</th><th>Status</th></tr></thead>
            <tbody id="usersTable"><tr><td colspan="4" style="color:#8b7f7a;font-style:italic">Loading...</td></tr></tbody></table>
        </div>
    </div>
    <footer>aniwe &mdash; AI-Powered Fashion Stylist</footer>
    <script>
        async function loadData() {
            try {
                var products = await fetch("/api/products").then(function(r){return r.json()});
                var outfits = await fetch("/api/outfits").then(function(r){return r.json()});
                var users = await fetch("/api/users").then(function(r){return r.json()});
                document.getElementById("productCount").textContent = Array.isArray(products) ? products.length : 0;
                document.getElementById("outfitCount").textContent = Array.isArray(outfits) ? outfits.length : 0;
                document.getElementById("userCount").textContent = Array.isArray(users) ? users.length : 0;
                if (Array.isArray(products) && products.length > 0) {
                    document.getElementById("productsTable").innerHTML = products.slice(0,5).map(function(p){
                        return "<tr><td>"+p.product_ID+"</td><td>"+(p.name||"\u2014")+"</td><td>$"+(p.price||"\u2014")+"</td><td>"+(p.retailer_ID||"\u2014")+"</td></tr>";
                    }).join("");
                }
                if (Array.isArray(outfits) && outfits.length > 0) {
                    document.getElementById("outfitsTable").innerHTML = outfits.slice(0,5).map(function(o){
                        return "<tr><td>"+o.outfit_ID+"</td><td>"+(o.outfit_name||"\u2014")+"</td><td>"+(o.is_public?"Public":"Private")+"</td><td>"+(o.created_at||"\u2014")+"</td></tr>";
                    }).join("");
                }
                if (Array.isArray(users) && users.length > 0) {
                    document.getElementById("usersTable").innerHTML = users.slice(0,10).map(function(u){
                        return "<tr><td>"+(u.first_name||"")+" "+(u.last_name||"")+"</td><td>"+u.email+"</td><td>"+u.account_type+"</td><td>"+(u.account_status||"Active")+"</td></tr>";
                    }).join("");
                }
            } catch (err) { console.error("Error:", err); }
        }
        loadData();
    </script>
</body>
</html>
"""

@app.route("/")
def home():
    return render_template_string(HOME_PAGE)

@app.route("/api/products")
def get_products():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM PRODUCT LIMIT 50")
        results = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/outfits")
def get_outfits():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM OUTFIT LIMIT 50")
        results = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/users")
def get_users():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM USER LIMIT 50")
        results = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/occasions")
def get_occasions():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM OUTFIT_OCCASION LIMIT 50")
        results = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/access-logs")
def get_access_logs():
    try:
        db = get_db()
        cursor = db.cursor(dictionary=True)
        cursor.execute("SELECT * FROM ACCESS_LOG LIMIT 50")
        results = cursor.fetchall()
        cursor.close()
        db.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)
