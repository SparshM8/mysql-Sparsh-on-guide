# Lab 10: Advanced JOINs and Set Operations

## 🎯 Learning Objectives
By the end of this lab, you will be able to:
- Master all types of SQL JOINs in MySQL
- Understand when to use different JOIN types
- Implement complex multi-table queries
- Use UNION and UNION ALL for combining result sets
- Apply JOINs in real-world scenarios
- Troubleshoot common JOIN-related issues

## 📋 Prerequisites
- Completion of Lab 7: Keys and Relationships
- Understanding of basic SELECT queries
- Knowledge of primary and foreign keys
- Familiarity with table relationships

## 🕐 Lab Duration
**Estimated Time**: 90 minutes

## 📚 Theory Overview

### SQL JOINs
JOINs are used to combine rows from two or more tables based on related columns. MySQL supports several types of JOINs, each serving different purposes for data retrieval.

### Types of JOINs Covered:
1. **INNER JOIN**: Returns matching records from both tables
2. **LEFT JOIN**: Returns all records from left table + matching records from right table
3. **RIGHT JOIN**: Returns all records from right table + matching records from left table
4. **FULL JOIN**: Returns all records when there is a match in either table (simulated in MySQL)
5. **CROSS JOIN**: Returns Cartesian product of both tables
6. **SELF JOIN**: Join a table with itself for hierarchical data

### Set Operations
- **UNION**: Combines result sets and removes duplicates
- **UNION ALL**: Combines result sets and keeps duplicates

## 🔧 Step-by-Step Instructions

### Step 1: Environment Setup
```python
# Install mysql-connector-python if not already installed
!pip install mysql-connector-python

# Import required libraries
import mysql.connector
import pandas as pd

# Connect to MySQL
connection = mysql.connector.connect(
    host='localhost',
    user='your_username',
    password='your_password',
    database='your_database'
)
cursor = connection.cursor()
```

### Step 2: Create Sample Tables
```sql
-- Create users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    department_id INT
);

-- Create departments table
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    location VARCHAR(50)
);

-- Create orders table
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    product_name VARCHAR(100),
    amount DECIMAL(10,2),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert sample data
INSERT INTO departments (name, location) VALUES
('IT', 'Floor 1'),
('HR', 'Floor 2'),
('Sales', 'Floor 3');

INSERT INTO users (name, department_id) VALUES
('Aarav', 1),
('Sneha', 2),
('Raj', 3),
('Priya', 1);

INSERT INTO orders (user_id, product_name, amount) VALUES
(1, 'Laptop', 1200.00),
(1, 'Mouse', 25.00),
(2, 'Keyboard', 75.00),
(3, 'Monitor', 300.00),
(4, 'Headphones', 150.00);
```

### Step 3: INNER JOIN Examples
```sql
-- Basic INNER JOIN
SELECT u.name, d.name as department
FROM users u
INNER JOIN departments d ON u.department_id = d.id;

-- INNER JOIN with multiple tables
SELECT u.name, d.name as department, o.product_name, o.amount
FROM users u
INNER JOIN departments d ON u.department_id = d.id
INNER JOIN orders o ON u.id = o.user_id;
```

### Step 4: LEFT JOIN Examples
```sql
-- LEFT JOIN - all users, even those without orders
SELECT u.name, o.product_name, o.amount
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- LEFT JOIN with department info
SELECT u.name, d.name as department, COUNT(o.id) as order_count
FROM users u
LEFT JOIN departments d ON u.department_id = d.id
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, d.name;
```

### Step 5: RIGHT JOIN Examples
```sql
-- RIGHT JOIN - all departments, even those without users
SELECT d.name as department, u.name
FROM users u
RIGHT JOIN departments d ON u.department_id = d.id;
```

### Step 6: CROSS JOIN Examples
```sql
-- CROSS JOIN - Cartesian product
SELECT u.name, d.name as department
FROM users u
CROSS JOIN departments d;
```

### Step 7: SELF JOIN Examples
```sql
-- SELF JOIN example (requires hierarchical data)
-- First, let's add a manager_id column
ALTER TABLE users ADD COLUMN manager_id INT;

UPDATE users SET manager_id = 1 WHERE id IN (2, 3);
UPDATE users SET manager_id = 2 WHERE id = 4;

-- SELF JOIN to show employee-manager relationships
SELECT e.name as employee, m.name as manager
FROM users e
LEFT JOIN users m ON e.manager_id = m.id;
```

### Step 8: UNION Operations
```sql
-- Create another table for UNION examples
CREATE TABLE archived_orders (
    id INT PRIMARY KEY,
    user_id INT,
    product_name VARCHAR(100),
    amount DECIMAL(10,2),
    archived_date DATE
);

INSERT INTO archived_orders VALUES
(1, 1, 'Old Laptop', 800.00, '2023-01-15'),
(2, 2, 'Old Keyboard', 50.00, '2023-02-20');

-- UNION - removes duplicates
SELECT product_name, amount FROM orders
UNION
SELECT product_name, amount FROM archived_orders;

-- UNION ALL - keeps duplicates
SELECT product_name, amount FROM orders
UNION ALL
SELECT product_name, amount FROM archived_orders;
```

### Step 9: Complex JOIN Scenarios
```sql
-- Complex query with multiple JOINs and aggregations
SELECT
    d.name as department,
    d.location,
    COUNT(DISTINCT u.id) as employee_count,
    COUNT(o.id) as total_orders,
    SUM(o.amount) as total_amount,
    AVG(o.amount) as avg_order_amount
FROM departments d
LEFT JOIN users u ON d.id = u.department_id
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY d.id, d.name, d.location
ORDER BY total_amount DESC;

-- Using JOINs with subqueries
SELECT u.name,
       (SELECT COUNT(*) FROM orders WHERE user_id = u.id) as order_count
FROM users u
WHERE u.id IN (
    SELECT DISTINCT user_id FROM orders
    WHERE amount > 100
);
```

### Step 10: Performance Considerations
```sql
-- Check execution plans (use EXPLAIN)
EXPLAIN SELECT u.name, d.name
FROM users u
INNER JOIN departments d ON u.department_id = d.id;

-- Create indexes for better JOIN performance
CREATE INDEX idx_users_dept ON users(department_id);
CREATE INDEX idx_orders_user ON orders(user_id);
```

## 📝 Exercises

### Exercise 1: Basic JOINs
Write queries to:
1. List all users with their department names
2. Show all orders with customer names and department info
3. Find users who haven't placed any orders

### Exercise 2: Advanced JOINs
1. Create a report showing department performance (employee count, total orders, total amount)
2. Find the most valuable customers (highest total order amount) per department
3. Show hierarchical employee-manager relationships

### Exercise 3: Set Operations
1. Combine current and archived orders without duplicates
2. Find products that exist in both current and archived orders
3. Create a unified product catalog from multiple sources

### Exercise 4: Real-world Scenario
Design and implement a JOIN query for an e-commerce database that shows:
- Customer information
- Order history
- Product details
- Shipping information
- Payment status

## 🐛 Common Issues and Solutions

### Issue 1: Cartesian Explosion
**Problem**: CROSS JOIN creates too many rows
**Solution**: Always use appropriate JOIN conditions

### Issue 2: NULL Values in Results
**Problem**: LEFT/RIGHT JOINs return NULL values
**Solution**: Use COALESCE() to handle NULLs or filter appropriately

### Issue 3: Performance Issues
**Problem**: JOINs are slow on large tables
**Solution**: Create proper indexes on JOIN columns

### Issue 4: Ambiguous Column Names
**Problem**: Same column names in different tables
**Solution**: Use table aliases and qualified column names

## 📊 Expected Output Examples

### INNER JOIN Result:
```
name    department
Aarav   IT
Sneha   HR
Raj     Sales
Priya   IT
```

### LEFT JOIN Result:
```
name    product_name    amount
Aarav   Laptop          1200.00
Aarav   Mouse           25.00
Sneha   Keyboard        75.00
Raj     Monitor         300.00
Priya   Headphones      150.00
```

## 🔍 Key Concepts to Remember

- **INNER JOIN**: Only matching rows from both tables
- **LEFT JOIN**: All rows from left table + matching from right
- **RIGHT JOIN**: All rows from right table + matching from left
- **CROSS JOIN**: Every combination (use carefully!)
- **SELF JOIN**: Join table with itself using aliases
- **UNION**: Combine results, remove duplicates
- **UNION ALL**: Combine results, keep duplicates

## 🎓 Summary

In this lab, you mastered:
- All major JOIN types in MySQL
- Complex multi-table query construction
- Set operations with UNION/UNION ALL
- Performance optimization techniques
- Real-world JOIN scenario implementation

JOINs are fundamental to relational database querying. Practice combining different JOIN types to solve complex data retrieval problems efficiently.

## 🚀 Next Steps
- Practice with larger datasets
- Learn about query optimization and indexing
- Explore window functions and CTEs
- Study database design for optimal JOIN performance</content>
<parameter name="filePath">d:\SQL\10-Advanced-JOINs\README.md