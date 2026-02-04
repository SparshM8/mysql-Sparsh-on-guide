# Lab 14: Performance Tuning and Optimization

## Overview

Welcome to Lab 14: Performance Tuning and Optimization! This lab focuses on optimizing MySQL database performance through query analysis, indexing strategies, configuration tuning, and monitoring techniques. You'll learn to identify performance bottlenecks and implement solutions to improve database speed and efficiency.

## Learning Objectives

By the end of this lab, you will be able to:
- Analyze query performance using EXPLAIN plans
- Design and implement effective indexing strategies
- Optimize slow queries and identify bottlenecks
- Configure MySQL server parameters for optimal performance
- Monitor database performance and resource usage
- Implement caching strategies and connection pooling
- Use performance monitoring tools and techniques
- Apply best practices for database optimization

## Prerequisites

- **Lab 13**: Database Triggers and Events
- **MySQL Server**: Running with administrative access
- **Sample Data**: Large dataset for performance testing
- **MySQL Tools**: Access to performance monitoring tools

## Estimated Duration

- **Total Time**: 150 minutes
- **Setup**: 15 minutes
- **Exercises**: 120 minutes
- **Review**: 15 minutes

## Key Concepts

### Query Optimization
- **EXPLAIN Plans**: Understanding query execution
- **Index Usage**: When and how to use indexes
- **Query Rewriting**: Optimizing SQL statements
- **Join Optimization**: Efficient table relationships

### Index Strategies
- **Primary Keys**: Clustered index benefits
- **Secondary Indexes**: Covering and composite indexes
- **Index Maintenance**: Rebuilding and defragmentation
- **Index Statistics**: Cardinality and selectivity

### Configuration Tuning
- **Buffer Pool**: InnoDB memory optimization
- **Query Cache**: Result set caching
- **Connection Settings**: Thread and connection management
- **Log Settings**: Binary and slow query logs

### Monitoring and Tools
- **Performance Schema**: Detailed performance metrics
- **Slow Query Log**: Identifying problematic queries
- **Process List**: Active connection monitoring
- **System Variables**: Runtime configuration

## Step-by-Step Guide

### Step 1: Setting Up Performance Monitoring

First, let's enable performance monitoring and create a test database with sample data.

```sql
-- Enable performance monitoring
SET GLOBAL performance_schema = ON;
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 1; -- Log queries taking > 1 second

-- Create performance test database
CREATE DATABASE performance_test;
USE performance_test;

-- Create large test tables
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    created_date DATE,
    last_login TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_email (email),
    INDEX idx_city_state (city, state)
);

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status ENUM('pending', 'processing', 'shipped', 'delivered'),
    shipping_address TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(id),
    INDEX idx_customer_date (customer_id, order_date),
    INDEX idx_status_date (status, order_date),
    INDEX idx_total (total_amount)
);

CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(8,2),
    discount DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_order_product (order_id, product_id),
    INDEX idx_product (product_id)
);

-- Generate sample data (this will create ~100K customers, ~500K orders, ~2M order items)
DELIMITER $$
CREATE PROCEDURE generate_test_data()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1;
    DECLARE k INT DEFAULT 1;

    -- Generate customers
    WHILE i <= 100000 DO
        INSERT INTO customers (name, email, city, state, zip_code, created_date, last_login)
        VALUES (
            CONCAT('Customer ', i),
            CONCAT('customer', i, '@example.com'),
            ELT(MOD(i, 10) + 1, 'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'),
            ELT(MOD(i, 5) + 1, 'NY', 'CA', 'IL', 'TX', 'AZ'),
            LPAD(i, 5, '0'),
            DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
            TIMESTAMP(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY))
        );
        SET i = i + 1;
    END WHILE;

    -- Generate orders and order items
    SET i = 1;
    WHILE i <= 500000 DO
        INSERT INTO orders (customer_id, order_date, total_amount, status, shipping_address)
        VALUES (
            FLOOR(RAND() * 100000) + 1,
            DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
            ROUND(RAND() * 1000, 2),
            ELT(MOD(i, 4) + 1, 'pending', 'processing', 'shipped', 'delivered'),
            CONCAT('Address for order ', i)
        );

        -- Generate 2-5 items per order
        SET j = FLOOR(RAND() * 4) + 2;
        WHILE j > 0 DO
            INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
            VALUES (
                i,
                FLOOR(RAND() * 1000) + 1,
                FLOOR(RAND() * 10) + 1,
                ROUND(RAND() * 100, 2),
                ROUND(RAND() * 20, 2)
            );
            SET j = j - 1;
        END WHILE;

        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

-- Execute data generation (this may take several minutes)
CALL generate_test_data();
```

### Step 2: Analyzing Query Performance with EXPLAIN

Let's learn how to use EXPLAIN to understand query execution plans.

```sql
USE performance_test;

-- Basic EXPLAIN usage
EXPLAIN SELECT * FROM customers WHERE id = 1;

-- Analyze a complex query
EXPLAIN SELECT
    c.name,
    COUNT(o.id) as order_count,
    SUM(o.total_amount) as total_spent
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
WHERE c.state = 'CA'
GROUP BY c.id, c.name
ORDER BY total_spent DESC
LIMIT 10;

-- Check index usage
EXPLAIN SELECT * FROM customers WHERE name LIKE 'Customer 1%';
EXPLAIN SELECT * FROM customers WHERE city = 'New York' AND state = 'NY';

-- Analyze join performance
EXPLAIN SELECT
    c.name,
    o.order_date,
    o.total_amount,
    COUNT(oi.id) as item_count
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
WHERE c.created_date >= '2023-01-01'
GROUP BY c.id, c.name, o.id, o.order_date, o.total_amount;
```

### Step 3: Index Optimization

Learn to create and optimize indexes for better performance.

```sql
USE performance_test;

-- Check existing indexes
SHOW INDEXES FROM customers;
SHOW INDEXES FROM orders;
SHOW INDEXES FROM order_items;

-- Analyze index usage with performance schema
SELECT
    object_schema,
    object_name,
    index_name,
    count_read,
    count_fetch,
    count_insert,
    count_update,
    count_delete
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE object_schema = 'performance_test'
ORDER BY count_read DESC;

-- Create composite indexes for common query patterns
CREATE INDEX idx_customer_state_city ON customers (state, city);
CREATE INDEX idx_order_date_status ON orders (order_date, status);
CREATE INDEX idx_order_customer_date ON orders (customer_id, order_date);

-- Analyze index selectivity
SELECT
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    PAGES,
    FILTER_CONDITION
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'performance_test'
ORDER BY TABLE_NAME, SEQ_IN_INDEX;

-- Test query performance before and after index creation
-- Query 1: Customer search by state and city
EXPLAIN SELECT COUNT(*) FROM customers WHERE state = 'CA' AND city = 'Los Angeles';

-- Query 2: Recent orders analysis
EXPLAIN SELECT
    DATE_FORMAT(order_date, '%Y-%m') as month,
    COUNT(*) as order_count,
    SUM(total_amount) as total_amount
FROM orders
WHERE order_date >= '2023-01-01'
GROUP BY DATE_FORMAT(order_date, '%Y-%m');

-- Create covering index for the above query
CREATE INDEX idx_order_date_covering ON orders (order_date, total_amount);

-- Analyze again
EXPLAIN SELECT
    DATE_FORMAT(order_date, '%Y-%m') as month,
    COUNT(*) as order_count,
    SUM(total_amount) as total_amount
FROM orders
WHERE order_date >= '2023-01-01'
GROUP BY DATE_FORMAT(order_date, '%Y-%m');
```

### Step 4: Query Optimization Techniques

Learn various techniques to optimize slow queries.

```sql
USE performance_test;

-- Subquery optimization
-- Inefficient subquery
EXPLAIN SELECT *
FROM customers c
WHERE c.id IN (
    SELECT customer_id
    FROM orders
    WHERE total_amount > 500
);

-- Optimized with JOIN
EXPLAIN SELECT DISTINCT c.*
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.total_amount > 500;

-- EXISTS optimization
EXPLAIN SELECT c.*
FROM customers c
WHERE EXISTS (
    SELECT 1 FROM orders o
    WHERE o.customer_id = c.id
    AND o.total_amount > 500
);

-- LIMIT optimization
-- Inefficient: Get all records then limit
EXPLAIN SELECT * FROM orders ORDER BY total_amount DESC LIMIT 10;

-- Optimized: Use index for ordering
CREATE INDEX idx_orders_total_desc ON orders (total_amount DESC);
EXPLAIN SELECT * FROM orders ORDER BY total_amount DESC LIMIT 10;

-- UNION vs UNION ALL
-- UNION removes duplicates (slower)
EXPLAIN
SELECT customer_id, 'high_value' as category FROM orders WHERE total_amount > 500
UNION
SELECT customer_id, 'frequent' as category FROM orders GROUP BY customer_id HAVING COUNT(*) > 10;

-- UNION ALL keeps duplicates (faster)
EXPLAIN
SELECT customer_id, 'high_value' as category FROM orders WHERE total_amount > 500
UNION ALL
SELECT customer_id, 'frequent' as category FROM orders GROUP BY customer_id HAVING COUNT(*) > 10;

-- Optimize GROUP BY queries
-- Inefficient GROUP BY
EXPLAIN SELECT
    customer_id,
    COUNT(*) as order_count,
    SUM(total_amount) as total_spent,
    AVG(total_amount) as avg_order
FROM orders
GROUP BY customer_id;

-- Add index for GROUP BY optimization
CREATE INDEX idx_orders_customer_total ON orders (customer_id, total_amount);
EXPLAIN SELECT
    customer_id,
    COUNT(*) as order_count,
    SUM(total_amount) as total_spent,
    AVG(total_amount) as avg_order
FROM orders
GROUP BY customer_id;
```

### Step 5: MySQL Configuration Tuning

Learn to optimize MySQL server configuration for better performance.

```sql
-- Check current configuration
SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'innodb_log_file_size';
SHOW VARIABLES LIKE 'max_connections';
SHOW VARIABLES LIKE 'query_cache_size';
SHOW VARIABLES LIKE 'tmp_table_size';
SHOW VARIABLES LIKE 'max_heap_table_size';

-- Calculate optimal buffer pool size (typically 70-80% of available RAM)
-- For a system with 8GB RAM, buffer pool should be ~5-6GB
SET GLOBAL innodb_buffer_pool_size = 5368709120; -- 5GB

-- Optimize connection settings
SET GLOBAL max_connections = 200;
SET GLOBAL max_connect_errors = 100000;

-- Configure query cache (MySQL 5.7 and earlier)
SET GLOBAL query_cache_size = 268435456; -- 256MB
SET GLOBAL query_cache_type = ON;
SET GLOBAL query_cache_limit = 1048576; -- 1MB

-- Optimize temporary table settings
SET GLOBAL tmp_table_size = 134217728; -- 128MB
SET GLOBAL max_heap_table_size = 134217728; -- 128MB

-- Configure InnoDB settings
SET GLOBAL innodb_log_file_size = 268435456; -- 256MB
SET GLOBAL innodb_flush_log_at_trx_commit = 2; -- Better performance, slight durability trade-off
SET GLOBAL innodb_flush_method = O_DIRECT;

-- Configure slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2; -- Log queries > 2 seconds
SET GLOBAL slow_query_log_file = '/var/log/mysql/mysql-slow.log';

-- Check current performance
SHOW ENGINE INNODB STATUS;
SHOW PROCESSLIST;
SHOW OPEN TABLES;
```

### Step 6: Performance Monitoring

Learn to monitor database performance and identify bottlenecks.

```sql
USE performance_test;

-- Monitor active connections
SHOW PROCESSLIST;

-- Check InnoDB status
SHOW ENGINE INNODB STATUS\G

-- Monitor table locks
SELECT
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    r.trx_query waiting_query,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    b.trx_query blocking_query
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;

-- Monitor slow queries
SELECT
    sql_text,
    exec_count,
    avg_timer_wait/1000000000 as avg_time_sec,
    min_timer_wait/1000000000 as min_time_sec,
    max_timer_wait/1000000000 as max_time_sec
FROM performance_schema.events_statements_summary_by_digest
WHERE avg_timer_wait > 1000000000 -- More than 1 second average
ORDER BY avg_timer_wait DESC
LIMIT 10;

-- Check index usage statistics
SELECT
    object_schema,
    object_name,
    index_name,
    count_read,
    count_fetch,
    count_insert,
    count_update,
    count_delete
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE object_schema = 'performance_test'
AND count_read > 0
ORDER BY count_read DESC;

-- Monitor memory usage
SELECT
    event_name,
    current_alloc,
    high_alloc
FROM sys.memory_global_by_current_bytes
WHERE current_alloc > 1024*1024 -- More than 1MB
ORDER BY current_alloc DESC;

-- Check query cache efficiency (MySQL 5.7 and earlier)
SHOW STATUS LIKE 'Qcache%';

-- Monitor table statistics
SELECT
    table_schema,
    table_name,
    table_rows,
    avg_row_length,
    data_length/1024/1024 as data_mb,
    index_length/1024/1024 as index_mb,
    (data_length + index_length)/1024/1024 as total_mb
FROM information_schema.tables
WHERE table_schema = 'performance_test'
ORDER BY data_length DESC;
```

### Step 7: Advanced Optimization Techniques

Learn advanced techniques for maximum performance.

```sql
USE performance_test;

-- Partitioning for large tables
-- Partition orders table by date
ALTER TABLE orders
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Check partition information
SELECT
    table_name,
    partition_name,
    table_rows,
    avg_row_length,
    data_length/1024/1024 as data_mb
FROM information_schema.partitions
WHERE table_schema = 'performance_test'
AND table_name = 'orders'
ORDER BY partition_ordinal_position;

-- Query performance with partitioning
EXPLAIN SELECT COUNT(*) FROM orders WHERE order_date >= '2024-01-01';

-- Optimize with partition pruning
EXPLAIN SELECT * FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- Create compressed tables for read-heavy workloads
CREATE TABLE audit_log_compressed (
    id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    operation VARCHAR(10),
    record_id INT,
    old_values JSON,
    new_values JSON,
    user_name VARCHAR(100),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB
ROW_FORMAT=COMPRESSED
KEY_BLOCK_SIZE=8;

-- Compare table sizes
SELECT
    table_name,
    table_rows,
    avg_row_length,
    data_length/1024/1024 as data_mb,
    index_length/1024/1024 as index_mb
FROM information_schema.tables
WHERE table_schema = 'performance_test'
AND table_name LIKE '%audit%'
ORDER BY table_name;

-- Optimize for read-heavy workloads
-- Create summary tables for common aggregations
CREATE TABLE customer_summary (
    customer_id INT PRIMARY KEY,
    total_orders INT,
    total_spent DECIMAL(12,2),
    avg_order_value DECIMAL(10,2),
    last_order_date DATE,
    customer_since DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Populate summary table
INSERT INTO customer_summary
SELECT
    c.id,
    COUNT(o.id) as total_orders,
    COALESCE(SUM(o.total_amount), 0) as total_spent,
    COALESCE(AVG(o.total_amount), 0) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    c.created_date as customer_since
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.created_date;

-- Query using summary table (much faster)
SELECT
    cs.*,
    c.name,
    c.email
FROM customer_summary cs
JOIN customers c ON cs.customer_id = c.id
WHERE cs.total_spent > 1000
ORDER BY cs.total_spent DESC;
```

### Step 8: Performance Testing and Benchmarking

Learn to perform systematic performance testing.

```sql
USE performance_test;

-- Create a stored procedure for performance testing
DELIMITER $$
CREATE PROCEDURE performance_test(
    IN iterations INT,
    IN test_name VARCHAR(100)
)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time TIMESTAMP;
    DECLARE end_time TIMESTAMP;

    SET start_time = NOW();

    -- Test different query patterns
    WHILE i <= iterations DO
        -- Test 1: Simple SELECT
        SELECT COUNT(*) INTO @count1 FROM customers WHERE state = 'CA';

        -- Test 2: JOIN query
        SELECT COUNT(*) INTO @count2
        FROM customers c
        JOIN orders o ON c.id = o.customer_id
        WHERE c.state = 'CA' AND o.total_amount > 100;

        -- Test 3: Aggregation
        SELECT AVG(total_amount) INTO @avg_amount
        FROM orders
        WHERE customer_id IN (
            SELECT id FROM customers WHERE state = 'CA' LIMIT 100
        );

        SET i = i + 1;
    END WHILE;

    SET end_time = NOW();

    -- Log results
    INSERT INTO performance_results (test_name, iterations, start_time, end_time, duration_seconds)
    VALUES (test_name, iterations, start_time, end_time,
            TIMESTAMPDIFF(SECOND, start_time, end_time));

    SELECT CONCAT('Performance test completed: ', iterations, ' iterations in ',
                  TIMESTAMPDIFF(SECOND, start_time, end_time), ' seconds') as result;
END$$
DELIMITER ;

-- Create results table
CREATE TABLE performance_results (
    id INT PRIMARY KEY AUTO_INCREMENT,
    test_name VARCHAR(100),
    iterations INT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    duration_seconds INT,
    notes TEXT
);

-- Run performance tests
CALL performance_test(100, 'Baseline Test');

-- Add indexes and test again
CREATE INDEX idx_customers_state ON customers (state);
CREATE INDEX idx_orders_customer_amount ON orders (customer_id, total_amount);

CALL performance_test(100, 'After Index Optimization');

-- Compare results
SELECT
    test_name,
    iterations,
    duration_seconds,
    ROUND(iterations / duration_seconds, 2) as queries_per_second
FROM performance_results
ORDER BY start_time DESC;

-- Test with different configurations
-- Test 1: Default configuration
SET GLOBAL query_cache_type = OFF;
CALL performance_test(50, 'No Query Cache');

-- Test 2: With query cache
SET GLOBAL query_cache_type = ON;
SET GLOBAL query_cache_size = 67108864; -- 64MB
CALL performance_test(50, 'With Query Cache');

-- Compare cache effectiveness
SELECT
    test_name,
    duration_seconds,
    ROUND(iterations / duration_seconds, 2) as queries_per_second
FROM performance_results
WHERE test_name LIKE '%Cache%'
ORDER BY start_time DESC;
```

## Best Practices

### Index Design
1. **Primary Keys**: Always use appropriate primary keys
2. **Foreign Keys**: Index foreign key columns
3. **Selectivity**: Index columns with high selectivity (>5% unique values)
4. **Composite Indexes**: Order columns by selectivity (most selective first)
5. **Covering Indexes**: Include all columns needed by query
6. **Avoid Over-Indexing**: Each index has maintenance overhead

### Query Optimization
1. **EXPLAIN First**: Always analyze query plans before optimization
2. **Avoid SELECT *** : Specify only needed columns
3. **Use LIMIT**: For large result sets, use pagination
4. **Optimize JOINs**: Ensure proper indexing on join columns
5. **Subquery vs JOIN**: Use JOINs for better performance
6. **Avoid Functions**: Don't use functions on indexed columns in WHERE clauses

### Configuration Tuning
1. **Buffer Pool**: Set to 70-80% of available RAM
2. **Connection Pool**: Configure appropriate connection limits
3. **Query Cache**: Use for read-heavy workloads (MySQL 5.7 and earlier)
4. **Log Settings**: Configure slow query logging
5. **InnoDB Settings**: Optimize for your workload type

### Monitoring
1. **Regular Monitoring**: Set up automated monitoring
2. **Slow Query Analysis**: Review slow query logs weekly
3. **Index Usage**: Monitor unused indexes for removal
4. **Resource Usage**: Track memory, CPU, and disk I/O
5. **Performance Baselines**: Establish normal performance metrics

## Troubleshooting Common Issues

### Slow Queries
```sql
-- Find slowest queries
SELECT
    sql_text,
    exec_count,
    avg_timer_wait/1000000000 as avg_time_sec,
    sum_timer_wait/1000000000 as total_time_sec
FROM performance_schema.events_statements_summary_by_digest
ORDER BY sum_timer_wait DESC
LIMIT 10;

-- Analyze specific slow query
EXPLAIN SELECT * FROM orders WHERE customer_id = 12345;
SHOW WARNINGS; -- Shows optimizer warnings
```

### Index Issues
```sql
-- Find unused indexes
SELECT
    object_schema,
    object_name,
    index_name
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE object_schema NOT IN ('mysql', 'performance_schema', 'information_schema')
AND count_star = 0; -- Index never used

-- Check index fragmentation
SELECT
    table_schema,
    table_name,
    index_name,
    avg_fragmentation_pct
FROM sys.schema_index_statistics
WHERE avg_fragmentation_pct > 10;
```

### Memory Issues
```sql
-- Check memory usage
SELECT
    event_name,
    current_alloc,
    high_alloc
FROM sys.memory_global_by_current_bytes
ORDER BY current_alloc DESC
LIMIT 10;

-- Monitor buffer pool efficiency
SHOW ENGINE INNODB STATUS;
```

## Exercises

### Exercise 1: Query Analysis
1. Use EXPLAIN to analyze the query performance of finding all orders for customers in California
2. Identify any missing indexes and create them
3. Compare query execution time before and after optimization

### Exercise 2: Index Optimization
1. Create appropriate indexes for the order_items table
2. Analyze the impact of composite indexes on product-based queries
3. Test the performance difference between single-column and composite indexes

### Exercise 3: Configuration Tuning
1. Analyze your current MySQL configuration
2. Adjust buffer pool size based on available memory
3. Configure slow query logging and test it

### Exercise 4: Performance Monitoring
1. Set up monitoring for slow queries
2. Create a dashboard query showing key performance metrics
3. Identify and optimize the top 5 slowest queries

### Exercise 5: Advanced Optimization
1. Implement table partitioning on the orders table
2. Create summary tables for common aggregations
3. Compare query performance with and without optimizations

## Summary

In this lab, you learned:
- **Query Analysis**: Using EXPLAIN to understand query execution plans
- **Index Strategies**: Creating and optimizing database indexes
- **Configuration Tuning**: Optimizing MySQL server settings
- **Performance Monitoring**: Tracking and analyzing database performance
- **Optimization Techniques**: Advanced methods for maximum performance
- **Best Practices**: Guidelines for maintaining optimal database performance

### Key Takeaways:
- Always analyze queries with EXPLAIN before optimization
- Proper indexing is crucial for query performance
- Configuration tuning should match your workload requirements
- Regular monitoring helps identify performance issues early
- Balance between read and write optimization based on your use case

### Next Steps:
- **Lab 15**: Database Security and User Management
- **Lab 16**: Backup, Recovery, and High Availability
- Apply these techniques to your production databases
- Set up automated monitoring and alerting
- Consider MySQL Enterprise features for advanced optimization

Remember: Performance optimization is an ongoing process. Regularly monitor your database and adjust configurations as your workload changes!