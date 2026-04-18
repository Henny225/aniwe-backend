-- 1. Create the database
CREATE DATABASE IF NOT EXISTS AniweDB;
USE AniweDB;

-- 2. Cleanup Section (Ensures a fresh start)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS CONSUMER_STYLE_PREFERENCE_LOG, STOCKS, REVIEW, ORDER_ITEM, `ORDER`,
                    ACCESS_LOG, PRODUCT_SEASON, PRODUCT_SIZE, PRODUCT, CONSISTS_OF, OUTFIT_SEASON,
                    OUTFIT_OCCASION, OUTFIT, CLOTHING_ITEM_COLOUR, CLOTHING_ITEM, 
                    SUBCATEGORY, CONSUMER_STYLE_PREFERENCES, ADMINISTRATOR, 
                    RETAIL_PARTNER, CONSUMER, USER;
DROP VIEW IF EXISTS vw_low_stock_alerts, vw_style_summary, vw_UserDirectory;
DROP TRIGGER IF EXISTS trg_stocks_decrement;
DROP TRIGGER IF EXISTS tr_AfterPreferenceInsert;
DROP FUNCTION IF EXISTS fn_average_product_rating;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------
-- TABLES (1-20)
-- -----------------------------------------------------

-- USER Table (Supertype)
CREATE TABLE USER (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(20),
    account_status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    account_type VARCHAR(20)
);

-- CONSUMER Table (Subtype of USER)
CREATE TABLE CONSUMER (
    consumer_ID INT PRIMARY KEY,
    street_address VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    -- Ensures if user_id changes or is deleted, the consumer record follows suit
    FOREIGN KEY (consumer_ID) REFERENCES USER(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- RETAIL_PARTNER Table (Subtype of USER)
CREATE TABLE RETAIL_PARTNER (
    retailer_ID INT PRIMARY KEY,
    brand_name VARCHAR(100),
    website_url VARCHAR(255),
    store_description TEXT,
    -- Maintains synchronization with the primary USER record
    FOREIGN KEY (retailer_ID) REFERENCES USER(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- ADMINISTRATOR Table (Subtype of USER)
CREATE TABLE ADMINISTRATOR (
    admin_ID INT PRIMARY KEY,
    admin_level VARCHAR(50),
    department VARCHAR(100),
    -- Protects integrity for administrative account links
    FOREIGN KEY (admin_ID) REFERENCES USER(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- CONSUMER_STYLE_PREFERENCES Table (Weak Entity/Attribute of CONSUMER)
CREATE TABLE CONSUMER_STYLE_PREFERENCES (
    consumer_ID INT,
    preference VARCHAR(100),
    -- Ensures preferences are removed if the consumer profile is deleted
    FOREIGN KEY (consumer_ID) REFERENCES CONSUMER(consumer_ID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

-- Log table for the style preference trigger
CREATE TABLE CONSUMER_STYLE_PREFERENCE_LOG (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    consumer_id INT,
    action_message VARCHAR(255),
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SUBCATEGORY Table
CREATE TABLE SUBCATEGORY (
    subcategory_ID INT PRIMARY KEY,
    subcategory_name VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- CLOTHING_ITEM Table
CREATE TABLE CLOTHING_ITEM (
    item_ID INT PRIMARY KEY AUTO_INCREMENT,
    consumer_ID INT NOT NULL,
    subcategory_ID INT,
    item_name VARCHAR(255) NOT NULL,
    brand VARCHAR(100),
    size VARCHAR(20),
    purchase_price DECIMAL(10,2),
    image_url VARCHAR(255),
    status VARCHAR(50) CHECK (status IN ('Active', 'Archived', 'Donated', 'Sold', 'Dirty', 'Laundry')),
    tag VARCHAR(100),
    FOREIGN KEY (consumer_ID) REFERENCES CONSUMER(consumer_ID) ON DELETE CASCADE,
    FOREIGN KEY (subcategory_ID) REFERENCES SUBCATEGORY(subcategory_ID) ON DELETE SET NULL
);

-- CLOTHING_ITEM_COLOUR Table
CREATE TABLE CLOTHING_ITEM_COLOUR (
    item_ID INT,
    colour VARCHAR(100),
    PRIMARY KEY (item_ID, colour),
    FOREIGN KEY (item_ID) REFERENCES CLOTHING_ITEM(item_ID) ON DELETE CASCADE
);

CREATE TABLE OUTFIT (
    outfit_ID INT PRIMARY KEY AUTO_INCREMENT,
    consumer_ID INT NOT NULL,
    outfit_name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT FALSE,
    times_worn INT DEFAULT 0,
    FOREIGN KEY (consumer_ID) REFERENCES CONSUMER(consumer_ID) ON DELETE CASCADE
);

-- OUTFIT_OCCASION Table (1NF decomposition — multivalued attribute)
CREATE TABLE OUTFIT_OCCASION (
    outfit_ID INT,
    occasion VARCHAR(100),
    PRIMARY KEY (outfit_ID, occasion),
    FOREIGN KEY (outfit_ID) REFERENCES OUTFIT(outfit_ID) ON DELETE CASCADE
);

CREATE TABLE OUTFIT_SEASON (
    outfit_ID INT,
    season VARCHAR(50),
    PRIMARY KEY (outfit_ID, season),
    FOREIGN KEY (outfit_ID) REFERENCES OUTFIT(outfit_ID) ON DELETE CASCADE
);

CREATE TABLE CONSISTS_OF (
    outfit_ID INT,
    item_ID INT,
    PRIMARY KEY (outfit_ID, item_ID),
    FOREIGN KEY (outfit_ID) REFERENCES OUTFIT(outfit_ID) ON DELETE CASCADE,
    FOREIGN KEY (item_ID) REFERENCES CLOTHING_ITEM(item_ID) ON DELETE CASCADE
);

CREATE TABLE PRODUCT (
    product_ID INT PRIMARY KEY AUTO_INCREMENT,
    retailer_ID INT NOT NULL,
    subcategory_ID INT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    tag VARCHAR(100),
    image_url VARCHAR(255),
    FOREIGN KEY (retailer_ID) REFERENCES RETAIL_PARTNER(retailer_ID) ON DELETE CASCADE,
    FOREIGN KEY (subcategory_ID) REFERENCES SUBCATEGORY(subcategory_ID) ON DELETE SET NULL
);

CREATE TABLE PRODUCT_SEASON (
    product_ID INT,
    season VARCHAR(50),
    PRIMARY KEY (product_ID, season),
    FOREIGN KEY (product_ID) REFERENCES PRODUCT(product_ID) ON DELETE CASCADE
);

CREATE TABLE PRODUCT_SIZE (
    product_ID INT,
    size VARCHAR(20),
    PRIMARY KEY (product_ID, size),
    FOREIGN KEY (product_ID) REFERENCES PRODUCT(product_ID) ON DELETE CASCADE
);

CREATE TABLE ACCESS_LOG (
    log_ID INT PRIMARY KEY AUTO_INCREMENT,
    user_ID INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IP_address VARCHAR(45),
    status VARCHAR(50),
    action_type VARCHAR(100),
    FOREIGN KEY (user_ID) REFERENCES USER(user_id) ON DELETE CASCADE
);

CREATE TABLE `ORDER` (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    consumer_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending','processing','shipped','delivered','cancelled','returned') DEFAULT 'pending',
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    FOREIGN KEY (consumer_id) REFERENCES CONSUMER(consumer_ID) ON DELETE RESTRICT
);

CREATE TABLE ORDER_ITEM (
    order_id INT NOT NULL,
    line_num INT NOT NULL,
    product_id INT NOT NULL,
    size VARCHAR(20) NOT NULL DEFAULT 'One Size',
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, line_num),
    FOREIGN KEY (order_id) REFERENCES `ORDER`(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_ID) ON DELETE RESTRICT
);

CREATE TABLE REVIEW (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    consumer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (consumer_id, product_id),
    FOREIGN KEY (consumer_id) REFERENCES CONSUMER(consumer_ID) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_ID) ON DELETE CASCADE
);

CREATE TABLE STOCKS (
    retailer_id INT NOT NULL,
    product_id INT NOT NULL,
    size VARCHAR(20) NOT NULL DEFAULT 'One Size',
    stock_quantity INT DEFAULT 0,
    restock_threshold INT DEFAULT 10,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (retailer_id, product_id, size),
    FOREIGN KEY (retailer_id) REFERENCES RETAIL_PARTNER(retailer_ID) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCT(product_ID) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- LOGIC: TRIGGERS
-- -----------------------------------------------------
DELIMITER //

CREATE TRIGGER tr_AfterPreferenceInsert
AFTER INSERT ON CONSUMER_STYLE_PREFERENCES
FOR EACH ROW
BEGIN
    INSERT INTO CONSUMER_STYLE_PREFERENCE_LOG (consumer_id, action_message)
    VALUES (NEW.consumer_ID, CONCAT('Preference added: ', NEW.preference));
END //

CREATE TRIGGER trg_stocks_decrement
AFTER INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE STOCKS s
    JOIN PRODUCT p ON p.product_ID = NEW.product_id
    SET s.stock_quantity = s.stock_quantity - NEW.quantity
    WHERE s.retailer_id = p.retailer_ID AND s.product_id = NEW.product_id AND s.size = NEW.size;
END //

DELIMITER ;

-- -----------------------------------------------------
-- LOGIC: VIEWS
-- -----------------------------------------------------

CREATE VIEW vw_UserDirectory AS
SELECT user_id, email, first_name, last_name, account_type FROM USER;

CREATE VIEW vw_style_summary AS
SELECT u.first_name, u.last_name, csp.preference
FROM USER u
JOIN CONSUMER_STYLE_PREFERENCES csp ON u.user_id = csp.consumer_ID;

-- -----------------------------------------------------
-- LOGIC: FUNCTIONS
-- -----------------------------------------------------
SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER //
CREATE FUNCTION fn_average_product_rating(p_product_id INT)
RETURNS DECIMAL(3,2)
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    SELECT ROUND(AVG(rating), 2) INTO avg_rating FROM REVIEW WHERE product_id = p_product_id;
    RETURN avg_rating;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS trg_stocks_decrement;

DELIMITER $$

CREATE TRIGGER trg_order_total_insert
AFTER INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE `ORDER`
    SET total_amount = (
        SELECT SUM(quantity * unit_price)
        FROM ORDER_ITEM
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$

CREATE TRIGGER trg_order_total_update
AFTER UPDATE ON ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE `ORDER`
    SET total_amount = (
        SELECT SUM(quantity * unit_price)
        FROM ORDER_ITEM
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$

CREATE TRIGGER trg_stocks_decrement
AFTER INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    UPDATE STOCKS s
    JOIN `ORDER` o ON o.order_id = NEW.order_id
    JOIN PRODUCT p ON p.product_id = NEW.product_id
    SET s.stock_quantity = s.stock_quantity - NEW.quantity,
        s.last_updated = CURRENT_TIMESTAMP
    WHERE s.retailer_id = p.retailer_id
      AND s.product_id = NEW.product_id
      AND s.stock_quantity >= NEW.quantity;
END$$

DELIMITER ;

SHOW TRIGGERS;


CREATE OR REPLACE VIEW vw_low_stock_alerts AS
SELECT
    s.retailer_id,
    rp.brand_name,
    s.product_id,
    p.name AS product_name,
    s.stock_quantity,
    s.restock_threshold,
    s.last_updated
FROM STOCKS s
JOIN RETAIL_PARTNER rp ON rp.retailer_id = s.retailer_id
JOIN PRODUCT p ON p.product_id = s.product_id
WHERE s.stock_quantity <= s.restock_threshold
ORDER BY s.stock_quantity ASC;
