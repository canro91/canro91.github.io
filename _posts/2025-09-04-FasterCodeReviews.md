---
layout: post
title: "Two Proven Strategies For Faster Code Reviews (Learned From Dozens of Pull Requests)"
tags: codereview
---

Two days into my last full-time job, I thought I had finished my first task. I was wrong.

At my previous job, I was used to going fast and breaking things. But that wasn't the case anymore. After telling my team leader I was done, they ripped my code apart. I had to rewrite it almost entirely. No stored procedures. New naming conventions. [Unit tests]({% post_url 2021-03-15-UnitTesting101 %}). That was my welcoming code review session.

A couple of years after my first code review, I learned the unwritten rules and became one of the company's "default" code reviewers. Yes, it took quite some time.

As [a default reviewer]({% post_url 2022-12-19-LessonsAsReviewer %}), I had the chance to review code from people outside my team. And after dozens of review sessions, I started to notice some patterns that made me change my reviewing strategy.

### 1. Follow Pull-Request Driven Development

Occasionally, someone opened a pull request (PR) with thousands of lines.

After noticing that, I adopted **Pull-Request Driven Development** (PRDD). Before starting a task, think of how to split and organize your changes so they're easy to review.

Instead of a monstrous PR, split your changes into small, working PRs anyone can review in under five minutes.

And if a task spans multiple projects, label and cross-reference each change for easier navigation. If you're adding a new field to a form, create three separate PRs:
1. PR 1/3 adds the new field
2. PR 2/3 updates the REST API
3. PR 3/3 changes the database schema. 

You can even use "PR #/3" as a title to make things easier for your reviewers.

### 2. Give clear and actionable feedback

There was another pattern I noticed as a code reviewer: sometimes it took about 24 hours to get a pull request approved and merged.

Some reviewers used ["pushy" questions]({% post_url 2022-12-05-LeadingQuestionsOnCodeReviews %}) that only hinted at a request for a change. Questions like _"What if this parameter is null?"_ weren't clear enough. Was the reviewer asking for a change or simply starting a discussion? And since most of us were in different time zones, any interaction took about half or even an entire day.

Those long code review sessions made me adopt three guidelines:
1. Write clear and unambiguous comments.
2. Always leave a suggestion with each comment.
3. Distinguish between actionable items and suggestions.

That strategy turned a comment like _"What if this parameter is null?"_ into _"Is it possible that this parameter could be null? If that's the case, please add the appropriate null checks."_

I kept using that strategy inside my team, after my reviewer rotation ended. And I noticed how other reviewers picked it up as well. Point for preaching by example!

## Parting thought

Code reviews feel like a pain in the neck. I know!

But until we put our code in front of others, we might think we're writing the best code we've ever written, just like me before joining my last full-time job.

Code reviews reveal how grumpy and opinionated we as coders can be when talking about code, arguing about variable names, code style, and best practices. Yes, often the stereotype is true.

Sometimes you might want to remote choke your reviewers with the Force. But code reviews don't just improve your code, they teach you to grow a thick skin and soften your ego.

