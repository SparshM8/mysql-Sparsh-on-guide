-- This is a simple test script to verify MySQL installation
-- Run this after connecting to MySQL

-- Show databases
SHOW DATABASES;

-- Create a test database
CREATE DATABASE test_installation;

-- Use it
USE test_installation;

-- Create a test table
CREATE TABLE test_table (
    id INT PRIMARY KEY,
    message VARCHAR(100)
);

-- Insert test data
INSERT INTO test_table (id, message) VALUES (1, 'MySQL installation successful!');

-- Query
SELECT * FROM test_table;

-- Clean up
DROP DATABASE test_installation;