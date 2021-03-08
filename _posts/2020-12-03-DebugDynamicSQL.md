---
layout: post
title: TIL&colon; Three Tricks to Debug Your Dynamic SQL Queries
tags: todayilearned sql
---

These three tips will help you to troubleshoot your dynamic queries and identify the source of a dynamic query when you find one in your query store or plan cache.

**Dynamic SQL is a string with a query to execute**. This string is built based on the input parameters of a store procedure or any other condition to include the right clauses, comparisons and statements to execute. Often, Dynamic SQL is used with store procedures to search records with optional input parameters.

## Format your dynamic SQL queries for more readability

To read your dynamic queries stored in the plan cache, make sure to insert new lines when appropriate. Use a variable for the line endings. For example, `DECLARE @crlf NVARCHAR(2) = NCHAR(13) + NCHAR(10)`.

Also, to identify the source of a dynamic query, add as a comment the name of the store procedure generating it. But, don't use inside that comment a timestamp or any other dynamic text. Otherwise, you will end up with almost identical entries in the plan cache.

## Add a parameter to print the generated query

To debug the generated dynamic query, add a parameter to print it. Also, you can add a second debugging parameter to avoid executing the query. For example, you can name these two parameters, `@Debug_PrintQuery` and `@Debug_ExecuteQuery`, respectively.

## Change the casing of variables and keywords inside your dynamic SQL

To distinguish errors between the actual SQL query and the dynamic query, change the casing keywords and variables inside your the dynamic query.

## Example

In the store procedure `dbo.usp_SearchUsers` below, notice the use of the variable `@crlf` to insert line breaks and the comment `/* usp_SearchUsers */` to identify the source of the query. 

Also, check the two debugging parameters: `@Debug_PrintQuery` and `@Debug_ExecuteQuery`. And, finally, see how the casing is different inside the dynamic SQL.

```sql
CREATE OR ALTER PROC dbo.usp_SearchUsers
  @SearchDisplayName NVARCHAR(100) = NULL,
  @SearchLocation NVARCHAR(100) = NULL
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
      @SearchDisplayName, @SearchLocation, @SearchReputation;
END
GO
```

_Source_: [Dynamic SQL Pro Tips](https://www.brentozar.com/sql/dynamic/) 
