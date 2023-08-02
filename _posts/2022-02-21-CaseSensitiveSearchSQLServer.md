---
layout: post
title: "TIL: How to do a case-sensitive search in SQL Server"
tags: todayilearned sql
cover: Cover.png
cover-alt: "Ancient writing in a wall"
---

Do you use LOWER or UPPER to do case-sensitive searches? Let's see how to write a case-sensitive search in SQL Server.

**To write a case-sensitive search in SQL Server, don't use UPPER or LOWER functions around the column to filter. Instead, use the COLLATE keyword with a case-sensitive collation followed by the comparison.**

## Naive case sensitive search

Often by mistake, to do a case-sensitive search, we wrap a column around `LOWER()`. Something like this,

```sql
SELECT TOP 50 DisplayName, Location, CreationDate, Reputation
FROM dbo.Users
WHERE LOWER(DisplayName) LIKE 'john%'
ORDER BY Reputation DESC;
GO
```

We tried to find the first 50 StackOverflow users with DisplayName containing lowercase 'john'.

But, interestingly enough. Some results don't match our intended filter. They include both lowercase and uppercase 'john'.

{% include image.html name="LikeWithLower.png" alt="Result of finding users by wrapping a column with LOWER" caption="Naive case insensitive search using LOWER" width="600px" %}

Don't try to use `UPPER()` either. It would be the same. In general, [don't use functions around columns in your WHEREs]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}). That's a common bad practice.

<figure>
<img src="https://images.unsplash.com/photo-1597742200037-aa4d64d843be?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjI0ODU2MzAz&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="scrabble pieces" />

<figcaption>Photo by <a href="https://unsplash.com/@brett_jordan?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Brett Jordan</a> on <a href="https://unsplash.com/s/photos/abc?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Collation and case sensitivity

In SQL Server, collations provide sorting rules and case and accent sensitivity for our data. For example, when we use an ORDER BY, the sort order of our results depends on the database collation.

Find the database collation on the Database Properties option under the Maintenance menu.

Here's mine.

{% include image.html name="DatabaseProperties.png" alt="SQL Server database properties" caption="SQL Server database properties" width="600px" %}

**The default collation for English is SQL_Latin1_General_CP1_CI_AS. This is a case-insensitive collation.**

In collation names, CI means case insensitive. And, AS means accent sensitive.

That's why when we wrote `LOWER(DisplayName)`, SQL Server showed uppercase and lowercase results. SQL Server used the default collation, which was a case-insensitive one.

For more details about collations, check Microsoft docs on [collations and Unicode support](https://docs.microsoft.com/en-us/sql/relational-databases/collations/collation-and-unicode-support?view=sql-server-ver15).

## Case sensitive searches in WHERE clause

**For case-sensitive searches in SQL Server, use COLLATE keyword with the case sensitive collation "SQL_Latin1_General_CP1_CS_AS" followed by the LIKE or = comparisons as usual.**

When using the SQL_Latin1_General_CP1_CS_AS collation, a is different from A, and à is different from á. It's both case and accent-sensitive.

Let's rewrite our query with COLLATE,

```sql
SELECT TOP 50 DisplayName, Location, CreationDate, Reputation
FROM dbo.Users
WHERE DisplayName COLLATE SQL_Latin1_General_CP1_CS_AS LIKE '%john'
ORDER BY Reputation DESC;
GO
```

This time, we have the results we were expecting. Only users with lowercase 'john' in their display name.

{% include image.html name="CaseSensitive.png" alt="Query to find StackOverflow users with COLLATE" caption="Case sensitive query with COLLATE" width="600px" %}

Voilà! That's how we can write case-sensitive searches in SQL Server. Remember, don't use LOWER or UPPER. They won't work for case-sensitive searches. Use a different collation instead.

For more content on SQL Server, check [what are implicit conversions and why you should care]({% post_url 2022-02-07-WhatAreImplicitConversions %}) and [how to optimize Group by queries in SQL Server]({% post_url 2022-03-07-OptimizeGroupBySQLServer %}).

_Happy coding!_