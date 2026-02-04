# Lab 12: Stored Procedures and Views

## 🎯 Learning Objectives
By the end of this lab, you will be able to:
- Create and execute stored procedures in MySQL
- Pass parameters to stored procedures
- Handle stored procedure errors and exceptions
- Create, query, and manage database views
- Update and drop views safely
- Implement database indexes for performance optimization
- Understand limitations and best practices for views and procedures
- Apply stored procedures and views in real-world scenarios

## 📋 Prerequisites
- Completion of Lab 11: Subqueries and Advanced Querying
- Understanding of basic SQL queries and data manipulation
- Knowledge of database design and relationships
- Familiarity with MySQL syntax and functions

## 🕐 Lab Duration
**Estimated Time**: 90 minutes

## 📚 Theory Overview

### Stored Procedures
A stored procedure is a set of SQL statements stored in the database that can be executed as a single unit. Stored procedures:
- Accept parameters for dynamic behavior
- Can perform complex operations and calculations
- Enhance security by encapsulating business logic
- Improve performance through compilation and caching
- Support error handling and transaction management

### Views
A view is a virtual table based on a SQL query result set. Views:
- Simplify complex queries for end users
- Provide data security by restricting column/row access
- Present consistent data interfaces
- Can be used like regular tables in queries
- Support most SELECT operations but limited UPDATE operations

### Indexes
Indexes are data structures that improve query performance by providing fast access to rows in a table. Key points:
- Created on columns used in WHERE, JOIN, and ORDER BY clauses
- Speed up SELECT operations but slow down data modifications
- Require additional storage space
- Should be used strategically, not on every column

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
    database='procedures_views_db'
)
cursor = connection.cursor()
```

### Step 2: Create Sample Database
```sql
-- Create database
CREATE DATABASE IF NOT EXISTS procedures_views_db;
USE procedures_views_db;

-- Create employees table
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    email VARCHAR(100),
    active BOOLEAN DEFAULT TRUE
);

-- Create departments table
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    budget DECIMAL(12,2),
    manager_id INT
);

-- Create projects table
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    department_id INT,
    budget DECIMAL(12,2),
    start_date DATE,
    end_date DATE,
    status ENUM('planning', 'active', 'completed', 'cancelled')
);

-- Insert sample data
INSERT INTO departments (name, budget) VALUES
('IT', 500000.00),
('HR', 300000.00),
('Sales', 400000.00),
('Marketing', 350000.00);

INSERT INTO employees (name, department, salary, hire_date, email) VALUES
('Aarav', 'IT', 75000.00, '2023-01-15', 'aarav@company.com'),
('Sneha', 'HR', 65000.00, '2023-02-20', 'sneha@company.com'),
('Raj', 'Sales', 80000.00, '2023-03-10', 'raj@company.com'),
('Priya', 'IT', 70000.00, '2023-04-05', 'priya@company.com'),
('Vikram', 'Sales', 55000.00, '2023-05-12', 'vikram@company.com'),
('Anjali', 'Marketing', 60000.00, '2023-06-18', 'anjali@company.com');

INSERT INTO projects (name, department_id, budget, start_date, end_date, status) VALUES
('Website Redesign', 1, 150000.00, '2024-01-01', '2024-06-30', 'active'),
('HR System Upgrade', 2, 80000.00, '2024-02-01', '2024-08-31', 'planning'),
('Sales CRM', 3, 200000.00, '2024-01-15', '2024-12-15', 'active'),
('Marketing Campaign', 4, 120000.00, '2024-03-01', '2024-09-30', 'completed');
```

### Step 3: Basic Stored Procedures
```sql
-- Change delimiter for procedure definition
DELIMITER $$

-- Create a simple stored procedure
CREATE PROCEDURE GetAllEmployees()
BEGIN
    SELECT id, name, department, salary
    FROM employees
    WHERE active = TRUE
    ORDER BY name;
END$$

DELIMITER ;

-- Call the stored procedure
CALL GetAllEmployees();
```

### Step 4: Stored Procedures with Parameters
```sql
-- Procedure with IN parameter
DELIMITER $$

CREATE PROCEDURE GetEmployeesByDepartment(IN dept_name VARCHAR(50))
BEGIN
    SELECT id, name, salary, hire_date
    FROM employees
    WHERE department = dept_name AND active = TRUE
    ORDER BY salary DESC;
END$$

DELIMITER ;

-- Call with parameter
CALL GetEmployeesByDepartment('IT');

-- Procedure with multiple parameters
DELIMITER $$

CREATE PROCEDURE GetEmployeesBySalaryRange(
    IN min_salary DECIMAL(10,2),
    IN max_salary DECIMAL(10,2)
)
BEGIN
    SELECT name, department, salary
    FROM employees
    WHERE salary BETWEEN min_salary AND max_salary
    AND active = TRUE
    ORDER BY salary;
END$$

DELIMITER ;

-- Call with multiple parameters
CALL GetEmployeesBySalaryRange(60000, 80000);
```

### Step 5: Stored Procedures with OUT Parameters
```sql
-- Procedure with OUT parameter
DELIMITER $$

CREATE PROCEDURE GetEmployeeCount(OUT total_count INT)
BEGIN
    SELECT COUNT(*) INTO total_count
    FROM employees
    WHERE active = TRUE;
END$$

DELIMITER ;

-- Call and get output
CALL GetEmployeeCount(@count);
SELECT @count as total_employees;

-- Procedure with INOUT parameter
DELIMITER $$

CREATE PROCEDURE AdjustSalary(
    INOUT emp_salary DECIMAL(10,2),
    IN percentage DECIMAL(5,2)
)
BEGIN
    SET emp_salary = emp_salary * (1 + percentage / 100);
END$$

DELIMITER ;

-- Call with INOUT parameter
SET @salary = 75000.00;
CALL AdjustSalary(@salary, 10.0);
SELECT @salary as adjusted_salary;
```

### Step 6: Stored Procedures with Error Handling
```sql
-- Procedure with error handling
DELIMITER $$

CREATE PROCEDURE SafeEmployeeInsert(
    IN emp_name VARCHAR(50),
    IN emp_dept VARCHAR(50),
    IN emp_salary DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred while inserting employee' as message;
    END;

    -- Validate input
    IF emp_salary < 30000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary must be at least 30,000';
    END IF;

    -- Insert employee
    INSERT INTO employees (name, department, salary, hire_date)
    VALUES (emp_name, emp_dept, emp_salary, CURDATE());

    SELECT 'Employee inserted successfully' as message;
END$$

DELIMITER ;

-- Test error handling
CALL SafeEmployeeInsert('John Doe', 'IT', 25000);  -- Should fail
CALL SafeEmployeeInsert('Jane Smith', 'HR', 65000);  -- Should succeed
```

### Step 7: Creating and Using Views
```sql
-- Create a simple view
CREATE VIEW active_employees AS
SELECT id, name, department, salary, email
FROM employees
WHERE active = TRUE;

-- Query the view
SELECT * FROM active_employees;

-- Create a view with calculated columns
CREATE VIEW employee_summary AS
SELECT
    department,
    COUNT(*) as employee_count,
    ROUND(AVG(salary), 2) as avg_salary,
    MIN(salary) as min_salary,
    MAX(salary) as max_salary
FROM employees
WHERE active = TRUE
GROUP BY department;

-- Query the summary view
SELECT * FROM employee_summary;
```

### Step 8: Complex Views with JOINs
```sql
-- Create a view combining multiple tables
CREATE VIEW project_details AS
SELECT
    p.id,
    p.name as project_name,
    d.name as department_name,
    p.budget as project_budget,
    d.budget as dept_budget,
    ROUND((p.budget / d.budget * 100), 2) as budget_percentage,
    p.start_date,
    p.end_date,
    p.status
FROM projects p
JOIN departments d ON p.department_id = d.id;

-- Query the complex view
SELECT * FROM project_details
WHERE status = 'active'
ORDER BY budget_percentage DESC;

-- Create a view for department performance
CREATE VIEW dept_performance AS
SELECT
    d.name as department,
    COUNT(DISTINCT e.id) as employee_count,
    COUNT(DISTINCT p.id) as project_count,
    ROUND(AVG(e.salary), 2) as avg_salary,
    COALESCE(SUM(p.budget), 0) as total_project_budget,
    ROUND(COALESCE(SUM(p.budget), 0) / d.budget * 100, 2) as budget_utilization
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
LEFT JOIN projects p ON d.id = p.department_id
GROUP BY d.id, d.name, d.budget;

-- Query department performance
SELECT * FROM dept_performance
ORDER BY budget_utilization DESC;
```

### Step 9: Updating and Managing Views
```sql
-- Update a view using CREATE OR REPLACE
CREATE OR REPLACE VIEW active_employees AS
SELECT id, name, department, salary, email, hire_date
FROM employees
WHERE active = TRUE;

-- Check updated view
SELECT * FROM active_employees LIMIT 3;

-- Drop a view
DROP VIEW IF EXISTS employee_summary;

-- Check if view exists
SHOW TABLES LIKE 'employee_summary';
```

### Step 10: Indexes for Performance
```sql
-- Create indexes on commonly queried columns
CREATE INDEX idx_employees_department ON employees(department);
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_employees_active ON employees(active);
CREATE INDEX idx_projects_dept_status ON projects(department_id, status);

-- Check index performance
EXPLAIN SELECT name, salary
FROM employees
WHERE department = 'IT' AND active = TRUE;

-- Drop an index
DROP INDEX idx_employees_active ON employees;

-- Show all indexes on a table
SHOW INDEXES FROM employees;
```

### Step 11: Stored Procedures with Views
```sql
-- Create a procedure that uses views
DELIMITER $$

CREATE PROCEDURE GetDepartmentReport(IN dept_name VARCHAR(50))
BEGIN
    -- Check if department exists
    IF NOT EXISTS (SELECT 1 FROM departments WHERE name = dept_name) THEN
        SELECT 'Department not found' as error_message;
    ELSE
        -- Return department performance from view
        SELECT * FROM dept_performance
        WHERE department = dept_name;

        -- Return active employees from view
        SELECT 'Active Employees:' as section;
        SELECT name, salary, hire_date
        FROM active_employees
        WHERE department = dept_name
        ORDER BY salary DESC;
    END IF;
END$$

DELIMITER ;

-- Test the procedure
CALL GetDepartmentReport('IT');
CALL GetDepartmentReport('Nonexistent Dept');
```

## 📝 Exercises

### Exercise 1: Basic Stored Procedures
1. Create a stored procedure to get employees hired in a specific year
2. Create a procedure to update employee salaries with a percentage increase
3. Create a procedure to deactivate employees by ID

### Exercise 2: Parameterized Procedures
1. Create a procedure to find projects within a budget range
2. Create a procedure to get department statistics with date range
3. Create a procedure with validation for inserting new projects

### Exercise 3: Views Creation
1. Create a view showing only employee contact information
2. Create a view for project status summary
3. Create a view combining employee and department data

### Exercise 4: Complex Views and Indexes
1. Create a view for monthly hiring trends
2. Create appropriate indexes for the views you created
3. Test query performance with and without indexes

### Exercise 5: Integration Project
1. Create stored procedures that utilize the views you created
2. Implement error handling in all procedures
3. Create a comprehensive reporting procedure

## 🐛 Common Issues and Solutions

### Issue 1: Delimiter Problems
**Problem**: MySQL interprets ; as end of statement in procedures
**Solution**: Change delimiter to $$ before procedure creation

### Issue 2: View Update Restrictions
**Problem**: Some views cannot be updated directly
**Solution**: Update underlying tables instead, or redesign view

### Issue 3: Index Performance Trade-offs
**Problem**: Indexes slow down INSERT/UPDATE operations
**Solution**: Create indexes only on columns used in WHERE/JOIN clauses

### Issue 4: Parameter Type Mismatches
**Problem**: Wrong parameter types cause procedure failures
**Solution**: Validate parameter types and ranges in procedures

## 📊 Expected Output Examples

### Stored Procedure Result:
```
id    name    department    salary
1     Aarav   IT            75000.00
4     Priya   IT            70000.00
```

### View Query Result:
```
department    employee_count    avg_salary    project_count
IT            2                 72500.00      1
HR            1                 65000.00      1
```

### Index Performance Check:
```
EXPLAIN output showing index usage and performance metrics
```

## 🔍 Key Concepts to Remember

- **DELIMITER**: Change to $$ for procedure definitions
- **IN parameters**: Input values passed to procedures
- **OUT parameters**: Output values returned from procedures
- **Views**: Virtual tables based on SELECT queries
- **CREATE OR REPLACE**: Update existing views safely
- **Indexes**: Improve SELECT performance, slow modifications
- **Error handling**: Use DECLARE EXIT HANDLER in procedures

## 🎓 Summary

In this lab, you mastered:
- **Stored procedures**: Creation, parameters, error handling
- **Views**: Creation, querying, updating, dropping
- **Indexes**: Performance optimization and management
- **Integration**: Procedures using views for complex operations
- **Best practices**: When to use each feature and their limitations

Stored procedures and views are essential for database application development. They provide reusable, maintainable, and secure database logic that can be called from applications.

## 🚀 Next Steps
- Learn about triggers and events
- Explore advanced stored procedure features
- Study database security and permissions
- Consider certification preparation
- Build complete database applications</content>
<parameter name="filePath">d:\SQL\12-Stored-Procedures-and-Views\README.md