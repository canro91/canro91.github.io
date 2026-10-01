---
layout: post
title: "The Scariest Lines of Code I've Ever Written"
tags: sql
---

I don't remember if it was rainy or sunny outside. It was more than five years ago. I was still becoming a senior coder.

I've written hundreds of thousands of lines of code that I don't remember anymore. But I still remember these ones.

As part of my daily tasks, I wrote this query in a stored procedure,

```sql
SELECT * FROM dbo.HugeTableWithoutIndexes
WHERE DATEDIFF(DAY, ADateColumn, @InputDate) = 0
```

I was working with an email system built with Amazon SES. I needed to show all email activity: delivered, opened, bounced, and so on. [I wrapped a column in a function]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}). A deadly sin!

The table had millions of records and no indexes. My query forced a full scan of the table. The next thing I knew the server was on fire. Not literally, of course. LOL!

Those days I refused to learn SQL, convinced ORMs and NoSQL were enough. I couldn’t have been more wrong. Relational databases and SQL still reign.

Eventually I learned about [indexing]({% post_url 2022-03-21-SQLServerIndexRecommendations %}), scans vs seeks, and SQL Server internals. Shout out to [Brent Ozar's courses]({% post_url 2022-05-02-BrentOzarMasteringCoursesReview %}).

A painful lesson I will never forget. Take your vitamins, exercise, and use indexes.

_You can't escape from SQL. That's why I made it one of the lessons in **[Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding?utm_source=blog&utm_medium=post&utm_campaign=scariest-lines-of-code-ive-ever-written)**. It's the guide I wish I'd had on my journey to becoming a senior coder._
