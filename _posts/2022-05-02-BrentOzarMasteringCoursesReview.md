---
layout: post
title: "Brent Ozar Mastering courses. My Review"
tags: showdev sql
cover: Cover.png
cover-alt: "CV, Resume and computer" 
---

This is an honest review of Brent Ozar Mastering courses. I finished all of them some months ago.

I couldn't write this a couple of years ago. Working with databases was a subject I avoided at all costs. Even to the point where I traded database-related tasks with an ex-coworker at a past job.

Avoiding database concepts cost me painful lessons. Like the day I wrote a query with [a function around a column in the WHERE](% post_url 2022-01-24-DontPutFunctionsInYourWheres %) and it almost took the server to its knees. That query was poorly written, and the table didn't have good indexes. It ended up scanning the whole table. Arrgggg!

But, it changed a couple of years later while working with one of my clients. They asked me to investigate the performance of some critical parts of the app. And, I ended up Googling what to do to speed up SQL Server queries and compiling [six SQL Server performance tuning tips]({% post_url 2020-09-28-SQLServerTuningTips %}) I found.

<figure>
<img src="https://images.unsplash.com/photo-1509541206217-cde45c41aa6d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY0Nzg4MDExOQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Airplane cockpit" />

<figcaption>Don't press random buttons to make SQL Server faster. Photo by <a href="https://unsplash.com/@franzharvin?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Franz Harvin Aceituna</a> on <a href="https://unsplash.com/s/photos/air-plane-cockpit?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

In that search for performance tuning advice, I found [Brent Ozar and his mastering courses](https://www.brentozar.com/). These are the three things I liked after taking them.

## 1. Realistic Labs and Workloads

As part of Brent's courses, we work with a copy of the StackOverflow database. Yeap, the same StackOverflow we all know and use. 

After every subject in each course, we have labs to finish. Labs with bad queries, no indexes, blocking issues, etc. For the last course, Mastering Server Tuning, we have an emergency to fix. A server is on fire, and we have to put down the fire and lay out a long-term fix.

Often, some labs have easier alternatives. Either focus on a particular issue or run a workload and assess the whole situation.

## 2. Constraints to Solve Labs

As we progress throughout the courses, we start to have constraints to solve the labs. For example, "no index changes allowed" or "only query-level fixes."

But, the exercise I like the most is the "Let's play being performance consultant." We have to fix a workload under 30 minutes with as few changes as possible. The closest thing to a real-world situation. That's from Mastering Server Tuning again. I would say that was my favorite course.

Of course, there are more courses. They're four in total. There's one course solely on indexes, another one about query tuning, one to fix parameter sniffing issues, and, my favorite, the one on server-level fixes. Each course sits on top of the previous ones.

## 3. Popular wisdom and guerilla tactics

All over the courses, Brent shares his experience as a consultant. I have these pieces of advice on my notes like "when working with clients."

For example, he shares to build as few indexes as possible and provide rollback scripts for index creation, just in case. Also, to provide a prioritize list of actionable steps to make SQL Server fast.

Also, he shares personal anecdotes. Like the day he went to consult wearing jeans, and everybody at the place was wearing jackets and ties. That story didn't have a happy ending for the company. But, I won't tell you more.

Voilà! These are the three things I liked. My biggest lessons are to focus all tuning efforts on the top-most wait type and make as few changes as possible to take you across the finish line. Often, we start to push buttons and knobs expecting SQL Server to run faster without noticeable improvements. Making more harm than good.

I will take the second lesson to other parts of my work, even outside of performance tuning context. Focus on the few changes that make the biggest impact.

For more SQL and performance tuning content, check [don't use functions around columns in your WHEREs]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}), [what implicit conversions are and why you should care]({% post_url 2022-02-07-WhatAreImplicitConversions %}) and [just listen to index recommendations]({% post_url 2022-03-21-SQLServerIndexRecommendations %}). I wrote some of these posts to share my learnings after taking all Brent's courses.

_Happy coding!_