---
layout: post
title: "Don't use functions around columns in your WHEREs: The worst T-SQL mistake"
tags: tutorial sql
cover: Cover.png
cover-alt: "Warning sign in a street"
---

There's one thing we could do to write faster queries in SQL Server: don't use functions around columns in WHERE clauses. I learned it the hard way. Let me share this lesson with you.

**Don't use user-defined or built-in functions around columns in the WHERE clause of queries. It prevents SQL Server from estimating the right amount of rows out of the function. Write queries with operators and comparisons to make SQL Server better use the indexes it has.**

## With functions around columns in WHEREs

To prove this point, let's query [StackOverflow database](https://www.brentozar.com/archive/2021/03/download-the-current-stack-overflow-database-for-free-2021-02/). Yes, the StackOverflow we all know and use.

StackOverflow has a Users table that contains, well..., all registered users and their profiles. Among other things, every user has a display name, location, and reputation.

Let's find the first 50 users by reputation in Colombia.

To make things faster, let's create an index on the Location field. It's an `NVARCHAR(100)` column.

```sql
CREATE INDEX Location ON dbo.Users(Location);
```

This is the query we often write,

```sql
DECLARE @Location NVARCHAR(20) = N'Colombia';

SELECT TOP 50 DisplayName, Location, CreationDate, Reputation
FROM dbo.Users
/* Often, we put LOWER on both sides of the comparison */
WHERE LOWER(Location) = LOWER(@Location)
ORDER BY Reputation DESC;
GO
```

Did you notice the `LOWER` function on both sides of the equal sign?

We all have written queries like that one. I declared myself guilty too. Often, we use `LOWER` and `UPPER` or wrap the column around `RTRIM` and `LTRIM`.

But, let's see what happened in the Execution Plan.

{% include image.html name="UsersInColombia.png" alt="Execution plan of finding the first 50 StackOverflow users in Colombia" caption="First 50 StackOverflow users in Colombia by reputation" width="600px" %}

We read execution plans from right to left and top to bottom.

Here, SQL Server chose to scan the index `Location` first. And notice the width of the arrow coming out of the first operator. When we place the cursor on it, it shows "Number of Rows Read."

{% include image.html name="RowsRead.png" alt="Rows read by Index Scan when finding StackOveflow users" caption="Rows read by Index Scan on Location index" width="600px" %}

In this copy of the StackOverflow database, there are 2,465,713 users, only 463 living in Colombia. SQL Server has to read the whole content of the index to execute our query.

It means that to find all users in Colombia, SQL Server had to go through all users in the index. We could use that index in a better way.

**Write queries with comparisons, functions, and operators around parameters. This way SQL Server could properly use indexes and have better estimates of the contents of tables. But, don't write functions around columns in the WHERE clauses.**

The same is true when joining tables. Don't put functions around the foreign keys in your JOINs either.

## Rewrite your queries to avoid functions around columns in WHERE

Let's go back and rewrite our query without any functions wrapping columns. This way,

```sql
DECLARE @Location NVARCHAR(20) = N'Colombia';

SELECT TOP 50 DisplayName, Location, CreationDate, Reputation
FROM dbo.Users
/* We remove LOWER on both sides */
WHERE Location = @Location
ORDER BY Reputation DESC;
GO
```

And, let's check the execution plan again.

{% include image.html name="NoFunction.png" alt="First 50 StackOverflow users in Colombia" caption="Again, first 50 StackOverflow users in Colombia by reputation" width="600px" %}

This time, SQL Server used an Index Seek. It means SQL Server knew the starting point when reading the index on `Location`. And the execution plan didn't go parallel. We don't have the black arrows in yellow circles in the operators.

Notice, this time we have a thinner arrow on the first operator. Let's see how many rows SQL Server read this time.

{% include image.html name="RowsReadWithoutFunction.png" alt="Rows read by Index Seek on Location index" caption="Rows read by Index Seek on Location index" width="400px" %}

After that change, SQL Server only read 463 records. That was way better than reading the whole index.

Voilà! If we want to write faster queries, let's stop using functions around columns in our WHEREs. That screws SQL Server estimates. For example, let's not use LOWER or UPPER around our columns. By the way, [SQL Server string searches are case insensitive]({% post_url 2022-02-21-CaseSensitiveSearchSQLServer %}) by default. we don't need those functions at all.

To read more SQL Server content, check [What are implicit conversions and why you should care]({% post_url 2022-02-07-WhatAreImplicitConversions %}), [how to optimize queries with GROUP BY]({% post_url 2022-03-07-OptimizeGroupBySQLServer %}), and [Just listen to SQL Server index recommendations]({% post_url 2022-03-21-SQLServerIndexRecommendations %}).

_Happy SQL time!_