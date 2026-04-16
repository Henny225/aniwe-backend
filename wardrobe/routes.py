from functools import wraps
from flask import Blueprint, session, redirect, url_for, render_template, request
from database import execute_query, execute_insert_update
from utils import normalize_account_type

wardrobe = Blueprint('wardrobe', __name__, template_folder='templates')

def consumer_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        if normalize_account_type(session.get('role')) != 'CONSUMER':
            return redirect('/')
        return f(*args, **kwargs)
    return decorated_function

@wardrobe.route('/wardrobe')
@consumer_required
def wardrobe_page():
    consumer_id = session.get('user_id')

    query = """
    SELECT 
        ci.item_ID,
        ci.item_name,
        ci.brand,
        ci.size,
        ci.purchase_price,
        ci.status,
        s.subcategory_name,
        s.category,
        GROUP_CONCAT(DISTINCT cic.colour ORDER BY cic.colour SEPARATOR ', ') AS colours
    FROM CLOTHING_ITEM ci
    JOIN SUBCATEGORY s ON s.subcategory_ID = ci.subcategory_ID
    LEFT JOIN CLOTHING_ITEM_COLOUR cic ON cic.item_ID = ci.item_ID
    WHERE ci.consumer_ID = %s
    GROUP BY
        ci.item_ID, ci.item_name, ci.brand, ci.size, ci.purchase_price,
        ci.status, s.subcategory_name, s.category
    ORDER BY ci.item_ID DESC
    """
    items = execute_query(query, (consumer_id,)) or []

    return render_template('wardrobe.html', items=items)

@wardrobe.route('/wardrobe/add', methods=['GET', 'POST'])
@consumer_required
def add_item():
    error = None
    consumer_id = session.get('user_id')

    subcategories = execute_query(
        "SELECT subcategory_ID, subcategory_name, category FROM SUBCATEGORY ORDER BY category, subcategory_name"
    ) or []

    if request.method == 'POST':
        item_name = request.form.get('item_name', '').strip()
        brand = request.form.get('brand', '').strip()
        size = request.form.get('size', '').strip()
        price = request.form.get('price', '').strip()
        status = request.form.get('status', '').strip()
        subcategory_id = request.form.get('subcategory_id', '').strip()
        colour = request.form.get('colour', '').strip()

        if not all([item_name, brand, size, price, status, subcategory_id, colour]):
            error = "Please fill in all fields"
        else:
            item_insert_query = """
            INSERT INTO CLOTHING_ITEM
            (consumer_ID, subcategory_ID, item_name, brand, size, purchase_price, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """
            success = execute_insert_update(
                item_insert_query,
                (consumer_id, subcategory_id, item_name, brand, size, price, status)
            )

            if success:
                newest_item = execute_query(
                    """
                    SELECT item_ID
                    FROM CLOTHING_ITEM
                    WHERE consumer_ID = %s
                    ORDER BY item_ID DESC
                    LIMIT 1
                    """,
                    (consumer_id,)
                )

                if newest_item:
                    item_id = newest_item[0]['item_ID']
                    execute_insert_update(
                        "INSERT INTO CLOTHING_ITEM_COLOUR (item_ID, colour) VALUES (%s, %s)",
                        (item_id, colour)
                    )

                return redirect('/wardrobe')
            else:
                error = "Error creating clothing item"

    return render_template('add_item.html', subcategories=subcategories, error=error)

@wardrobe.route('/outfits')
@consumer_required
def outfits_page():
    consumer_id = session.get('user_id')

    outfit_query = """
    SELECT
        o.outfit_ID,
        o.outfit_name,
        o.times_worn,
        o.created_at,
        GROUP_CONCAT(DISTINCT oc.occasion ORDER BY oc.occasion SEPARATOR ', ') AS occasions,
        GROUP_CONCAT(DISTINCT os.season ORDER BY os.season SEPARATOR ', ') AS seasons
    FROM OUTFIT o
    LEFT JOIN OUTFIT_OCCASION oc ON oc.outfit_ID = o.outfit_ID
    LEFT JOIN OUTFIT_SEASON os ON os.outfit_ID = o.outfit_ID
    WHERE o.consumer_ID = %s
    GROUP BY o.outfit_ID, o.outfit_name, o.times_worn, o.created_at
    ORDER BY o.created_at DESC
    """
    outfits = execute_query(outfit_query, (consumer_id,)) or []

    item_query = """
    SELECT
        o.outfit_ID,
        ci.item_name,
        ci.brand
    FROM OUTFIT o
    JOIN CONSISTS_OF co ON co.outfit_ID = o.outfit_ID
    JOIN CLOTHING_ITEM ci ON ci.item_ID = co.item_ID
    WHERE o.consumer_ID = %s
    ORDER BY o.outfit_ID, ci.item_name
    """
    outfit_items = execute_query(item_query, (consumer_id,)) or []

    items_by_outfit = {}
    for row in outfit_items:
        items_by_outfit.setdefault(row['outfit_ID'], []).append({
            'item_name': row['item_name'],
            'brand': row['brand']
        })

    for outfit in outfits:
        outfit['items'] = items_by_outfit.get(outfit['outfit_ID'], [])

    return render_template('outfits.html', outfits=outfits)

@wardrobe.route('/outfits/create', methods=['GET', 'POST'])
@consumer_required
def create_outfit():
    error = None
    consumer_id = session.get('user_id')

    clothing_items = execute_query(
        """
        SELECT item_ID, item_name, brand
        FROM CLOTHING_ITEM
        WHERE consumer_ID = %s
        ORDER BY item_name
        """,
        (consumer_id,)
    ) or []

    if request.method == 'POST':
        outfit_name = request.form.get('outfit_name', '').strip()
        occasion = request.form.get('occasion', '').strip()
        season = request.form.get('season', '').strip()
        selected_items = request.form.getlist('item_ids')

        if not outfit_name or not occasion or not season:
            error = "Please fill in all fields"
        elif not selected_items:
            error = "Please select at least one item"
        else:
            outfit_insert_query = """
            INSERT INTO OUTFIT (consumer_ID, outfit_name, is_public)
            VALUES (%s, %s, %s)
            """
            success = execute_insert_update(
                outfit_insert_query,
                (consumer_id, outfit_name, False)
            )

            if success:
                newest_outfit = execute_query(
                    """
                    SELECT outfit_ID
                    FROM OUTFIT
                    WHERE consumer_ID = %s
                    ORDER BY outfit_ID DESC
                    LIMIT 1
                    """,
                    (consumer_id,)
                )

                if newest_outfit:
                    outfit_id = newest_outfit[0]['outfit_ID']

                    execute_insert_update(
                        "INSERT INTO OUTFIT_OCCASION (outfit_ID, occasion) VALUES (%s, %s)",
                        (outfit_id, occasion)
                    )

                    execute_insert_update(
                        "INSERT INTO OUTFIT_SEASON (outfit_ID, season) VALUES (%s, %s)",
                        (outfit_id, season)
                    )

                    for item_id in selected_items:
                        execute_insert_update(
                            "INSERT INTO CONSISTS_OF (outfit_ID, item_ID) VALUES (%s, %s)",
                            (outfit_id, item_id)
                        )

                return redirect('/outfits')
            else:
                error = "Error creating outfit"

    return render_template('create_outfit.html', clothing_items=clothing_items, error=error)