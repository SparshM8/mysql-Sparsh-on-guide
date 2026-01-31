-- Examples of different data types and constraints

-- Create a database for examples
CREATE DATABASE data_types_examples;
USE data_types_examples;

-- Example table with various data types
CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    age INT CHECK (age >= 18),
    salary DECIMAL(10, 2) DEFAULT 0.00,
    birth_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    user_type ENUM('admin', 'user', 'moderator') DEFAULT 'user'
);

-- Insert sample data
INSERT INTO user_profiles (username, email, age, salary, birth_date, user_type) VALUES
('john_doe', 'john@example.com', 25, 50000.00, '1999-01-15', 'user'),
('jane_admin', 'jane@example.com', 30, 75000.00, '1994-05-20', 'admin'),
('bob_mod', 'bob@example.com', 28, 60000.00, '1996-11-10', 'moderator');

-- Query to see the data
SELECT * FROM user_profiles;

-- Example of constraints in action (this will fail due to CHECK constraint)
-- INSERT INTO user_profiles (username, email, age) VALUES ('young_user', 'young@example.com', 16);

-- Clean up
-- DROP DATABASE data_types_examples;