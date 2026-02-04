# MySQL Constraints Lab

## Lab Objectives
By the end of this lab, you will be able to:
- Understand different types of MySQL constraints
- Implement constraints in table creation
- Apply constraints to existing tables
- Handle constraint violations appropriately

## Prerequisites
- MySQL Server installed and running
- Python 3.x with mysql-connector-python
- Understanding of basic table creation
- Knowledge of data types

## Lab Duration
Approximately 60 minutes

## Materials Needed
- MySQL Server
- Python environment
- This Jupyter notebook

## Constraint Types Overview
- **NOT NULL**: Prevents NULL values
- **UNIQUE**: Ensures unique values
- **PRIMARY KEY**: Unique identifier (NOT NULL + UNIQUE)
- **FOREIGN KEY**: Maintains referential integrity
- **CHECK**: Validates data against conditions
- **DEFAULT**: Provides default values
- **AUTO_INCREMENT**: Generates unique numbers automatically

## Important Notes
- Constraints help maintain data integrity
- Some constraints can be added to existing tables
- Constraint violations prevent invalid data entry
- Use ALTER TABLE to modify constraints

## Step-by-Step Guide

First, install the required Python package: