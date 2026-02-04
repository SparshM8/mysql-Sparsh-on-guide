-- Advanced Querying Lab - SQL Examples
-- This file contains comprehensive examples of advanced SQL querying techniques in MySQL

-- ===========================================
-- DATABASE SETUP AND SAMPLE DATA
-- ===========================================

CREATE DATABASE IF NOT EXISTS advanced_queries_lab;
USE advanced_queries_lab;

-- Create sample tables
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(50),
    budget DECIMAL(12, 2),
    created_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2),
    department_id INT,
    manager_id INT,
    job_title VARCHAR(50),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12, 2),
    status ENUM('planning', 'active', 'completed', 'cancelled') DEFAULT 'planning',
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Insert sample data
INSERT INTO departments (department_name, location, budget) VALUES
('Engineering', 'Building A', 500000.00),
('Marketing', 'Building B', 300000.00),
('Sales', 'Building C', 400000.00),
('HR', 'Building A', 200000.00),
('Finance', 'Building B', 350000.00);

INSERT INTO employees (first_name, last_name, email, phone, hire_date, salary, department_id, job_title) VALUES
('John', 'Doe', 'john.doe@company.com', '555-0101', '2020-01-15', 75000.00, 1, 'Senior Engineer'),
('Jane', 'Smith', 'jane.smith@company.com', '555-0102', '2019-03-20', 80000.00, 1, 'Engineering Manager'),
('Bob', 'Johnson', 'bob.johnson@company.com', '555-0103', '2021-06-10', 65000.00, 2, 'Marketing Specialist'),
('Alice', 'Williams', 'alice.williams@company.com', '555-0104', '2018-11-05', 90000.00, 3, 'Sales Director'),
('Charlie', 'Brown', 'charlie.brown@company.com', '555-0105', '2022-01-20', 55000.00, 4, 'HR Coordinator'),
('Diana', 'Davis', 'diana.davis@company.com', '555-0106', '2020-09-15', 70000.00, 5, 'Financial Analyst'),
('Eve', 'Miller', 'eve.miller@company.com', '555-0107', '2021-12-01', 60000.00, 2, 'Marketing Coordinator'),
('Frank', 'Wilson', 'frank.wilson@company.com', NULL, '2019-07-30', 85000.00, 1, 'Senior Developer'),
('Grace', 'Moore', 'grace.moore@company.com', '555-0109', '2020-04-25', 72000.00, 3, 'Sales Representative'),
('Henry', 'Taylor', 'henry.taylor@company.com', '555-0110', '2022-03-15', 58000.00, 4, 'HR Assistant');

-- Update manager relationships
UPDATE employees SET manager_id = 2 WHERE employee_id IN (1, 8); -- Engineering team reports to Jane
UPDATE employees SET manager_id = 4 WHERE employee_id IN (3, 7, 9); -- Marketing/Sales report to Alice

INSERT INTO projects (project_name, start_date, end_date, budget, status, department_id) VALUES
('Website Redesign', '2023-01-01', '2023-06-30', 150000.00, 'active', 1),
('Marketing Campaign', '2023-02-01', '2023-05-31', 75000.00, 'active', 2),
('Sales CRM', '2023-03-01', '2023-08-31', 200000.00, 'planning', 3),
('HR System Upgrade', '2022-12-01', '2023-04-30', 100000.00, 'completed', 4),
('Financial Reporting', '2023-01-15', '2023-07-15', 125000.00, 'active', 5);

-- ===========================================
-- BASIC ADVANCED QUERIES
-- ===========================================

-- Example 1: Complex WHERE clause with multiple conditions
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary,
    department_id
FROM employees
WHERE salary BETWEEN 60000 AND 80000
  AND hire_date >= '2020-01-01'
  AND department_id IN (1, 2, 3);

-- Example 2: Pattern matching with LIKE
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    job_title
FROM employees
WHERE first_name LIKE 'J%'
   OR last_name LIKE '%son'
   OR email LIKE '%@company.com';

-- Example 3: NULL value handling
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    phone,
    manager_id
FROM employees
WHERE phone IS NULL
   OR manager_id IS NULL;

-- Example 4: Sorting with multiple columns
SELECT
    department_name,
    COUNT(*) as employee_count,
    AVG(salary) as avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, department_name
ORDER BY employee_count DESC, avg_salary DESC;

-- ===========================================
-- FILTERING TECHNIQUES
-- ===========================================

-- Example 5: BETWEEN for date ranges
SELECT
    project_name,
    start_date,
    end_date,
    budget,
    status
FROM projects
WHERE start_date BETWEEN '2023-01-01' AND '2023-06-30'
  AND budget BETWEEN 100000 AND 200000;

-- Example 6: IN operator with subquery
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location = 'Building A'
);

-- Example 7: EXISTS for correlated subqueries
SELECT
    d.department_name,
    d.location
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
    AND e.salary > 70000
);

-- Example 8: Complex LIKE patterns
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    job_title
FROM employees
WHERE job_title LIKE '%Manager%'
   OR job_title LIKE '%Director%'
   OR job_title LIKE '%Senior%';

-- ===========================================
-- LOGICAL OPERATORS AND COMPLEX CONDITIONS
-- ===========================================

-- Example 9: AND/OR combinations with parentheses
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary,
    hire_date
FROM employees
WHERE (salary > 70000 AND hire_date < '2021-01-01')
   OR (department_id = 1 AND salary BETWEEN 60000 AND 80000);

-- Example 10: NOT operator
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    department_id
FROM employees
WHERE department_id NOT IN (1, 4)
  AND salary NOT BETWEEN 50000 AND 70000;

-- Example 11: Complex boolean expressions
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    job_title,
    salary
FROM employees
WHERE (job_title LIKE '%Engineer%' OR job_title LIKE '%Developer%')
  AND salary >= 65000
  AND (hire_date <= '2020-12-31' OR manager_id IS NOT NULL);

-- ===========================================
-- SORTING AND PAGINATION
-- ===========================================

-- Example 12: ORDER BY with NULLS handling
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    phone,
    salary
FROM employees
ORDER BY phone IS NULL, phone ASC, salary DESC;

-- Example 13: LIMIT and OFFSET for pagination
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary,
    hire_date
FROM employees
ORDER BY hire_date DESC
LIMIT 5 OFFSET 0;  -- First page

-- Example 14: Pagination with calculated values
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary,
    hire_date,
    DATEDIFF(CURRENT_DATE, hire_date) as days_employed
FROM employees
ORDER BY salary DESC
LIMIT 3 OFFSET 3;  -- Second page of 3 results each

-- ===========================================
-- DATA MODIFICATION OPERATIONS
-- ===========================================

-- Example 15: UPDATE with complex WHERE
UPDATE employees
SET salary = salary * 1.10,
    job_title = CONCAT('Senior ', job_title)
WHERE hire_date < '2020-01-01'
  AND salary < 75000
  AND department_id IN (
      SELECT department_id
      FROM departments
      WHERE department_name LIKE '%Engineering%'
  );

-- Example 16: UPDATE with JOIN (using subquery)
UPDATE employees
SET phone = '555-0000'
WHERE employee_id IN (
    SELECT e.employee_id
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.location = 'Building A'
    AND e.phone IS NULL
);

-- Example 17: DELETE with subquery
DELETE FROM employees
WHERE employee_id IN (
    SELECT e.employee_id
    FROM employees e
    LEFT JOIN projects p ON e.department_id = p.department_id
    WHERE p.project_id IS NULL
    AND e.hire_date > '2022-01-01'
);

-- Example 18: Safe DELETE with EXISTS
DELETE FROM projects
WHERE status = 'cancelled'
  AND NOT EXISTS (
      SELECT 1
      FROM employees e
      WHERE e.department_id = projects.department_id
  );

-- ===========================================
-- TABLE STRUCTURE MODIFICATION
-- ===========================================

-- Example 19: ADD COLUMN
ALTER TABLE employees
ADD COLUMN performance_rating INT DEFAULT 3
    CHECK (performance_rating >= 1 AND performance_rating <= 5);

-- Example 20: MODIFY COLUMN
ALTER TABLE employees
MODIFY COLUMN phone VARCHAR(25) NOT NULL DEFAULT 'Not provided';

-- Example 21: ADD CONSTRAINT
ALTER TABLE employees
ADD CONSTRAINT chk_salary_positive CHECK (salary > 0);

-- Example 22: ADD INDEX for performance
ALTER TABLE employees
ADD INDEX idx_salary (salary),
ADD INDEX idx_hire_date (hire_date);

-- Example 23: DROP COLUMN
ALTER TABLE projects
DROP COLUMN budget;

-- Example 24: RENAME TABLE
ALTER TABLE projects
RENAME TO company_projects;

-- Example 25: DROP CONSTRAINT
ALTER TABLE employees
DROP CONSTRAINT chk_salary_positive;

-- Example 26: ADD FOREIGN KEY
ALTER TABLE employees
ADD CONSTRAINT fk_dept_location
FOREIGN KEY (department_id) REFERENCES departments(department_id)
ON DELETE RESTRICT;

-- ===========================================
-- ADVANCED QUERY PATTERNS
-- ===========================================

-- Example 27: Conditional aggregation with CASE
SELECT
    department_name,
    COUNT(*) as total_employees,
    SUM(CASE WHEN salary > 70000 THEN 1 ELSE 0 END) as high_earners,
    AVG(CASE WHEN hire_date >= '2021-01-01' THEN salary ELSE NULL END) as avg_new_hires_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, department_name;

-- Example 28: Window functions (MySQL 8.0+)
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    department_id,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_salary_rank,
    RANK() OVER (ORDER BY salary DESC) as overall_salary_rank
FROM employees;

-- Example 29: Complex subquery with aggregation
SELECT
    d.department_name,
    d.location,
    dept_stats.avg_salary,
    dept_stats.employee_count
FROM departments d
JOIN (
    SELECT
        department_id,
        AVG(salary) as avg_salary,
        COUNT(*) as employee_count
    FROM employees
    GROUP BY department_id
    HAVING COUNT(*) >= 2
) dept_stats ON d.department_id = dept_stats.department_id;

-- Example 30: UNION for combining results
SELECT
    'High Salary' as category,
    CONCAT(first_name, ' ', last_name) AS employee_name,
    salary
FROM employees
WHERE salary >= 75000

UNION ALL

SELECT
    'Recent Hire' as category,
    CONCAT(first_name, ' ', last_name) AS employee_name,
    salary
FROM employees
WHERE hire_date >= '2022-01-01'
ORDER BY category, salary DESC;

-- ===========================================
-- PERFORMANCE AND OPTIMIZATION
-- ===========================================

-- Example 31: Query with EXPLAIN
EXPLAIN SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    d.department_name,
    e.salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 65000
ORDER BY e.salary DESC
LIMIT 10;

-- Example 32: Optimized query with proper indexing
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary,
    hire_date
FROM employees
WHERE hire_date BETWEEN '2020-01-01' AND '2022-12-31'
  AND salary BETWEEN 50000 AND 80000
ORDER BY hire_date DESC, salary DESC
LIMIT 20;

-- ===========================================
-- CLEANUP (Optional - run to reset database)
-- ===========================================

-- DROP TABLE IF EXISTS company_projects;
-- DROP TABLE IF EXISTS employees;
-- DROP TABLE IF EXISTS departments;
-- DROP DATABASE IF EXISTS advanced_queries_lab;