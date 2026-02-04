# Keys and Relationships Lab

## Lab Overview
This lab focuses on implementing and understanding database keys and relationships in MySQL. You will learn how to create primary keys, unique constraints, foreign keys, and establish various types of table relationships.

## Learning Objectives
By the end of this lab, you will be able to:
- Implement different types of primary keys (single-column, auto-increment, composite)
- Create and manage unique constraints
- Establish foreign key relationships with referential integrity
- Understand relationship types: one-to-one, one-to-many, and many-to-many
- Use CASCADE actions for automatic data management
- Query related data using JOIN operations
- Design proper database schemas with keys and relationships

## Prerequisites
- Basic understanding of MySQL table creation
- Knowledge of data types and constraints
- MySQL Server installed and running
- Basic SQL knowledge (SELECT, INSERT, UPDATE, DELETE)

## Materials Needed
- MySQL Server (8.0 or later recommended)
- MySQL Workbench or command-line client
- Text editor for SQL scripts
- This lab's practice files

## Estimated Time
- Reading and understanding: 30 minutes
- Hands-on practice: 60 minutes
- Exercises and challenges: 30 minutes
- Total: ~2 hours

## Key Concepts

### Primary Keys
- **Purpose**: Uniquely identify each record in a table
- **Characteristics**: Unique, non-null, single per table
- **Types**:
  - Single-column: One column serves as primary key
  - Auto-increment: Automatically generates unique values
  - Composite: Multiple columns form the primary key

### Unique Keys
- **Purpose**: Ensure uniqueness of column values
- **Characteristics**: Allows one NULL value, multiple per table
- **Use Cases**: Email addresses, usernames, product codes

### Foreign Keys
- **Purpose**: Establish relationships between tables
- **Characteristics**: References primary key in another table
- **Benefits**: Maintains referential integrity

### Relationship Types
- **One-to-One**: One record relates to one record in another table
- **One-to-Many**: One record relates to many records in another table
- **Many-to-Many**: Many records relate to many records (requires junction table)

## Lab Structure

### Part 1: Primary Keys
1. Single-column primary keys
2. Auto-increment primary keys
3. Composite primary keys

### Part 2: Unique Constraints
1. Single unique constraints
2. Multiple unique constraints
3. Unique vs. primary key differences

### Part 3: Foreign Keys
1. Basic foreign key relationships
2. Foreign key constraints
3. CASCADE actions (DELETE, UPDATE, SET NULL)

### Part 4: Relationship Types
1. One-to-One relationships
2. One-to-Many relationships
3. Many-to-Many relationships

### Part 5: Querying Relationships
1. INNER JOIN operations
2. LEFT JOIN operations
3. Multiple table JOINs
4. Self-JOINs for hierarchical data

## Step-by-Step Instructions

### Step 1: Set Up Practice Database
```sql
CREATE DATABASE IF NOT EXISTS keys_lab;
USE keys_lab;
```

### Step 2: Create Tables with Primary Keys
Create tables demonstrating different primary key types:

1. **Customers table** with single-column primary key
2. **Products table** with auto-increment primary key
3. **Order_Items table** with composite primary key

### Step 3: Add Unique Constraints
Add unique constraints to ensure data integrity:
- Email addresses must be unique
- Product SKUs must be unique
- Employee codes must be unique

### Step 4: Establish Foreign Key Relationships
Create relationships between tables:
- Orders reference customers
- Order items reference both orders and products
- Product categories link products to categories

### Step 5: Implement Different Relationship Types
- User profiles (one-to-one with users)
- Orders and order items (one-to-many)
- Products and categories (many-to-many)

### Step 6: Test Constraints
Attempt operations that should fail:
- Duplicate primary key values
- Invalid foreign key references
- Unique constraint violations

### Step 7: Query Related Data
Use JOIN operations to retrieve related information:
- Customer order history
- Product category information
- Complete order details with customer and product data

## Practice Exercises

### Exercise 1: Library Database
Design and implement a library database with:
- Books table (with ISBN as unique identifier)
- Authors table
- Members table
- Book loans (many-to-many relationship)

### Exercise 2: E-commerce Schema
Create an e-commerce database including:
- Users and user addresses (one-to-one)
- Products and categories (many-to-many)
- Orders and order items (one-to-many)
- Product reviews

### Exercise 3: Company Structure
Design a company database with:
- Employees table with manager relationships
- Departments table
- Projects table
- Employee-project assignments (many-to-many)

## Advanced Challenges

### Challenge 1: Self-Referencing Tables
Create an employee hierarchy where managers reference other employees in the same table.

### Challenge 2: Complex CASCADE Actions
Implement a system where deleting a department automatically handles employee reassignments.

### Challenge 3: Audit Trail
Create audit tables that track changes to related data using triggers and foreign keys.

## Common Issues and Solutions

### Foreign Key Constraint Errors
- **Issue**: Cannot delete referenced records
- **Solution**: Use CASCADE DELETE or delete child records first

### Primary Key Violations
- **Issue**: Duplicate key errors
- **Solution**: Use auto-increment or ensure unique values

### Performance Issues with Foreign Keys
- **Issue**: Slow queries on large tables
- **Solution**: Create indexes on foreign key columns

## Best Practices

### Key Design
- Use meaningful primary key names (id, code, etc.)
- Consider auto-increment for surrogate keys
- Use composite keys only when necessary
- Avoid changing primary key values

### Relationship Design
- Always define foreign keys for data integrity
- Choose appropriate CASCADE actions
- Use junction tables for many-to-many relationships
- Consider performance implications

### Query Optimization
- Create indexes on foreign key columns
- Use appropriate JOIN types
- Avoid unnecessary table scans
- Consider denormalization for read-heavy workloads

## Files in This Lab
- `README.md`: This instruction file
- `examples.sql`: Comprehensive SQL examples
- `practice.ipynb`: Interactive Jupyter notebook with step-by-step exercises

## Next Steps
After completing this lab, you should be ready to:
- Design normalized database schemas
- Implement complex relationships
- Write efficient queries with JOINs
- Understand database integrity constraints

## Additional Resources
- MySQL Documentation: Keys and Constraints
- Database Design Books: "Database System Concepts"
- Online Tutorials: SQL JOIN operations
- Practice Platforms: LeetCode SQL, HackerRank SQL

## Lab Completion Checklist
- [ ] Created tables with different primary key types
- [ ] Implemented unique constraints
- [ ] Established foreign key relationships
- [ ] Tested constraint violations
- [ ] Used JOIN queries successfully
- [ ] Completed practice exercises
- [ ] Understood CASCADE actions
- [ ] Designed a complete database schema

## Troubleshooting
- **Connection Issues**: Check MySQL server status and credentials
- **Syntax Errors**: Verify SQL syntax and data types
- **Constraint Violations**: Review data before insertion
- **Performance Problems**: Add appropriate indexes

Remember: Keys and relationships are the foundation of relational databases. Mastering these concepts will enable you to design robust, scalable database systems.