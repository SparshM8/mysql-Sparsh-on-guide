# Lab 11: Subqueries and Advanced Querying

## 🎯 Learning Objectives
By the end of this lab, you will be able to:
- Master subqueries in all contexts (WHERE, FROM, SELECT, HAVING)
- Understand single-row vs multiple-row subqueries
- Implement correlated subqueries
- Use GROUP BY and HAVING clauses effectively
- Apply the ROLLUP operator for summary reports
- Choose between WHERE and HAVING appropriately
- Optimize complex queries with subqueries

## 📋 Prerequisites
- Completion of Lab 8: Advanced Querying
- Understanding of basic SELECT queries
- Knowledge of aggregate functions (COUNT, SUM, AVG, etc.)
- Familiarity with JOIN operations

## 🕐 Lab Duration
**Estimated Time**: 90 minutes

## 📚 Theory Overview

### Subqueries
A subquery is a query nested inside another query. Subqueries allow you to perform complex operations by breaking them down into simpler parts.

### Types of Subqueries:
1. **Single-row subqueries**: Return one value, used with comparison operators (=, <, >, etc.)
2. **Multiple-row subqueries**: Return multiple values, used with IN, ANY, ALL
3. **Correlated subqueries**: Reference columns from the outer query
4. **Scalar subqueries**: Return a single value
5. **Table subqueries**: Return a result set (used in FROM clause)

### GROUP BY and HAVING
- **GROUP BY**: Groups rows with identical values into summary rows
- **HAVING**: Filters groups based on aggregate conditions (applied after grouping)
- **WHERE**: Filters individual rows (applied before grouping)

### ROLLUP Operator
- Extension of GROUP BY that creates subtotals and grand totals
- Generates summary rows for each level of aggregation

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
    database='subqueries_db'
)
cursor = connection.cursor()
```

### Step 2: Create Sample Database
```sql
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
('Meera', 2, 62000.00, '2023-10-08');

-- Set up manager hierarchy
UPDATE employees SET manager_id = 1 WHERE id IN (2, 4, 7);  -- Aarav manages Sneha, Priya, Rohit
UPDATE employees SET manager_id = 3 WHERE id IN (5, 9);     -- Raj manages Vikram, Suresh
UPDATE employees SET manager_id = 8 WHERE id = 6;           -- Kavita manages Anjali

INSERT INTO projects (name, department_id, budget, start_date, end_date) VALUES
('Website Redesign', 1, 150000.00, '2024-01-01', '2024-06-30'),
('HR System Upgrade', 2, 80000.00, '2024-02-01', '2024-08-31'),
('Sales CRM', 3, 200000.00, '2024-01-15', '2024-12-15'),
('Marketing Campaign', 4, 120000.00, '2024-03-01', '2024-09-30'),
('Financial Reporting', 5, 90000.00, '2024-04-01', '2024-10-31'),
('Mobile App', 1, 250000.00, '2024-05-01', '2024-12-31');
```

### Step 3: Single-Row Subqueries
```sql
-- Find employees in the Sales department
SELECT name, salary
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
);

-- Find the department with highest budget
SELECT name, budget
FROM departments
WHERE budget = (
    SELECT MAX(budget)
    FROM departments
);
```

### Step 4: Multiple-Row Subqueries
```sql
-- Find employees in IT or HR departments
SELECT name, department_id
FROM employees
WHERE department_id IN (
    SELECT id
    FROM departments
    WHERE name IN ('IT', 'HR')
);

-- Find employees with salary above ANY department average
SELECT e.name, e.salary, d.name as department
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary > ANY (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department_id
);

-- Find employees with salary above ALL department averages
SELECT e.name, e.salary
FROM employees e
WHERE e.salary > ALL (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department_id
);
```

### Step 5: Correlated Subqueries
```sql
-- Find employees earning more than their department average
SELECT e1.name, e1.salary, d.name as department
FROM employees e1
JOIN departments d ON e1.department_id = d.id
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
);

-- Find departments where all employees earn above 60000
SELECT d.name
FROM departments d
WHERE 60000 >= ALL (
    SELECT e.salary
    FROM employees e
    WHERE e.department_id = d.id
);
```

### Step 6: Subqueries in FROM Clause (Derived Tables)
```sql
-- Department salary statistics
SELECT
    dept_stats.department_name,
    dept_stats.avg_salary,
    dept_stats.employee_count
FROM (
    SELECT
        d.name as department_name,
        AVG(e.salary) as avg_salary,
        COUNT(e.id) as employee_count
    FROM departments d
    LEFT JOIN employees e ON d.id = e.department_id
    GROUP BY d.id, d.name
) dept_stats
WHERE dept_stats.avg_salary > 65000;

-- Project budget analysis with department info
SELECT
    p.name as project_name,
    p.budget as project_budget,
    dept_info.dept_budget,
    (p.budget / dept_info.dept_budget * 100) as budget_percentage
FROM projects p
JOIN (
    SELECT id, budget as dept_budget
    FROM departments
) dept_info ON p.department_id = dept_info.id;
```

### Step 7: Subqueries in SELECT Clause
```sql
-- Show employee info with department average
SELECT
    e.name,
    e.salary,
    d.name as department,
    (
        SELECT AVG(salary)
        FROM employees
        WHERE department_id = e.department_id
    ) as dept_avg_salary,
    e.salary - (
        SELECT AVG(salary)
        FROM employees
        WHERE department_id = e.department_id
    ) as difference_from_avg
FROM employees e
JOIN departments d ON e.department_id = d.id;
```

### Step 8: GROUP BY and HAVING Basics
```sql
-- Basic GROUP BY: Count employees per department
SELECT d.name as department, COUNT(e.id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name;

-- GROUP BY with aggregates
SELECT
    d.name as department,
    COUNT(e.id) as employees,
    AVG(e.salary) as avg_salary,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary,
    SUM(e.salary) as total_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name;
```

### Step 9: HAVING Clause
```sql
-- HAVING: Filter groups with conditions
SELECT d.name as department, COUNT(e.id) as employee_count
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING COUNT(e.id) > 1;

-- HAVING with aggregate conditions
SELECT d.name as department, AVG(e.salary) as avg_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING AVG(e.salary) > 65000;

-- Complex HAVING conditions
SELECT
    d.name as department,
    COUNT(e.id) as employee_count,
    AVG(e.salary) as avg_salary,
    MAX(e.salary) as max_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING COUNT(e.id) >= 2 AND AVG(e.salary) > 60000;
```

### Step 10: ROLLUP Operator
```sql
-- ROLLUP: Create subtotals and grand totals
SELECT
    d.name as department,
    YEAR(e.hire_date) as hire_year,
    COUNT(e.id) as employees_hired
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.name, YEAR(e.hire_date) WITH ROLLUP;

-- ROLLUP with multiple levels
SELECT
    COALESCE(d.name, 'TOTAL') as department,
    COALESCE(YEAR(e.hire_date), 'ALL YEARS') as hire_year,
    COUNT(e.id) as employees_hired,
    SUM(e.salary) as total_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.name, YEAR(e.hire_date) WITH ROLLUP
ORDER BY d.name, YEAR(e.hire_date);
```

### Step 11: Complex Subquery Scenarios
```sql
-- Subquery with EXISTS
SELECT d.name as department
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.id
    AND e.salary > 70000
);

-- Subquery in HAVING clause
SELECT d.name as department, AVG(e.salary) as avg_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.name
HAVING AVG(e.salary) > (
    SELECT AVG(salary) FROM employees
);

-- Nested subqueries
SELECT name, salary
FROM employees
WHERE department_id = (
    SELECT id
    FROM departments
    WHERE budget = (
        SELECT MAX(budget)
        FROM departments
    )
);
```

## 📝 Exercises

### Exercise 1: Single-Row Subqueries
1. Find the employee with the highest salary
2. Find employees hired after the most recent hire in Sales department
3. Find departments with budget above company average

### Exercise 2: Multiple-Row Subqueries
1. Find employees in departments located on 'Floor 1' or 'Floor 2'
2. Find employees earning more than at least one employee in every department
3. Find projects in departments with above-average budgets

### Exercise 3: Correlated Subqueries
1. Find employees who earn more than their manager
2. Find departments where the highest salary is above 75000
3. Find employees whose salary is above their department's median

### Exercise 4: GROUP BY and HAVING
1. Show departments with more than 2 employees earning above 60000
2. Find departments where total salary exceeds department budget
3. Show monthly hiring trends for the current year

### Exercise 5: ROLLUP Reports
1. Create a salary report with subtotals by department and grand total
2. Generate a hiring report with yearly and monthly breakdowns
3. Create a budget utilization report with department subtotals

## 🐛 Common Issues and Solutions

### Issue 1: Subquery Returns Multiple Rows
**Problem**: Using single-row comparison with multi-row subquery
**Solution**: Use IN, ANY, or ALL operators for multiple rows

### Issue 2: Correlated Subquery Performance
**Problem**: Correlated subqueries execute once per outer row
**Solution**: Consider JOINs or temporary tables for better performance

### Issue 3: WHERE vs HAVING Confusion
**Problem**: Using WHERE instead of HAVING for aggregate conditions
**Solution**: WHERE filters rows before grouping, HAVING filters groups after

### Issue 4: NULL Values in Aggregates
**Problem**: COUNT(*) vs COUNT(column) with NULLs
**Solution**: Use COUNT(*) for row count, COUNT(column) excludes NULLs

## 📊 Expected Output Examples

### Single-Row Subquery Result:
```
name    salary
Raj     80000.00
Kavita  85000.00
```

### GROUP BY with HAVING Result:
```
department    employee_count    avg_salary
IT            3                 72333.33
Sales         3                 64333.33
```

### ROLLUP Result:
```
department    hire_year    employees_hired
IT            2023         3
IT            NULL         3
Sales         2023         3
Sales         NULL         3
NULL          NULL         10
```

## 🔍 Key Concepts to Remember

- **Single-row subquery**: Returns one value (=, <, >)
- **Multiple-row subquery**: Returns many values (IN, ANY, ALL)
- **Correlated subquery**: References outer query columns
- **GROUP BY**: Groups identical data for aggregation
- **HAVING**: Filters groups (after GROUP BY)
- **WHERE**: Filters rows (before GROUP BY)
- **ROLLUP**: Creates subtotals and grand totals

## 🎓 Summary

In this lab, you mastered:
- All types of subqueries and their applications
- GROUP BY and HAVING clause usage
- ROLLUP operator for summary reports
- Complex query construction techniques
- Performance considerations for subqueries

Subqueries are powerful tools for complex data analysis. They allow you to break down complex problems into manageable parts and perform sophisticated filtering and calculations.

## 🚀 Next Steps
- Practice with larger datasets
- Learn about Common Table Expressions (CTEs)
- Explore window functions
- Study query optimization techniques
- Consider stored procedures for complex logic</content>
<parameter name="filePath">d:\SQL\11-Subqueries-and-Advanced-Querying\README.md