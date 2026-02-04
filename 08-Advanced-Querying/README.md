# Advanced Querying Lab

## Lab Overview
This lab focuses on advanced SQL querying techniques in MySQL. You will learn complex SELECT statements, advanced filtering, pattern matching, subqueries, aggregations, and data modification operations.

## Learning Objectives
By the end of this lab, you will be able to:
- Write complex SELECT queries with multiple conditions
- Use advanced filtering techniques (BETWEEN, LIKE, IN, EXISTS)
- Implement sorting and pagination with ORDER BY, LIMIT, and OFFSET
- Handle NULL values effectively in queries
- Use logical operators (AND, OR, NOT) in complex conditions
- Perform data modification operations (UPDATE, DELETE)
- Modify table structures with ALTER TABLE
- Understand query optimization principles

## Prerequisites
- Basic SQL knowledge (SELECT, FROM, WHERE)
- Understanding of MySQL data types
- Knowledge of table creation and constraints
- MySQL Server installed and running

## Materials Needed
- MySQL Server (8.0 or later recommended)
- MySQL Workbench or command-line client
- Sample database with test data
- This lab's practice files

## Estimated Time
- Reading and understanding: 45 minutes
- Hands-on practice: 75 minutes
- Exercises and challenges: 45 minutes
- Total: ~2.5 hours

## Key Concepts

### Advanced Filtering
- **BETWEEN**: Range-based filtering
- **LIKE**: Pattern matching with wildcards
- **IN**: Multiple value matching
- **EXISTS**: Subquery-based existence checks

### Logical Operators
- **AND**: All conditions must be true
- **OR**: At least one condition must be true
- **NOT**: Negates a condition
- **Operator Precedence**: Understanding evaluation order

### NULL Handling
- **IS NULL**: Check for NULL values
- **IS NOT NULL**: Check for non-NULL values
- **NULL-safe operators**: <=> (null-safe equality)

### Sorting and Pagination
- **ORDER BY**: Sort results by one or more columns
- **LIMIT**: Restrict number of rows returned
- **OFFSET**: Skip rows before returning results
- **Pagination**: Combining LIMIT and OFFSET

### Data Modification
- **UPDATE**: Modify existing data
- **DELETE**: Remove data from tables
- **TRUNCATE**: Remove all data from tables

### Table Structure Modification
- **ALTER TABLE**: Change table structure
- **ADD COLUMN**: Add new columns
- **MODIFY COLUMN**: Change column definitions
- **DROP COLUMN**: Remove columns
- **Constraint Management**: Add/drop constraints

## Lab Structure

### Part 1: Advanced SELECT Queries
1. Complex WHERE clauses
2. Multiple table queries (without JOINs)
3. Subqueries and derived tables

### Part 2: Filtering Techniques
1. BETWEEN and range queries
2. LIKE and pattern matching
3. IN and EXISTS operators
4. NULL value handling

### Part 3: Logical Operations
1. AND/OR combinations
2. Operator precedence
3. Complex boolean expressions

### Part 4: Sorting and Pagination
1. ORDER BY with multiple columns
2. ASC/DESC combinations
3. LIMIT and OFFSET
4. Pagination implementation

### Part 5: Data Modification
1. UPDATE statements
2. DELETE operations
3. Safe deletion practices

### Part 6: Table Alteration
1. Adding columns and constraints
2. Modifying column definitions
3. Dropping elements
4. Renaming objects

## Step-by-Step Instructions

### Step 1: Set Up Practice Database
```sql
CREATE DATABASE IF NOT EXISTS advanced_queries_lab;
USE advanced_queries_lab;
```

### Step 2: Create Sample Tables and Data
Create tables with diverse data for practicing queries:
- Employees table with various data types
- Departments table
- Projects table
- Salaries table

### Step 3: Practice Basic Advanced Queries
Start with complex WHERE clauses combining multiple conditions.

### Step 4: Implement Pattern Matching
Use LIKE operator with different wildcard patterns.

### Step 5: Work with Ranges and Lists
Practice BETWEEN, IN, and range-based queries.

### Step 6: Handle NULL Values
Learn to query NULL and non-NULL data appropriately.

### Step 7: Sort and Paginate Results
Implement ORDER BY with LIMIT and OFFSET.

### Step 8: Modify Data
Practice UPDATE and DELETE operations safely.

### Step 9: Alter Table Structures
Learn ALTER TABLE operations for schema changes.

## Practice Exercises

### Exercise 1: Employee Queries
Write queries to:
- Find employees in specific salary ranges
- Search employees by name patterns
- List employees with missing information
- Sort employees by multiple criteria

### Exercise 2: Department Analysis
Create queries for:
- Department statistics
- Employee distribution
- Department performance metrics
- Cross-department comparisons

### Exercise 3: Data Maintenance
Practice:
- Updating employee information
- Removing inactive records
- Adding new table columns
- Modifying constraints

### Exercise 4: Report Generation
Build complex queries for:
- Employee summaries
- Department reports
- Salary analysis
- Trend identification

## Advanced Challenges

### Challenge 1: Complex Filtering
Create a query that finds employees who:
- Earn between $50K-$80K
- Work in departments starting with 'S'
- Have names containing 'a' but not starting with 'J'
- Were hired in the last 2 years

### Challenge 2: Pagination System
Implement a pagination system that:
- Shows 10 results per page
- Allows jumping to specific pages
- Displays total records and pages
- Handles edge cases (invalid pages)

### Challenge 3: Data Cleanup
Write safe scripts to:
- Remove duplicate records
- Update NULL values with defaults
- Archive old data
- Clean up orphaned records

### Challenge 4: Dynamic Queries
Create flexible queries that can:
- Search across multiple columns
- Handle optional filter criteria
- Sort by any column
- Support both ASC and DESC sorting

## Common Issues and Solutions

### Query Performance Issues
- **Issue**: Slow queries on large datasets
- **Solution**: Add appropriate indexes, use LIMIT

### NULL-Related Errors
- **Issue**: Unexpected results with NULL comparisons
- **Solution**: Use IS NULL instead of = NULL

### Data Modification Conflicts
- **Issue**: Foreign key constraint violations
- **Solution**: Delete child records first or use CASCADE

### ALTER TABLE Blocking
- **Issue**: Table locks during structure changes
- **Solution**: Perform during maintenance windows

## Best Practices

### Query Writing
- Use meaningful aliases for tables and columns
- Format queries for readability
- Test queries with small datasets first
- Use comments for complex logic

### Data Modification
- Always backup before major changes
- Use transactions for multiple operations
- Test UPDATE/DELETE with SELECT first
- Be cautious with DELETE without WHERE

### Table Alteration
- Plan schema changes carefully
- Consider data migration needs
- Test on development environment first
- Document all changes

### Performance Optimization
- Use indexes on frequently queried columns
- Avoid SELECT * in production
- Use LIMIT for large result sets
- Consider query execution plans

## Files in This Lab
- `README.md`: This instruction file
- `examples.sql`: Comprehensive SQL examples
- `practice.ipynb`: Interactive Jupyter notebook with step-by-step exercises

## Next Steps
After completing this lab, you should be ready to:
- Write complex analytical queries
- Implement search functionality
- Build reporting systems
- Perform database maintenance tasks

## Additional Resources
- MySQL Documentation: SELECT Syntax
- SQL Performance Tuning Books
- Online SQL Practice Platforms
- Database Administration Guides

## Lab Completion Checklist
- [ ] Written complex WHERE clauses
- [ ] Used pattern matching with LIKE
- [ ] Implemented range queries with BETWEEN
- [ ] Handled NULL values properly
- [ ] Used LIMIT and OFFSET for pagination
- [ ] Performed safe UPDATE operations
- [ ] Executed DELETE operations
- [ ] Modified table structures with ALTER TABLE
- [ ] Completed all practice exercises
- [ ] Solved advanced challenges

## Troubleshooting
- **Syntax Errors**: Check MySQL documentation for correct syntax
- **Logic Errors**: Break complex queries into smaller parts
- **Performance Issues**: Use EXPLAIN to analyze query execution
- **Data Issues**: Verify data types and constraints

Remember: Advanced querying is essential for extracting meaningful insights from your data. Practice these techniques regularly to become proficient in SQL.