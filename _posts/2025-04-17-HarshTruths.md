---
layout: post
title: "12 Hard Truths About Coding I Learned the Hard Way After 10 Years"
tags: career coding
---

I got fired from my first job, took down a database server with a badly written query, and was rejected from a FAANG. That all happened over the past 10 years.

But I've learned a lesson or two about coding along the way:

## 1. Estimates are just guesses.

The problem is when your guesses don't overlap with everybody else's guesses.

## 2. Showing progress is better than doing the work. 

Did you guess you can finish a task in 4 days? No, no, no. You're better off splitting it into smaller ones to show progress.

## 3. Proofs of concept are better than long documents nobody will read.

When was the last time you read more than 2 or 3 pages of documentation?

You're better off creating a quick and dirty Pull Request to show an idea or a prototype. "Working code over documentation."

## 4. The work isn't over when you finish coding.

After coding comes deployment, testing, user adoption, customer support, and follow-up.

## 5. The more senior you become, the less it's about coding and the more about meetings.

Did you join Software Engineering because you like coding? Forget about that.

You'll spend more time in meetings:
* 1-on-1s,
* Daily meetings,
* Retrospectives,
* Sprint planning,
* Alignment meetings,
* Brainstorming sessions,
* Poker estimation sessions,
* A few minutes with a guy from another team who needs to touch the code you wrote one year ago and you don't remember now.

And on and on...

In a perfect day, you'll have 1 or 2 hours of coding without distractions.

## 6. You learn to love tests when you work with a legacy app.

Call it unit, integration, end to end, TDD, BDD, or anything DD.

You're better off with anything that lets you know when you break something before shipping your code.

## 7. Don't start a big major refactoring if nobody asks you to.

This is what I call [Massive Unrequested Refactorings]({% post_url 2023-09-04-AgainstMassiveUnrequestedRefactorings %}).

Either you refactor as part of your tasks or make it official as part of your sprint planning. There's no point in between.

## 8. Don't waste time on pointless discussions about tools or tech.

—"Entity Framework is the best."
—"No, it's painfully slow."
—"Nooo, stored procedures are the best"

Arrggg!

Tools are just tools. That's why we, coders, have the reputation of being opinionated and grumpy. And please, let's not talk about clean code and best practices. That's [a subject I changed my mind about]({% post_url 2025-03-19-ChangedMyMind %}).

## 9. Always automate code style and best practices.

Don't ask a human to do the work of a machine. [Code style perfectly matches the type of work for machines]({% post_url 2025-03-10-AutomateCodeStyle %}).

## 10. Projects fail because of communication problems.

The same thing I've heard about marriages.

At a past job, I was engaged in 3- or 6-month projects. We used the shiniest and brightest tools and frameworks. But some projects ended up off the rails.

The only moving variable? Our communication patterns: Failing to communicate expectations, project goals and scope, action plans, and technical issues on time.

## 11. Every tech problem is a communication problem.

It's a corollary of #10.

At a past job, I was new to ASP.NET Core and when trying to test my code, I changed a connection string in a settings file and ended up deleting another environment database. Ooops!

I used the wrong settings file in the wrong environment. I didn't ask, nobody told me, and there wasn't any restrictions or guards in the code.

It was a communication problem.

## 12. Solve the problem you have today.

Premature optimization or just being lazy, don't solve and optimize for a problem you don't have yet. Avoid writing just-in-case code.

{% include 7day_email_course_longer.html %}
