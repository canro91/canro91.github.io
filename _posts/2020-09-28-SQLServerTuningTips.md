---
layout: post
title: Six SQL Server performance tuning tips from Pinal Dave
tags: sql
description: Do you need to tune your SQL Server and you don't know how to start? These are six tips from Pinal Dave to tune your SQL Server
---

Recently, I've needed to optimize some SQL Server queries. I decided to look out there what to do to tune SQL Server and SQL queries. This is what I found.

**At the database level, turn on automatic update of statistics, increase the file size autogrowth and update the compatibility level. At the table level, delete unused indexes and create the missing ones, keeping around 5 indexes per table. And, at the query level, find and fix implicit conversions.**

While looking up what I could do to tune my queries, I found [Pinal Dave from SQLAuthority](https://blog.sqlauthority.com/). Chances are you have already found one of his blog posts when searching for SQL Server tuning tips. He's been blogging about the subject for years.

These are six tips from Pinal's blog and online presentations I've applied recently. Please, let's test these changes in a development or staging environment before making anything on our production servers.

## 1. Enable automatic update of statistics 

**Let's turn on automatic update of statistics.** We should turn it off if we're updating a really long table during your work-hours.

This is how to enable automatic update of statistic update, [[Source]](https://blog.sqlauthority.com/2009/10/15/sql-server-enable-automatic-statistic-update-on-database/)

```sql
USE <YourDatabase>;
GO

-- Enable Auto Create of Statistics
ALTER DATABASE <YourDatabase>
SET AUTO_CREATE_STATISTICS ON WITH NO_WAIT;

-- Enable Auto Update of Statistics
ALTER DATABASE <YourDatabase>
SET AUTO_UPDATE_STATISTICS ON WITH NO_WAIT;
GO

-- Update Statistics for whole database
EXEC sp_updatestats
GO
```

## 2. Fix File Autogrowth

Let's add size and file growth to our database. Let's use our weekly file growth. Otherwise, let's change it to 200 or 250MB.

From SQL Server Management Studio, to change the file autogrowth:

1. Let's go to our database properties and then to Files, then
2. Click on the three dots in the Autogrowth column, and
3. Change the file growth.

{% include image.html name="FileAutogrowth.png" caption="Files page from Database properties in SQL Server Management Studio" alt="Files page from Database properties in SQL Server Management Studio" width="800px" %}

## 3. Find and Fix Implicit conversions

Implicit conversions happen when SQL Server needs to convert between two data types in a `WHERE` or in `JOIN`.

For example, if we compare a `OrderNumber` column being `VARCHAR(20)` to an `INT` parameter, SQL Server warns about an implicit conversion.

```sql
DECLARE @OrderNumber INT = 123;

SELECT *
FROM dbo.Orders
WHERE OrderNumber = @OrderNumber;
GO
```

To run this query, SQL Server has to go through all the rows in the `dbo.Orders` table to convert the `OrderNumber` from `VARCHAR(20)` to `INT`.

To decide when implicit conversions happen, SQL Server follows a precedence rule between data types. For example, SQL Server always converts `VARCHAR` to `INT` and `NVARCHAR`. 

This script indentifies queries with implicit conversions, [[Source]](https://blog.sqlauthority.com/2018/06/11/sql-server-how-to-fix-convert_implicit-warnings/)

```sql
SELECT TOP(50) DB_NAME(t.[dbid]) AS [Database Name], 
t.text AS [Query Text],
qs.total_worker_time AS [Total Worker Time], 
qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
qs.max_worker_time AS [Max Worker Time], 
qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
qs.max_elapsed_time AS [Max Elapsed Time],
qs.total_logical_reads/qs.execution_count AS [Avg Logical Reads],
qs.max_logical_reads AS [Max Logical Reads], 
qs.execution_count AS [Execution Count], 
qs.creation_time AS [Creation Time],
qp.query_plan AS [Query Plan]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
WHERE CAST(query_plan AS NVARCHAR(MAX)) LIKE ('%CONVERT_IMPLICIT%')
 AND t.[dbid] = DB_ID()
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);
```

Let's be aware, not all implicit convesions are bad. Often implicit conversions lead to scans or seeks. That's why [we should care about implicit conversions]({% post_url 2022-02-07-WhatAreImplicitConversions %}).

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/ef-BmyNipU4?start=196&rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

## 4. Change compatibility level

After updating our SQL Server, let's make sure to update the compatibility level of our database to the highest level supported by the current version of our SQL Server.

We can change your SQL Server compatibility level using SQL Server Management Studio or with  a query. [[Source]](https://blog.sqlauthority.com/2017/05/22/sql-server-change-database-compatibility-level/)

```sql
ALTER DATABASE <YourDatabase>
SET COMPATIBILITY_LEVEL = { 150 | 140 | 130 | 120 | 110 | 100 | 90 }
```

## 5. Find and Create missing indexes

Let's create our missing indexes. But, let's not create them all. Let's create the first 10 missing indexes in our database and stick to around 5 indexes per table.

We can use the next script to find the missing indexes in our database. [[Source]](https://blog.sqlauthority.com/2011/01/03/sql-server-2008-missing-index-script-download/) Let's check the indexes we already have and the estimated impact of the missing indexes. [Let's not blindly follow index recommendations]({% post_url 2022-03-21-SQLServerIndexRecommendations %}).

```sql
SELECT TOP 25
dm_mid.database_id AS DatabaseID,
dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') 
+ CASE
WHEN dm_mid.equality_columns IS NOT NULL
AND dm_mid.inequality_columns IS NOT NULL THEN '_'
ELSE ''
END
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + dm_mid.statement
+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns 
IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (dm_mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
ORDER BY Avg_Estimated_Impact DESC
GO
```

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/fX05yEkSkpo?start=706&rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

## 6. Delete unused indexes

**Indexes reduce perfomance all the time.** They reduce performance of inserts, updates, deletes and selects. Even if a query isn't using an index, it reduces performance of the query.

Let's delete most our indexes. Let's identify our "main" table and check if it has more than 5 indexes.

Also, let's keep in mind if we rebuild an index for a table, SQL Server will remove all plans cached for that table.

**Rebuilding indexes is the most expensive way of updating statistics.**

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/SqhX8OaOI6A?start=395&rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

We can find our unused indexes with the next script. [[Source]](https://blog.sqlauthority.com/2011/01/04/sql-server-2008-unused-index-script-download/) Let's look for indexes with zero seeks or scans and lots of updates. They're good candidates to drop.

```sql
SELECT TOP 25
o.name AS ObjectName
, i.name AS IndexName
, i.index_id AS IndexID
, dm_ius.user_seeks AS UserSeek
, dm_ius.user_scans AS UserScans
, dm_ius.user_lookups AS UserLookups
, dm_ius.user_updates AS UserUpdates
, p.TableRows
, 'DROP INDEX ' + QUOTENAME(i.name)
+ ' ON ' + QUOTENAME(s.name) + '.'
+ QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS 'drop statement'
FROM sys.dm_db_index_usage_stats dm_ius
INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id 
AND dm_ius.OBJECT_ID = i.OBJECT_ID
INNER JOIN sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
FROM sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
WHERE OBJECTPROPERTY(dm_ius.OBJECT_ID,'IsUserTable') = 1
AND dm_ius.database_id = DB_ID()
AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC
GO
```

Voilà! These are six tips I learned from Pinal Dave to start tuning your SQL Server. Let's pay attention to your implicit conversions. You can get a surprise.

I gained a lot of improvement only by fixing implicit conversions. In a store procedure, we had a `NVARCHAR` parameter to compare it with a `VARCHAR` column. Yes, implicit conversions happen between `VARCHAR` and `NVARCHAR`.

After taking [Brent Ozar's Mastering courses]({% post_url 2022-05-02-BrentOzarMasteringCoursesReview %}), I learned to look at the overall SQL Server server health, focusing on the top wait type and the most expensive queries. Also, I started to use some of the stored procedures from the [First Responder Kit repository on GitHub](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit) instead. 

For more SQL and performance tuning content, check [don't use functions around columns in your WHEREs]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}), [what implicit conversions are and why you should care]({% post_url 2022-02-07-WhatAreImplicitConversions %}) and [just listen to index recommendations]({% post_url 2022-03-21-SQLServerIndexRecommendations %}).

_Happy SQL time!_
