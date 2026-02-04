# SQL Functions and Transactions Lab

## Lab Objectives
By the end of this lab, you will be able to:
- Use various SQL functions for data manipulation
- Understand transaction concepts and ACID properties
- Control transaction behavior with COMMIT and ROLLBACK
- Apply functions in real-world scenarios

## Prerequisites
- MySQL Server installed and running
- Python 3.x with mysql-connector-python
- Understanding of basic SQL queries
- Knowledge of table operations

## Lab Duration
Approximately 75 minutes

## Materials Needed
- MySQL Server
- Python environment
- This Jupyter notebook

## SQL Functions Overview

### Aggregate Functions
- **COUNT()**: Count rows or non-NULL values
- **SUM()**: Sum numeric values
- **AVG()**: Calculate average
- **MIN()**: Find minimum value
- **MAX()**: Find maximum value

### String Functions
- **CONCAT()**: Join strings
- **SUBSTRING()**: Extract part of string
- **UPPER()/LOWER()**: Change case
- **LENGTH()**: Get string length

### Date/Time Functions
- **NOW()**: Current date and time
- **DATE()**: Extract date part
- **DATEDIFF()**: Calculate date difference

### Mathematical Functions
- **ABS()**: Absolute value
- **ROUND()**: Round numbers
- **CEIL()/FLOOR()**: Round up/down

### Control Flow Functions
- **IF()**: Conditional logic
- **CASE**: Multiple conditions
- **COALESCE()**: Handle NULL values

## Transactions Overview
- **ACID Properties**: Atomicity, Consistency, Isolation, Durability
- **Auto-commit**: Default MySQL behavior
- **Manual Transactions**: START TRANSACTION, COMMIT, ROLLBACK

## Step-by-Step Guide

First, install the required Python package: