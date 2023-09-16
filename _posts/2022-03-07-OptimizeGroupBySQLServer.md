---
layout: post
title: "TIL: How to optimize Group by queries in SQL Server"
tags: todayilearned sql
cover: Cover.png
cover-alt: "Chess pieces in a board"
---

Let me share this technique I learned to improve queries with GROUP BY in SQL Server.

**To improve queries with GROUP BY, write the SELECT query with the GROUP BY part using only the needed columns to do the grouping or sorting inside a common table expression (CTE) first. Then, join the CTE with the right tables to find other columns.**

## Usual GROUP BY: Find StackOverflow most down-voted questions

Let's use this technique to tune the store procedure to find [most down-voted questions on StackOverflow](http://data.stackexchange.com/stackoverflow/query/36660/most-down-voted-questions).

Here's the store procedure. Let's fire our local copy of the [StackOverflow 2013 database](https://www.brentozar.com/archive/2021/03/download-the-current-stack-overflow-database-for-free-2021-02/) to run it.

```sql
CREATE OR ALTER PROC dbo.MostDownVotedQuestions AS
BEGIN
    select top 20 count(v.PostId) as 'Vote count', v.PostId AS [Post Link],p.Body
    from Votes v 
    inner join Posts p on p.Id=v.PostId
    where PostTypeId = 1 and v.VoteTypeId=3
    group by v.PostId, p.Body
    order by 'Vote count' desc
END
GO
```

I ran this stored procedure on my local machine  five times without any indexes. It took about 2 seconds each time. On my machine, SQL Server only had 8GB of RAM. Remember, by default [SQL Server uses all available RAM]({% post_url 2020-11-13-SQLServerMemory %}).

This is the execution plan. Let's notice the Clustered Index Seek on the `dbo.Posts` table. And, yes, SQL Server is recommending an index. But we're not adding it.

{% include image.html name="ExecutionPlan-Before.png" alt="StackOverflow most down-votes questions" caption="StackOverflow most down-votes questions" %}

Then, these are the metrics grabbed with [sp_BlitzCache](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit#sp_blitzcache-find-the-most-resource-intensive-queries) from the First Responder Kit. This stored procedure finds all the most CPU intensive queries SQL Server has recently executed.

{% include image.html name="spBlitzCacheBefore.png" alt="Most CPU intensive queries" caption="Most CPU intensive queries" %}

To find the most down-voted questions, our stored procedure is grouping by `Body`. And, that's an `NVARCHAR(MAX)` column, the actual content of StackOverflow posts.

Sorting and grouping on large data types is a CPU expensive operation.

<figure>
<img src="https://images.unsplash.com/photo-1509358271058-acd22cc93898?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYyNjk4NzY5MA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Spoons full of Indian spices" />

<figcaption>Photo by <a href="https://unsplash.com/@pratiksha_mohanty?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Pratiksha Mohanty</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Group and order inside CTE's first

**To improve queries with GROUP BY, group inside a common table expression (CTE) with only the required columns in the grouping. For example, IDs or columns covered by indexes. Then, join the CTE with the right tables to find other columns.**

After grouping only by `PostId` inside a CTE first, our stored procedure looks like this,

```sql
CREATE OR ALTER PROC dbo.MostDownVotedQuestions AS
BEGIN
    WITH MostDownVoted AS (
        select top 20 count(v.PostId) as VoteCount, v.PostId /* We removed the Body column */
        from Votes v 
        inner join Posts p on p.Id=v.PostId
        where PostTypeId = 1 and v.VoteTypeId=3
        group by v.PostId /* Also, from here */
        order by VoteCount desc
    )
    select VoteCount as 'Vote count', d.PostId AS [Post Link], p.Body
    from MostDownVoted d
    inner join Posts p on p.Id = d.PostId
END
GO
```

This time, we are excluding the `Body` column from the GROUP BY part. Then, we are joining the `MostDownVotes` CTE to the `dbo.Post` table to show only the `Body` of the 20 resulting posts.

Again, this is the execution plan of grouping inside a CTE first.

{% include image.html name="ExecutionPlanAfter.png" alt="StackOverflow most down-votes questions" caption="StackOverflow most down-votes questions grouping inside a CTE" %}

Notice the Clustered Index Seek operator on the left branch. That's to find the body of only the 20 post SQL Server found as a result of grouping inside the CTE. This time, SQL Server is grouping and sorting fewer data. It made our stored procedure use less CPU time.

Let's take another look at sp_BlitzCache. Before running the modified version of our store procedure five times, I ran `DBCC FREEPROCCACHE` to free up SQL Server's plan cache.

{% include image.html name="spBlitzCacheAfter.png" alt="Most CPU intensive queries" caption="Most CPU intensive queries with our modified stored proc" %}

Notice the "Total CPU" and "Avg CPU" columns, we're using less CPU time after the change. I went from 36.151ms of total CPU time to 35.505ms. Hooray!

Now, imagine if that store procedure runs not only 5 times, but multiple times per minute. What if our stored procedure feeds a reporting screen in our app? That change with a CTE will make a huge difference in the overral CPU usage.

Voilà! That's how we can improve queries with GROUP BY. Remember, group and sort inside CTE's to take advantage of existing indexes and avoid expensive sorting operations. Use this technique with OFFSET/FETCH, SUM, AVG, and other group functions.

I learned this technique following [Brent Ozar's Mastering Query Tuning]({% post_url 2022-05-02-BrentOzarMasteringCoursesReview %}) class.

For more SQL Server content, check [don't write functions around columns in WHERE]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}), [what are implicit conversions?]({% post_url 2022-02-07-WhatAreImplicitConversions %}), and [How to do a case-sensitive search in SQL Server]({% post_url 2022-02-21-CaseSensitiveSearchSQLServer %}).

_Happy coding!_