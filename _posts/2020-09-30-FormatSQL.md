---
layout: post
title: Two free tools to format SQL queries
tags: sql productivity
description: The lazy way to format your SQL queries. Learn how to format your SQL queries with two free tools
---

Do you need to format your SQL queries? Are you doing it by hand? Stop! There is a better way!

I spent too much time formatting queries by hand. It means making keywords uppercase, aligning columns and arranging spaces.

I tried to use "Find and Replace" inside an editor. But, it only worked for making keywords uppercase. Sometimes I ended up messing with variables, parameters or any other thing. 

<figure>
<img src="https://source.unsplash.com/-1_RZL8BGBM/800x400" alt="Macro typewriter ribbon" />

<figcaption><span>Photo by <a href="https://unsplash.com/@kellysikkema?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Kelly Sikkema</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

Things were worse with long store procedures. I changed two lines and I ended up formatting thousand of lines. _"Once you touch it, you're the owner"_.

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

After formatting the query to follow [Simon Holywell SQL Style Guide](https://www.sqlstyle.guide/), it should like this

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

These are two free tools you can use to format your SQL queries and store procedures. Inside Notepad++, you can use **Poor Man's T-SQL Formatter**. And, **ApexSQL Refactor** for Visual Studio and SQL Server Management Studio (SSMS).

## Poor Man's T-SQL Formatter

[Poor Man's T-SQL Formatter](https://github.com/TaoK/PoorMansTSqlFormatter) is a free and open source .NET and JavaScript library to format your SQL queries. It's available for Notepad++, Visual Studio, SQL Server Management Studio and others. You can try its formatting options [online](http://poorsql.com/) too.

This is how Poor Man's T-SQL format our sample query.

{% include image.html name="PoorManTSQL.PNG" caption="Sample query formatted by Poor Man's T-SQL inside Notepad++" alt="Sample query formatted by Poor Man's T-SQL inside Notepad++" width="700px" %}

It doesn't make function names uppercase. It indents `AND`'s clauses. But, it's a good starting point. Sometimes, it need a bit of help if the query has single-line comments in it.

## ApexSQL Refactor

[ApexSQL Refactor](https://www.apexsql.com/sql-tools-refactor.aspx) is a free query formatter for Visual Studio and SQL Server Management Studio. It has over 160 formatting options. You can create your own formattig profiles and preview them. It comes with four built-in profiles. Also, you can try it [online](https://sql-formatter.online/options/formatting).

This is how ApexSQL Refactor format our sample query.

{% include image.html name="ApexSQL.PNG" caption="Sample query formatted by ApexSQL Refactor inside Visual Studio" alt="Sample query formatted by ApexSQL Refactor inside Visual Studio" width="600px" %}

It isn't perfect either. It indents `AND` clauses too. I couldn't find an option to change it. But, there is an option to indent `ON` in `SELECT`, but it affects `ON` for index creation too.

Voilà! Please, save you some time formatting your SQL queries with any of these two free tools. For other alternatives, check [this SQLShack collection of formatter tools](https://www.sqlshack.com/sql-formatter-tools/).

You can find more extensions for Visual Studio in [my Visual Studio setup]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}). Also, for tips to tune your SQL Server, read my post on [six tips to performance tune your SQL Server]({% post_url 2020-09-28-SQLServerTuningTips %}).

_Happy SQL time!_