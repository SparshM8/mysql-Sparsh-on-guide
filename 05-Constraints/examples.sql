-- MySQL Constraints Examples

-- Create database for constraints practice
CREATE DATABASE constraints_practice;
USE constraints_practice;

-- Example 1: NOT NULL constraint
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Example 2: UNIQUE constraint
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL
);

-- Example 3: PRIMARY KEY constraint
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2)
);

-- Example 4: FOREIGN KEY constraint
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Example 5: CHECK constraint
CREATE TABLE inventory (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    quantity INT,
    price DECIMAL(10, 2),
    CHECK (quantity >= 0),
    CHECK (price >= 0)
);

-- Example 6: DEFAULT constraint
CREATE TABLE logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Example 7: AUTO_INCREMENT
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Insert sample data
INSERT INTO users (user_id, name, email) VALUES
(1, 'John Doe', 'john@example.com'),
(2, 'Jane Smith', 'jane@example.com');

INSERT INTO employees (employee_id, email, name) VALUES
(1, 'emp1@company.com', 'Alice Johnson'),
(2, 'emp2@company.com', 'Bob Wilson');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Laptop', 999.99),
(2, 'Mouse', 25.99);

INSERT INTO orders (order_id, user_id, order_date) VALUES
(1, 1, '2024-01-15'),
(2, 2, '2024-01-16');

INSERT INTO inventory (item_id, item_name, quantity, price) VALUES
(1, 'Widget A', 100, 10.99),
(2, 'Widget B', 50, 15.99);

INSERT INTO logs (message) VALUES ('System started');
INSERT INTO logs (message) VALUES ('User logged in');

INSERT INTO categories (category_name) VALUES ('Electronics');
INSERT INTO categories (category_name) VALUES ('Books');

-- Query to see the data
SELECT * FROM users;
SELECT * FROM employees;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM inventory;
SELECT * FROM logs;
SELECT * FROM categories;

-- Clean up
-- DROP DATABASE constraints_practice;