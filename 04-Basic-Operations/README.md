# Basic Operations in MySQL

This section covers the fundamental CRUD (Create, Read, Update, Delete) operations in MySQL.

## Inserting Data into a Table

To insert data into a table in MySQL, you can use the following SQL command:

```sql
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...);
```

You can insert multiple rows at once:

```sql
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...),
       (value1, value2, value3, ...),
       (value1, value2, value3, ...);
```

## Querying Data from a Table

To retrieve data from a table in MySQL, you can use the following SQL command:

```sql
SELECT column1, column2, column3, ...
FROM table_name
WHERE condition;
```

- Use `SELECT *` to select all columns
- Use `WHERE` clause to filter results
- Use `ORDER BY` to sort results
- Use `LIMIT` to limit the number of results

## Updating Data in a Table

To update existing data in a table in MySQL, you can use the following SQL command:

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;
```

**Important**: Always include a WHERE clause when updating, otherwise all rows will be updated!

## Deleting Data from a Table

To delete data from a table in MySQL, you can use the following SQL command:

```sql
DELETE FROM table_name
WHERE condition;
```

**Important**: Always include a WHERE clause when deleting, otherwise all rows will be deleted!

## Best Practices

1. Always backup your data before performing UPDATE or DELETE operations
2. Use transactions for multiple related operations
3. Test your queries on a copy of the data first
4. Use meaningful WHERE conditions to avoid accidental data modification

## Next Steps

Congratulations! You've learned the basic operations. Continue exploring more advanced MySQL topics like joins, indexes, and stored procedures.