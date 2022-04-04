---
layout: post
title: "TIL: T-SQL doesn't have constants and variables aren't a good idea"
tags: todayilearned sql
cover: Cover.png
cover-alt: "TIL: T-SQL doesn't have constants and variables aren't a good idea" 
---

Today I learned how to use constants in SQL Server stored procedures. While getting a stored procedure reviewed, I got one comment to remove literal values. This is how to bring constants in T-SQL.

**SQL Server doesn't have a keyword for constants. To introduce constants in stored procedures, write literal values next to an explaining comment or use single-row views with the constant values as columns.**

## Don't use variables as constants

From C# and other programming languages, we've learned to use constants or enums instead of magic values all over our code. Often, we bring constants to our T-SQL queries. But...

**T-SQL doesn't have a keyword for constants. And, SQL Server engine doesn't inline variables when executing stored procedures.**

The first thing we try by mistake to emulate constants is to use variables.

For example, let's find all StackOverflow users with two reputation points. That's not a popular reputation among StackOverflow users. Something like this,

```sql
/* An index to speed things up a bit */
CREATE INDEX Reputation ON dbo.Users(Reputation)
GO

CREATE OR ALTER PROC dbo.usp_GetUsers
AS
BEGIN
    /* This is how we often emulate constants */
    DECLARE @Reputation INT = 2;

    SELECT *
    FROM dbo.Users u
    WHERE u.Reputation = @Reputation
    ORDER BY u.CreationDate DESC;
END
GO
```

This is the execution plan. Let's keep an eye on the number of estimated users.

{% include image.html name="Variable.png" alt="StackOverflow users with reputation = 2" caption="Execution plan of finding users with 2-point reputation" width="600px" %}

But, there's a downside. Variables inside stored procedures trigger a different behavior in SQL Server.

### Variables and execution plans

When executing a stored procedure, SQL Server creates an execution plan for the first set of parameters it sees. And, SQL Server reuses the same execution plan the next time we run that stored procedure. We call this behavior **Parameter Sniffing**.

SQL Server uses statistics (histograms built from samples of our data) to choose the shape of the execution plan. Which table to read first, how to read that table, the number of threads, the amount of memory, among other things.

But, when there are variables in a stored procedure, SQL Server builds execution plans, not from statistics (e.i. samples of our data), but from an "average value."

Variables make SQL Server build different execution plans, probably not suited for the set of parameters we're calling our stored prcedures with. That's why variables aren't a good idea to replace constants.

## Literal values and comments

**The simplest solution to constants in T-SQL is to use literal values.** 

To make stored procedures more maintainable, it's a good idea to write an explaining comment next to the literal value.

Let's rewrite our stored procedure with a literal and a comment.

```sql
CREATE OR ALTER PROC dbo.usp_GetUsers
AS
BEGIN
    SELECT DisplayName, Location, CreationDate
    FROM dbo.Users u
    WHERE u.Reputation = /* Interesting reputation */2
    ORDER BY u.CreationDate DESC;
END
GO
```

This is the execution plan.

{% include image.html name="LiteralAndComment.png" alt="StackOverflow users with reputation = 2" caption="This time, we're back to a literal value and a comment" width="600px" %}

Do you remember the estimated number of users from our example with variables? Now, we have a more accurate estimated number. SQL Server isn't using an average value. It has better estimates this time.

We even have an index recommendation in our execution plan. By the way, [don't blindly follow index recommendations]({% post_url 2022-03-21-SQLServerIndexRecommendations %}), just listening to them. 

## Create a view for constants

The hardcoded value and an explanatory comment are OK if we have our "constant" in a few places. 

A more maintainable solution to literal values is to create a single-row view with columns named after the constants to declare.

```sql
CREATE OR ALTER VIEW dbo.vw_Constant
AS
SELECT (2) InterestingReputation
GO
```

With that view in place, we can replace the hardcoded values in our stored procedure. 

```sql
CREATE OR ALTER PROC dbo.usp_GetUsers
AS
BEGIN
    SELECT *
    FROM dbo.Users u
    /* The views with our constant */
    INNER JOIN dbo.vw_Constant c 
    ON u.Reputation = c.InterestingReputation
    ORDER BY u.CreationDate DESC;
END
GO
```

A more maintainable alternative while keeping good estimates.

Voilà! That's how to use constants with a view in SQL Server. I found a proposal to introduce [a constant keyword](https://blog.greglow.com/2020/03/05/sql-t-sql-really-needs-constants/) in SQL Server. I learned about the trick with views while getting my code reviewed. But I also found the same idea in this [StackOverflow question](https://stackoverflow.com/questions/26652/is-there-a-way-to-make-a-tsql-variable-constant) and in [this one](https://stackoverflow.com/questions/6114826/sql-views-no-variables) too.

For more content on SQL Server, check my other posts on [functions and WHERE clauses]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}), [implicit conversions]({% post_url 2022-02-07-WhatAreImplicitConversions %}) and [index recommendations]({% post_url 2022-03-21-SQLServerIndexRecommendations %}).

_Happy coding!_