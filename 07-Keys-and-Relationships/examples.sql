-- Keys and Relationships Lab - SQL Examples
-- This file contains practical SQL examples for implementing keys and relationships in MySQL

-- ===========================================
-- DATABASE SETUP
-- ===========================================

-- Create practice database
CREATE DATABASE IF NOT EXISTS keys_lab;
USE keys_lab;

-- ===========================================
-- PRIMARY KEY EXAMPLES
-- ===========================================

-- Example 1: Single-column primary key
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

-- Example 2: Auto-increment primary key
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Example 3: Composite primary key
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

-- ===========================================
-- UNIQUE KEY EXAMPLES
-- ===========================================

-- Example 4: Unique constraints
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_code VARCHAR(10) UNIQUE,  -- Unique employee code
    email VARCHAR(100) UNIQUE,         -- Unique email address
    ssn VARCHAR(11) UNIQUE,           -- Unique social security number
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

-- Example 5: Multiple unique constraints
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

-- ===========================================
-- FOREIGN KEY EXAMPLES
-- ===========================================

-- Example 6: Basic foreign key relationship
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered') DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Example 7: Foreign key with different actions
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Example 8: Multiple foreign keys in one table
CREATE TABLE product_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

-- ===========================================
-- RELATIONSHIP TYPES EXAMPLES
-- ===========================================

-- Example 9: One-to-One relationship
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,
    date_of_birth DATE,
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    bio TEXT,
    profile_picture VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- Example 10: One-to-Many relationship (already shown above)
-- orders table has many order_items (one-to-many)
-- categories can have many products (one-to-many)

-- Example 11: Many-to-Many relationship
CREATE TABLE product_categories (
    product_id INT,
    category_id INT,
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE CASCADE
);

-- ===========================================
-- INSERTING SAMPLE DATA
-- ===========================================

-- Insert customers
INSERT INTO customers (customer_id, first_name, last_name, email, phone) VALUES
(1, 'John', 'Doe', 'john.doe@email.com', '555-0101'),
(2, 'Jane', 'Smith', 'jane.smith@email.com', '555-0102'),
(3, 'Bob', 'Johnson', 'bob.johnson@email.com', '555-0103');

-- Insert products
INSERT INTO products (product_name, description, price, stock_quantity) VALUES
('Laptop', 'High-performance laptop', 1299.99, 50),
('Mouse', 'Wireless optical mouse', 29.99, 200),
('Keyboard', 'Mechanical keyboard', 89.99, 100),
('Monitor', '27-inch 4K monitor', 399.99, 30);

-- Insert categories
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Computers', 'Computer hardware and software'),
('Accessories', 'Computer accessories');

-- Update categories with parent relationships
UPDATE categories SET parent_category_id = 1 WHERE category_id = 2; -- Computers under Electronics
UPDATE categories SET parent_category_id = 1 WHERE category_id = 3; -- Accessories under Electronics

-- Insert orders
INSERT INTO orders (customer_id, total_amount, status) VALUES
(1, 1329.98, 'processing'),
(2, 29.99, 'shipped'),
(3, 489.98, 'pending');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1299.99),  -- Laptop in order 1
(1, 2, 1, 29.99),    -- Mouse in order 1
(2, 2, 1, 29.99),    -- Mouse in order 2
(3, 3, 1, 89.99),    -- Keyboard in order 3
(3, 4, 1, 399.99);   -- Monitor in order 3

-- Insert product categories
INSERT INTO product_categories (product_id, category_id) VALUES
(1, 2),  -- Laptop in Computers
(2, 3),  -- Mouse in Accessories
(3, 3),  -- Keyboard in Accessories
(4, 2);  -- Monitor in Computers

-- ===========================================
-- QUERYING WITH JOINS
-- ===========================================

-- Example 12: INNER JOIN - Get all orders with customer details
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.order_date,
    o.total_amount,
    o.status
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- Example 13: LEFT JOIN - Get all products with their categories
SELECT
    p.product_name,
    c.category_name,
    p.price,
    p.stock_quantity
FROM products p
LEFT JOIN product_categories pc ON p.product_id = pc.product_id
LEFT JOIN categories c ON pc.category_id = c.category_id
ORDER BY p.product_name;

-- Example 14: Multiple JOINs - Complete order details
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id, p.product_name;

-- Example 15: Self-JOIN - Category hierarchy
SELECT
    child.category_name AS subcategory,
    parent.category_name AS parent_category
FROM categories child
LEFT JOIN categories parent ON child.parent_category_id = parent.category_id
ORDER BY parent.category_name, child.category_name;

-- ===========================================
-- CONSTRAINT TESTING
-- ===========================================

-- Example 16: Test primary key violation (will fail)
-- INSERT INTO customers (customer_id, first_name, last_name) VALUES (1, 'Duplicate', 'Customer');

-- Example 17: Test unique constraint violation (will fail)
-- INSERT INTO customers (customer_id, first_name, last_name, email) VALUES (4, 'Test', 'User', 'john.doe@email.com');

-- Example 18: Test foreign key violation (will fail)
-- INSERT INTO orders (customer_id, total_amount) VALUES (999, 100.00);

-- Example 19: Test CHECK constraint violation (will fail)
-- INSERT INTO product_reviews (product_id, customer_id, rating, review_text) VALUES (1, 1, 6, 'Great!');

-- ===========================================
-- CASCADE ACTIONS DEMONSTRATION
-- ===========================================

-- Example 20: Create table with CASCADE DELETE
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    action VARCHAR(50) NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);

-- Insert audit records
INSERT INTO audit_log (customer_id, action, details) VALUES
(1, 'LOGIN', 'User logged in from web browser'),
(2, 'PURCHASE', 'Made a purchase order #1'),
(3, 'UPDATE_PROFILE', 'Updated shipping address');

-- Show CASCADE effect (conceptual - don't run DELETE)
-- If we ran: DELETE FROM customers WHERE customer_id = 1;
-- This would automatically delete:
-- - All orders for customer 1
-- - All order_items for those orders
-- - All product_reviews by customer 1
-- - All audit_log entries for customer 1

-- ===========================================
-- INDEXING FOREIGN KEYS
-- ===========================================

-- Example 21: Create indexes on foreign keys for better performance
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_product_categories_product_id ON product_categories(product_id);
CREATE INDEX idx_product_categories_category_id ON product_categories(category_id);

-- ===========================================
-- USEFUL QUERIES FOR ANALYSIS
-- ===========================================

-- Example 22: Count orders per customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Example 23: Best-selling products
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sold DESC;

-- Example 24: Category performance
SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id) AS products_in_category,
    COUNT(oi.product_id) AS items_sold,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM categories c
LEFT JOIN product_categories pc ON c.category_id = pc.category_id
LEFT JOIN products p ON pc.product_id = p.product_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;

-- ===========================================
-- CLEANUP (Optional - run to reset database)
-- ===========================================

-- DROP TABLE IF EXISTS audit_log;
-- DROP TABLE IF EXISTS product_reviews;
-- DROP TABLE IF EXISTS product_categories;
-- DROP TABLE IF EXISTS order_items;
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS categories;
-- DROP TABLE IF EXISTS customers;
-- DROP DATABASE IF EXISTS keys_lab;