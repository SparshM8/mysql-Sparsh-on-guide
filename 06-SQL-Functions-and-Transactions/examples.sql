-- SQL Functions and Transactions Examples

-- Create database for functions and transactions practice
CREATE DATABASE functions_transactions_practice;
USE functions_transactions_practice;

-- Create sample tables
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE,
    email VARCHAR(100)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    product_name VARCHAR(100),
    quantity INT,
    unit_price DECIMAL(8, 2),
    sale_date DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Insert sample data
INSERT INTO employees (first_name, last_name, department, salary, hire_date, email) VALUES
('John', 'Doe', 'Sales', 50000.00, '2020-01-15', 'john.doe@company.com'),
('Jane', 'Smith', 'Marketing', 55000.00, '2019-03-20', 'jane.smith@company.com'),
('Bob', 'Johnson', 'IT', 60000.00, '2018-07-10', 'bob.johnson@company.com'),
('Alice', 'Williams', 'Sales', 48000.00, '2021-02-28', 'alice.williams@company.com'),
('Charlie', 'Brown', 'HR', 52000.00, '2019-11-05', 'charlie.brown@company.com');

INSERT INTO sales (employee_id, product_name, quantity, unit_price, sale_date) VALUES
(1, 'Laptop', 2, 999.99, '2024-01-15'),
(1, 'Mouse', 5, 25.99, '2024-01-16'),
(2, 'Monitor', 1, 299.99, '2024-01-17'),
(4, 'Keyboard', 3, 79.99, '2024-01-18'),
(1, 'Headphones', 2, 149.99, '2024-01-19'),
(3, 'Software License', 1, 499.99, '2024-01-20');

-- AGGREGATE FUNCTIONS EXAMPLES

-- COUNT: Count total employees
SELECT COUNT(*) as total_employees FROM employees;

-- COUNT with condition: Count employees in Sales department
SELECT COUNT(*) as sales_employees FROM employees WHERE department = 'Sales';

-- SUM: Total salary expenditure
SELECT SUM(salary) as total_salary FROM employees;

-- AVG: Average salary
SELECT AVG(salary) as average_salary FROM employees;

-- MIN/MAX: Salary range
SELECT MIN(salary) as min_salary, MAX(salary) as max_salary FROM employees;

-- GROUP BY with aggregates: Average salary by department
SELECT department, AVG(salary) as avg_salary, COUNT(*) as employee_count
FROM employees
GROUP BY department;

-- STRING FUNCTIONS EXAMPLES

-- CONCAT: Full names
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM employees;

-- UPPER/LOWER: Case conversion
SELECT UPPER(first_name) as upper_name, LOWER(last_name) as lower_name FROM employees;

-- SUBSTRING: Extract parts of email
SELECT email, SUBSTRING(email, 1, LOCATE('@', email) - 1) as username FROM employees;

-- LENGTH: Email length
SELECT email, LENGTH(email) as email_length FROM employees;

-- DATE FUNCTIONS EXAMPLES

-- NOW(): Current timestamp
SELECT NOW() as current_datetime;

-- DATE(): Extract date from datetime
SELECT hire_date, DATE(NOW()) as today FROM employees LIMIT 1;

-- DATEDIFF: Days since hire
SELECT first_name, last_name, DATEDIFF(NOW(), hire_date) as days_employed FROM employees;

-- MATHEMATICAL FUNCTIONS EXAMPLES

-- ROUND: Round salaries
SELECT first_name, salary, ROUND(salary, -3) as rounded_salary FROM employees;

-- ABS: Absolute values (useful for calculations)
SELECT ABS(-100) as absolute_value;

-- CONTROL FLOW FUNCTIONS EXAMPLES

-- IF: Conditional logic
SELECT first_name, salary, IF(salary > 50000, 'High Earner', 'Regular') as salary_category FROM employees;

-- CASE: Multiple conditions
SELECT first_name, department,
CASE
    WHEN department = 'Sales' THEN 'Revenue Generator'
    WHEN department = 'IT' THEN 'Tech Support'
    WHEN department = 'HR' THEN 'People Management'
    ELSE 'Other'
END as department_role
FROM employees;

-- COALESCE: Handle NULL values
SELECT first_name, COALESCE(department, 'Not Assigned') as department FROM employees;

-- TRANSACTIONS EXAMPLES

-- Disable auto-commit for manual transaction control
SET autocommit = 0;

-- Start a transaction
START TRANSACTION;

-- Multiple operations as one transaction
INSERT INTO employees (first_name, last_name, department, salary, hire_date, email)
VALUES ('David', 'Wilson', 'Finance', 58000.00, '2024-01-25', 'david.wilson@company.com');

INSERT INTO sales (employee_id, product_name, quantity, unit_price, sale_date)
VALUES (LAST_INSERT_ID(), 'Calculator', 10, 19.99, '2024-01-25');

-- Check if everything looks good, then commit
COMMIT;

-- Example of rollback (commented out to avoid actual rollback)
-- START TRANSACTION;
-- INSERT INTO employees (first_name, last_name, department, salary, hire_date, email)
-- VALUES ('Test', 'User', 'Test', 0, '2024-01-01', 'test@example.com');
-- ROLLBACK;  -- This would undo the insert

-- Re-enable auto-commit
SET autocommit = 1;

-- COMPLEX QUERY WITH MULTIPLE FUNCTIONS
SELECT
    department,
    COUNT(*) as employee_count,
    ROUND(AVG(salary), 2) as avg_salary,
    MAX(salary) as highest_salary,
    MIN(salary) as lowest_salary,
    SUM(salary) as total_department_salary
FROM employees
GROUP BY department
ORDER BY total_department_salary DESC;

-- Clean up
-- DROP DATABASE functions_transactions_practice;