---
layout: post
title: Six SQL Server performance tuning tips from Pinal Dave
tags: sql
description: Do you need to tune your SQL Server and you don't know how to start? These are six tips from Pinal Dave to tune your SQL Server
---

Recently, I've needed to optimize some SQL Server queries. I decided to look out there what to do to tune SQL Server and SQL queries. This is what I found.

**To tune your SQL Server queries, you can make changes at the database, table and query level.** At the database level, you can turn on automatic update of statistics, increase the file size autogrowth and update the compatibility level. At the table level, delete your unused indexes and create the missing ones. But, keep less than 5 indexes per table. And, at the query level, find and fix implicit conversions.

While looking up what I could do to tune my queries, I found Pinal Dave from [SQLAuthority](https://blog.sqlauthority.com/). Chances are you have already found one of his blog posts when searching for SQL Server tuning tips. He's been blogging about the subject for years.

These are six tips from Pinal's blog and online presentations I've applied recently. Please, test these changes in a development or staging environment before making anything on your production servers. I gained a lot of improvement by fixing implicit conversions. We had a `VARCHAR` column and in one store procedure we use a `NVARCHAR` parameter for the same column. SQL Server had to scan the whole table to make that comparison.

## Enable automatic statistics update 

**Turn on automatic update of statistics.** You should turn it off if you're updating a really long table during your work-hours. You can [enable automatic statistic update](https://blog.sqlauthority.com/2009/10/15/sql-server-enable-automatic-statistic-update-on-database/) with this query:

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

## Fix File Autogrowth

Add size and file growth to your database. Make it your weekly file growth. Otherwise set it to 200 or 250MB. You can [change the file autogrowth](https://blog.sqlauthority.com/2018/12/23/how-to-track-autogrowth-of-any-database-interview-question-of-the-week-205/) from SQL Server Management Studio.

## Find and Fix Implicit conversions

Implicit conversions happen when SQL Server needs to convert between two data types in a `WHERE` or in `JOIN`. For example, the query `SELECT * FROM dbo.Orders WHERE OrderNumber = 123` with `OrderNumber` as a `VARCHAR(20)` column has implicit warning when compared to an integer.

To decide when implicit conversion happens, you can check [Microsoft Data Type Precedence table](https://docs.microsoft.com/en-us/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-ver15). Types with lower precedence convert to types with higher precedence. For example, `VARCHAR` will be always converted to `INT` and to `NVARCHAR`.

You can use this script to [indentify queries with implicit conversion](https://blog.sqlauthority.com/2018/06/11/sql-server-how-to-fix-convert_implicit-warnings/).

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

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/ef-BmyNipU4?start=196&rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

## Change compatibility level

After updating your SQL Server, make sure to update the compatibility level of your database to the highest level supported by the current version of your SQL Server. You can check SqlAuthority blog on [how to change compatibility level](https://blog.sqlauthority.com/2017/05/22/sql-server-change-database-compatibility-level/).

```sql
ALTER DATABASE <YourDatabase>
SET COMPATIBILITY_LEVEL = { 150 | 140 | 130 | 120 | 110 | 100 | 90 }
```

## Create missing indexes

But, don't create all missing indexes. Create the first 10 missing indexes. You should have only ~5 indexes per table. You can use the next script to [find the missing indexes in your database](https://blog.sqlauthority.com/2011/01/03/sql-server-2008-missing-index-script-download/).

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

## Delete most of your indexes

**Indexes reduce perfomance all the time.** They reduce performance of inserts, updates, deletes and selects. Even if a query isn't using an index, it reduces performance of the query.

Delete most your indexes. Identify your main table and check if it has more than 5 indexes. Don't create indexes on every key of a join.

Also, keep in mind if you rebuild an index for a table, SQL Server will remove all caches related to that table. Rebuilding your indexes is the most expensive way of updating statistics.

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/SqhX8OaOI6A?start=395&rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

You can [find your unused indexes](https://blog.sqlauthority.com/2011/01/04/sql-server-2008-unused-index-script-download/) with this script:

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

_Happy SQL time!_
