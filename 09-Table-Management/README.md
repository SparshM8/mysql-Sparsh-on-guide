# Table Management Lab

## Lab Overview
This lab focuses on comprehensive table management operations in MySQL. You will learn how to create, alter, drop, and maintain database tables throughout their lifecycle. Understanding table management is crucial for database administration and schema evolution.

## Learning Objectives
By the end of this lab, you will be able to:
- Create tables with proper data types and constraints
- Alter table structures (add/modify/drop columns)
- Manage table constraints and indexes
- Rename and drop tables safely
- Understand table storage engines and options
- Implement table maintenance operations
- Handle schema migrations and versioning

## Prerequisites
- Basic SQL knowledge (CREATE, SELECT, INSERT)
- Understanding of data types and constraints
- MySQL Server installed and running
- Basic database concepts

## Materials Needed
- MySQL Server (8.0 or later recommended)
- MySQL Workbench or command-line client
- Text editor for SQL scripts
- This lab's practice files

## Estimated Time
- Reading and understanding: 45 minutes
- Hands-on practice: 75 minutes
- Exercises and challenges: 45 minutes
- Total: ~2.5 hours

## Key Concepts

### Table Creation
- **CREATE TABLE**: Define table structure with columns and constraints
- **Data Types**: Choose appropriate types (INT, VARCHAR, DATE, etc.)
- **Constraints**: PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL
- **Table Options**: Engine, charset, collation, auto_increment

### Table Alteration
- **ADD COLUMN**: Add new columns to existing tables
- **MODIFY COLUMN**: Change column definitions
- **DROP COLUMN**: Remove columns
- **RENAME COLUMN**: Change column names
- **Constraint Management**: Add/drop constraints

### Table Operations
- **RENAME TABLE**: Change table names
- **DROP TABLE**: Remove tables permanently
- **TRUNCATE TABLE**: Remove all data but keep structure
- **Table Maintenance**: Optimize, repair, analyze

### Advanced Table Features
- **Indexes**: Improve query performance
- **Partitions**: Divide large tables
- **Triggers**: Automatic actions on data changes
- **Views**: Virtual tables based on queries

## Lab Structure

### Part 1: Table Creation
1. Basic table creation with data types
2. Adding constraints and indexes
3. Table options and storage engines
4. Creating tables with relationships

### Part 2: Table Alteration
1. Adding columns and constraints
2. Modifying column definitions
3. Dropping columns and constraints
4. Renaming columns

### Part 3: Table Management
1. Renaming tables
2. Dropping tables safely
3. Table maintenance operations
4. Working with table metadata

### Part 4: Advanced Operations
1. Bulk table operations
2. Schema migrations
3. Table copying and duplication
4. Performance considerations

## Step-by-Step Instructions

### Step 1: Set Up Practice Database
```sql
CREATE DATABASE IF NOT EXISTS table_management_lab;
USE table_management_lab;
```

### Step 2: Create Basic Tables
Start with creating tables with various data types and constraints.

### Step 3: Add Constraints and Indexes
Learn to add primary keys, foreign keys, unique constraints, and indexes.

### Step 4: Alter Table Structures
Practice adding, modifying, and dropping columns.

### Step 5: Manage Constraints
Add and remove various types of constraints.

### Step 6: Rename and Drop Tables
Learn safe table renaming and dropping operations.

### Step 7: Table Maintenance
Perform optimization and analysis operations.

## Practice Exercises

### Exercise 1: Company Database Schema
Create a complete company database with:
- Employees table with all constraints
- Departments table with relationships
- Projects table with foreign keys
- Employee-project assignments

### Exercise 2: E-commerce Schema
Design tables for an online store:
- Products with categories
- Customers with addresses
- Orders with order items
- Reviews and ratings

### Exercise 3: Schema Evolution
Practice altering existing tables:
- Add audit columns (created_at, updated_at)
- Modify data types for better storage
- Add new relationships
- Implement soft deletes

### Exercise 4: Table Maintenance
Perform maintenance operations:
- Analyze table statistics
- Optimize table performance
- Check for data integrity
- Clean up unused tables

## Advanced Challenges

### Challenge 1: Complex Schema Design
Create a multi-tenant application schema with:
- Tenant isolation
- Shared tables with tenant_id
- Proper indexing strategy
- Data partitioning

### Challenge 2: Schema Migration Script
Write a migration script that:
- Safely adds new columns
- Migrates existing data
- Updates constraints
- Provides rollback capability

### Challenge 3: Performance Optimization
Optimize a poorly designed schema:
- Normalize denormalized tables
- Add appropriate indexes
- Partition large tables
- Implement archiving strategy

### Challenge 4: Database Refactoring
Refactor a legacy schema:
- Rename tables and columns
- Change data types
- Split large tables
- Implement new relationships

## Common Issues and Solutions

### ALTER TABLE Blocking
- **Issue**: Long-running ALTER operations block access
- **Solution**: Use online DDL (MySQL 8.0+) or maintenance windows

### Foreign Key Constraints
- **Issue**: Cannot drop referenced tables
- **Solution**: Drop foreign keys first or use CASCADE

### Data Type Changes
- **Issue**: Data loss during type conversion
- **Solution**: Backup data, test conversions, use safe casting

### Table Locks
- **Issue**: Operations lock entire tables
- **Solution**: Use row-level locking engines, optimize queries

## Best Practices

### Table Design
- Use descriptive, consistent naming conventions
- Choose appropriate data types for storage efficiency
- Plan for future growth and changes
- Document table purposes and relationships

### Schema Changes
- Always backup before major changes
- Test changes on development environment
- Use transactions for multiple operations
- Plan rollback strategies

### Performance Considerations
- Add indexes on frequently queried columns
- Consider table partitioning for large datasets
- Use appropriate storage engines
- Monitor table statistics

### Maintenance
- Regularly analyze and optimize tables
- Monitor index usage and rebuild if needed
- Archive old data to maintain performance
- Document all schema changes

## Files in This Lab
- `README.md`: This instruction file
- `examples.sql`: Comprehensive SQL examples
- `practice.ipynb`: Interactive Jupyter notebook with step-by-step exercises

## Next Steps
After completing this lab, you should be ready to:
- Design and maintain database schemas
- Perform database refactoring and migrations
- Implement proper indexing strategies
- Handle database maintenance tasks

## Additional Resources
- MySQL Documentation: CREATE TABLE Syntax
- Database Design Books: "SQL and Relational Theory"
- Schema Migration Tools: Flyway, Liquibase
- Performance Tuning Guides

## Lab Completion Checklist
- [ ] Created tables with proper data types and constraints
- [ ] Added and modified columns using ALTER TABLE
- [ ] Managed constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE)
- [ ] Renamed and dropped tables safely
- [ ] Performed table maintenance operations
- [ ] Completed all practice exercises
- [ ] Solved advanced challenges

## Troubleshooting
- **Syntax Errors**: Check MySQL documentation for correct syntax
- **Permission Errors**: Ensure proper database privileges
- **Locking Issues**: Use appropriate isolation levels
- **Performance Problems**: Monitor query execution plans

Remember: Table management is a critical skill for database administrators. Proper table design and maintenance ensure data integrity, performance, and scalability of your database systems.