-- Basic CRUD operations examples

-- Create database
CREATE DATABASE crud_examples;
USE crud_examples;

-- Create table
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE
);

-- INSERT examples
INSERT INTO employees (name, department, salary, hire_date) VALUES
('Alice Johnson', 'Engineering', 75000.00, '2023-01-15'),
('Bob Smith', 'Marketing', 65000.00, '2023-02-20'),
('Charlie Brown', 'Sales', 55000.00, '2023-03-10');

-- SELECT examples
-- Select all employees
SELECT * FROM employees;

-- Select specific columns
SELECT name, department FROM employees;

-- Select with WHERE condition
SELECT * FROM employees WHERE department = 'Engineering';

-- Select with ORDER BY
SELECT * FROM employees ORDER BY salary DESC;

-- UPDATE examples
-- Update salary for Alice
UPDATE employees SET salary = 80000.00 WHERE name = 'Alice Johnson';

-- Update department for Bob
UPDATE employees SET department = 'Digital Marketing' WHERE id = 2;

-- DELETE examples
-- Delete Charlie (be careful with DELETE!)
DELETE FROM employees WHERE name = 'Charlie Brown';

-- Check remaining data
SELECT * FROM employees;

-- Clean up
-- DROP DATABASE crud_examples;