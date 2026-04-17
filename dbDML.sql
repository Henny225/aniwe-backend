-- Populate the USER Table
-- 1-5 Consumers, 6-8 retailers, and 9-10 admins
INSERT INTO USER (user_id, email, password_hash, first_name, last_name, phone_number, account_type) VALUES
(1, 'alice.smith@mail.com', 'hash123', 'Alice', 'Smith', '555-0101', 'Consumer'),
(2, 'b.jones@provider.net', 'hash456', 'Bob', 'Jones', '555-0102', 'Consumer'),
(3, 'charlie.d@inbox.com', 'hash789', 'Charlie', 'Davis', '555-0103', 'Consumer'),
(4, 'dana.w@service.com', 'hash101', 'Dana', 'White', '555-0104', 'Consumer'),
(5, 'e.green@webmail.com', 'hash202', 'Eva', 'Green', '555-0105', 'Consumer'),
(6, 'partner@velvetvibe.com', 'retail77', 'Velvet', 'Vibe', '555-9001', 'Retailer'),
(7, 'contact@urbanthread.co', 'retail88', 'Urban', 'Threads', '555-9002', 'Retailer'),
(8, 'info@starlitstyle.io', 'retail99', 'Starlit', 'Style', '555-9003', 'Retailer'),
(9, 'admin.sarah@fashionapp.com', 'adm001', 'Sarah', 'Chief', '555-0001', 'Admin'),
(10, 'admin.mike@fashionapp.com', 'adm002', 'Mike', 'Tech', '555-0002', 'Admin');

-- Populate CONSUMER (IDs 1-5)
INSERT INTO CONSUMER (consumer_ID, street_address, city, state_province, postal_code, country) VALUES
(1, '123 Maple St', 'Toronto', 'ON', 'M5V 2T6', 'Canada'),
(2, '456 Oak Ave', 'Vancouver', 'BC', 'V6B 1A1', 'Canada'),
(3, '789 Pine Rd', 'New York', 'NY', '10001', 'USA'),
(4, '101 Cedar Ln', 'London', 'ON', 'N6A 1B1', 'Canada'),
(5, '202 Birch Dr', 'Calgary', 'AB', 'T2P 1J1', 'Canada');

-- Populate RETAIL_PARTNER (IDs 6-8)
INSERT INTO RETAIL_PARTNER (retailer_ID, brand_name, website_url, store_description) VALUES
(6, 'Velvet Vibe Designs', 'https://www.velvetvibe.example', 'Boutique luxury evening wear and accessories.'),
(7, 'Urban Threads Co.', 'https://www.urbanthreads.example', 'Contemporary street style for the modern professional.'),
(8, 'Starlit Style Collective', 'https://www.starlitstyle.example', 'Eco-friendly activewear and lounge clothing.');

-- Populate ADMINISTRATOR (IDs 9 and 10)
INSERT INTO ADMINISTRATOR (admin_ID, admin_level, department) VALUES
(9, 'Senior Executive', 'Operations'),
(10, 'Technical Lead', 'IT Infrastructure');

-- Populate CONSUMER_STYLE_PREFERENCES (Sample data for the 5 consumers)
INSERT INTO CONSUMER_STYLE_PREFERENCES (consumer_ID, preference) VALUES
(1, 'Minimalist'),
(1, 'Chic'),
(2, 'Sporty'),
(2, 'Casual'),
(2, 'Streetwear'),
(3, 'Eclectic'),
(3, 'Boho-Chic'),
(4, 'Chic'),
(4, 'Formal'),
(4, 'Monochrome'),
(5, 'Androgynous'),
(5, 'Oversized Fit');

-- Populate the SUBCATEGORY Table
INSERT INTO SUBCATEGORY (subcategory_ID, subcategory_name, category) VALUES
(1, 'T-shirt', 'Tops'),
(2, 'Blouse', 'Tops'),
(3, 'Sweater', 'Tops'),
(4, 'Jeans', 'Bottoms'),
(5, 'Pants', 'Bottoms'),
(6, 'Skirt', 'Bottoms'),
(7, 'Jacket', 'Outerwear'),
(8, 'Coat', 'Outerwear'),
(9, 'Dress', 'Dresses'),
(10, 'Sneakers', 'Shoes'),
(11, 'Sandals', 'Shoes'),
(12, 'Jewelry', 'Accessories'),
(13, 'Bags', 'Accessories');

UPDATE USER SET password_hash = SHA2('hash123', 256) WHERE user_id = 1;
UPDATE USER SET password_hash = SHA2('hash456', 256) WHERE user_id = 2;
UPDATE USER SET password_hash = SHA2('hash789', 256) WHERE user_id = 3;
UPDATE USER SET password_hash = SHA2('hash101', 256) WHERE user_id = 4;
UPDATE USER SET password_hash = SHA2('hash202', 256) WHERE user_id = 5;
UPDATE USER SET password_hash = SHA2('retail77', 256) WHERE user_id = 6;
UPDATE USER SET password_hash = SHA2('retail88', 256) WHERE user_id = 7;
UPDATE USER SET password_hash = SHA2('retail99', 256) WHERE user_id = 8;
UPDATE USER SET password_hash = SHA2('adm001', 256) WHERE user_id = 9;
UPDATE USER SET password_hash = SHA2('adm002', 256) WHERE user_id = 10;

-- ============================================================
-- 20 Sample Products across 3 retailers
-- ============================================================

-- Retailer 6: Velvet Vibe Designs — luxury evening wear & accessories (7 products)
-- Retailer 7: Urban Threads Co.   — street style / modern professional (7 products)
-- Retailer 8: Starlit Style       — eco-friendly activewear & lounge  (6 products)

INSERT INTO PRODUCT (retailer_ID, subcategory_ID, name, description, price, tag) VALUES
-- Velvet Vibe Designs (6)
(6,  9, 'Satin Evening Gown',          'Floor-length satin gown with adjustable straps and a sweeping train.',        299.99, 'formal'),
(6,  9, 'Lace Cocktail Dress',          'Fitted lace overlay cocktail dress with a scalloped hem.',                   189.99, 'formal'),
(6,  2, 'Silk Wrap Blouse',             'Lightweight silk blouse with a self-tie wrap and flutter sleeves.',           89.99, 'luxury'),
(6,  8, 'Cashmere Wrap Coat',           'Double-breasted cashmere coat with a belted waist in ivory.',                399.99, 'luxury'),
(6,  7, 'Velvet Blazer',                'Structured velvet blazer in deep emerald with gold button detail.',          219.99, 'formal'),
(6, 13, 'Structured Leather Tote',      'Full-grain leather tote with suede interior lining and brass hardware.',     249.99, 'luxury'),
(6, 12, 'Pearl Drop Earrings',          'Freshwater pearl drop earrings on a sterling silver setting.',                79.99, 'luxury'),

-- Urban Threads Co. (7)
(7,  1, 'Graphic Oversized Tee',        'Drop-shoulder tee with bold urban graphic print, 100% cotton.',              45.99, 'streetwear'),
(7,  4, 'High-Rise Skinny Jeans',       'Classic high-rise skinny jeans in dark indigo with a slim taper.',           99.99, 'denim'),
(7,  5, 'Wide-Leg Cargo Pants',         'Relaxed wide-leg pants with utility cargo pockets in olive.',                89.99, 'streetwear'),
(7,  7, 'Denim Bomber Jacket',          'Washed denim bomber with ribbed cuffs and a contrast lining.',              149.99, 'streetwear'),
(7,  3, 'Ribbed Turtleneck Sweater',    'Slim-fit ribbed turtleneck in soft merino wool blend, heather grey.',        79.99, 'workwear'),
(7,  6, 'Pleated Mini Skirt',           'High-waisted pleated mini skirt in black, perfect day-to-night.',            65.99, 'chic'),
(7, 10, 'Platform Chunky Sneakers',     'Chunky sole leather sneakers with a 4 cm platform and padded collar.',      129.99, 'streetwear'),

-- Starlit Style Collective (8)
(8,  1, 'Organic Cotton Tee',           'GOTS-certified organic cotton relaxed tee, naturally dyed in sage.',         34.99, 'eco'),
(8,  3, 'Recycled Fleece Pullover',     'Cozy pullover made from 100% recycled post-consumer plastic bottles.',       74.99, 'eco'),
(8,  5, 'Yoga Wide-Leg Pants',          'High-waisted wide-leg pants in moisture-wicking bamboo jersey.',             69.99, 'activewear'),
(8,  9, 'Bamboo Lounge Dress',          'Breathable bamboo-blend slip dress, doubles as activewear or casualwear.',   89.99, 'activewear'),
(8, 10, 'Low-Top Canvas Sneakers',      'Minimalist low-top sneaker in unbleached canvas with a natural rubber sole.',64.99, 'eco'),
(8, 13, 'Woven Crossbody Bag',          'Hand-woven recycled cotton crossbody with adjustable strap.',                54.99, 'eco');

-- ============================================================
-- PRODUCT_SIZE  (clothing → S/M/L/XL | shoes → 6–10 | accessories → One Size)
-- ============================================================

-- Clothing sizes (subcategory 1–9)
INSERT INTO PRODUCT_SIZE (product_ID, size)
SELECT p.product_ID, s.size
FROM PRODUCT p
CROSS JOIN (
    SELECT 'S' AS size UNION ALL SELECT 'M' UNION ALL SELECT 'L' UNION ALL SELECT 'XL'
) s
WHERE p.retailer_ID IN (6, 7, 8)
  AND p.subcategory_ID BETWEEN 1 AND 9;

-- Shoe sizes (subcategory 10–11)
INSERT INTO PRODUCT_SIZE (product_ID, size)
SELECT p.product_ID, s.size
FROM PRODUCT p
CROSS JOIN (
    SELECT '6' AS size UNION ALL SELECT '7' UNION ALL SELECT '8'
    UNION ALL SELECT '9' UNION ALL SELECT '10'
) s
WHERE p.retailer_ID IN (6, 7, 8)
  AND p.subcategory_ID IN (10, 11);

-- One Size (subcategory 12–13: jewelry, bags)
INSERT INTO PRODUCT_SIZE (product_ID, size)
SELECT product_ID, 'One Size'
FROM PRODUCT
WHERE retailer_ID IN (6, 7, 8)
  AND subcategory_ID IN (12, 13);

-- ============================================================
-- PRODUCT_SEASON
-- ============================================================

-- Velvet Vibe luxury: Fall + Winter
INSERT INTO PRODUCT_SEASON (product_ID, season)
SELECT p.product_ID, s.season
FROM PRODUCT p
CROSS JOIN (SELECT 'Fall' AS season UNION ALL SELECT 'Winter') s
WHERE p.retailer_ID = 6;

-- Urban Threads street: Spring + Summer + Fall
INSERT INTO PRODUCT_SEASON (product_ID, season)
SELECT p.product_ID, s.season
FROM PRODUCT p
CROSS JOIN (SELECT 'Spring' AS season UNION ALL SELECT 'Summer' UNION ALL SELECT 'Fall') s
WHERE p.retailer_ID = 7;

-- Starlit activewear/lounge: all four seasons
INSERT INTO PRODUCT_SEASON (product_ID, season)
SELECT p.product_ID, s.season
FROM PRODUCT p
CROSS JOIN (
    SELECT 'Spring' AS season UNION ALL SELECT 'Summer'
    UNION ALL SELECT 'Fall' UNION ALL SELECT 'Winter'
) s
WHERE p.retailer_ID = 8;

-- ============================================================
-- STOCKS (one row per product/size, 30 units, threshold 5)
-- ============================================================

INSERT INTO STOCKS (retailer_id, product_id, size, stock_quantity, restock_threshold)
SELECT p.retailer_ID, ps.product_ID, ps.size, 30, 5
FROM PRODUCT_SIZE ps
JOIN PRODUCT p ON p.product_ID = ps.product_ID
WHERE p.retailer_ID IN (6, 7, 8);
COMMIT;
