# Introduction to MySQL

MySQL is a popular open-source relational database management system (RDBMS) that uses Structured Query Language (SQL) for database operations. It is widely used for web applications and data management.

## What is a Database?

A database is a container that stores related data in an organized way. In MySQL, a database holds one or more tables, which are used to store data in rows and columns based on management.

Think of it like:
- **Folder analogy**: A database is like a folder. Each table is a file inside that folder. The rows in the table are like the content inside each file.
- **Excel analogy**: A database is like an Excel workbook. Each table is a separate sheet inside that workbook. Each row in the table is like a row in Excel.

## What is a Table?

A table is a structured collection of data within a database. Tables are used to store data in rows and columns, similar to a spreadsheet.

## Creation of Database and Table

To create a database and a table in MySQL, you can use the following SQL commands:

### Create Database
```sql
CREATE DATABASE database_name;
```

### Use Database
```sql
USE database_name;
```

### Create Table
```sql
CREATE TABLE table_name (
    column1 datatype,
    column2 datatype,
    column3 datatype,
    ...
);
```

## Next Steps

After understanding the basics, proceed to [Installation](02-Installation/) to set up MySQL on your system.