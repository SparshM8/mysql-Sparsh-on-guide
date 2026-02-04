-- Lab 13: Database Triggers and Events
-- Comprehensive SQL examples for triggers and scheduled events

-- ===========================================
-- SETUP: Create sample database and tables
-- ===========================================

-- Create database
CREATE DATABASE IF NOT EXISTS triggers_events_db;
USE triggers_events_db;

-- Create employees table
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create audit_log table for tracking changes
CREATE TABLE audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    operation VARCHAR(10),
    record_id INT,
    old_values JSON,
    new_values JSON,
    user_name VARCHAR(100),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create salary_history table
CREATE TABLE salary_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(255),
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- Create notifications table
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    message TEXT,
    recipient VARCHAR(100),
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'sent', 'failed') DEFAULT 'pending'
);

-- Create departments table with budget tracking
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    budget DECIMAL(12,2),
    current_spending DECIMAL(12,2) DEFAULT 0,
    employee_count INT DEFAULT 0,
    max_employees INT DEFAULT 50
);

-- Insert sample departments
INSERT INTO departments (name, budget, max_employees) VALUES
('IT', 500000.00, 20),
('HR', 300000.00, 15),
('Sales', 400000.00, 25),
('Marketing', 350000.00, 18),
('Finance', 450000.00, 12);

-- ===========================================
-- BASIC AUDIT TRIGGERS
-- ===========================================

-- Change delimiter for trigger definitions
DELIMITER $$

-- AFTER INSERT trigger for audit logging
CREATE TRIGGER audit_employee_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, new_values, user_name)
    VALUES ('employees', 'INSERT', NEW.id,
            JSON_OBJECT('name', NEW.name, 'department', NEW.department,
                        'salary', NEW.salary, 'hire_date', NEW.hire_date),
            USER());
END$$

-- AFTER UPDATE trigger for audit logging
CREATE TRIGGER audit_employee_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id,
                          old_values, new_values, user_name)
    VALUES ('employees', 'UPDATE', NEW.id,
            JSON_OBJECT('name', OLD.name, 'department', OLD.department,
                        'salary', OLD.salary, 'hire_date', OLD.hire_date),
            JSON_OBJECT('name', NEW.name, 'department', NEW.department,
                        'salary', NEW.salary, 'hire_date', NEW.hire_date),
            USER());
END$$

-- AFTER DELETE trigger for audit logging
CREATE TRIGGER audit_employee_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, old_values, user_name)
    VALUES ('employees', 'DELETE', OLD.id,
            JSON_OBJECT('name', OLD.name, 'department', OLD.department,
                        'salary', OLD.salary, 'hire_date', OLD.hire_date),
            USER());
END$$

DELIMITER ;

-- Test the audit triggers
INSERT INTO employees (name, department, salary, hire_date) VALUES
('John Doe', 'IT', 75000.00, '2024-01-15'),
('Jane Smith', 'HR', 65000.00, '2024-02-20');

UPDATE employees SET salary = 80000.00 WHERE name = 'John Doe';

DELETE FROM employees WHERE name = 'Jane Smith';

-- Check audit log
SELECT * FROM audit_log ORDER BY operation_time DESC;

-- ===========================================
-- BEFORE TRIGGERS FOR DATA VALIDATION
-- ===========================================

DELIMITER $$

-- BEFORE INSERT trigger for validation and data cleaning
CREATE TRIGGER validate_employee_before_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Validate salary is positive
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than 0';
    END IF;

    -- Validate hire date is not in the future
    IF NEW.hire_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hire date cannot be in the future';
    END IF;

    -- Validate department exists
    IF NEW.department IS NOT NULL AND
       NOT EXISTS (SELECT 1 FROM departments WHERE name = NEW.department) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid department name';
    END IF;

    -- Set default department if not provided
    IF NEW.department IS NULL OR NEW.department = '' THEN
        SET NEW.department = 'General';
    END IF;

    -- Capitalize and trim name
    SET NEW.name = TRIM(UPPER(NEW.name));
END$$

-- BEFORE UPDATE trigger for salary tracking and validation
CREATE TRIGGER track_salary_changes
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Only track if salary actually changed
    IF OLD.salary != NEW.salary THEN
        INSERT INTO salary_history (employee_id, old_salary, new_salary, reason)
        VALUES (OLD.id, OLD.salary, NEW.salary, 'Salary update via trigger');

        -- Prevent salary decreases over 20%
        IF NEW.salary < OLD.salary * 0.8 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Salary cannot be decreased by more than 20%';
        END IF;

        -- Notify for large salary increases
        IF NEW.salary > OLD.salary * 1.5 THEN
            INSERT INTO notifications (message, recipient)
            VALUES (CONCAT('Large salary increase for ', NEW.name,
                          ': $', OLD.salary, ' → $', NEW.salary),
                    'hr@company.com');
        END IF;
    END IF;
END$$

DELIMITER ;

-- Test BEFORE triggers
INSERT INTO employees (name, department, salary, hire_date) VALUES
('Alice Johnson', 'IT', 70000.00, '2024-03-10'),
('Bob Wilson', 'Sales', 60000.00, '2024-04-05');

-- Test validation (this should fail)
-- INSERT INTO employees (name, department, salary, hire_date) VALUES
-- ('Charlie Brown', 'IT', -50000.00, '2024-05-01');

-- Test salary update
UPDATE employees SET salary = 75000.00 WHERE name = 'ALICE JOHNSON';

-- Check salary history
SELECT * FROM salary_history;

-- ===========================================
-- DEPARTMENT BUDGET MANAGEMENT TRIGGERS
-- ===========================================

DELIMITER $$

-- BEFORE INSERT trigger for department budget control
CREATE TRIGGER check_department_budget_before_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    DECLARE dept_budget DECIMAL(12,2);
    DECLARE dept_spending DECIMAL(12,2);
    DECLARE dept_max_emp INT;
    DECLARE dept_current_emp INT;

    -- Get department information
    SELECT budget, current_spending, max_employees, employee_count
    INTO dept_budget, dept_spending, dept_max_emp, dept_current_emp
    FROM departments
    WHERE name = NEW.department;

    -- Check employee count limit
    IF dept_current_emp >= dept_max_emp THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department has reached maximum employee count';
    END IF;

    -- Check budget limit (assuming salary is annual)
    IF dept_spending + NEW.salary > dept_budget THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Adding this employee would exceed department budget';
    END IF;
END$$

-- AFTER INSERT trigger to update department spending
CREATE TRIGGER update_department_spending_after_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    UPDATE departments
    SET current_spending = current_spending + NEW.salary,
        employee_count = employee_count + 1
    WHERE name = NEW.department;
END$$

-- AFTER DELETE trigger to update department spending
CREATE TRIGGER update_department_spending_after_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    UPDATE departments
    SET current_spending = current_spending - OLD.salary,
        employee_count = employee_count - 1
    WHERE name = OLD.department;
END$$

-- BEFORE UPDATE trigger for department transfers
CREATE TRIGGER handle_department_transfer
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Only process if department changed
    IF OLD.department != NEW.department THEN
        DECLARE old_dept_budget DECIMAL(12,2);
        DECLARE old_dept_spending DECIMAL(12,2);
        DECLARE old_dept_max_emp INT;
        DECLARE old_dept_current_emp INT;
        DECLARE new_dept_budget DECIMAL(12,2);
        DECLARE new_dept_spending DECIMAL(12,2);
        DECLARE new_dept_max_emp INT;
        DECLARE new_dept_current_emp INT;

        -- Get old department info
        SELECT budget, current_spending, max_employees, employee_count
        INTO old_dept_budget, old_dept_spending, old_dept_max_emp, old_dept_current_emp
        FROM departments WHERE name = OLD.department;

        -- Get new department info
        SELECT budget, current_spending, max_employees, employee_count
        INTO new_dept_budget, new_dept_spending, new_dept_max_emp, new_dept_current_emp
        FROM departments WHERE name = NEW.department;

        -- Check if new department can accommodate the employee
        IF new_dept_current_emp >= new_dept_max_emp THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'New department has reached maximum employee count';
        END IF;

        IF new_dept_spending + NEW.salary > new_dept_budget THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer would exceed new department budget';
        END IF;

        -- Update spending for both departments
        UPDATE departments
        SET current_spending = current_spending - OLD.salary,
            employee_count = employee_count - 1
        WHERE name = OLD.department;

        UPDATE departments
        SET current_spending = current_spending + NEW.salary,
            employee_count = employee_count + 1
        WHERE name = NEW.department;
    END IF;
END$$

DELIMITER ;

-- Test department budget triggers
INSERT INTO employees (name, department, salary, hire_date) VALUES
('David Lee', 'Finance', 85000.00, '2024-06-01'),
('Eva Garcia', 'Marketing', 55000.00, '2024-07-15');

-- Check department status
SELECT * FROM departments;

-- Test department transfer
UPDATE employees SET department = 'HR' WHERE name = 'EVA GARCIA';

-- Check updated department status
SELECT * FROM departments;

-- ===========================================
-- SCHEDULED EVENTS
-- ===========================================

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- Check if event scheduler is running
SHOW VARIABLES LIKE 'event_scheduler';

DELIMITER $$

-- Monthly salary review event
CREATE EVENT monthly_salary_review
ON SCHEDULE EVERY 1 MONTH STARTS '2024-02-01 09:00:00'
DO
BEGIN
    -- Create notifications for employees due for review
    INSERT INTO notifications (message, recipient)
    SELECT CONCAT('Monthly salary review due for: ', name, ' (Hired: ', hire_date, ')'),
           CONCAT(LOWER(REPLACE(name, ' ', '.')), '@company.com')
    FROM employees
    WHERE hire_date <= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    AND MOD(TIMESTAMPDIFF(MONTH, hire_date, CURDATE()), 6) = 0; -- Every 6 months
END$$

-- Daily audit log cleanup event
CREATE EVENT daily_audit_cleanup
ON SCHEDULE EVERY 1 DAY STARTS CURDATE() + INTERVAL 1 DAY
DO
BEGIN
    DECLARE deleted_count INT DEFAULT 0;

    -- Remove audit logs older than 1 year
    DELETE FROM audit_log
    WHERE operation_time < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

    SET deleted_count = ROW_COUNT();

    -- Log the cleanup operation
    INSERT INTO notifications (message, recipient, status)
    VALUES (CONCAT('Daily cleanup completed. Removed ', deleted_count, ' old audit records.'),
            'admin@company.com', 'sent');
END$$

-- Weekly department budget report event
CREATE EVENT weekly_budget_report
ON SCHEDULE EVERY 1 WEEK STARTS CURDATE() + INTERVAL 1 DAY
DO
BEGIN
    -- Generate budget reports for departments over 90% utilization
    INSERT INTO notifications (message, recipient, status)
    SELECT CONCAT('Budget Alert: ', name, ' department is at ',
                 ROUND((current_spending / budget) * 100, 1), '% capacity'),
           'management@company.com',
           'pending'
    FROM departments
    WHERE (current_spending / budget) > 0.9;
END$$

-- Quarterly performance review event
CREATE EVENT quarterly_performance_review
ON SCHEDULE EVERY 3 MONTH STARTS '2024-04-01 08:00:00'
DO
BEGIN
    -- Create performance review notifications
    INSERT INTO notifications (message, recipient)
    SELECT CONCAT('Quarterly performance review due for: ', name,
                 ' (', TIMESTAMPDIFF(MONTH, hire_date, CURDATE()), ' months tenure)'),
           CONCAT(LOWER(REPLACE(name, ' ', '.')), '@company.com')
    FROM employees
    WHERE hire_date <= DATE_SUB(CURDATE(), INTERVAL 3 MONTH);
END$$

DELIMITER ;

-- ===========================================
-- ADVANCED TRIGGER CONCEPTS
-- ===========================================

DELIMITER $$

-- Multiple triggers on the same event (execution order)
CREATE TRIGGER salary_notification_after_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.salary != NEW.salary THEN
        INSERT INTO notifications (message, recipient)
        VALUES (CONCAT('Salary changed for ', NEW.name,
                      ': $', FORMAT(OLD.salary, 2), ' → $', FORMAT(NEW.salary, 2)),
                'hr@company.com');
    END IF;
END$$

-- Trigger for cascading updates (when department name changes)
CREATE TRIGGER cascade_department_name_change
AFTER UPDATE ON departments
FOR EACH ROW
BEGIN
    IF OLD.name != NEW.name THEN
        UPDATE employees
        SET department = NEW.name
        WHERE department = OLD.name;
    END IF;
END$$

-- Trigger with conditional logic and error handling
CREATE TRIGGER complex_business_rules
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    DECLARE dept_name VARCHAR(50);
    DECLARE emp_count INT;
    DECLARE avg_salary DECIMAL(10,2);

    -- Get department info
    SELECT name INTO dept_name
    FROM departments
    WHERE name = NEW.department;

    -- If department not found, create it (with error handling)
    IF dept_name IS NULL THEN
        BEGIN
            DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Could not create department automatically';
            END;

            INSERT INTO departments (name, budget, max_employees)
            VALUES (NEW.department, 100000.00, 10);

            INSERT INTO notifications (message, recipient)
            VALUES (CONCAT('New department created: ', NEW.department),
                    'admin@company.com');
        END;
    END IF;

    -- Business rule: Don't allow more than 3 employees with salary > 100k in same dept
    SELECT COUNT(*), AVG(salary)
    INTO emp_count, avg_salary
    FROM employees
    WHERE department = NEW.department AND salary > 100000;

    IF emp_count >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department already has 3 high-salary employees';
    END IF;

    -- Business rule: New employee salary shouldn't be more than 150% of dept average
    IF NEW.salary > avg_salary * 1.5 AND avg_salary > 0 THEN
        INSERT INTO notifications (message, recipient)
        VALUES (CONCAT('High salary alert: ', NEW.name, ' salary ($', NEW.salary,
                      ') is 150% above department average ($', FORMAT(avg_salary, 2), ')'),
                'ceo@company.com');
    END IF;
END$$

DELIMITER ;

-- ===========================================
-- MANAGING TRIGGERS AND EVENTS
-- ===========================================

-- View all triggers
SHOW TRIGGERS;

-- View triggers for specific table
SHOW TRIGGERS WHERE `table` = 'employees';

-- Get detailed trigger information
SELECT
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    action_statement,
    created
FROM information_schema.triggers
WHERE trigger_schema = DATABASE()
ORDER BY event_object_table, action_timing, action_order;

-- View all events
SHOW EVENTS;

-- Get detailed event information
SELECT
    event_name,
    event_definition,
    event_type,
    execute_at,
    interval_value,
    interval_field,
    starts,
    ends,
    status,
    created
FROM information_schema.events
WHERE event_schema = DATABASE();

-- Check event scheduler status
SHOW VARIABLES LIKE 'event_scheduler';

-- Manually execute an event (for testing)
-- ALTER EVENT monthly_salary_review ENABLE;

-- ===========================================
-- TESTING AND DEBUGGING
-- ===========================================

-- Insert test data
INSERT INTO employees (name, department, salary, hire_date) VALUES
('Test Employee 1', 'IT', 80000.00, '2023-01-15'),
('Test Employee 2', 'HR', 60000.00, '2023-06-20'),
('Test Employee 3', 'Sales', 70000.00, '2023-11-10');

-- Check audit logs
SELECT * FROM audit_log ORDER BY operation_time DESC LIMIT 10;

-- Check salary history
SELECT * FROM salary_history ORDER BY change_date DESC;

-- Check notifications
SELECT * FROM notifications ORDER BY sent_at DESC;

-- Check department status
SELECT * FROM departments;

-- Test trigger with error (should fail)
-- INSERT INTO employees (name, department, salary, hire_date) VALUES
-- ('Invalid Employee', 'IT', -1000.00, '2025-01-01');

-- ===========================================
-- CLEANUP: Drop objects (uncomment to clean up)
-- ===========================================

/*
-- Drop triggers
DROP TRIGGER IF EXISTS audit_employee_insert;
DROP TRIGGER IF EXISTS audit_employee_update;
DROP TRIGGER IF EXISTS audit_employee_delete;
DROP TRIGGER IF EXISTS validate_employee_before_insert;
DROP TRIGGER IF EXISTS track_salary_changes;
DROP TRIGGER IF EXISTS check_department_budget_before_insert;
DROP TRIGGER IF EXISTS update_department_spending_after_insert;
DROP TRIGGER IF EXISTS update_department_spending_after_delete;
DROP TRIGGER IF EXISTS handle_department_transfer;
DROP TRIGGER IF EXISTS salary_notification_after_update;
DROP TRIGGER IF EXISTS cascade_department_name_change;
DROP TRIGGER IF EXISTS complex_business_rules;

-- Drop events
DROP EVENT IF EXISTS monthly_salary_review;
DROP EVENT IF EXISTS daily_audit_cleanup;
DROP EVENT IF EXISTS weekly_budget_report;
DROP EVENT IF EXISTS quarterly_performance_review;

-- Drop tables
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS salary_history;
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- Drop database
DROP DATABASE IF EXISTS triggers_events_db;
*/