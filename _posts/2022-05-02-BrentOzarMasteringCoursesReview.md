---
layout: post
title: "Brent Ozar’s Mastering Courses: My Honest Review"
tags: showdev sql
cover: Cover.png
cover-alt: "CV, Resume and computer" 
---

This is an honest review of Brent Ozar's Mastering courses after finishing them all some months ago.

I couldn't write this a couple of years ago. Working with databases was a subject I avoided at all costs. Even to the point where I traded database-related tasks with an ex-coworker at a past job.

Avoiding database concepts cost me painful lessons.

Like the day I wrote a query with [a function around a column in the WHERE]({% post_url 2022-01-24-DontPutFunctionsInYourWheres %}) and it almost took the server to its knees. That query was poorly written, and the table didn't have good indexes. My query ended up making SQL Server scan the whole table. Arrgggg!

But, it changed a couple of years later while working with one of my clients.

They asked me to investigate the performance of some critical parts of the app. The bottleneck was in the database and I ended up Googling what to do to speed up SQL Server queries and compiling [six SQL Server performance tuning tips]({% post_url 2020-09-28-SQLServerTuningTips %}) I found.

<figure>
<img src="https://images.unsplash.com/photo-1509541206217-cde45c41aa6d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY0Nzg4MDExOQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Airplane cockpit" />

<figcaption>Don't press random buttons to make SQL Server faster. Photo by <a href="https://unsplash.com/@franzharvin?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Franz Harvin Aceituna</a> on <a href="https://unsplash.com/s/photos/air-plane-cockpit?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

In that search for performance tuning advice, I found <a href="https://training.brentozar.com/?affcode=920087_fhe3khrq" target="_blank" rel="noopener noreferrer">Brent Ozar and his Mastering courses</a>. These are the three things I liked after taking them.

## 1. Realistic Labs and Workloads

As part of Brent's courses, we work with a copy of the StackOverflow database. Yeap, the same StackOverflow we all know and use. 

After every subject in each course, we have labs to finish. Labs with bad queries, no indexes, blocking issues, etc. For the last course, Mastering Server Tuning, we have an emergency to fix. A server is on fire, and we have to put down the fire and lay out a long-term fix.

Often, some labs have easier alternatives. Either focus on a particular issue or run a workload and assess the whole situation.

## 2. Constraints to Solve Labs

As we progress throughout the courses, we start to have constraints to solve the labs. For example, "no index changes allowed" or "only query-level fixes."

But, the exercise I like the most is the "Let's play being performance consultant." We have to fix a workload under 30 minutes with as few changes as possible. The closest thing to a real-world emergency. That's from Mastering Server Tuning again. My favorite course.

Of course, there are more courses. They're four in total. There's one course solely on indexes, another one about query tuning, one to fix parameter sniffing issues, and, my favorite, the one on server-level fixes. Each course sits on top of the previous ones.

## 3. Popular Wisdom and Guerilla Tactics

All over the courses, Brent shares his experience as a consultant. I have those tips and pieces of advice on my notes like _"when working with clients."_

For example, he shares to build as few indexes as possible and provide rollback scripts for index creation, just in case. Also, to provide a prioritized list of actionable steps to make SQL Server fast.

Also, he shares personal anecdotes. Like the day he went to consult wearing jeans, and everybody at the place was wearing jackets and ties. That story didn't have a happy ending for the company. But, I won't tell you more so you can find out what happened by taking the courses.

## Parting Thought

Voilà! These are the three things I liked. My biggest lessons are:

1. Focus all tuning efforts on the top-most wait type, and,
2. Make as few changes as possible to take you across the finish line.

Often, we start to push buttons and turn knobs expecting SQL Server to run faster, without noticeable improvements and making more harm than good.

I will take the second lesson to other parts of my work, even outside of performance tuning context. Focus on the few changes that make the biggest impact.

_To learn how to make your SQL Server go faster with Brent—and support this blog—buy <a href="https://training.brentozar.com/p/recorded-class-season-pass-fundamentals?affcode=920087_fhe3khrq" target="_blank" rel="noopener noreferrer">the Fundamentals Bundle here</a> and the <a href="https://training.brentozar.com/p/fundamentals-and-mastering-bundle?affcode=920087_fhe3khrq" target="_blank" rel="noopener noreferrer">Fundamentals + Mastering Bundle here</a>. I can't recommend Brent's courses enough. Learn from a real expert, with real queries._