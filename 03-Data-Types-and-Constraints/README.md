# Data Types and Constraints in MySQL

In MySQL, data types define the type of data that can be stored in a column of a table. Choosing the appropriate data type is crucial for optimizing storage and ensuring data integrity.

## Data Types

### Numeric Data Types
- **INT**: Used for integer values (whole numbers).
- **FLOAT**: Used for floating-point numbers (decimal values).
- **DOUBLE**: Used for double-precision floating-point numbers.
- **DECIMAL**: Used for fixed-point numbers with a specified precision and scale.

### String Data Types
- **VARCHAR**: Used for variable-length strings with a maximum length.
- **CHAR**: Used for fixed-length strings.
- **TEXT**: Used for large text data.
- **BLOB**: Used for binary large objects (e.g., images, files).

### Date and Time Data Types
- **DATE**: Used for date values (YYYY-MM-DD).
- **DATETIME**: Used for date and time values (YYYY-MM-DD HH:MM:SS).
- **TIMESTAMP**: Used for timestamp values (automatically updated on record modification).
- **TIME**: Used for time values (HH:MM:SS).

### Other Data Types
- **BOOLEAN**: Used for true/false values (stored as TINYINT with 0 for false and 1 for true).
- **ENUM**: Used for a predefined set of string values.
- **SET**: Used for a predefined set of string values where multiple values can be selected.

## Constraints

Constraints are rules applied to columns in a database table to enforce data integrity and consistency.

- **NOT NULL**: Ensures that a column cannot have a NULL value.
- **UNIQUE**: Ensures that all values in a column are unique (no duplicates).
- **PRIMARY KEY**: A combination of NOT NULL and UNIQUE. It uniquely identifies each record in a table.
- **FOREIGN KEY**: Ensures referential integrity by linking a column in one table to the primary key of another table.
- **CHECK**: Ensures that the values in a column meet a specific condition.
- **DEFAULT**: Sets a default value for a column when no value is specified during insertion.

## Example Table Creation

```sql
CREATE TABLE example_table (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    salary DECIMAL(10, 2),
    join_date DATE,
    is_active BOOLEAN
);
```

```sql
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department_id INT,
    salary DECIMAL(10, 2) CHECK (salary > 0),
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);
```

Choosing the right data type and constraints helps in efficient data storage and retrieval, as well as maintaining the integrity of the data stored in the database.

## Next Steps

Now that you understand data types and constraints, move to [Basic Operations](04-Basic-Operations/) to learn CRUD operations.