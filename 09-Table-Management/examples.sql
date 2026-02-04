-- Table Management Lab - SQL Examples
-- This file contains comprehensive examples of table management operations in MySQL

-- ===========================================
-- DATABASE SETUP
-- ===========================================

CREATE DATABASE IF NOT EXISTS table_management_lab;
USE table_management_lab;

-- ===========================================
-- BASIC TABLE CREATION
-- ===========================================

-- Example 1: Basic table creation with common data types
CREATE TABLE users (
    user_id INT,
    username VARCHAR(50),
    email VARCHAR(100),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Example 2: Table with constraints
CREATE TABLE products (
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_name),
    PRIMARY KEY (product_id)
);

-- Example 3: Table with foreign key relationships
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    shipping_address TEXT,
    FOREIGN KEY (customer_id) REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Example 4: Table with various indexes
CREATE TABLE articles (
    article_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    author_id INT,
    published_date DATE,
    view_count INT DEFAULT 0,
    tags VARCHAR(500),
    INDEX idx_author (author_id),
    INDEX idx_published (published_date),
    INDEX idx_title (title(50)),
    FULLTEXT INDEX idx_content (content),
    FOREIGN KEY (author_id) REFERENCES users(user_id)
);

-- ===========================================
-- TABLE OPTIONS AND STORAGE ENGINES
-- ===========================================

-- Example 5: Table with specific options
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action VARCHAR(20) NOT NULL,
    old_values JSON,
    new_values JSON,
    user_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_timestamp (timestamp)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  AUTO_INCREMENT = 1;

-- Example 6: Temporary table
CREATE TEMPORARY TABLE temp_user_stats (
    user_id INT PRIMARY KEY,
    login_count INT DEFAULT 0,
    last_login TIMESTAMP,
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(10, 2) DEFAULT 0.00
);

-- Example 7: Table with partitioning (MySQL 8.0+)
CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8, 2) NOT NULL,
    total_amount DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    INDEX idx_sale_date (sale_date),
    INDEX idx_product (product_id)
) PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- ===========================================
-- ALTER TABLE OPERATIONS
-- ===========================================

-- Example 8: Add single column
ALTER TABLE users
ADD COLUMN phone VARCHAR(20);

-- Example 9: Add multiple columns
ALTER TABLE users
ADD COLUMN middle_name VARCHAR(50),
ADD COLUMN profile_picture VARCHAR(255),
ADD COLUMN last_login TIMESTAMP;

-- Example 10: Add column with constraints
ALTER TABLE products
ADD COLUMN sku VARCHAR(50) UNIQUE NOT NULL DEFAULT 'TBD';

-- Example 11: Modify column data type
ALTER TABLE users
MODIFY COLUMN phone VARCHAR(25);

-- Example 12: Modify column with constraints
ALTER TABLE users
MODIFY COLUMN email VARCHAR(150) NOT NULL UNIQUE;

-- Example 13: Change column name and type
ALTER TABLE users
CHANGE COLUMN date_of_birth birth_date DATE NOT NULL;

-- Example 14: Drop column
ALTER TABLE users
DROP COLUMN middle_name;

-- Example 15: Drop multiple columns
ALTER TABLE articles
DROP COLUMN tags,
DROP COLUMN view_count;

-- ===========================================
-- CONSTRAINT MANAGEMENT
-- ===========================================

-- Example 16: Add primary key to existing table
CREATE TABLE temp_table (
    id INT,
    name VARCHAR(100)
);

ALTER TABLE temp_table
ADD PRIMARY KEY (id);

-- Example 17: Add foreign key constraint
ALTER TABLE products
ADD CONSTRAINT fk_products_category
FOREIGN KEY (category_id) REFERENCES categories(category_id);

-- Example 18: Add unique constraint
ALTER TABLE users
ADD CONSTRAINT uk_users_email UNIQUE (email);

-- Example 19: Add check constraint
ALTER TABLE products
ADD CONSTRAINT chk_positive_price CHECK (price > 0);

-- Example 20: Add composite primary key
CREATE TABLE user_permissions (
    user_id INT,
    permission_id INT,
    granted_by INT,
    granted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE user_permissions
ADD PRIMARY KEY (user_id, permission_id);

-- Example 21: Drop constraint
ALTER TABLE users
DROP CONSTRAINT uk_users_email;

-- Example 22: Drop foreign key
ALTER TABLE products
DROP FOREIGN KEY fk_products_category;

-- Example 23: Drop primary key
ALTER TABLE temp_table
DROP PRIMARY KEY;

-- ===========================================
-- INDEX MANAGEMENT
-- ===========================================

-- Example 24: Add various types of indexes
ALTER TABLE orders
ADD INDEX idx_customer_date (customer_id, order_date),
ADD INDEX idx_status (status),
ADD FULLTEXT INDEX idx_shipping (shipping_address);

-- Example 25: Add unique index
ALTER TABLE products
ADD UNIQUE INDEX uk_sku (sku);

-- Example 26: Drop index
ALTER TABLE orders
DROP INDEX idx_status;

-- Example 27: Rename index (MySQL 8.0+)
ALTER TABLE orders
RENAME INDEX idx_customer_date TO idx_customer_order_date;

-- ===========================================
-- TABLE RENAMING AND DROPPING
-- ===========================================

-- Example 28: Rename table
ALTER TABLE temp_table
RENAME TO archived_data;

-- Example 29: Rename using RENAME TABLE
RENAME TABLE archived_data TO old_temp_data;

-- Example 30: Drop table
DROP TABLE old_temp_data;

-- Example 31: Drop table with CASCADE (removes dependent objects)
-- DROP TABLE users CASCADE;  -- Be very careful with this!

-- Example 32: Drop table if exists
DROP TABLE IF EXISTS non_existent_table;

-- ===========================================
-- TABLE MAINTENANCE OPERATIONS
-- ===========================================

-- Example 33: Analyze table (update statistics)
ANALYZE TABLE orders;

-- Example 34: Optimize table (rebuild and defragment)
OPTIMIZE TABLE products;

-- Example 35: Repair table (fix corruption)
REPAIR TABLE articles;

-- Example 36: Check table (verify integrity)
CHECK TABLE users;

-- ===========================================
-- ADVANCED TABLE OPERATIONS
-- ===========================================

-- Example 37: Create table from SELECT (copy structure and data)
CREATE TABLE products_backup AS
SELECT * FROM products;

-- Example 38: Create table with specific structure
CREATE TABLE products_summary (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    total_sold INT DEFAULT 0,
    revenue DECIMAL(12, 2) DEFAULT 0.00
);

-- Example 39: Truncate table (remove all data but keep structure)
TRUNCATE TABLE temp_user_stats;

-- Example 40: Show table structure
DESCRIBE users;
-- or
SHOW CREATE TABLE users;

-- Example 41: Show table indexes
SHOW INDEXES FROM orders;

-- Example 42: Show table status
SHOW TABLE STATUS LIKE 'users';

-- ===========================================
-- BULK TABLE OPERATIONS
-- ===========================================

-- Example 43: Create multiple tables at once
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id INT,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

CREATE TABLE product_categories (
    product_id INT,
    category_id INT,
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Example 44: Add multiple constraints at once
ALTER TABLE categories
ADD INDEX idx_parent (parent_id),
ADD CONSTRAINT chk_category_name_length CHECK (LENGTH(category_name) >= 2);

-- ===========================================
-- SCHEMA MIGRATION PATTERNS
-- ===========================================

-- Example 45: Safe column addition with default
ALTER TABLE users
ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;

-- Update existing records
UPDATE users
SET email_verified = TRUE
WHERE email LIKE '%.com';

-- Then make it NOT NULL
ALTER TABLE users
MODIFY COLUMN email_verified BOOLEAN NOT NULL DEFAULT FALSE;

-- Example 46: Data migration during schema change
-- Add new column
ALTER TABLE products
ADD COLUMN price_usd DECIMAL(10, 2);

-- Migrate data (assuming exchange rate)
UPDATE products
SET price_usd = price * 1.0;  -- Assuming 1:1 conversion for demo

-- Make new column NOT NULL
ALTER TABLE products
MODIFY COLUMN price_usd DECIMAL(10, 2) NOT NULL;

-- Optionally drop old column later
-- ALTER TABLE products DROP COLUMN price;

-- ===========================================
-- PERFORMANCE CONSIDERATIONS
-- ===========================================

-- Example 47: Add indexes for performance
CREATE INDEX idx_orders_date_status ON orders(order_date, status);
CREATE INDEX idx_products_category_price ON products(category_id, price);

-- Example 48: Composite indexes for common queries
ALTER TABLE sales_data
ADD INDEX idx_product_customer_date (product_id, customer_id, sale_date);

-- Example 49: Covering index (includes all columns needed)
ALTER TABLE orders
ADD INDEX idx_customer_status_total (customer_id, status, total_amount);

-- ===========================================
-- CLEANUP AND RESET
-- ===========================================

-- Example 50: Safe database cleanup
-- DROP TABLE IF EXISTS sales_data;
-- DROP TABLE IF EXISTS product_categories;
-- DROP TABLE IF EXISTS categories;
-- DROP TABLE IF EXISTS products_backup;
-- DROP TABLE IF EXISTS products_summary;
-- DROP TABLE IF EXISTS user_permissions;
-- DROP TABLE IF EXISTS audit_log;
-- DROP TABLE IF EXISTS articles;
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS users;
-- DROP DATABASE IF EXISTS table_management_lab;