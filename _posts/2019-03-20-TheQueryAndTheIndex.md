---
layout: post
title: <em>#BugOfTheDay</em> The query and the index
---

A report from IT, the database is hitting 100% of CPU usage. Some users describe that the main application is slowing down and displaying error messages related to database issues. The report includes a very slow query to a huge table. What's wrong?

The reported query looked like this:

```sql
SELECT Id, SomeColumn, Date, Column4
FROM schema.TableWithLotsOfRows
WHERE Id = @Id AND SomeColumn = @SomeColumn
        AND ABS(DATEDIFF(MINUTE, Date, @Date)) <= @THRESHOLD_IN_MIN)
```

An index can't be used if there are expressions using functions in the where clause. This will cause a full scan. Since the query is in an store procedure, this slow query is exhausting all database connections.

## Solution

### The Query

Rewrite your query to use equality, inequality, `BETWEEN` and `IN` operators in the predicate, so an index can be used to run the query<sup>[1]</sup>.

```sql
SELECT Id, SomeColumn, Date, Column4
FROM schema.TableWithLotsOfRows
WHERE Id = @Id AND SomeColumn = @SomeColumn
        AND Date BETWEEN DATEADD(MINUTE, -1 * @THRESHOLD_IN_MIN, @Date) AND DATEADD(MINUTE, @THRESHOLD_IN_MIN, @Date)
```

### The Index

Create an index for the columns in the predicate. The `ONLINE` option will allow you to use the table while the index is being created. But, be aware a large number of indexes will make INSERTs slower<sup>[2]</sup>. 

```sql
CREATE INDEX IX_TableWithLotsOfRows_Date
    ON schema.TableWithLotsOfRows (Id, SomeColumn, Date) 
    WITH (ONLINE = ON);
```

[1]: https://www.red-gate.com/simple-talk/sql/performance/index-selection-and-the-query-optimizer/
[2]: https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-guides/jj835095(v=sql.110)