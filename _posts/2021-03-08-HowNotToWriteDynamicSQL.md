---
layout: post
title: How not to write Dynamic SQL
tags: tutorial sql
---

Last time, I showed you [three tips to debug your Dynamic SQL]({% post_url 2020-12-03-DebugDynamicSQL %}). Let's take a step back. Let's see what is a dynamic SQL query and how to use one to rewrite a stored procedure with optional parameters.

**Dynamic SQL is a string with a query to execute. In a stored procedure with optional parameters, Dynamic SQL is used to build a string containing a query with only the comparisons and clauses for the parameters passed with a non-default value**.

## Without Dynamic SQL

Let's go back to the stored procedure `dbo.usp_SearchUsers` from our previous post [on debugging Dynamic SQL queries]({% post_url 2020-12-03-DebugDynamicSQL %}). This stored procedure finds StackOverflow users by display name or location.

Without Dynamic SQL, we end up with funny comparisons in the WHERE clause. First, we check if the optional parameters have value. To then, with an OR, add the right comparisons. Everything in a single statement.

```sql
CREATE OR ALTER PROC dbo.usp_SearchUsers
  @SearchDisplayName NVARCHAR(100) = NULL,
  @SearchLocation NVARCHAR(100) = NULL
BEGIN
    
  SELECT TOP 100 *
  FROM dbo.Users u
  WHERE (@SearchDisplayName IS NULL OR DisplayName LIKE @SearchDisplayName)
    AND (@SearchLocation IS NULL OR Location LIKE @SearchLocation);
END
GO
```

Sometimes, we use the `ISNULL()` or `COALESCE()` functions instead of `IS NULL`. But, those are variations on the same theme.

The more optional parameters our stored procedure has, the worse our query gets. SQL Server will scan more rows than what it needs.

<figure>
<img src="https://images.unsplash.com/photo-1548630435-998a2cbbff67?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="How not to write Dynamic SQL" />

<figcaption><span>Photo by <a href="https://unsplash.com/@nadineshaabana?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Nadine Shaabana</a> on <a href="https://unsplash.com/photos/HBABoZYH0yI?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## With Dynamic SQL, the wrong way

Probably, we hear about Dynamic SQL somewhere on the Internet and we decide to use it.

Then, we write the next version of our stored procedure. Something like the one below.

```sql
CREATE OR ALTER PROC dbo.usp_SearchUsersWithWrongDynamicSQL
  @SearchDisplayName NVARCHAR(100) = NULL,
  @SearchLocation NVARCHAR(100) = NULL
AS
BEGIN
 
  DECLARE @StringToExecute NVARCHAR(4000);
    
  SET @StringToExecute = N'SELECT TOP 100 *
  FROM dbo.Users u
  WHERE (@SearchDisplayName IS NULL OR DisplayName LIKE @SearchDisplayName)
    AND (@SearchLocation IS NULL OR Location LIKE @SearchLocation);';

  EXEC sp_executesql @StringToExecute, 
    N'@SearchDisplayName NVARCHAR(100), @SearchLocation NVARCHAR(100)', 
    @SearchDisplayName, @SearchLocation;
END
GO
```

We moved the exact same query to a string and ask SQL Server to execute that string. That won't make any difference between the execution plans of both versions. We only put makeup on the problem. _Arggg!_

## With Dynamic SQL, the right way

With Dynamic SQL, we want to create smaller queries for the different set of parameters passed to our stored procedure.

We need to add only the comparisons and clauses for the parameters passed with non-default values.

Let's rewrite the stored procedure to include the conditions to the WHERE based on the parameters passed.

```sql
CREATE OR ALTER PROC dbo.usp_SearchUsers_DynamicSQL
  @SearchDisplayName NVARCHAR(100) = NULL,
  @SearchLocation NVARCHAR(100) = NULL
AS
BEGIN
 
  DECLARE @StringToExecute NVARCHAR(4000);
    
  SET @StringToExecute = N'SELECT TOP 100 *
  FROM dbo.Users u
  WHERE 1 = 1';

  IF @SearchDisplayName IS NOT NULL
    SET @StringToExecute = @StringToExecute + N' AND DisplayName LIKE @SearchDisplayName ';

  IF @SearchLocation IS NOT NULL
    SET @StringToExecute = @StringToExecute + N' AND Location LIKE @SearchLocation ';

  EXEC sp_executesql @StringToExecute, 
    N'@SearchDisplayName NVARCHAR(100), @SearchLocation NVARCHAR(100)', 
    @SearchDisplayName, @SearchLocation;
END
GO
```

First, we created a `@StringToExecute` variable with the first part of the SELECT.

Then, notice the two IF statements. We added the conditions to the WHERE clause depending on the parameter passed.

After that, we executed the query inside the string with `sp_executesql` with the parameter declaration and the parameters themselves.

With Dynamic SQL, our stored procedure will generate one execution plan for each set of parameters. This time, SQL Server could use the right indexes to run each query. That's the point of using Dynamic SQL.

Voilà! That's how NOT to write a stored procedure with optional parameters with Dynamic SQL. Notice that to make things simple, we didn't follow all the tips to [make our Dynamic SQL easier to debug]({% post_url 2020-12-03-DebugDynamicSQL %}).

If you're interested in more content about SQL and SQL Server, check my posts on [Six SQL Server performance tuning tips]({% post_url 2020-09-28-SQLServerTuningTips %}) and [How to format your SQL queries]({% post_url 2020-09-30-FormatSQL %}).

_Happy coding!_
