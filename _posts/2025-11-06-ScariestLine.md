---
layout: post
title: "The Scariest Lines of Code I've Ever Written"
tags: sql
---

I don't remember if it was rainy or sunny outside. It was more than five years ago. I was still becoming a senior coder.

I've written hundreds of thousands of lines of code. But I still remember this one. As part of my routine, I wrote this query in a stored procedure,

```sql
SELECT * FROM dbo.HugeTableWithoutIndexes
WHERE DATEDIFF(DAY, ADateColumn, @InputDate) = 0
```

I was working with an email system built with Amazon SES. I needed to show all email activity: delivered, opened, bounced, and so on. [I wrapped a column in a function]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}). A deadly sin!

The table had millions of records and no indexes. My query forced a full scan of the table. The next thing I knew the server was on fire. Not literally, of course.

Those days I refused to learn SQL, convinced ORMs and NoSQL were enough. I couldn’t have been more wrong. Relational databases and SQL still reign.

Eventually I learned about [indexing]({% post_url 2022-03-21-SQLServerIndexRecommendations %}), scans vs seeks, and SQL Server internals. Shout out to [Brent Ozar's courses]({% post_url 2022-05-02-BrentOzarMasteringCoursesReview %}).

A painful lesson I will never forget. That's why learning SQL found its way into my new book, _Street-Smart Coding._ It isn't a textbook. It's a roadmap with 30 proven lessons to help you code like a pro. It's the guide I wish I had starting out.

Want to avoid painful mistakes like mine? _[Grab your copy of Street-Smart Coding here](https://imcsarag.gumroad.com/l/streetsmartcoding?utm_source=blog&utm_medium=post&utm_campaign=scariest-lines-of-code-ive-ever-written)_
