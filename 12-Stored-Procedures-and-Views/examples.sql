-- Lab 12: Stored Procedures and Views
-- Comprehensive SQL examples for stored procedures, views, and indexes

-- ===========================================
-- SETUP: Create sample database and tables
-- ===========================================

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

-- Create audit_log table for procedures
CREATE TABLE audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    action VARCHAR(100),
    table_name VARCHAR(50),
    record_id INT,
    old_value TEXT,
    new_value TEXT,
    user_name VARCHAR(50),
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO departments (name, budget) VALUES
('IT', 500000.00),
('HR', 300000.00),
('Sales', 400000.00),
('Marketing', 350000.00),
('Finance', 450000.00);

INSERT INTO employees (name, department, salary, hire_date, email) VALUES
('Aarav', 'IT', 75000.00, '2023-01-15', 'aarav@company.com'),
('Sneha', 'HR', 65000.00, '2023-02-20', 'sneha@company.com'),
('Raj', 'Sales', 80000.00, '2023-03-10', 'raj@company.com'),
('Priya', 'IT', 70000.00, '2023-04-05', 'priya@company.com'),
('Vikram', 'Sales', 55000.00, '2023-05-12', 'vikram@company.com'),
('Anjali', 'Marketing', 60000.00, '2023-06-18', 'anjali@company.com'),
('Rohit', 'IT', 72000.00, '2023-07-22', 'rohit@company.com'),
('Kavita', 'Finance', 85000.00, '2023-08-30', 'kavita@company.com'),
('Suresh', 'Sales', 58000.00, '2023-09-14', 'suresh@company.com'),
('Meera', 'HR', 62000.00, '2023-10-08', 'meera@company.com');

INSERT INTO projects (name, department_id, budget, start_date, end_date, status) VALUES
('Website Redesign', 1, 150000.00, '2024-01-01', '2024-06-30', 'active'),
('HR System Upgrade', 2, 80000.00, '2024-02-01', '2024-08-31', 'planning'),
('Sales CRM', 3, 200000.00, '2024-01-15', '2024-12-15', 'active'),
('Marketing Campaign', 4, 120000.00, '2024-03-01', '2024-09-30', 'completed'),
('Financial Reporting', 5, 90000.00, '2024-04-01', '2024-10-31', 'active'),
('Mobile App', 1, 250000.00, '2024-05-01', '2024-12-31', 'planning'),
('Data Analytics', 5, 180000.00, '2024-06-01', '2024-12-31', 'active');

-- ===========================================
-- BASIC STORED PROCEDURES
-- ===========================================

-- Change delimiter for procedure definitions
DELIMITER $$

-- Create a simple stored procedure
CREATE PROCEDURE GetAllEmployees()
BEGIN
    SELECT id, name, department, salary, hire_date
    FROM employees
    WHERE active = TRUE
    ORDER BY name;
END$$

DELIMITER ;

-- Call the procedure
CALL GetAllEmployees();

-- Create procedure to get employee count
DELIMITER $$

CREATE PROCEDURE GetEmployeeCount()
BEGIN
    DECLARE emp_count INT;

    SELECT COUNT(*) INTO emp_count
    FROM employees
    WHERE active = TRUE;

    SELECT CONCAT('Total active employees: ', emp_count) as message;
END$$

DELIMITER ;

CALL GetEmployeeCount();

-- ===========================================
-- STORED PROCEDURES WITH PARAMETERS
-- ===========================================

-- Procedure with IN parameter
DELIMITER $$

CREATE PROCEDURE GetEmployeesByDepartment(IN dept_name VARCHAR(50))
BEGIN
    SELECT id, name, salary, hire_date, email
    FROM employees
    WHERE department = dept_name AND active = TRUE
    ORDER BY salary DESC;
END$$

DELIMITER ;

-- Call with parameter
CALL GetEmployeesByDepartment('IT');
CALL GetEmployeesByDepartment('Sales');

-- Procedure with multiple IN parameters
DELIMITER $$

CREATE PROCEDURE GetEmployeesBySalaryRange(
    IN min_salary DECIMAL(10,2),
    IN max_salary DECIMAL(10,2)
)
BEGIN
    SELECT name, department, salary, hire_date
    FROM employees
    WHERE salary BETWEEN min_salary AND max_salary
    AND active = TRUE
    ORDER BY salary;
END$$

DELIMITER ;

CALL GetEmployeesBySalaryRange(60000, 80000);

-- Procedure with IN and OUT parameters
DELIMITER $$

CREATE PROCEDURE GetDepartmentStats(
    IN dept_name VARCHAR(50),
    OUT emp_count INT,
    OUT avg_salary DECIMAL(10,2),
    OUT total_budget DECIMAL(12,2)
)
BEGIN
    -- Get employee count
    SELECT COUNT(*) INTO emp_count
    FROM employees
    WHERE department = dept_name AND active = TRUE;

    -- Get average salary
    SELECT IFNULL(AVG(salary), 0) INTO avg_salary
    FROM employees
    WHERE department = dept_name AND active = TRUE;

    -- Get department budget
    SELECT budget INTO total_budget
    FROM departments
    WHERE name = dept_name;
END$$

DELIMITER ;

-- Call procedure with OUT parameters
CALL GetDepartmentStats('IT', @count, @avg_sal, @budget);
SELECT @count as employee_count, @avg_sal as average_salary, @budget as department_budget;

-- ===========================================
-- STORED PROCEDURES WITH ERROR HANDLING
-- ===========================================

-- Procedure with input validation and error handling
DELIMITER $$

CREATE PROCEDURE SafeEmployeeInsert(
    IN emp_name VARCHAR(50),
    IN emp_dept VARCHAR(50),
    IN emp_salary DECIMAL(10,2),
    IN emp_email VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SELECT 'Error occurred while inserting employee' as error_message,
               'Please check your input data' as suggestion;
    END;

    -- Validate inputs
    IF emp_name IS NULL OR LENGTH(TRIM(emp_name)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee name cannot be empty';
    END IF;

    IF emp_salary < 30000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary must be at least 30,000';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM departments WHERE name = emp_dept) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid department name';
    END IF;

    -- Check for duplicate email
    IF EXISTS (SELECT 1 FROM employees WHERE email = emp_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email address already exists';
    END IF;

    -- Insert employee
    INSERT INTO employees (name, department, salary, hire_date, email)
    VALUES (TRIM(emp_name), emp_dept, emp_salary, CURDATE(), emp_email);

    -- Log the action
    INSERT INTO audit_log (action, table_name, record_id, new_value, user_name)
    VALUES ('INSERT', 'employees', LAST_INSERT_ID(),
            CONCAT('Name: ', TRIM(emp_name), ', Dept: ', emp_dept, ', Salary: ', emp_salary),
            USER());

    SELECT 'Employee inserted successfully' as message, LAST_INSERT_ID() as new_employee_id;
END$$

DELIMITER ;

-- Test error handling
CALL SafeEmployeeInsert('', 'IT', 75000, 'test@test.com');  -- Empty name
CALL SafeEmployeeInsert('John Doe', 'IT', 25000, 'john@test.com');  -- Low salary
CALL SafeEmployeeInsert('Jane Smith', 'InvalidDept', 65000, 'jane@test.com');  -- Invalid department
CALL SafeEmployeeInsert('Valid Employee', 'HR', 65000, 'valid@test.com');  -- Should succeed

-- ===========================================
-- STORED PROCEDURES WITH TRANSACTIONS
-- ===========================================

-- Procedure with transaction handling
DELIMITER $$

CREATE PROCEDURE TransferEmployee(
    IN emp_id INT,
    IN new_dept VARCHAR(50)
)
BEGIN
    DECLARE old_dept VARCHAR(50);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction failed - changes rolled back' as error_message;
    END;

    START TRANSACTION;

    -- Get current department
    SELECT department INTO old_dept
    FROM employees
    WHERE id = emp_id AND active = TRUE;

    IF old_dept IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee not found or inactive';
    END IF;

    -- Update employee department
    UPDATE employees
    SET department = new_dept
    WHERE id = emp_id;

    -- Log the transfer
    INSERT INTO audit_log (action, table_name, record_id, old_value, new_value, user_name)
    VALUES ('UPDATE', 'employees', emp_id,
            CONCAT('Department: ', old_dept),
            CONCAT('Department: ', new_dept),
            USER());

    COMMIT;
    SELECT CONCAT('Employee successfully transferred from ', old_dept, ' to ', new_dept) as message;
END$$

DELIMITER ;

-- Test transaction procedure
CALL TransferEmployee(1, 'Finance');  -- Should succeed
CALL TransferEmployee(999, 'IT');     -- Should fail

-- ===========================================
-- CREATING AND USING VIEWS
-- ===========================================

-- Create a simple view
CREATE VIEW active_employees AS
SELECT id, name, department, salary, email, hire_date
FROM employees
WHERE active = TRUE;

-- Query the view
SELECT * FROM active_employees ORDER BY department, name;

-- Create a view with calculated columns
CREATE VIEW employee_salary_analysis AS
SELECT
    department,
    COUNT(*) as employee_count,
    ROUND(AVG(salary), 2) as avg_salary,
    MIN(salary) as min_salary,
    MAX(salary) as max_salary,
    ROUND(STDDEV(salary), 2) as salary_stddev
FROM employees
WHERE active = TRUE
GROUP BY department;

-- Query the analysis view
SELECT * FROM employee_salary_analysis
ORDER BY avg_salary DESC;

-- ===========================================
-- COMPLEX VIEWS WITH JOINS
-- ===========================================

-- Create a comprehensive project view
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
    p.status,
    DATEDIFF(p.end_date, p.start_date) as duration_days,
    CASE
        WHEN p.status = 'completed' THEN 'Finished'
        WHEN p.status = 'active' THEN 'In Progress'
        WHEN p.status = 'planning' THEN 'Not Started'
        ELSE 'Cancelled'
    END as status_description
FROM projects p
JOIN departments d ON p.department_id = d.id;

-- Query the project details view
SELECT * FROM project_details
ORDER BY budget_percentage DESC;

-- Create department performance view
CREATE VIEW dept_performance AS
SELECT
    d.name as department,
    d.budget as dept_budget,
    COUNT(DISTINCT e.id) as employee_count,
    COUNT(DISTINCT p.id) as project_count,
    ROUND(AVG(e.salary), 2) as avg_salary,
    COALESCE(SUM(p.budget), 0) as total_project_budget,
    ROUND(COALESCE(SUM(p.budget), 0) / d.budget * 100, 2) as budget_utilization,
    COUNT(CASE WHEN p.status = 'active' THEN 1 END) as active_projects,
    COUNT(CASE WHEN p.status = 'completed' THEN 1 END) as completed_projects
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
LEFT JOIN projects p ON d.id = p.department_id
GROUP BY d.id, d.name, d.budget;

-- Query department performance
SELECT * FROM dept_performance
ORDER BY budget_utilization DESC;

-- ===========================================
-- UPDATING AND MANAGING VIEWS
-- ===========================================

-- Update a view using CREATE OR REPLACE
CREATE OR REPLACE VIEW active_employees AS
SELECT id, name, department, salary, email, hire_date,
       TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) as years_with_company
FROM employees
WHERE active = TRUE;

-- Check updated view
SELECT name, department, years_with_company
FROM active_employees
ORDER BY years_with_company DESC;

-- Create a view with CHECK OPTION (MySQL 8.0+)
CREATE VIEW it_employees AS
SELECT id, name, salary, hire_date
FROM employees
WHERE department = 'IT' AND active = TRUE
WITH CHECK OPTION;

-- Test CHECK OPTION
INSERT INTO it_employees (name, salary, hire_date) VALUES
('New IT Employee', 70000, CURDATE());  -- Should work

-- This would fail due to CHECK OPTION:
-- INSERT INTO it_employees (name, salary, hire_date) VALUES
-- ('New HR Employee', 65000, CURDATE());  -- Would fail

-- Drop views
DROP VIEW IF EXISTS employee_salary_analysis;
DROP VIEW IF EXISTS project_details;

-- Check remaining views
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- ===========================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ===========================================

-- Create indexes on commonly queried columns
CREATE INDEX idx_employees_department ON employees(department);
CREATE INDEX idx_employees_salary ON employees(salary);
CREATE INDEX idx_employees_active ON employees(active);
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_projects_dept_status ON projects(department_id, status);
CREATE INDEX idx_projects_budget ON projects(budget);
CREATE INDEX idx_departments_name ON departments(name);

-- Check index performance with EXPLAIN
EXPLAIN SELECT name, salary, department
FROM employees
WHERE department = 'IT' AND active = TRUE
ORDER BY salary DESC;

EXPLAIN SELECT name, email
FROM employees
WHERE email LIKE '%@company.com';

-- Analyze table for index optimization
ANALYZE TABLE employees;
ANALYZE TABLE projects;

-- Show all indexes on employees table
SHOW INDEXES FROM employees;

-- Drop an index
DROP INDEX idx_employees_active ON employees;

-- Create composite index for complex queries
CREATE INDEX idx_emp_dept_salary ON employees(department, salary);

-- Test composite index performance
EXPLAIN SELECT name, salary
FROM employees
WHERE department = 'IT' AND salary > 70000;

-- ===========================================
-- STORED PROCEDURES USING VIEWS
-- ===========================================

-- Create procedure that uses views
DELIMITER $$

CREATE PROCEDURE GenerateDepartmentReport(IN dept_name VARCHAR(50))
BEGIN
    -- Check if department exists
    IF NOT EXISTS (SELECT 1 FROM departments WHERE name = dept_name) THEN
        SELECT CONCAT('Error: Department ', dept_name, ' not found') as error_message;
    ELSE
        -- Department overview
        SELECT 'DEPARTMENT OVERVIEW' as section;
        SELECT * FROM dept_performance WHERE department = dept_name;

        -- Employee details
        SELECT '' as separator;
        SELECT 'ACTIVE EMPLOYEES' as section;
        SELECT name, salary, hire_date, years_with_company
        FROM active_employees
        WHERE department = dept_name
        ORDER BY salary DESC;

        -- Project details
        SELECT '' as separator;
        SELECT 'PROJECT DETAILS' as section;
        SELECT project_name, project_budget, budget_percentage, status_description
        FROM project_details
        WHERE department_name = dept_name
        ORDER BY budget_percentage DESC;
    END IF;
END$$

DELIMITER ;

-- Test the comprehensive report procedure
CALL GenerateDepartmentReport('IT');
CALL GenerateDepartmentReport('Sales');

-- ===========================================
-- ADVANCED STORED PROCEDURE FEATURES
-- ===========================================

-- Procedure with dynamic SQL
DELIMITER $$

CREATE PROCEDURE DynamicEmployeeSearch(
    IN search_column VARCHAR(50),
    IN search_value VARCHAR(100)
)
BEGIN
    DECLARE sql_query TEXT;

    -- Validate column name for security
    IF search_column NOT IN ('name', 'department', 'email') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid search column';
    END IF;

    -- Build dynamic query
    SET sql_query = CONCAT(
        'SELECT id, name, department, salary, email FROM employees ',
        'WHERE ', search_column, ' LIKE ? AND active = TRUE ',
        'ORDER BY name'
    );

    -- Prepare and execute
    SET @search_pattern = CONCAT('%', search_value, '%');
    PREPARE stmt FROM sql_query;
    EXECUTE stmt USING @search_pattern;
    DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;

-- Test dynamic SQL procedure
CALL DynamicEmployeeSearch('name', 'Aa');
CALL DynamicEmployeeSearch('department', 'IT');

-- Procedure with cursor for processing multiple rows
DELIMITER $$

CREATE PROCEDURE ProcessSalaryIncrease(
    IN dept_name VARCHAR(50),
    IN increase_percentage DECIMAL(5,2)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE emp_salary DECIMAL(10,2);
    DECLARE cur CURSOR FOR
        SELECT id, salary FROM employees
        WHERE department = dept_name AND active = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Start transaction
    START TRANSACTION;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO emp_id, emp_salary;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Update salary
        UPDATE employees
        SET salary = salary * (1 + increase_percentage / 100)
        WHERE id = emp_id;

        -- Log the change
        INSERT INTO audit_log (action, table_name, record_id, old_value, new_value, user_name)
        VALUES ('UPDATE', 'employees', emp_id,
                CONCAT('Salary: ', emp_salary),
                CONCAT('Salary: ', emp_salary * (1 + increase_percentage / 100)),
                USER());
    END LOOP;

    CLOSE cur;
    COMMIT;

    SELECT CONCAT('Salary increase of ', increase_percentage, '% applied to ', dept_name, ' department') as message;
END$$

DELIMITER ;

-- Test cursor procedure
CALL ProcessSalaryIncrease('IT', 5.0);

-- Verify the changes
SELECT name, department, salary FROM employees WHERE department = 'IT';

-- ===========================================
-- BUSINESS INTELLIGENCE DASHBOARD
-- ===========================================

-- Create comprehensive dashboard view
CREATE VIEW company_dashboard AS
SELECT
    'COMPANY OVERVIEW' as report_type,
    COUNT(DISTINCT d.id) as total_departments,
    COUNT(DISTINCT e.id) as total_employees,
    COUNT(DISTINCT p.id) as total_projects,
    ROUND(AVG(e.salary), 2) as company_avg_salary,
    SUM(d.budget) as total_budget,
    SUM(p.budget) as total_project_budget,
    COUNT(CASE WHEN p.status = 'active' THEN 1 END) as active_projects,
    COUNT(CASE WHEN p.status = 'completed' THEN 1 END) as completed_projects
FROM departments d
CROSS JOIN (SELECT COUNT(*) as dummy FROM employees LIMIT 1) dummy_table
LEFT JOIN employees e ON 1=1  -- Cross join effect
LEFT JOIN projects p ON 1=1;  -- Cross join effect

-- Create monthly metrics procedure
DELIMITER $$

CREATE PROCEDURE GetMonthlyMetrics(IN target_year INT, IN target_month INT)
BEGIN
    DECLARE start_date DATE;
    DECLARE end_date DATE;

    SET start_date = DATE(CONCAT(target_year, '-', LPAD(target_month, 2, '0'), '-01'));
    SET end_date = LAST_DAY(start_date);

    SELECT 'MONTHLY METRICS' as report_type;
    SELECT
        target_year as year,
        target_month as month,
        COUNT(CASE WHEN e.hire_date BETWEEN start_date AND end_date THEN 1 END) as new_hires,
        COUNT(CASE WHEN p.start_date BETWEEN start_date AND end_date THEN 1 END) as projects_started,
        COUNT(CASE WHEN p.end_date BETWEEN start_date AND end_date AND p.status = 'completed' THEN 1 END) as projects_completed,
        ROUND(AVG(CASE WHEN e.hire_date <= end_date THEN e.salary END), 2) as avg_salary
    FROM employees e
    CROSS JOIN projects p;
END$$

DELIMITER ;

-- Test monthly metrics
CALL GetMonthlyMetrics(2023, 6);

-- ===========================================
-- CLEANUP: Drop objects (uncomment to clean up)
-- ===========================================

/*
-- Drop procedures
DROP PROCEDURE IF EXISTS GetAllEmployees;
DROP PROCEDURE IF EXISTS GetEmployeeCount;
DROP PROCEDURE IF EXISTS GetEmployeesByDepartment;
DROP PROCEDURE IF EXISTS GetEmployeesBySalaryRange;
DROP PROCEDURE IF EXISTS GetDepartmentStats;
DROP PROCEDURE IF EXISTS SafeEmployeeInsert;
DROP PROCEDURE IF EXISTS TransferEmployee;
DROP PROCEDURE IF EXISTS GenerateDepartmentReport;
DROP PROCEDURE IF EXISTS DynamicEmployeeSearch;
DROP PROCEDURE IF EXISTS ProcessSalaryIncrease;
DROP PROCEDURE IF EXISTS GetMonthlyMetrics;

-- Drop views
DROP VIEW IF EXISTS active_employees;
DROP VIEW IF EXISTS employee_salary_analysis;
DROP VIEW IF EXISTS dept_performance;
DROP VIEW IF EXISTS it_employees;
DROP VIEW IF EXISTS company_dashboard;

-- Drop indexes
DROP INDEX IF EXISTS idx_employees_department ON employees;
DROP INDEX IF EXISTS idx_employees_salary ON employees;
DROP INDEX IF EXISTS idx_employees_email ON employees;
DROP INDEX IF EXISTS idx_projects_dept_status ON projects;
DROP INDEX IF EXISTS idx_projects_budget ON projects;
DROP INDEX IF EXISTS idx_departments_name ON departments;
DROP INDEX IF EXISTS idx_emp_dept_salary ON employees;

-- Drop tables
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP DATABASE IF EXISTS procedures_views_db;
*/</content>
<parameter name="filePath">d:\SQL\12-Stored-Procedures-and-Views\examples.sql