-- Lab 11: Subqueries and Advanced Querying
-- Comprehensive SQL examples for subqueries, GROUP BY, HAVING, and ROLLUP

-- ===========================================
-- SETUP: Create sample database and tables
-- ===========================================

-- Create database
CREATE DATABASE IF NOT EXISTS subqueries_db;
USE subqueries_db;

-- Create employees table
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    department_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    manager_id INT
);

-- Create departments table
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    budget DECIMAL(12,2),
    location VARCHAR(50)
);

-- Create projects table
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department_id INT,
    budget DECIMAL(12,2),
    start_date DATE,
    end_date DATE
);

-- Create sales table for advanced examples
CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    product_name VARCHAR(100),
    amount DECIMAL(10,2),
    sale_date DATE,
    region VARCHAR(50)
);

-- Insert sample data
INSERT INTO departments (name, budget, location) VALUES
('IT', 500000.00, 'Floor 1'),
('HR', 300000.00, 'Floor 2'),
('Sales', 400000.00, 'Floor 3'),
('Marketing', 350000.00, 'Floor 4'),
('Finance', 450000.00, 'Floor 5');

INSERT INTO employees (name, department_id, salary, hire_date) VALUES
('Aarav', 1, 75000.00, '2023-01-15'),
('Sneha', 2, 65000.00, '2023-02-20'),
('Raj', 3, 80000.00, '2023-03-10'),
('Priya', 1, 70000.00, '2023-04-05'),
('Vikram', 3, 55000.00, '2023-05-12'),
('Anjali', 4, 60000.00, '2023-06-18'),
('Rohit', 1, 72000.00, '2023-07-22'),
('Kavita', 5, 85000.00, '2023-08-30'),
('Suresh', 3, 58000.00, '2023-09-14'),
('Meera', 2, 62000.00, '2023-10-08'),
('Arjun', 1, 68000.00, '2023-11-15'),
('Pooja', 4, 63000.00, '2023-12-01'),
('Rahul', 3, 59000.00, '2024-01-10');

-- Set up manager hierarchy
UPDATE employees SET manager_id = 1 WHERE id IN (2, 4, 7, 11);  -- Aarav manages Sneha, Priya, Rohit, Arjun
UPDATE employees SET manager_id = 3 WHERE id IN (5, 9, 13);     -- Raj manages Vikram, Suresh, Rahul
UPDATE employees SET manager_id = 8 WHERE id = 6;               -- Kavita manages Anjali
UPDATE employees SET manager_id = 12 WHERE id = 10;             -- Pooja manages Meera

INSERT INTO projects (name, department_id, budget, start_date, end_date) VALUES
('Website Redesign', 1, 150000.00, '2024-01-01', '2024-06-30'),
('HR System Upgrade', 2, 80000.00, '2024-02-01', '2024-08-31'),
('Sales CRM', 3, 200000.00, '2024-01-15', '2024-12-15'),
('Marketing Campaign', 4, 120000.00, '2024-03-01', '2024-09-30'),
('Financial Reporting', 5, 90000.00, '2024-04-01', '2024-10-31'),
('Mobile App', 1, 250000.00, '2024-05-01', '2024-12-31'),
('Data Analytics', 5, 180000.00, '2024-06-01', '2024-12-31');

INSERT INTO sales (employee_id, product_name, amount, sale_date, region) VALUES
(1, 'Laptop', 1200.00, '2024-01-15', 'North'),
(1, 'Mouse', 25.00, '2024-01-16', 'North'),
(3, 'Monitor', 300.00, '2024-01-20', 'South'),
(5, 'Keyboard', 75.00, '2024-01-25', 'East'),
(3, 'Printer', 250.00, '2024-02-01', 'South'),
(1, 'Webcam', 80.00, '2024-02-05', 'North'),
(5, 'Headphones', 150.00, '2024-02-10', 'East'),
(3, 'USB Drive', 15.00, '2024-02-12', 'South'),
(8, 'Software License', 500.00, '2024-02-15', 'West'),
(6, 'Marketing Materials', 200.00, '2024-02-18', 'Central');

-- ===========================================
-- SINGLE-ROW SUBQUERIES
-- ===========================================

-- Find employees in the Sales department
SELECT name, salary, hire_date
FROM employees
WHERE department_id = (
    SELECT id
    FROM departments
    WHERE name = 'Sales'
);

-- Find employees with salary above company average
SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY salary DESC;

-- Find the department with highest budget
SELECT name, budget, location
FROM departments
WHERE budget = (
    SELECT MAX(budget)
    FROM departments
);

-- Find employee with highest salary
SELECT name, salary, department_id
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);

-- Find employees hired after the most recent hire in IT department
SELECT name, hire_date
FROM employees
WHERE hire_date > (
    SELECT MAX(hire_date)
    FROM employees
    WHERE department_id = (
        SELECT id FROM departments WHERE name = 'IT'
    )
);

-- ===========================================
-- MULTIPLE-ROW SUBQUERIES
-- ===========================================

-- Find employees in IT or HR departments
SELECT e.name, e.salary, d.name as department
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.department_id IN (
    SELECT id
    FROM departments
    WHERE name IN ('IT', 'HR')
)
ORDER BY d.name, e.salary DESC;

-- Find employees with salary above ANY department average
SELECT e.name, e.salary, d.name as department
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary > ANY (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department_id
)
ORDER BY e.salary DESC;

-- Find employees with salary above ALL department averages
SELECT e.name, e.salary
FROM employees
WHERE salary > ALL (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department_id
);

-- Find projects in departments with above-average budgets
SELECT p.name as project_name, p.budget as project_budget, d.name as department
FROM projects p
JOIN departments d ON p.department_id = d.id
WHERE d.id IN (
    SELECT id
    FROM departments
    WHERE budget > (
        SELECT AVG(budget) FROM departments
    )
);

-- ===========================================
-- CORRELATED SUBQUERIES
-- ===========================================

-- Find employees earning more than their department average
SELECT e1.name, e1.salary, d.name as department,
       ROUND((SELECT AVG(e2.salary) FROM employees e2 WHERE e2.department_id = e1.department_id), 2) as dept_avg
FROM employees e1
JOIN departments d ON e1.department_id = d.id
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
)
ORDER BY d.name, e1.salary DESC;

-- Find departments where all employees earn above 60000
SELECT d.name
FROM departments d
WHERE 60000 <= ALL (
    SELECT e.salary
    FROM employees e
    WHERE e.department_id = d.id
);

-- Find employees who earn more than their manager
SELECT e.name as employee, e.salary as emp_salary,
       m.name as manager, m.salary as mgr_salary
FROM employees e
JOIN employees m ON e.manager_id = m.id
WHERE e.salary > m.salary;

-- Find employees whose hire date is before their manager's hire date
SELECT e.name as employee, e.hire_date as emp_hire,
       m.name as manager, m.hire_date as mgr_hire
FROM employees e
JOIN employees m ON e.manager_id = m.id
WHERE e.hire_date < m.hire_date;

-- ===========================================
-- SUBQUERIES IN FROM CLAUSE (DERIVED TABLES)
-- ===========================================

-- Department salary statistics
SELECT
    dept_stats.department_name,
    dept_stats.employee_count,
    dept_stats.avg_salary,
    dept_stats.total_salary
FROM (
    SELECT
        d.name as department_name,
        COUNT(e.id) as employee_count,
        ROUND(AVG(e.salary), 2) as avg_salary,
        SUM(e.salary) as total_salary
    FROM departments d
    LEFT JOIN employees e ON d.id = e.department_id
    GROUP BY d.id, d.name
) dept_stats
WHERE dept_stats.employee_count > 0
ORDER BY dept_stats.avg_salary DESC;

-- Project budget analysis with department info
SELECT
    p.name as project_name,
    p.budget as project_budget,
    dept_info.dept_name,
    dept_info.dept_budget,
    ROUND((p.budget / dept_info.dept_budget * 100), 2) as budget_percentage
FROM projects p
JOIN (
    SELECT id, name as dept_name, budget as dept_budget
    FROM departments
) dept_info ON p.department_id = dept_info.id
ORDER BY budget_percentage DESC;

-- Monthly sales summary
SELECT
    monthly_stats.sale_month,
    monthly_stats.total_sales,
    monthly_stats.transaction_count,
    ROUND(monthly_stats.avg_sale_amount, 2) as avg_transaction
FROM (
    SELECT
        DATE_FORMAT(sale_date, '%Y-%m') as sale_month,
        SUM(amount) as total_sales,
        COUNT(*) as transaction_count,
        AVG(amount) as avg_sale_amount
    FROM sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
) monthly_stats
ORDER BY monthly_stats.sale_month;

-- ===========================================
-- SUBQUERIES IN SELECT CLAUSE
-- ===========================================

-- Show employee info with department statistics
SELECT
    e.name,
    e.salary,
    d.name as department,
    ROUND((
        SELECT AVG(salary)
        FROM employees
        WHERE department_id = e.department_id
    ), 2) as dept_avg_salary,
    ROUND(e.salary - (
        SELECT AVG(salary)
        FROM employees
        WHERE department_id = e.department_id
    ), 2) as difference_from_avg,
    (
        SELECT COUNT(*)
        FROM employees
        WHERE department_id = e.department_id
    ) as dept_size
FROM employees e
JOIN departments d ON e.department_id = d.id
ORDER BY d.name, e.salary DESC;

-- Employee ranking within department
SELECT
    e.name,
    d.name as department,
    e.salary,
    (
        SELECT COUNT(*) + 1
        FROM employees e2
        WHERE e2.department_id = e.department_id
        AND e2.salary > e.salary
    ) as salary_rank_in_dept
FROM employees e
JOIN departments d ON e.department_id = d.id
ORDER BY d.name, salary_rank_in_dept;

-- ===========================================
-- GROUP BY AND HAVING BASICS
-- ===========================================

-- Basic GROUP BY: Count employees per department
SELECT d.name as department, COUNT(e.id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
ORDER BY employee_count DESC;

-- GROUP BY with multiple aggregates
SELECT
    d.name as department,
    COUNT(e.id) as employees,
    ROUND(AVG(e.salary), 2) as avg_salary,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary,
    SUM(e.salary) as total_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
ORDER BY total_salary DESC;

-- GROUP BY by year and month
SELECT
    YEAR(hire_date) as hire_year,
    MONTH(hire_date) as hire_month,
    COUNT(*) as hires,
    ROUND(AVG(salary), 2) as avg_salary
FROM employees
GROUP BY YEAR(hire_date), MONTH(hire_date)
ORDER BY hire_year, hire_month;

-- ===========================================
-- HAVING CLAUSE EXAMPLES
-- ===========================================

-- HAVING: Filter groups with employee count > 1
SELECT d.name as department, COUNT(e.id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING COUNT(e.id) > 1
ORDER BY employee_count DESC;

-- HAVING with salary conditions
SELECT d.name as department, ROUND(AVG(e.salary), 2) as avg_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING AVG(e.salary) > 65000
ORDER BY avg_salary DESC;

-- Complex HAVING conditions
SELECT
    d.name as department,
    COUNT(e.id) as employee_count,
    ROUND(AVG(e.salary), 2) as avg_salary,
    MAX(e.salary) as max_salary,
    MIN(e.salary) as min_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING COUNT(e.id) >= 2
   AND AVG(e.salary) > 60000
   AND (MAX(e.salary) - MIN(e.salary)) < 30000
ORDER BY avg_salary DESC;

-- HAVING with subquery
SELECT d.name as department, COUNT(e.id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING COUNT(e.id) > (
    SELECT AVG(employee_count)
    FROM (
        SELECT COUNT(*) as employee_count
        FROM employees
        GROUP BY department_id
    ) dept_counts
);

-- ===========================================
-- ROLLUP OPERATOR EXAMPLES
-- ===========================================

-- ROLLUP: Department and year subtotals
SELECT
    d.name as department,
    YEAR(e.hire_date) as hire_year,
    COUNT(e.id) as employees_hired
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.name, YEAR(e.hire_date) WITH ROLLUP
ORDER BY d.name, YEAR(e.hire_date);

-- ROLLUP with multiple levels and COALESCE
SELECT
    COALESCE(d.name, 'TOTAL') as department,
    COALESCE(YEAR(e.hire_date), 'ALL YEARS') as hire_year,
    COUNT(e.id) as employees_hired,
    ROUND(SUM(e.salary), 2) as total_salary,
    ROUND(AVG(e.salary), 2) as avg_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.name, YEAR(e.hire_date) WITH ROLLUP
ORDER BY
    CASE WHEN d.name IS NULL THEN 1 ELSE 0 END,
    d.name,
    CASE WHEN YEAR(e.hire_date) IS NULL THEN 1 ELSE 0 END,
    YEAR(e.hire_date);

-- ROLLUP with sales data
SELECT
    COALESCE(region, 'ALL REGIONS') as region,
    COALESCE(YEAR(sale_date), 'ALL YEARS') as sale_year,
    COALESCE(MONTH(sale_date), 'ALL MONTHS') as sale_month,
    COUNT(*) as transactions,
    ROUND(SUM(amount), 2) as total_sales,
    ROUND(AVG(amount), 2) as avg_sale
FROM sales
GROUP BY region, YEAR(sale_date), MONTH(sale_date) WITH ROLLUP
ORDER BY
    CASE WHEN region IS NULL THEN 1 ELSE 0 END,
    region,
    CASE WHEN YEAR(sale_date) IS NULL THEN 1 ELSE 0 END,
    YEAR(sale_date),
    CASE WHEN MONTH(sale_date) IS NULL THEN 1 ELSE 0 END,
    MONTH(sale_date);

-- ===========================================
-- COMPLEX SUBQUERY SCENARIOS
-- ===========================================

-- Subquery with EXISTS
SELECT d.name as department, d.location
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.id
    AND e.salary > 70000
);

-- Subquery with NOT EXISTS
SELECT d.name as department
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.id
    AND e.salary < 60000
);

-- Subquery in HAVING with aggregate
SELECT d.name as department, ROUND(AVG(e.salary), 2) as avg_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING AVG(e.salary) > (
    SELECT AVG(salary) FROM employees
);

-- Nested subqueries
SELECT name, salary, hire_date
FROM employees
WHERE department_id = (
    SELECT id
    FROM departments
    WHERE budget = (
        SELECT MAX(budget)
        FROM departments
    )
);

-- Subquery with ALL and ANY
SELECT
    name,
    salary,
    (
        SELECT COUNT(*)
        FROM employees e2
        WHERE e2.salary > e1.salary
    ) as higher_salary_count,
    (
        SELECT COUNT(*)
        FROM employees e2
        WHERE e2.salary < e1.salary
    ) as lower_salary_count
FROM employees e1
ORDER BY salary DESC;

-- ===========================================
-- PERFORMANCE OPTIMIZATION EXAMPLES
-- ===========================================

-- Check execution plan for subquery
EXPLAIN SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary) FROM employees
);

-- Create indexes for better subquery performance
CREATE INDEX idx_employees_dept ON employees(department_id);
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_departments_budget ON departments(budget);

-- Optimized version using JOIN instead of correlated subquery
SELECT e.name, e.salary, d.name as department
FROM employees e
JOIN departments d ON e.department_id = d.id
JOIN (
    SELECT department_id, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_salary;

-- ===========================================
-- BUSINESS INTELLIGENCE EXAMPLES
-- ===========================================

-- Department performance dashboard
SELECT
    d.name as department,
    COUNT(DISTINCT e.id) as employees,
    COUNT(DISTINCT p.id) as projects,
    ROUND(AVG(e.salary), 2) as avg_salary,
    SUM(p.budget) as project_budget,
    ROUND(SUM(p.budget) / d.budget * 100, 2) as budget_utilization
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
LEFT JOIN projects p ON d.id = p.department_id
GROUP BY d.id, d.name, d.budget
ORDER BY budget_utilization DESC;

-- Employee performance analysis
SELECT
    e.name as employee,
    d.name as department,
    e.salary,
    (
        SELECT COUNT(*) FROM sales WHERE employee_id = e.id
    ) as sales_count,
    (
        SELECT SUM(amount) FROM sales WHERE employee_id = e.id
    ) as total_sales,
    CASE
        WHEN e.salary > (SELECT AVG(salary) FROM employees WHERE department_id = e.department_id)
        THEN 'Above Average'
        ELSE 'Below Average'
    END as salary_performance
FROM employees e
JOIN departments d ON e.department_id = d.id
ORDER BY total_sales DESC;

-- ===========================================
-- CLEANUP: Drop tables (uncomment to clean up)
-- ===========================================

/*
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP DATABASE IF EXISTS subqueries_db;
*/</content>
<parameter name="filePath">d:\SQL\11-Subqueries-and-Advanced-Querying\examples.sql