---
layout: post
title: TIL&colon; NULL isn't LIKE anything else in SQL Server
tags: todayilearned sql
---

How does `LIKE` operator handle `NULL` values? `NULL` and `LIKE` don't get along. If you're using the `LIKE` operator on a nullable column, all rows containing `NULL` values won't be included in the results. And, the same is true for `NOT LIKE`. Rows with `NULL` values won't be included with `NOT LIKE`.

Let's see an example. It uses a `Client` table with an ID, name and middleName. Only two of the four clients have a middlename.

```sql
CREATE TABLE #Clients
(
    ID INT,
    Name VARCHAR(20),
    MiddleName VARCHAR(20)
)
GO

INSERT INTO #Clients
VALUES
    (1, 'Alice', 'A'),
    (2, 'Bob',   NULL),
    (3, 'Charlie', 'C'),
    (4, 'Dwight',  NULL)
GO
```

Let's find all users with middlename starting and not starting with 'A'.

```sql
SELECT *
FROM #Clients
WHERE MiddleName LIKE 'A%'
GO

SELECT *
FROM #Clients
WHERE MiddleName NOT LIKE 'A%'
GO
```

Notice the results don't include any rows with `NULL` middlenames.

```
ID          Name                 MiddleName
----------- -------------------- --------------------
1           Alice                A

(1 row affected)

ID          Name                 MiddleName
----------- -------------------- --------------------
3           Charlie              C

(1 row affected)
```

_Source_: [NULL is NOT LIKE and NOT NOT LIKE](https://weblogs.sqlteam.com/markc/2009/06/08/60929/)
