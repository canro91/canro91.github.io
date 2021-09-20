---
layout: post
title: "TIL: NULL isn't LIKE anything else in SQL Server"
tags: todayilearned sql
---

How does the LIKE operator handle NULL values of a column? Let's see what SQL Server does when using LIKE with a nullable column.

**When using the LIKE operator on a nullable column, SQL Server doesn't include in the results rows with NULL values in that column. The same is true, when using NOT LIKE in a WHERE clause.**

Let's see an example. Let's create a `Client` table with an ID, name and middleName. Only two of the four sample clients have a middlename.

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

{% include image.html name="Null&Like.png" alt="Results of querying a nullable column with LIKE" caption="Results of querying a nullable column with LIKE and NOT LIKE" %}

Voilà! That's how SQL Server handle NULL when using LIKE and NOT LIKE. Remember you don't need to check for null values.

If you want to read more SQL Server content, check [six performance tuning tips]({% post_url 2020-09-28-SQLServerTuningTips %}) and the lessons learned while [tuning a store procedure to search reservations]({% post_url 2020-10-14-SearchingReservations %}).

_Source_: [NULL is NOT LIKE and NOT NOT LIKE](https://weblogs.sqlteam.com/markc/2009/06/08/60929/)