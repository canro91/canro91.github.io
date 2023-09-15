---
layout: post
title: "TIL: How to compare DateTime without the time part in SQL Server"
tags: todayilearned sql
---

If you use `DATEDIFF()` or `CAST()` to filter a table by a DATETIME column using only the date part, there's a better way. Let's find it out.

**To compare dates without the time part, don't use the DATEDIFF() or any other function on both sides of the comparison in a WHERE clause. Instead, put CAST() on the parameter and compare using >= and < operators**.

Let's use a local copy of the [StackOverflow database](https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/) to find all user profiles created on a particular date.

Inside StackOverflow database, there's `dbo.Users` table with a `CreationDate` column. Let's use that column to find all users who created their profiles today.

Before we get started, let's create an index on `CreationDate` to make things faster.

```sql
CREATE INDEX CreationDate ON dbo.Users(CreationDate);
```

Probably, we would write a query like this one,

```sql
SELECT * FROM dbo.Users
WHERE DATEDIFF(DAY, CreationDate, GETDATE()) = 0;
```

But, SQL Server has to scan the entire index. Notice the "Index Scan" operator in the execution plan. SQL Server doesn't have any statistics on `CreationDate` wrapped in a `DATEDIFF()` function.

{% include image.html name="DATEDIFF.png" alt="Execution plan filtering a DateTime column with DATEDIFF" caption="Execution plan filtering a DateTime column with DATEDIFF" %}

**An Index Scan by itself in an execution plan isn't good or bad. It depends on the number of rows read**.

In this case, SQL Server read all the records on the `dbo.Users` table. When we hover over the row next to the "Index Scan" operator, we notice the number of rows read. It scanned the whole index, more than 2 millions of records.

{% include image.html name="Rows.png" alt="Execution plan showing the rows read" caption="Execution plan showing the rows read" %}

Let's stop using `DATEDIFF()` or `CAST()` to filter a table on a DATETIME column.

**To filter a table on a DATETIME column comparing only the date part, use `CAST()` only around the parameter, and `>=` and `<` with the desired date and the day after.**

```sql
SELECT * FROM dbo.Users
 WHERE CreationDate >= CAST(GETDATE() AS DATE)
   AND CreationDate < DATEADD(day, 1, CAST(GETDATE() AS DATE));
```

Voilà! That's how to compare dates on the WHERE clauses. Don't use `DATEDIFF()` or `CAST()` on both sides of the comparison. In general, [don't put functions around columns]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}) in the WHERE clause.

For more content about SQL Server, check the [difference between EXISTS SELECT 1 and EXISTS SELECT *]({% post_url 2020-10-08-ExistsSelectSQLServer %}) and [how LIKE handle NULL values]({% post_url 2020-10-20-LikeWithNullSQLServer %}).

_Source_: [Optimized date compare in WHERE clause](https://dba.stackexchange.com/questions/128235/optimized-date-compare-in-where-clause-convert-or-datediff-0)