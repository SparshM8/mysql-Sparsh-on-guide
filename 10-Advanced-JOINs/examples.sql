-- Lab 10: Advanced JOINs and Set Operations
-- Comprehensive SQL examples for all JOIN types and set operations

-- ===========================================
-- SETUP: Create sample database and tables
-- ===========================================

-- Create database
CREATE DATABASE IF NOT EXISTS advanced_joins_db;
USE advanced_joins_db;

-- Create users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    department_id INT,
    manager_id INT,
    email VARCHAR(100),
    hire_date DATE
);

-- Create departments table
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    location VARCHAR(50),
    budget DECIMAL(10,2)
);

-- Create orders table
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_name VARCHAR(100),
    amount DECIMAL(10,2),
    order_date DATE,
    status ENUM('pending', 'shipped', 'delivered', 'cancelled'),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create archived_orders table for UNION examples
CREATE TABLE archived_orders (
    id INT PRIMARY KEY,
    user_id INT,
    product_name VARCHAR(100),
    amount DECIMAL(10,2),
    archived_date DATE
);

-- Insert sample data
INSERT INTO departments (name, location, budget) VALUES
('IT', 'Floor 1', 500000.00),
('HR', 'Floor 2', 300000.00),
('Sales', 'Floor 3', 400000.00),
('Marketing', 'Floor 4', 350000.00);

INSERT INTO users (name, department_id, email, hire_date) VALUES
('Aarav', 1, 'aarav@company.com', '2023-01-15'),
('Sneha', 2, 'sneha@company.com', '2023-02-20'),
('Raj', 3, 'raj@company.com', '2023-03-10'),
('Priya', 1, 'priya@company.com', '2023-04-05'),
('Vikram', 3, 'vikram@company.com', '2023-05-12'),
('Anjali', 4, 'anjali@company.com', '2023-06-18');

-- Set up manager hierarchy
UPDATE users SET manager_id = 1 WHERE id IN (2, 3);  -- Aarav is manager for Sneha and Raj
UPDATE users SET manager_id = 2 WHERE id = 4;        -- Sneha is manager for Priya
UPDATE users SET manager_id = 3 WHERE id = 5;        -- Raj is manager for Vikram

INSERT INTO orders (user_id, product_name, amount, order_date, status) VALUES
(1, 'Laptop', 1200.00, '2024-01-15', 'delivered'),
(1, 'Mouse', 25.00, '2024-01-16', 'delivered'),
(2, 'Keyboard', 75.00, '2024-01-20', 'shipped'),
(3, 'Monitor', 300.00, '2024-01-25', 'delivered'),
(4, 'Headphones', 150.00, '2024-02-01', 'pending'),
(1, 'Webcam', 80.00, '2024-02-05', 'shipped'),
(5, 'Printer', 250.00, '2024-02-10', 'delivered'),
(2, 'USB Drive', 15.00, '2024-02-12', 'delivered');

INSERT INTO archived_orders VALUES
(1, 1, 'Old Laptop', 800.00, '2023-01-15'),
(2, 2, 'Old Keyboard', 50.00, '2023-02-20'),
(3, 3, 'Old Monitor', 200.00, '2023-03-10');

-- ===========================================
-- INNER JOIN Examples
-- ===========================================

-- Basic INNER JOIN: Users with their departments
SELECT u.name, d.name as department, d.location
FROM users u
INNER JOIN departments d ON u.department_id = d.id;

-- INNER JOIN with multiple tables: Complete order information
SELECT u.name, d.name as department, o.product_name, o.amount, o.order_date
FROM users u
INNER JOIN departments d ON u.department_id = d.id
INNER JOIN orders o ON u.id = o.user_id;

-- INNER JOIN with conditions
SELECT u.name, o.product_name, o.amount
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE o.amount > 100
ORDER BY o.amount DESC;

-- ===========================================
-- LEFT JOIN Examples
-- ===========================================

-- LEFT JOIN: All users, even those without orders
SELECT u.name, u.email, o.product_name, o.amount, o.status
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
ORDER BY u.name;

-- LEFT JOIN with aggregation: Order statistics per user
SELECT
    u.name,
    COUNT(o.id) as order_count,
    COALESCE(SUM(o.amount), 0) as total_spent,
    COALESCE(AVG(o.amount), 0) as avg_order_amount
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC;

-- LEFT JOIN with multiple tables
SELECT
    u.name,
    d.name as department,
    COUNT(o.id) as order_count,
    COALESCE(SUM(o.amount), 0) as total_amount
FROM users u
LEFT JOIN departments d ON u.department_id = d.id
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, d.name
ORDER BY total_amount DESC;

-- ===========================================
-- RIGHT JOIN Examples
-- ===========================================

-- RIGHT JOIN: All departments, even those without users
SELECT d.name as department, d.location, u.name as employee
FROM users u
RIGHT JOIN departments d ON u.department_id = d.id
ORDER BY d.name;

-- RIGHT JOIN with aggregation: Department statistics
SELECT
    d.name as department,
    d.location,
    COUNT(u.id) as employee_count,
    COALESCE(SUM(o.amount), 0) as total_order_amount
FROM departments d
RIGHT JOIN users u ON d.id = u.department_id
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY d.id, d.name, d.location;

-- ===========================================
-- FULL JOIN Simulation (MySQL doesn't support FULL JOIN directly)
-- ===========================================

-- Simulate FULL JOIN using UNION of LEFT and RIGHT JOINs
SELECT u.name as user_name, d.name as department_name
FROM users u
LEFT JOIN departments d ON u.department_id = d.id
UNION
SELECT u.name as user_name, d.name as department_name
FROM users u
RIGHT JOIN departments d ON u.department_id = d.id
WHERE u.id IS NULL;

-- ===========================================
-- CROSS JOIN Examples
-- ===========================================

-- CROSS JOIN: Cartesian product (use carefully!)
SELECT u.name, d.name as department
FROM users u
CROSS JOIN departments d
ORDER BY u.name, d.name;

-- CROSS JOIN with filtering (more practical)
SELECT u.name, d.name as department
FROM users u
CROSS JOIN departments d
WHERE d.budget > 350000
ORDER BY u.name;

-- ===========================================
-- SELF JOIN Examples
-- ===========================================

-- SELF JOIN: Employee-manager relationships
SELECT
    e.name as employee,
    m.name as manager
FROM users e
LEFT JOIN users m ON e.manager_id = m.id
ORDER BY m.name, e.name;

-- SELF JOIN: Find employees with same manager
SELECT
    e1.name as employee1,
    e2.name as employee2,
    m.name as manager
FROM users e1
JOIN users e2 ON e1.manager_id = e2.manager_id AND e1.id < e2.id
JOIN users m ON e1.manager_id = m.id;

-- SELF JOIN with hierarchy levels
SELECT
    e.name as employee,
    m.name as manager,
    CASE
        WHEN m.manager_id IS NOT NULL THEN 'Mid-level'
        ELSE 'Top-level'
    END as hierarchy_level
FROM users e
LEFT JOIN users m ON e.manager_id = m.id;

-- ===========================================
-- UNION and UNION ALL Examples
-- ===========================================

-- UNION: Combine current and archived orders (removes duplicates)
SELECT product_name, amount, 'current' as source
FROM orders
UNION
SELECT product_name, amount, 'archived' as source
FROM archived_orders
ORDER BY product_name;

-- UNION ALL: Combine with duplicates preserved
SELECT product_name, amount, order_date as date, 'current' as source
FROM orders
UNION ALL
SELECT product_name, amount, archived_date as date, 'archived' as source
FROM archived_orders
ORDER BY date DESC;

-- UNION with different structures (same column count and types)
SELECT name as item_name, 'user' as type FROM users
UNION
SELECT name as item_name, 'department' as type FROM departments
UNION
SELECT product_name as item_name, 'product' as type FROM orders;

-- ===========================================
-- Complex JOIN Scenarios
-- ===========================================

-- Complex multi-table JOIN with aggregations
SELECT
    d.name as department,
    d.location,
    COUNT(DISTINCT u.id) as employee_count,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.amount), 0) as total_amount,
    COALESCE(AVG(o.amount), 0) as avg_order_amount,
    MAX(o.order_date) as last_order_date
FROM departments d
LEFT JOIN users u ON d.id = u.department_id
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY d.id, d.name, d.location
ORDER BY total_amount DESC;

-- JOIN with subquery
SELECT
    u.name,
    u.email,
    order_stats.total_orders,
    order_stats.total_amount
FROM users u
LEFT JOIN (
    SELECT
        user_id,
        COUNT(*) as total_orders,
        SUM(amount) as total_amount
    FROM orders
    GROUP BY user_id
) order_stats ON u.id = order_stats.user_id;

-- Multiple JOINs with complex conditions
SELECT
    u.name as customer,
    d.name as department,
    o.product_name,
    o.amount,
    o.status,
    CASE
        WHEN o.amount > 200 THEN 'High Value'
        WHEN o.amount > 50 THEN 'Medium Value'
        ELSE 'Low Value'
    END as order_category
FROM users u
INNER JOIN departments d ON u.department_id = d.id
INNER JOIN orders o ON u.id = o.user_id
WHERE o.status != 'cancelled'
ORDER BY o.amount DESC;

-- ===========================================
-- Performance Optimization Examples
-- ===========================================

-- Check execution plan
EXPLAIN SELECT u.name, d.name
FROM users u
INNER JOIN departments d ON u.department_id = d.id;

-- Create indexes for better JOIN performance
CREATE INDEX idx_users_dept ON users(department_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_date ON orders(order_date);

-- Analyze query performance after indexing
EXPLAIN SELECT u.name, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name;

-- ===========================================
-- Real-world Business Intelligence Examples
-- ===========================================

-- Sales performance by department
SELECT
    d.name as department,
    COUNT(DISTINCT u.id) as salespeople,
    COUNT(o.id) as total_sales,
    SUM(o.amount) as revenue,
    AVG(o.amount) as avg_sale_amount
FROM departments d
LEFT JOIN users u ON d.id = u.department_id
LEFT JOIN orders o ON u.id = o.user_id AND o.status = 'delivered'
GROUP BY d.id, d.name
ORDER BY revenue DESC;

-- Customer lifetime value analysis
SELECT
    u.name as customer,
    u.hire_date,
    MIN(o.order_date) as first_order,
    MAX(o.order_date) as last_order,
    COUNT(o.id) as total_orders,
    SUM(o.amount) as lifetime_value,
    AVG(o.amount) as avg_order_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.hire_date
HAVING total_orders > 0
ORDER BY lifetime_value DESC;

-- ===========================================
-- CLEANUP: Drop tables (uncomment to clean up)
-- ===========================================

/*
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS archived_orders;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS departments;
DROP DATABASE IF EXISTS advanced_joins_db;
*/</content>
<parameter name="filePath">d:\SQL\10-Advanced-JOINs\examples.sql