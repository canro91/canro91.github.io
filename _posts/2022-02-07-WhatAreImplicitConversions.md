---
layout: post
title: "What are implicit conversions and why you should care"
tags: tutorial sql
cover: Cover.png
cover-alt: "Geometric shapes made of wood"
---

SQL Server compares columns and parameters with the same data types. But, if the two data types are different, weird things happen. Let's see what implicit conversions are and why we should care.

**An implicit conversion happens when the data types of columns and parameters in comparisons are different. And SQL Server has to convert between them, following type precedence rules. Often, implicit conversions lead to unneeded index or table scans.**

## An implicit conversion that scans

Let's see an implicit convention. For this, let's create a new table from the StackOverflow Users table. But, this time, let's change the Location data type from NVARCHAR to VARCHAR.

```sql
USE StackOverflow2013;
GO

CREATE TABLE dbo.Users_Varchar (Id INT PRIMARY KEY CLUSTERED, Location VARCHAR(100));
INSERT INTO dbo.Users_Varchar (Id, Location)
  SELECT Id, Location
  FROM dbo.Users;
GO

CREATE INDEX Location ON dbo.Users_Varchar(Location);
GO
```

Let's find all users from Colombia. To prove a point, let's query the `dbo.Users_Varchar` table.

```sql
DECLARE @Location NVARCHAR(20) = N'Colombia';

SELECT Id, Location
FROM dbo.Users_Varchar
/* The column is VARCHAR, but the parameter NVARCHAR */
WHERE Location = @Location;
GO
```

Notice we have used as a parameter an NVARCHAR variable. We have a type mismatch between the column and the variable.

Let's see the execution plan.

{% include image.html name="IndexScanOnLocation.png" alt="Execution plan of finding all users StackOverflow users from Colombia" caption="StackOverflow users from Colombia" width="600px" %}

SQL Server had to scan the index on Location. But, why?

{% include image.html name="WarningSign.png" alt="Warning sign on execution plan of finding all users StackOverflow users from Colombia" caption="Warning sign on SELECT operator" width="500px" %}

Notice the warning sign on the execution plan. When we hover over it, it shows the cause. SQL Server had to convert the two types. Yes, SQL Server converted between VARCHAR and NVARCHAR.

## SQL Server data type precedence

To determine what types to convert SQL Server follows a data type precedence table. This is a short version.

| Data Types |
|---|
| datetimeoffset |
| datetime2 |
| datetime |
| smalldatetime |
| date |
| time |
| decimal |
| bigint |
| int |
| timestamp |
| uniqueidentifier |
| nvarchar (including nvarchar(max)) |
| varchar (including varchar(max)) |

Lower types in the table convert to higher ones. You don't need to memorize it. Remember, SQL Server always has to convert VARCHAR to other types.

For the complete list, check Microsoft docs on [SQL Server data Type precedence](https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-ver15).

## An implicit conversion that seeks

In our example, the VARCHAR type was on the left of the comparison in the WHERE. It means SQL Server had to read the whole content of the index to convert and then compare. More than 2 million rows. That's why the index scan.

Let's use the original `dbo.Users` table with Location as NVARCHAR and repeat the query. This time, switching the variable type to VARCHAR. What would be different?

```sql
DECLARE @Location VARCHAR(20) = 'Colombia';

SELECT Id, Location
/* We're filtering on the original Users table */
FROM dbo.Users
/* This time, the column is NVARCHAR, but the parameter VARCHAR */
WHERE Location = @Location;
GO
```

Now, the VARCHAR type is on the right of the comparison. It means SQL Server has to do one single conversion. The parameter.

{% include image.html name="IndexSeekOnLocation.png" alt="Execution plan of finding all users StackOverflow users from Colombia" caption="Index Seek on Location index when finding all users from Colombia" width="800px" %}

This time we don't have a yellow bang on our execution plan. And, we have an Index Seek. Not all implicit conversions are bad.

**In stored procedures and queries, use input parameters with the same types as the columns on the tables.**

To identify which queries on your SQL Server have implicit conversions issues, we can use the third query from [these six performance tuning tips from Pinal Dave]({% post_url 2020-09-28-SQLServerTuningTips %}). But, after taking [Brent Ozar's Mastering courses]({% post_url 2022-05-02-BrentOzarMasteringCoursesReview %}), I learned to start working with the most expensive queries instead of jumping to queires with implicit convertion issues right away.

Voilà! Those are implicit conversions and why you should care. Let's use input parameters with the right data types on your queries and store procedures. Otherwise, we will pay the performance penalty of converting and comparing types. Implicit conversions are like [functions around columns]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}), implicitly added by SQL Server itself.

Let's remember that not all implicit conversions are bad. When looking at execution plans, let's check how many rows SQL Server reads to convert and compare things.

For more content on SQL Server, check [how to compare datetimes without the time part]({% post_url 2020-10-05-CompareDateTimeSQLServer %}), [how to write case-insensitive searches]({% post_url 2022-02-21-CaseSensitiveSearchSQLServer %}) and [how to optimize queries with GROUP BY]({% post_url 2022-03-07-OptimizeGroupBySQLServer %}).

_Happy coding!_