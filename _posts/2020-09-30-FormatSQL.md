---
layout: post
title: Two free tools to format SQL queries
tags: sql productivity showdev
description: The lazy way to format your SQL queries. Learn how to format your SQL queries with two free tools
---

Do you need to format your SQL queries? Are you doing it by hand? Stop! There is a better way!

Instead of formatting SQL queries to follow code conventions by hand, we can use online tools or extensions inside Visual Studio, SQL Server Management Studio, or any other text editor.

These are two free tools to format SQL queries and store procedures. Inside Notepad++, use **Poor Man's T-SQL Formatter**. And, **ApexSQL Refactor** for Visual Studio and SQL Server Management Studio.

## Before

Before using Poor Man's T-SQL Formatter and ApexSQL Refactor, I spent too much time formatting queries by hand. I mean making keywords uppercase, aligning columns, and arranging spaces.

I tried to use the "Find and Replace" option inside a text editor. But it only worked for making keywords uppercase. Sometimes, I ended up messing with variables, parameters, and other things inside my queries. 

<figure>
<img src="https://images.unsplash.com/photo-1507925921958-8a62f3d1a50d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixlib=rb-4.0.3&q=80&w=600&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA" alt="Macro typewriter ribbon" />

<figcaption><span>Photo by <a href="https://unsplash.com/@kellysikkema?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Kelly Sikkema</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

Things were worse with long store procedures. I changed two lines and ended up formatting thousand of lines. _"Once you touch it, you're the owner."_

## Let's format a sample query from StackOverflow

Let's format the query to [find StackOverflow posts with many "thank you" answers](https://data.stackexchange.com/stackoverflow/query/886/posts-with-many-thank-you-answers).

```sql
select
   ParentId as [Post Link],
   count(id)
from posts
where posttypeid = 2 and len(body) <= 200
  and (body like '%hank%')
group by parentid
having count(id) > 1
order by count(id) desc;
```

After formatting the query to follow [Simon Holywell SQL Style Guide](https://www.sqlstyle.guide/), it should look like this,

```sql
SELECT ParentId AS [Post Link]
     , COUNT(id)
  FROM posts
 WHERE posttypeid = 2
   AND LEN(body) <= 200
   AND (body LIKE '%hank%')
 GROUP BY parentid
HAVING COUNT(id) > 1
 ORDER BY COUNT(id) DESC;
```

Let's see how these two tools format our sample query.

### 1. Poor Man's T-SQL Formatter

[Poor Man's T-SQL Formatter](https://github.com/TaoK/PoorMansTSqlFormatter) is a free and open-source .NET and JavaScript library to format your SQL queries. It's available for Notepad++, Visual Studio, SQL Server Management Studio, and others. We can [try it online](http://poorsql.com/) too.

This is how Poor Man's T-SQL formatted our sample query in Notepad++.

{% include image.html name="PoorManTSQL.PNG" caption="Sample query formatted by Poor Man's T-SQL inside Notepad++" alt="Sample query formatted by Poor Man's T-SQL inside Notepad++" width="700px" %}

It doesn't make function names uppercase. Notice the functions `len` and `count`.

Also, it indents `AND` clauses in the `WHERE` clause. I want them right-aligned to the previous `WHERE`. But it's a good starting point.

Sometimes, it needs a bit of help if the query has single-line comments in it with `--`.

By the way, it's better to use `/* */` for single-line comments inside our queries and store procedures. This makes formatting easier when we copy queries or statements from our database's plan cache.

### 2. ApexSQL Refactor

[ApexSQL Refactor](https://www.apexsql.com/sql-tools-refactor.aspx) is a ~~free~~ query formatter for Visual Studio and SQL Server Management Studio. It has over 160 formatting options. We can create our own formatting profiles and preview them. It comes with four built-in profiles. ~~Also, we can try it online~~.

_**UPDATE (Sept 2023)**: ApexSQL Refactor isn't freely available online anymore._

This is how ApexSQL Refactor formatted our sample query in Visual Studio 2019.

{% include image.html name="ApexSQL.PNG" caption="Sample query formatted by ApexSQL Refactor inside Visual Studio" alt="Sample query formatted by ApexSQL Refactor inside Visual Studio" width="600px" %}

It isn't perfect, either. But, it makes functions uppercase. Point for ApexSQL Refactor.

Also, it indents `AND` clauses in the `WHERE` too. I couldn't find an option to change it. But, there is an option to indent `ON` in `SELECT` statements with `JOIN`. It affects `ON` for index creation too. We can live with that.

Voilà! Please let's save some time formatting our SQL queries with any of these two free tools.

We can take a step further and call a formatter inside a Git hook to [automatically format SQL files]({% post_url 2023-09-18-FormatSqlFilesOnCommit %}). I did it with Poor Man's T-SQL formatter.

For more content, check [my Visual Studio setup for C#]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}) and [six tips to performance tune our SQL Server]({% post_url 2020-09-28-SQLServerTuningTips %}).

_Happy SQL time!_