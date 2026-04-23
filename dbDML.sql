-- ============================================================
-- ANIWE DATABASE — MERGED DML SCRIPT
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE STOCKS;
TRUNCATE TABLE REVIEW;
TRUNCATE TABLE ORDER_ITEM;
TRUNCATE TABLE `ORDER`;
TRUNCATE TABLE ACCESS_LOG;
TRUNCATE TABLE CONSISTS_OF;
TRUNCATE TABLE OUTFIT_SEASON;
TRUNCATE TABLE OUTFIT_OCCASION;
TRUNCATE TABLE OUTFIT;
TRUNCATE TABLE CLOTHING_ITEM_COLOUR;
TRUNCATE TABLE CLOTHING_ITEM;
TRUNCATE TABLE PRODUCT_SIZE;
TRUNCATE TABLE PRODUCT_SEASON;
TRUNCATE TABLE PRODUCT;
TRUNCATE TABLE CONSUMER_STYLE_PREFERENCES;
TRUNCATE TABLE ADMINISTRATOR;
TRUNCATE TABLE RETAIL_PARTNER;
TRUNCATE TABLE CONSUMER;
TRUNCATE TABLE SUBCATEGORY;
TRUNCATE TABLE USER;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- USERS: 1-5 Consumers, 6-8 Retailers, 9-10 Admins
-- ============================================================
INSERT INTO USER (user_id, email, password_hash, first_name, last_name, phone_number, account_type) VALUES
(1,  'alice.smith@mail.com',       'hash123',  'Alice',   'Smith',   '555-0101', 'Consumer'),
(2,  'b.jones@provider.net',       'hash456',  'Bob',     'Jones',   '555-0102', 'Consumer'),
(3,  'charlie.d@inbox.com',        'hash789',  'Charlie', 'Davis',   '555-0103', 'Consumer'),
(4,  'dana.w@service.com',         'hash101',  'Dana',    'White',   '555-0104', 'Consumer'),
(5,  'e.green@webmail.com',        'hash202',  'Eva',     'Green',   '555-0105', 'Consumer'),
(6,  'partner@velvetvibe.com',     'retail77', 'Velvet',  'Vibe',    '555-9001', 'Retailer'),
(7,  'contact@urbanthread.co',     'retail88', 'Urban',   'Threads', '555-9002', 'Retailer'),
(8,  'info@starlitstyle.io',       'retail99', 'Starlit', 'Style',   '555-9003', 'Retailer'),
(9,  'admin.sarah@fashionapp.com', 'adm001',   'Sarah',   'Chief',   '555-0001', 'Admin'),
(10, 'admin.mike@fashionapp.com',  'adm002',   'Mike',    'Tech',    '555-0002', 'Admin');

-- Hash passwords with SHA2
SET SQL_SAFE_UPDATES = 0;
UPDATE USER SET password_hash = SHA2('hash123',  256) WHERE user_id = 1;
UPDATE USER SET password_hash = SHA2('hash456',  256) WHERE user_id = 2;
UPDATE USER SET password_hash = SHA2('hash789',  256) WHERE user_id = 3;
UPDATE USER SET password_hash = SHA2('hash101',  256) WHERE user_id = 4;
UPDATE USER SET password_hash = SHA2('hash202',  256) WHERE user_id = 5;
UPDATE USER SET password_hash = SHA2('retail77', 256) WHERE user_id = 6;
UPDATE USER SET password_hash = SHA2('retail88', 256) WHERE user_id = 7;
UPDATE USER SET password_hash = SHA2('retail99', 256) WHERE user_id = 8;
UPDATE USER SET password_hash = SHA2('adm001',   256) WHERE user_id = 9;
UPDATE USER SET password_hash = SHA2('adm002',   256) WHERE user_id = 10;

-- Simulate recent login & deactivate stale accounts
UPDATE USER SET last_login = NOW() WHERE user_id = 1;
UPDATE USER SET account_status = 'not-active'
WHERE last_login < DATE_SUB(NOW(), INTERVAL 180 DAY)
  AND account_status = 'Active';
SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- CONSUMER
-- ============================================================
INSERT INTO CONSUMER (consumer_ID, street_address, city, state_province, postal_code, country) VALUES
(1, '123 Maple St', 'Toronto',   'ON', 'M5V 2T6', 'Canada'),
(2, '456 Oak Ave',  'Vancouver', 'BC', 'V6B 1A1', 'Canada'),
(3, '789 Pine Rd',  'New York',  'NY', '10001',   'USA'),
(4, '101 Cedar Ln', 'Dover',     'DE', '12345',   'USA'),
(5, '202 Birch Dr', 'Boston',    'MA', '22222',   'USA');

-- ============================================================
-- RETAIL_PARTNER
-- ============================================================
INSERT INTO RETAIL_PARTNER (retailer_ID, brand_name, website_url, store_description) VALUES
(6, 'Velvet Vibe Designs',       'https://www.velvetvibe.example',  'Boutique luxury evening wear and accessories.'),
(7, 'Urban Threads Co.',         'https://www.urbanthreads.example', 'Contemporary street style for the modern professional.'),
(8, 'Starlit Style Collective',  'https://www.starlitstyle.example', 'Eco-friendly activewear and lounge clothing.');

-- ============================================================
-- ADMINISTRATOR
-- ============================================================
INSERT INTO ADMINISTRATOR (admin_ID, admin_level, department) VALUES
(9,  'Senior Executive', 'Operations'),
(10, 'Technical Lead',   'IT Infrastructure');

-- ============================================================
-- CONSUMER STYLE PREFERENCES
-- ============================================================
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

-- ============================================================
-- SUBCATEGORY
-- ============================================================
INSERT INTO SUBCATEGORY (subcategory_ID, subcategory_name, category) VALUES
(1,  'T-shirt',   'Tops'),
(2,  'Blouse',    'Tops'),
(3,  'Sweater',   'Tops'),
(4,  'Jeans',     'Bottoms'),
(5,  'Pants',     'Bottoms'),
(6,  'Skirt',     'Bottoms'),
(7,  'Jacket',    'Outerwear'),
(8,  'Coat',      'Outerwear'),
(9,  'Dress',     'Dresses'),
(10, 'Sneakers',  'Shoes'),
(11, 'Sandals',   'Shoes'),
(12, 'Jewelry',   'Accessories'),
(13, 'Bags',      'Accessories');

-- ============================================================
-- CLOTHING ITEMS
-- ============================================================
INSERT INTO CLOTHING_ITEM (item_ID, consumer_ID, subcategory_ID, item_name, brand, size, purchase_price, image_url, status, tag) VALUES
(1,  5, 4,  'Wide leg jeans',                   'Levis',        '31',    50.50,  'www.aws.com/jeans.png',                  'Laundry', 'Basic'),
(2,  1, 1,  'White tshirt',                     'Uniqlo',       'small', 19.90,  'www.aws.com/whitetshirt.png',            'Dirty',   'Basic'),
(3,  1, 9,  'Black going out mini dress',       'Zara',         'small', 35.00,  'www.aws.com/blackminidress.png',         'Active',  'Edgy'),
(4,  1, 7,  'Black blazer',                     'Zara',         'small', 69.90,  'www.aws.com/blackblazer.png',            'Active',  'Chic'),
(5,  3, 9,  'Floral maxi dress',                'Anthropologie','8',     84.00,  'www.aws.com/floralmaxidress.png',        'Active',  'Boho'),
(6,  5, 8,  'Gray puffer coat',                 'Aritzia',      'large', 157.50, 'www.aws.com/graypuffercoat.png',         'Active',  'Basic'),
(7,  5, 3,  'Gray cable knit sweater',          'J.Crew',       'large', 64.00,  'www.aws.com/graycableknitsweater.png',   'Active',  'Classic'),
(8,  1, 6,  'Black pleated midi skirt',         'Aritzia',      '4',     60.00,  'www.aws.com/blackpleatedmidiskirt.png',  'Active',  'Elegant'),
(9,  1, 2,  'White long sleeve tie neck blouse','Ann Taylor',   'small', 35.00,  'www.aws.com/whitetieneckblouse.png',     'Active',  'Formal'),
(10, 3, 9,  'Blue short sleeve dress',          'Old Navy',     '6',     24.50,  'www.aws.com/blueshortsleevedress.png',   'Active',  'Casual'),
(11, 1, 5,  'Black tailored trousers',          'Gap',          '4',     39.50,  'www.aws.com/blacktrousers.png',          'Active',  'Formal'),
(12, 1, 10, 'White sneakers',                   'Adidas',       '7',     44.50,  'www.aws.com/whitesneakers.png',          'Active',  'Sporty'),
(13, 1, 11, 'Black low heel sandals',           'Sam Edelman',  '7',     95.00,  'www.aws.com/blacksandals.png',           'Active',  'Chic'),
(14, 3, 12, 'Gold chain necklace',              'Mejuri',       'OS',    150.00, 'www.aws.com/goldchainnecklace.png',      'Active',  'Classic'),
(15, 5, 12, 'Black leather shoulder bag',       'Coach',        'OS',    225.00, 'www.aws.com/blackshoulderbag.png',       'Active',  'Minimal'),
(16, 3, 7,  'Black leather jacket',             'All Saints',   'medium',549.00, 'www.aws.com/blackleatherjacket.png',     'Active',  'Edgy'),
(17, 3, 11, 'Red strappy sandals',              'Madewell',     '8',     55.00,  'www.aws.com/redsandals.png',             'Active',  'Casual'),
(18, 5, 10, 'Gray sneakers',                    'New Balance',  '8',     105.00, 'www.aws.com/graysneakers.png',           'Active',  'Sporty');

-- ============================================================
-- CLOTHING ITEM COLOURS
-- ============================================================
INSERT INTO CLOTHING_ITEM_COLOUR (item_ID, colour) VALUES
(1,  'Blue'),
(2,  'White'),
(3,  'Black'),
(4,  'Black'),
(5,  'Red'),
(5,  'Pink'),
(6,  'Gray'),
(7,  'Gray'),
(8,  'Black'),
(9,  'White'),
(10, 'Blue'),
(11, 'Black'),
(12, 'White'),
(13, 'Black'),
(14, 'Gold'),
(15, 'Black'),
(16, 'Black'),
(17, 'Red'),
(18, 'Gray');

-- ============================================================
-- OUTFITS
-- ============================================================
INSERT INTO OUTFIT (outfit_ID, consumer_ID, outfit_name, created_at, is_public, times_worn) VALUES
(1,  1, 'Minimalist Monochrome',     '2025-07-05 12:00:00', TRUE,  4),
(2,  1, 'Chic Office Look',          '2025-07-10 14:00:00', TRUE,  2),
(3,  1, 'All-Black Night Out',       '2025-10-10 18:00:00', FALSE, 1),
(4,  2, 'Sporty Weekend Brunch',     '2025-08-01 10:00:00', TRUE,  3),
(5,  2, 'Casual Streetwear Fit',     '2025-10-20 08:00:00', FALSE, 5),
(6,  3, 'Boho-Chic Summer Day',      '2025-09-01 09:00:00', TRUE,  2),
(7,  3, 'Eclectic Garden Party',     '2025-10-15 11:00:00', TRUE,  1),
(8,  4, 'Formal Monochrome Set',     '2025-09-20 16:00:00', FALSE, 3),
(9,  4, 'Chic Dinner Look',          '2025-11-01 07:30:00', TRUE,  6),
(10, 5, 'Androgynous Winter Layers', '2025-11-15 13:00:00', TRUE,  2);

-- ============================================================
-- OUTFIT OCCASIONS
-- ============================================================
INSERT INTO OUTFIT_OCCASION (outfit_ID, occasion) VALUES
(1, 'wedding guest'),
(1, 'coffee run'),
(2, 'work'),
(2, 'happy hour'),
(3, 'date night'),
(4, 'brunch'),
(6, 'festival'),
(6, 'vacation'),
(7, 'garden party'),
(9, 'wedding guest');

-- ============================================================
-- OUTFIT SEASONS
-- ============================================================
INSERT INTO OUTFIT_SEASON (outfit_ID, season) VALUES
(1, 'fall'),
(1, 'spring'),
(1, 'winter'),
(2, 'fall'),
(2, 'spring'),
(4, 'spring'),
(5, 'fall'),
(5, 'winter'),
(6, 'summer'),
(9, 'winter');

-- ============================================================
-- CONSISTS OF (outfit → items)
-- ============================================================
INSERT INTO CONSISTS_OF (outfit_ID, item_ID) VALUES
(1,  4),
(1,  11),
(1,  12),
(2,  8),
(2,  9),
(2,  13),
(6,  5),
(6,  14),
(6,  17),
(7,  10),
(7,  16),
(10, 6),
(10, 7),
(10, 1),
(10, 18);

-- ============================================================
-- PRODUCTS
-- Retailer 6: Velvet Vibe Designs — luxury evening wear
-- Retailer 7: Urban Threads Co.   — street style
-- Retailer 8: Starlit Style       — eco-friendly activewear
-- ============================================================
INSERT INTO PRODUCT (product_ID, retailer_ID, subcategory_ID, name, description, price, tag) VALUES
(1, 7, 1,  'Essential Cotton Tee',      'Soft 100% organic cotton crew neck tee',                           29.99,  'basics'),
(2, 7, 4,  'Slim Fit Selvedge Denim',   'Japanese selvedge denim with slim taper fit',                      89.99,  'premium'),
(3, 7, 7,  'Waxed Canvas Jacket',       'Water-resistant waxed cotton field jacket',                        149.99, 'outerwear'),
(4, 6, 2,  'Silk Charmeuse Blouse',     'Luxe silk blouse with French seam detailing',                      120.00, 'luxury'),
(5, 6, 12, 'Gold Chain Layering Set',   'Set of 3 14k gold-plated layering chains',                         65.00,  'accessories'),
(6, 8, 1,  'Recycled Performance Tee',  'Made from 60% recycled polyester blend',                           35.00,  'sustainable'),
(7, 8, 5,  'Hemp Wide Leg Pant',        'Sustainable hemp blend wide leg trouser',                          78.00,  'sustainable'),
(8, 6, 13, 'Velvet Evening Clutch',     'Handcrafted velvet clutch with gold clasp',                        95.00,  'evening');

-- Product images (Unsplash)
SET SQL_SAFE_UPDATES = 0;
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1523381294911-8d3cead13475?w=600&q=80' WHERE product_ID = 1;
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1542060748-10c28b62716f?w=600&q=80' WHERE product_ID = 2;
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?w=600&q=80' WHERE product_ID = 3;
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&q=80' WHERE product_ID = 4;
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=600&q=80' WHERE product_ID = 5;
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=80' WHERE product_ID = 6;
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1608228088998-57828365d486?w=600&q=80' WHERE product_ID = 7;
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80' WHERE product_ID = 8;
SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- PRODUCT SIZES
-- Clothing (subcategory 1-9): S / M / L / XL
-- Shoes    (subcategory 10-11): 6-10
-- Accessories (subcategory 12-13): One Size
-- ============================================================

-- Clothing sizes
INSERT INTO PRODUCT_SIZE (product_ID, size)
SELECT p.product_ID, s.size
FROM PRODUCT p
CROSS JOIN (SELECT 'S' AS size UNION ALL SELECT 'M' UNION ALL SELECT 'L' UNION ALL SELECT 'XL') s
WHERE p.subcategory_ID BETWEEN 1 AND 9;

-- Shoe sizes
INSERT INTO PRODUCT_SIZE (product_ID, size)
SELECT p.product_ID, s.size
FROM PRODUCT p
CROSS JOIN (SELECT '6' AS size UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10') s
WHERE p.subcategory_ID IN (10, 11);

-- One Size (accessories)
INSERT INTO PRODUCT_SIZE (product_ID, size)
SELECT product_ID, 'One Size'
FROM PRODUCT
WHERE subcategory_ID IN (12, 13);

-- ============================================================
-- PRODUCT SEASONS
-- ============================================================
INSERT INTO PRODUCT_SEASON (product_ID, season) VALUES
(1, 'spring'),
(1, 'summer'),
(2, 'fall'),
(2, 'winter'),
(3, 'fall'),
(3, 'winter'),
(4, 'spring'),
(4, 'summer'),
(5, 'fall'),
(5, 'winter');

-- ============================================================
-- ACCESS LOG
-- ============================================================
INSERT INTO ACCESS_LOG (log_ID, user_ID, timestamp, IP_address, status, action_type) VALUES
(1,  1, '2025-11-01 08:15:00', '192.168.1.10',  'success', 'login'),
(2,  1, '2025-11-01 09:30:00', '192.168.1.10',  'success', 'logout'),
(3,  2, '2025-11-01 10:00:00', '10.0.0.55',     'success', 'login'),
(4,  3, '2025-11-01 10:05:00', '172.16.0.1',    'failed',  'login'),
(5,  3, '2025-11-01 10:06:00', '172.16.0.1',    'success', 'login'),
(6,  6, '2025-11-02 08:00:00', '203.0.113.42',  'success', 'login'),
(7,  9, '2025-11-02 09:00:00', '10.10.10.1',    'success', 'login'),
(8,  4, '2025-11-03 14:20:00', '198.51.100.7',  'failed',  'login'),
(9,  4, '2025-11-03 14:21:00', '198.51.100.7',  'failed',  'login'),
(10, 5, '2025-11-04 18:00:00', '192.0.2.99',    'success', 'login');

-- ============================================================
-- ORDERS
-- ============================================================
INSERT INTO `ORDER` (order_id, consumer_id, order_date, status, total_amount) VALUES
(1,  1, '2024-01-15 11:00:00', 'delivered',  159.98),
(2,  2, '2025-02-03 14:30:00', 'delivered',   89.99),
(3,  3, '2025-02-20 09:45:00', 'shipped',    179.98),
(4,  1, '2025-03-01 16:00:00', 'delivered',   54.99),
(5,  2, '2025-03-10 10:00:00', 'cancelled',   79.99),
(6,  3, '2026-03-22 13:15:00', 'processing', 289.97),
(7,  1, '2021-04-05 08:00:00', 'pending',    149.99),
(8,  2, '2025-04-12 17:45:00', 'delivered',  139.98),
(9,  3, '2022-05-01 12:00:00', 'shipped',     94.98),
(10, 1, '2025-05-18 15:30:00', 'returned',    74.99);

-- ============================================================
-- ORDER ITEMS
-- ============================================================
INSERT INTO ORDER_ITEM (order_id, line_num, product_id, quantity, unit_price) VALUES
(1,  1, 1, 1,  89.99),
(1,  2, 3, 1,  19.99),
(2,  1, 1, 1,  89.99),
(3,  1, 4, 1, 109.99),
(6,  1, 4, 1, 109.99),
(6,  2, 8, 2,  59.99),
(6,  3, 1, 1,  39.99),
(7,  1, 7, 1, 149.99),
(8,  1, 2, 1,  69.99),
(8,  2, 5, 1,  54.99),
(9,  1, 6, 1,  74.99),
(9,  2, 3, 1,  19.99),
(10, 1, 5, 1,  74.99);

-- ============================================================
-- REVIEWS
-- ============================================================
INSERT INTO REVIEW (review_id, consumer_id, product_id, rating, review_text, review_date) VALUES
(1, 1, 1, 5, 'Absolutely love this dress! The fabric is so light and the print is beautiful.',    '2025-01-20 10:00:00'),
(2, 2, 1, 4, 'Great quality for the price. Runs slightly small so size up.',                      '2025-02-10 14:00:00'),
(3, 3, 4, 5, 'This blazer is incredibly versatile. Wear it to the office and dinner!',            '2025-03-01 09:00:00'),
(4, 1, 5, 3, 'Nice shirt but the colour faded after two washes. Disappointing.',                  '2025-03-05 11:00:00'),
(5, 2, 6, 4, 'Classic denim jacket. Good fit and sturdy stitching.',                              '2025-04-15 16:00:00'),
(6, 3, 8, 5, 'Best jeans I have owned. The dark wash is perfect and the fit is immaculate.',      '2025-03-25 08:30:00'),
(7, 1, 4, 4, 'Very cosy cardigan. The camel colour goes with everything.',                        '2025-05-22 13:00:00'),
(8, 2, 2, 3, 'Trousers look great but the waistband is not very comfortable after long wear.',    '2025-04-18 15:00:00'),
(9, 3, 3, 4, 'Perfect basic crop top. Washes well and stays in shape.',                           '2025-05-05 10:45:00');
-- Note: review_id 10 was deleted (violated community guidelines)

-- ============================================================
-- STOCKS
-- ============================================================
INSERT INTO STOCKS (retailer_id, product_id, stock_quantity, restock_threshold, last_updated) VALUES
(6, 1, 120, 20, '2025-05-01 00:00:00'),
(6, 2,  45, 15, '2025-05-01 00:00:00'),
(6, 5,  80, 25, '2025-05-01 00:00:00'),
(6, 7,  30, 10, '2025-05-01 00:00:00'),
(8, 7,   8, 15, '2025-05-10 00:00:00'),
(7, 3, 200, 50, '2025-05-01 00:00:00'),
(7, 4,  55, 20, '2025-05-01 00:00:00'),
(7, 6,  12, 20, '2025-05-08 00:00:00'),
(8, 8,  95, 30, '2025-05-01 00:00:00'),
(8, 1, 150, 40, '2025-05-01 00:00:00');

-- ============================================================
-- DML OPERATIONS (Updates / Deletes)
-- ============================================================

SET SQL_SAFE_UPDATES = 0;

-- Customer requests an extra unit on an existing line item
UPDATE ORDER_ITEM
SET quantity = quantity + 1
WHERE order_id = 4 AND line_num = 1;

-- Restock after a delivery arrives
UPDATE STOCKS
SET stock_quantity = stock_quantity + 60,
    last_updated   = NOW()
WHERE retailer_id = 7 AND product_id = 3;

SET SQL_SAFE_UPDATES = 1;



SET SQL_SAFE_UPDATES = 0;

UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&q=80' WHERE item_ID = 1;  -- wide leg jeans
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600&q=80' WHERE item_ID = 2;  -- white tshirt
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1566206091558-7f218b696731?w=600&q=80' WHERE item_ID = 3;  -- black mini dress
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=80' WHERE item_ID = 4;  -- black blazer
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600&q=80' WHERE item_ID = 5;  -- floral maxi dress
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=600&q=80' WHERE item_ID = 6;  -- gray puffer coat
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1604176354204-9268737828e4?w=600&q=80' WHERE item_ID = 7;  -- gray sweater
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1614676471928-2ed0ad1061a4?w=600&q=80' WHERE item_ID = 8;  -- black midi skirt
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&q=80' WHERE item_ID = 9;  -- white blouse
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80' WHERE item_ID = 10; -- blue dress
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=600&q=80' WHERE item_ID = 11; -- black trousers
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80' WHERE item_ID = 12; -- white sneakers
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&q=80' WHERE item_ID = 13; -- black sandals
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=600&q=80' WHERE item_ID = 14; -- gold necklace
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80' WHERE item_ID = 15; -- black shoulder bag
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&q=80' WHERE item_ID = 16; -- black leather jacket
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&q=80' WHERE item_ID = 17; -- red sandals
UPDATE CLOTHING_ITEM SET image_url = 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80' WHERE item_ID = 18; -- gray sneakers

SET SQL_SAFE_UPDATES = 1;

COMMIT;
