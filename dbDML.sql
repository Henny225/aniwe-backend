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

COMMIT;
