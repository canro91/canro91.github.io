---
layout: post
title: "SQL Server Index recommendations: Just listen to them"
tags: todayilearned sql
cover: Cover.png
cover-alt: "Magazines and books in a library"
---

I guess you have seen SQL Server index recommendations on actual execution plans. But, you shouldn't take them too seriously. This is what I learned about SQL Server index recommendations.

**SQL Server builds index recommendations based on the WHERE and SELECT clauses of a query, without considering GROUP BY or ORDER BY clauses. Use index recommendations as an starting point to craft better indexes.**

## What's a nonclustered index anyways?

If you're wondering... **A nonclustered index is a redundant, sorted, and smaller copy of one table to make queries go faster.**

Imagine you want to find a particular book in a library. Would you go shelve by shelve, book by book until you find it? Or would you use the library catalog to go directly to the one you want? Well, these days, I guess libraries have software for that. But that's the same idea. That library catalog or reference software works like an index.

After that aside...

<figure>
<img src="https://images.unsplash.com/photo-1465929639680-64ee080eb3ed?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYyODI5MzQxOQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Rijksmuseum, Amsterdam, Netherlands" />

<figcaption>Rijksmuseum, Amsterdam, Netherlands. Photo by <a href="https://unsplash.com/@willvanw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Will van Wingerden</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

The next time you see an index recommendation on actual execution plans or from the Tuning Advisor, don't rush to create it. Just listen to them.

To prove why we shouldn't blindly create every index recommendation, let's use the StackOverflow database to write queries and indexes.

## Index recommendations and Scans

Let's start with no indexes and a simple query to find all users from Colombia. Let's check the actual execution plan.

```sql
SELECT Id, DisplayName, Reputation, Location
FROM dbo.Users
WHERE Location = 'Colombia'
```

This is the execution plan. Do you see any index recommendations? Nope.

{% include image.html name="UsersFromColombia-NoRecommendation.png" alt="Users from Colombia with no index recommendation" caption="Execution plan of finding all users from Colombia" width="800px" %}

**If SQL Server has to scan the object, the actual execution plan won't show any index recommendations.**

Now, let's change the query a bit. Let's find the first 1000 users from Colombia ordered by `Reputation` instead.

```sql
SELECT TOP 1000 Id, DisplayName, Reputation, Location
FROM dbo.Users
WHERE Location = 'Colombia'
ORDER BY Reputation DESC
```

Now, we have the missing index recommendation.

{% include image.html name="UsersFromColombia-Recommendation.png" alt="Users from Colombia with an index recommendation" caption="Ladies and gentlemen, now the index recommendation" %}

For that query, SQL Server suggests an index on `Location` including `DisplayName` and `Reputation`.

{% include image.html name="UsersFromColombia-RecommendedIndex.png" alt="Recommeded index for Users from Colombia" caption="The recommended index" width="800px" %}

**Indexes aren't sorted by included columns. Indexes might have some columns appended or "included" to avoid looking back to the table to access them.** 

## Index recommendations including all the columns

To point out the next reason not to blindly add recommended indexes, let's change our query to bring all columns instead of four of them.

Don't write SELECT * queries, by the way.

```sql
SELECT TOP 1000 *
FROM dbo.Users
WHERE Location = 'Colombia'
ORDER BY Reputation DESC
```

Let's see what the execution plan looks like.

{% include image.html name="UsersFromColombia-AllColumns.png" alt="Execution plan for a 'SELECT *'" caption="Execution plan for a 'SELECT *'" width="800px" %}

At first glance, the plan looks similar. But let's focus on what changed on the recommended index. Here it is.

{% include image.html name="RecommendedIndex-AllColumns.png" alt="Recommended index with all columns in the Users table" caption="Recommended index with all columns in the Users table" width="800px" %}

SQL Server recommended an index with all the columns in the table. Even NVARCHAR(MAX) columns. Arrrggg!

**Often, SQL Server recommends adding all the columns from the table into the INCLUDE part of indexes.**

Indexes aren't free. They take disk space. Even included columns take disk space. The more keys and included columns, the bigger the indexes get and the longer SQL Server will hold locks to insert, update, and delete data.

## Index Recommendations and ORDER BY's

The next thing to know about index recommendations has to do with the keys in the index.

**SQL Server index recommendations are based on the WHERE and SELECT clauses. SQL Server doesn't use GROUP BY or ORDER BY clauses to build index recommendations.**

For our last query, let's add the recommended index and another one with the ORDER BY in mind. These are the two new indexes,

```sql
/* This one has Reputation, which is on the ORDER BY */
CREATE INDEX Location_Reputation ON dbo.Users(Location, Reputation);

/* This is the recommended one */
CREATE INDEX Location ON dbo.Users(Location);
GO
```

After creating these indexes, let's run our query again,

```sql
SELECT TOP 1000 Id, DisplayName, Reputation, Location
FROM dbo.Users
WHERE Location = 'Colombia'
ORDER BY Reputation DESC
GO
```

This time, the execution plan looks like this,

{% include image.html name="RecommendedVsCustom.png" alt="Recommended index with all columns in the Users table" caption="Recommended index with all columns in the Users table" width="800px" %}

SQL Server recommended one index but used another. Even when the recommended index was in place.

SQL Server only looks at WHERE and SELECT part of queries to build recommendations. We can create better indexes than the recommended ones for queries with ORDER BY and GROUP BY clauses.

## Recommended indexes and key order

Next, let's dig into the order of keys in recommended indexes.

**Keys on the recommended indexes are based on equality and inequality comparisons on the WHERE. Columns with equality comparisons are shown first, followed by columns with inequality comparisons**.

Let's add another comparison to our sample query. This time, let's look for users from Colombia with more than 10 reputation points.

```sql
SELECT TOP 1000 Id, DisplayName, Reputation, Location
FROM dbo.Users
WHERE Reputation > 10
AND Location = 'Colombia'
ORDER BY Reputation DESC
```

Let's check the recommended index on the execution plan.

{% include image.html name="EqualityAndInequality.png" alt="Recommended index with all columns in the Users table" caption="Recommended index on Location followed by Reputation" width="800px" %}

The recommended index contains the `Location` column first, then the `Reputation` column. But, in the query, the filter on `Reputation` was first. What happened here?

**SQL Server builds recommended indexes on equality comparisons followed by inequality comparisons.** That's why an apparent mismatch in the order of keys on the index and filters on the query.

## Don't blindly create recommended indexes

Last thing about recommended indexes.

**Index recommendations don't take into account existing indexes.**

Check your existing indexes. See if you can combine the recommended indexes with your existing ones. If your existing indexes overlap with the recommended ones, drop the old ones. 

Build as few indexes as possible to support your queries. Keep around 5 indexes per table with around 5 columns per index.

## Parting words

Voilà! These are some of the things I learned about SQL Server index recommendations. Remember, indexes aren't free. The more indexes you add, the slower your queries will get. 

Next time you see index recommendations on your execution plans, check if you already have a similar index and modify it. If you don't, please remember to at least change its name. And not to include all the columns of your table.

I learned these things following [Brent Ozar's Master Index Tuning]({% post_url 2022-05-02-BrentOzarMasteringCoursesReview %}) class. Great class!

For more content on SQL Server, check [how to do case sensitive searches]({% post_url 2022-02-21-CaseSensitiveSearchSQLServer %}), [how to optimize GROUP BY queries]({% post_url 2022-03-07-OptimizeGroupBySQLServer %}) and [what implicit conversions are]({% post_url 2022-02-07-WhatAreImplicitConversions %}).