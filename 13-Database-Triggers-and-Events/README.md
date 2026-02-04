# Lab 13: Database Triggers and Events

## Overview
This lab covers MySQL triggers and scheduled events, essential for automating database operations and maintaining data integrity. You'll learn to create triggers that automatically execute in response to data changes and schedule events for recurring tasks.

## Learning Objectives
- Understand trigger concepts and types (BEFORE/AFTER, INSERT/UPDATE/DELETE)
- Create and manage database triggers
- Implement business logic through triggers
- Work with scheduled events and event scheduling
- Handle trigger execution order and conflicts
- Debug and troubleshoot trigger issues

## Prerequisites
- Lab 12: Stored Procedures and Views
- Basic understanding of SQL operations
- Familiarity with database transactions

## Estimated Time: 120 minutes

## Step-by-Step Guide

### Step 1: Understanding Triggers
Triggers are special stored procedures that automatically execute when specific events occur in the database.

**Trigger Types:**
- **BEFORE triggers**: Execute before the triggering event
- **AFTER triggers**: Execute after the triggering event
- **INSTEAD OF triggers**: Execute instead of the triggering event (MySQL doesn't support these)

**Trigger Events:**
- INSERT: When new rows are added
- UPDATE: When existing rows are modified
- DELETE: When rows are removed

### Step 2: Setting Up the Environment
Let's create a sample database for our trigger examples.

**Create the database and tables:**
```sql
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
```

### Step 3: Creating Basic Triggers
Let's start with simple triggers that log changes to the audit table.

**AFTER INSERT Trigger:**
```sql
DELIMITER $$

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

DELIMITER ;
```

**AFTER UPDATE Trigger:**
```sql
DELIMITER $$

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

DELIMITER ;
```

**AFTER DELETE Trigger:**
```sql
DELIMITER $$

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
```

### Step 4: BEFORE Triggers for Data Validation
BEFORE triggers can modify data before it's inserted or validate it.

**BEFORE INSERT Trigger for Validation:**
```sql
DELIMITER $$

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

    -- Set default department if not provided
    IF NEW.department IS NULL OR NEW.department = '' THEN
        SET NEW.department = 'General';
    END IF;

    -- Capitalize name
    SET NEW.name = TRIM(UPPER(NEW.name));
END$$

DELIMITER ;
```

**BEFORE UPDATE Trigger for Salary Changes:**
```sql
DELIMITER $$

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
    END IF;
END$$

DELIMITER ;
```

### Step 5: Working with Scheduled Events
Events allow you to schedule tasks to run automatically.

**Enable Event Scheduler:**
```sql
-- Check if event scheduler is enabled
SHOW VARIABLES LIKE 'event_scheduler';

-- Enable event scheduler (if not already enabled)
SET GLOBAL event_scheduler = ON;
```

**Create a Simple Event:**
```sql
DELIMITER $$

CREATE EVENT monthly_salary_review
ON SCHEDULE EVERY 1 MONTH STARTS '2024-02-01 09:00:00'
DO
BEGIN
    -- Create notifications for employees due for review
    INSERT INTO notifications (message, recipient)
    SELECT CONCAT('Monthly salary review due for: ', name),
           CONCAT(name, '@company.com')
    FROM employees
    WHERE hire_date <= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
END$$

DELIMITER ;
```

**Create a Daily Cleanup Event:**
```sql
DELIMITER $$

CREATE EVENT daily_audit_cleanup
ON SCHEDULE EVERY 1 DAY STARTS CURDATE() + INTERVAL 1 DAY
DO
BEGIN
    -- Remove audit logs older than 1 year
    DELETE FROM audit_log
    WHERE operation_time < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

    -- Log the cleanup operation
    INSERT INTO notifications (message, recipient, status)
    VALUES (CONCAT('Daily cleanup completed. Removed ',
                   ROW_COUNT(), ' old audit records.'),
            'admin@company.com', 'sent');
END$$

DELIMITER ;
```

### Step 6: Managing Triggers and Events
Learn how to view, modify, and remove triggers and events.

**View Existing Triggers:**
```sql
-- Show all triggers
SHOW TRIGGERS;

-- Show triggers for specific table
SHOW TRIGGERS WHERE `table` = 'employees';

-- Get trigger details from information_schema
SELECT * FROM information_schema.triggers
WHERE trigger_schema = 'triggers_events_db';
```

**View Existing Events:**
```sql
-- Show all events
SHOW EVENTS;

-- Show events from information_schema
SELECT * FROM information_schema.events
WHERE event_schema = 'triggers_events_db';
```

**Drop Triggers and Events:**
```sql
-- Drop triggers
DROP TRIGGER IF EXISTS audit_employee_insert;
DROP TRIGGER IF EXISTS audit_employee_update;
DROP TRIGGER IF EXISTS audit_employee_delete;
DROP TRIGGER IF EXISTS validate_employee_before_insert;
DROP TRIGGER IF EXISTS track_salary_changes;

-- Drop events
DROP EVENT IF EXISTS monthly_salary_review;
DROP EVENT IF EXISTS daily_audit_cleanup;
```

### Step 7: Advanced Trigger Concepts
Understanding trigger execution order and best practices.

**Multiple Triggers on Same Event:**
```sql
-- MySQL allows multiple triggers of the same type
-- They execute in creation order (FIFO)

DELIMITER $$

CREATE TRIGGER salary_notification_after_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.salary != NEW.salary THEN
        INSERT INTO notifications (message, recipient)
        VALUES (CONCAT('Salary changed for ', NEW.name,
                      ' from $', OLD.salary, ' to $', NEW.salary),
                'hr@company.com');
    END IF;
END$$

DELIMITER ;
```

**Trigger Execution Order:**
```sql
-- View trigger execution order
SELECT trigger_name, action_timing, event_manipulation, action_order
FROM information_schema.triggers
WHERE trigger_schema = 'triggers_events_db'
ORDER BY action_order;
```

### Step 8: Best Practices and Troubleshooting

**Trigger Best Practices:**
1. Keep triggers simple and focused
2. Avoid recursive triggers
3. Use appropriate trigger types (BEFORE vs AFTER)
4. Handle errors gracefully
5. Document trigger purposes
6. Test thoroughly before deployment

**Common Issues:**
- Infinite loops from recursive triggers
- Performance impact on DML operations
- Complex error handling
- Trigger execution order dependencies

**Debugging Triggers:**
```sql
-- Check trigger execution
SELECT * FROM audit_log ORDER BY operation_time DESC LIMIT 10;

-- Monitor trigger performance
SHOW PROCESSLIST;

-- Check for errors in triggers
SHOW ERRORS;
```

## Exercises

### Exercise 1: Basic Audit Trigger
Create a trigger that logs all changes to the employees table with detailed information about what changed.

### Exercise 2: Business Rule Enforcement
Create triggers that enforce business rules like:
- Department budget limits
- Maximum salary constraints
- Employee count restrictions

### Exercise 3: Automated Notifications
Create triggers that automatically send notifications for:
- High-value salary changes
- New employee onboarding
- Department transfers

### Exercise 4: Scheduled Maintenance
Create events for:
- Weekly database backups
- Monthly report generation
- Quarterly data archiving

### Exercise 5: Complex Trigger Logic
Create a trigger that handles complex business logic like:
- Automatic project assignments
- Inventory level management
- Approval workflow initiation

## Summary
In this lab, you learned:
- How to create and manage database triggers
- The difference between BEFORE and AFTER triggers
- Implementing business logic through triggers
- Working with scheduled events
- Best practices for trigger development
- Troubleshooting common trigger issues

Triggers and events are powerful tools for automating database operations and maintaining data integrity. Use them judiciously to avoid performance issues and complex dependencies.

## Next Steps
- Lab 14: Performance Tuning and Optimization
- Lab 15: Database Security and User Management
- Lab 16: Backup, Recovery, and High Availability