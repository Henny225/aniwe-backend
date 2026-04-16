# aniwe-backend

AI-powered fashion stylist platform. Flask backend connecting to AniweDB (MySQL 8.0 on GCP).

## Tech Stack

- **Backend**: Flask 3.1.3 (Python 3.10+)
- **Database**: MySQL 8.0 on GCP Compute Engine (Ubuntu 22.04, us-west1-a)
- **Deployment**: Google App Engine (app.yaml) + Gunicorn
- **Auth**: SHA-256 password hashing, Flask sessions
- **Dependencies**: flask, mysql-connector-python, gunicorn, python-dotenv

## Architecture

- `app.py` — Flask app factory, registers blueprints, role-based home route
- `config.py` — Two profiles: `dev` (localhost) and `gcp` (35.233.192.65)
- `database.py` — `get_connection()`, `execute_query()`, `execute_query_single()`, `execute_insert_update()`
- `auth_routes.py` — API endpoints (JSON) + web routes (HTML forms) for signup/login/logout
- `catalog/routes.py` — Product listing, detail, add, delete, reviews
- `wardrobe/routes.py` — Clothing items and outfits (CONSUMER only)
- `orders/routes.py` — Orders, new order, profile (NOTE: blueprint not yet registered in app.py)
- `utils.py` — `hash_password()`, `verify_password()`, `normalize_account_type()`

## Database Schema (20 Tables)

USER (supertype) → CONSUMER / RETAIL_PARTNER / ADMINISTRATOR (EER subtypes, disjoint)

Key tables: CLOTHING_ITEM, CLOTHING_ITEM_COLOUR, OUTFIT, CONSISTS_OF, OUTFIT_OCCASION, OUTFIT_SEASON, PRODUCT, PRODUCT_SEASON, STOCKS, ORDER, ORDER_ITEM, REVIEW, SUBCATEGORY, CONSUMER_STYLE_PREFERENCES, CONSUMER_STYLE_PREFERENCE_LOG, ACCESS_LOG

Triggers: `tr_AfterPreferenceInsert` (logs style pref additions), `trg_stocks_decrement` (auto-decrements stock on ORDER_ITEM insert)

## Three User Roles

- **CONSUMER** — Browse products, manage wardrobe, create outfits, place orders, write reviews
- **RETAIL_PARTNER** — Add products, view their orders
- **ADMINISTRATOR** — Delete products, view all orders/users

## Role Normalization

Use `normalize_account_type()` from `utils.py`. Canonical values: `CONSUMER`, `RETAIL_PARTNER`, `ADMINISTRATOR`. The orders module currently uses legacy values (`Consumer`, `Retailer`, `Admin`) — this is a known inconsistency.

## Templates

- `template/` — Main app (base.html, index.html, login.html, register.html)
- `catalog/templates/` — Catalog blueprint (products.html, product_detail.html, add_product.html)
- `wardrobe/templates/` — Wardrobe blueprint (wardrobe.html, add_item.html, outfits.html, create_outfit.html)
- `templates/orders/` — Orders blueprint (orders.html, new_order.html, profile.html)

## Running

```bash
python app.py        # dev profile (localhost DB)
python app.py -gcp   # gcp profile (remote DB)
```

Server runs on port 8080 by default.
