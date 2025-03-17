---
layout: post
title: "A Day in the Life of a Random C# Backend Engineer"
tags: career
---

What exactly does a C# backend software engineer do?

These days, I found this question on [Reddit](https://www.reddit.com/r/csharp/comments/1j4u01j/what_kind_of_tasks_do_you_usually_work_on/?rdt=40341) about the type of tasks we C# developers do:

> _"Do you find them exciting or just routine? Do they help you grow as a developer? Or is it mostly about finishing tasks quickly, making small adjustments, and moving on? Curious to hear your thoughts!"_

## It's 8:45. Time for the daily meeting.

You join the meeting. _"Good morning."_

Then you look through the window, scroll on Hacker News, and check your phone while you wait for your name.

_"Yesterday, I worked on the task to yada, yada. No blockers."_ Yes, another meeting that could be an update on Teams or Slack or an email.

## It's 9:15. Time for a coffee.

You pick your next ticket.

Another pair of REST endpoints to power a screen on the web application. You come up with request and response objects. And you contact the front-end developer to share those two objects, so nobody is blocked while the endpoints are ready.

You come up with validations, entities, and [value objects]({% post_url 2022-12-21-WhenToChooseValueObjects %}) to populate your core domain. Yes, [you're kind of doing DDD]({% post_url 2025-03-16-DDDIsNotAboutEntities %}). [Write some tests]({% post_url 2021-03-15-UnitTesting101 %}). Fire up your Postman and see if everything works.

That was the writing part.

Now, the reading part. The web application uses a grid with dynamic filters and ordering. It seems like a task for [dynamic SQL]({% post_url 2021-03-08-HowNotToWriteDynamicSQL %}). But you're too lazy to write SQL queries by hand. It's 2025 and the world has ORMs. Life is too short to write SQL queries by hand.

You need to pass a list of IDs to a query. You could use a string and send the IDs separated by commas. Passing a table type is the solution. But...Surprise, surprise, your ORM doesn't seem to support tables as parameters.

## Noon. It's lunchtime.

You step away from the screen to grab some food and give your brain a rest. At least, that's the plan. But you can't stop thinking about your task. _"Why it isn't working? What am I missing?"_

When you're back from lunch, you pull down the source code of your ORM and go down a rabbit hole. There's no way you're writing SQL queries by hand. Not today. _"Here it builds the SQL query from the mapping object..."_ Great. Progress. But still nothing. You keep going down the rabbit hole, determined to find the answer.

One method leads to another. One break point here and there. Until finally, you find it. _"Here it is. This ORM uses a converter to populate the underlying DbCommand object. I could use that."_ The solution is kind of hacky, but it works.

You write a converter and a simple test to prove you're right. Then you port that converter to your Database project and add some docstring comments to document your hacky solution.

## It's almost 5:00 PM.

You're tired from that [debugging session]({% post_url 2020-09-19-ThreeDebuggingTips %}).

But it was rewarding. You proved that sometimes being lazy means being efficient. By the end of your debugging session, you know a bit more about the internals of your obscure ORM. You have a trick you'll use in future tasks. And you have an idea for [a good blog post]({% post_url 2025-03-11-BloggingTips %}). 

It's time to create a pull request.

You slap a title, a description, and some good comments here and there to explain what you found. You change your ticket status on JIRA and ping the default reviewer for this project.

Time to unplug from work.

## It's 8:45 the next day. Another daily meeting.

This time, you don't scroll Hacker News, but go directly to your PR.

As usual, one reviewer is suggesting renaming a variable. And you forgot to cover one or two lines. Yes, the official guideline is 100% coverage. Arrggg!

Some of your coworkers find out the trick with the converter. For the first time in a while, you get a compliment in one of your PRs. Yay!

That's just one ticket. There are more. Hopefully QA doesn't find any issues in the search logic. Fingers crossed, all the issues are "move this label," "this textbox isn't green enough... ." Nothing you have to care about being a backend developer. Your UI is Postman, and everything is working fine from there.

Everything because you didn't want to write SQL queries by hand. Lazy? Maybe. Clever? Absolutely.

That's why you chose backend development: the satisfaction of solving tricky problems. And that's just another day in the life of a random backend engineer. Based on true events, because backend development could be boring, and yes, sometimes, a little wild.
