-- Create a sample database
CREATE DATABASE learning_mysql;

-- Use the database
USE learning_mysql;

-- Create a sample table
CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    grade VARCHAR(10)
);

-- Insert some sample data
INSERT INTO students (id, name, age, grade) VALUES
(1, 'Alice', 20, 'A'),
(2, 'Bob', 22, 'B'),
(3, 'Charlie', 21, 'A');

-- Query the data
SELECT * FROM students;