---
layout: post
title: How not to write Dynamic SQL
tags: tutorial sql
---

Last time, I showed you [three tips to debug your Dynamic SQL]({% post_url 2020-12-03-DebugDynamicSQL %}). Let's take a step back. Let's see what is a dynamic SQL query and how to use one to rewrite a stored procedure with optional parameters.

**Dynamic SQL is a string with a query to execute. In a stored procedure with optional parameters, Dynamic SQL is used to build a string containing a query with only the comparisons and clauses for the parameters passed with a non-default value**.

## Without Dynamic SQL

Let's go back to the stored procedure `dbo.usp_SearchUsers` from our previous post [on debugging Dynamic SQL queries]({% post_url 2020-12-03-DebugDynamicSQL %}). This stored procedure finds StackOverflow users by display name or location or both.

Without Dynamic SQL, we end up with funny comparisons in the WHERE clause. First, we check if the optional parameters have value. To then, with an OR, add the right comparisons. Everything in a single statement.

```sql
CREATE OR ALTER PROC dbo.usp_SearchUsers
  @SearchDisplayName NVARCHAR(100) = NULL,
  @SearchLocation NVARCHAR(100) = NULL
AS
BEGIN
    
  SELECT TOP 100 *
  FROM dbo.Users u
  WHERE (@SearchDisplayName IS NULL OR DisplayName LIKE @SearchDisplayName)
    AND (@SearchLocation IS NULL OR Location LIKE @SearchLocation);
END
GO
```

Let's run our stored procedure searching only by DisplayName and see its execution plan.

{% include image.html name="NoDynamicSQL.png" caption="Search for only a single user by DisplayName" alt="Execution plan of searching users by DisplayName" width="800px" %}

Notice SQL Server had to scan the `DisplayName` index and see the number of rows read.

Sometimes, we use the `ISNULL()` or `COALESCE()` functions instead of `IS NULL`. But, those are variations on the same theme.

The more optional parameters our stored procedure has, the worse our query gets. SQL Server will scan entire tables or indexes to satify our query.

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

We moved the exact same query to a string and asked SQL Server to execute that string. That won't make any difference between the execution plans of both versions. We only put makeup on the problem. _Arggg!_

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

First, we created a `@StringToExecute` variable with the first part of the SELECT. We added `1 = 1` on the WHERE to easily add conditions in the next steps.

Instead of, `1 = 1` we can also use a common or required condition for all other set of parameters.

Then, notice the two IF statements. We added the conditions to the WHERE clause depending on the parameter passed.

After that, we executed the query inside the string with `sp_executesql` with the parameter declaration and the parameters themselves.

{% include image.html name="WithDynamicSQL.png" caption="Search for only a single user by DisplayName with Dynamic SQL" alt="Execution plan of searching users by DisplayName" width="800px" %}

With Dynamic SQL, our stored procedure will generate one execution plan for each set of different parameters. That's the point of using Dynamic SQL.

This time, SQL Server could seek on `DisplayName` instead of scanning it. That's better.

Voilà! That's how NOT to write a stored procedure with optional parameters with Dynamic SQL. Notice that to make things simple, we didn't follow all the tips to [make our Dynamic SQL easier to debug]({% post_url 2020-12-03-DebugDynamicSQL %}).

If you're interested in more content about SQL and SQL Server, check my posts on [Six SQL Server performance tuning tips]({% post_url 2020-09-28-SQLServerTuningTips %}) and [How to format your SQL queries]({% post_url 2020-09-30-FormatSQL %}).

_Happy coding!_
