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

-- Populate the CLOTHING_ITEM Table
INSERT INTO CLOTHING_ITEM (item_ID, consumer_ID, subcategory_ID, item_name, brand, size, purchase_price, image_url, status, tag) VALUES
(1, 5, 4, 'Wide leg jeans', 'Levis', '31', 50.50, 'www.aws.com/jeans.png', 'Laundry', 'Basic'),
(2, 1, 1, 'White tshirt', 'Uniqlo', 'small', 19.90, 'www.aws.com/whitetshirt.png', 'Dirty', 'Basic'),
(3, 1, 9, 'Black going out mini dress', 'Zara', 'small', 35.00, 'www.aws.com/blackminidress.png', 'Active', 'Edgy'),
(4, 1, 7, 'Black blazer', 'Zara', 'small', 69.90, 'www.aws.com/blackblazer.png', 'Active', 'Chic'),
(5, 3, 9, 'Floral maxi dress', 'Anthropologie', '8', 84.00, 'www.aws.com/floralmaxidress.png', 'Active', 'Boho'),
(6, 5, 8, 'Gray puffer coat', 'Aritzia', 'large', 157.50, 'www.aws.com/graypuffercoat.png', 'Active', 'Basic'),
(7, 5, 3, 'Gray cable knit sweater', 'J.Crew', 'large', 64.00, 'www.aws.com/graycableknitsweater.png', 'Active', 'Classic'),
(8, 1, 6, 'Black pleated midi skirt', 'Aritzia', '4', 60.00, 'www.aws.com/blackpleatedmidiskirt.png', 'Active', 'Elegant'),
(9, 1, 2, 'White long sleeve tie neck blouse', 'Ann Taylor', 'small', 35.00, 'www.aws.com/whitetieneckblouse.png', 'Active', 'Formal'),
(10, 3, 9, 'Blue short sleeve dress', 'Old Navy', '6', 24.50, 'www.aws.com/blueshortsleevedress.png', 'Active', 'Casual'),
(11, 1, 5, 'Black tailored trousers', 'Gap', '4', 39.50, 'www.aws.com/blacktrousers.png', 'Active', 'Formal'),
(12, 1, 10, 'White sneakers', 'Adidas', '7', 44.50, 'www.aws.com/whitesneakers.png', 'Active', 'Sporty'),
(13, 1, 11, 'Black low heel sandals', 'Sam Edelman', '7', 95.00, 'www.aws.com/blacksandals.png', 'Active', 'Chic'),
(14, 3, 12, 'Gold chain necklace', 'Mejuri', 'OS', 150.00, 'www.aws.com/goldchainnecklace.png', 'Active', 'Classic'),
(15, 5, 12, 'Black leather shoulder bag', 'Coach', 'OS', 225.00, 'www.aws.com/blackshoulderbag.png', 'Active', 'Minimal'),
(16, 3, 7, 'Black leather jacket', 'All Saints', 'medium', 549.00, 'www.aws.com/blackleatherjacket.png', 'Active', 'Edgy'),
(17, 3, 11, 'Red strappy sandals', 'Madewell', '8', 55.00, 'www.aws.com/redsandals.png', 'Active', 'Casual'),
(18, 5, 10, 'Gray sneakers', 'New Balance', '8', 105.00, 'www.aws.com/graysneakers.png', 'Active', 'Sporty');

-- Populate the CLOTHING_ITEM_COLOUR Table
INSERT INTO CLOTHING_ITEM_COLOUR (item_ID, colour) VALUES
(1, 'Blue'),
(2, 'White'),
(3, 'Black'),
(4, 'Black'),
(5, 'Red'),
(5, 'Pink'),
(6, 'Gray'),
(7, 'Gray'),
(8, 'Black'),
(9, 'White'),
(10, 'Blue'),
(11, 'Black'),
(12, 'White'),
(13, 'Black'),
(14, 'Gold'),
(15, 'Black'),
(16, 'Black'),
(17, 'Red'),
(18, 'Gray');

-- Populate the OUTFIT Table
INSERT INTO OUTFIT (outfit_ID, consumer_ID, outfit_name, created_at, is_public, times_worn) VALUES
(1,  1, 'Minimalist Monochrome',      '2026-04-01 12:00:00', TRUE,  4),
(2,  1, 'Chic Office Look',           '2026-04-02 14:00:00', TRUE,  2),
(3,  1, 'All-Black Night Out',        '2026-04-01 18:00:00', FALSE, 1),
(4,  2, 'Sporty Weekend Brunch',      '2026-04-02 10:00:00', TRUE,  3),
(5,  2, 'Casual Streetwear Fit',      '2025-10-20 08:00:00', FALSE, 5),
(6,  3, 'Boho-Chic Summer Day',       '2025-09-01 09:00:00', TRUE,  2),
(7,  3, 'Eclectic Garden Party',      '2025-10-15 11:00:00', TRUE,  1),
(8,  4, 'Formal Monochrome Set',      '2026-03-30 16:00:00', TRUE,  3),
(9,  4, 'Chic Dinner Look',           '2025-11-01 07:30:00', FALSE, 6),
(10, 5, 'Androgynous Winter Layers',  '2025-11-15 13:00:00', TRUE,  2);

-- Populate the OUTFIT_OCCASION Table
INSERT INTO OUTFIT_OCCASION (outfit_ID, occasion) VALUES
(1,  'casual hangout'),
(1,  'coffee run'),
(2,  'work'),
(2,  'happy hour'),
(3,  'date night'),
(4,  'brunch'),
(5,  'streetwear meetup'),
(6,  'festival'),
(6,  'vacation'),
(7,  'garden party'),
(7, 'wedding guest'),
(8, 'wedding guest');

-- Populate the OUTFIT_SEASON Table
INSERT INTO OUTFIT_SEASON (outfit_ID, season) VALUES
(1,  'fall'),
(1,  'spring'),
(2,  'fall'),
(2,  'winter'),
(2,  'spring'),
(3,  'winter'),
(4,  'spring'),
(5,  'fall'),
(5,  'winter'),
(6,  'summer'),
(8,  'winter');

-- Populate the CONSISTS_OF Table
INSERT INTO CONSISTS_OF (outfit_ID, item_ID) VALUES
(1, 4),
(1, 11),
(1, 12),
(2, 8),
(2, 9),
(2, 13),
(6, 5),
(6, 14),
(6, 17),
(7, 10),
(7, 16),
(10, 6),
(10, 7),
(10, 1),
(10, 18);


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

-- ============================================================
-- PRODUCT IMAGES (Unsplash — free, no attribution required)
-- ============================================================
-- Velvet Vibe Designs (retailer_ID = 6)
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80' WHERE name = 'Satin Evening Gown';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600&q=80' WHERE name = 'Lace Cocktail Dress';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&q=80' WHERE name = 'Silk Wrap Blouse';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=600&q=80' WHERE name = 'Cashmere Wrap Coat';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1544441893-675973e31985?w=600&q=80' WHERE name = 'Velvet Blazer';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80' WHERE name = 'Structured Leather Tote';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=600&q=80' WHERE name = 'Pearl Drop Earrings';

-- Urban Threads Co. (retailer_ID = 7)
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1523381294911-8d3cead13475?w=600&q=80' WHERE name = 'Graphic Oversized Tee';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1542060748-10c28b62716f?w=600&q=80' WHERE name = 'High-Rise Skinny Jeans';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=600&q=80' WHERE name = 'Wide-Leg Cargo Pants';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?w=600&q=80' WHERE name = 'Denim Bomber Jacket';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1604176354204-9268737828e4?w=600&q=80' WHERE name = 'Ribbed Turtleneck Sweater';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1614676471928-2ed0ad1061a4?w=600&q=80' WHERE name = 'Pleated Mini Skirt';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600&q=80' WHERE name = 'Platform Chunky Sneakers';

-- Starlit Style Collective (retailer_ID = 8)
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=600&q=80' WHERE name = 'Organic Cotton Tee';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=600&q=80' WHERE name = 'Recycled Fleece Pullover';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1608228088998-57828365d486?w=600&q=80' WHERE name = 'Yoga Wide-Leg Pants';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=600&q=80' WHERE name = 'Bamboo Lounge Dress';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1571513722275-4b41940f54b8?w=600&q=80' WHERE name = 'Low-Top Canvas Sneakers';
UPDATE PRODUCT SET image_url = 'https://images.unsplash.com/photo-1583744946564-b52ac1c389c8?w=600&q=80' WHERE name = 'Woven Crossbody Bag';


COMMIT;
