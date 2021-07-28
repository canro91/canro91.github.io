---
layout: post
title: "TIL: Three Tricks to Debug Your Dynamic SQL Queries"
tags: todayilearned sql
---

These three tips will help you to troubleshoot your dynamic queries and identify the source of a dynamic query when you find one in your query store or plan cache.

**To make dynamic SQL queries easier to debug, format the generated query with line breaks, add as a comment the name of the source stored procedure and use a parameter to only print the generated query.**

## 1. Format your dynamic SQL queries for more readability

To read your dynamic queries stored in the plan cache, make sure to insert new lines when appropriate.

Use a variable for the line endings. For example, `DECLARE @crlf NVARCHAR(2) = NCHAR(13) + NCHAR(10)`.

Also, to identify the source of a dynamic query, add as a comment the name of the stored procedure generating it. But, don't use inside that comment a timestamp or any other dynamic text. Otherwise, you will end up with almost identical entries in the plan cache.

## 2. Add a parameter to print the generated query

To debug the generated dynamic query, add a parameter to print it. And, a second parameter to avoid executing the query.

For example, you can name these two parameters, `@Debug_PrintQuery` and `@Debug_ExecuteQuery`, respectively.

## 3. Change the casing of variables and keywords inside your dynamic SQL

To distinguish errors between the actual SQL query and the dynamic query, change the casing of keywords and variables inside your dynamic query.

## Example

In the store procedure `dbo.usp_SearchUsers` below, notice the use of the variable `@crlf` to insert line breaks and the comment `/* usp_SearchUsers */` to identify the source of the query. 

Also, check the two debugging parameters: `@Debug_PrintQuery` and `@Debug_ExecuteQuery`. And, finally, see how the casing is different inside the dynamic SQL.

```sql
CREATE OR ALTER PROC dbo.usp_SearchUsers
  @SearchDisplayName NVARCHAR(100) = NULL,
  @SearchLocation NVARCHAR(100) = NULL,
  @Debug_PrintQuery TINYINT = 0,
  @Debug_ExecuteQuery TINYINT = 1 AS
BEGIN
  DECLARE @StringToExecute NVARCHAR(4000);
  DECLARE @crlf NVARCHAR(2) = NCHAR(13) + NCHAR(10);
    
  SET @StringToExecute = @crlf + N'/* usp_SearchUsers */' + N'select * from dbo.Users u where 1 = 1 ' + @crlf;

  IF @SearchDisplayName IS NOT NULL
    SET @StringToExecute = @StringToExecute + N' and DisplayName like @searchdisplayName ' + @crlf;

  IF @SearchLocation IS NOT NULL
    SET @StringToExecute = @StringToExecute + N' and Location like @searchlocation ' + @crlf;

  IF @Debug_PrintQuery = 1
    PRINT @StringToExecute

  IF @Debug_ExecuteQuery = 1
    EXEC sp_executesql @StringToExecute, 
      N'@searchdisplayName nvarchar(100), @searchlocation nvarchar(100)', 
      @SearchDisplayName, @SearchLocation;
END
GO
```

Voilà! That's how you can make your dynamic SQL queries easier to debug. If you're new to the whole concept of dynamic SQL queries, check [how to NOT to write dynamic SQL]({% post_url 2021-03-08-HowNotToWriteDynamicSQL %}).

_Source_: [Dynamic SQL Pro Tips](https://www.brentozar.com/sql/dynamic/) 
