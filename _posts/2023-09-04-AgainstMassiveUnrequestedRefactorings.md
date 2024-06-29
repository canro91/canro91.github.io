---
layout: post
title: "A business case against massive unrequested refactorings"
tags: career
cover: Cover.png
cover-alt: "Stairs, paintings, and brushes" 
---

Blindly following coding principles is a bad idea.

"Leave the basecamp cleaner," "Make the change easy then make the easy change"...

Often, we follow those two principles and start huge refactoring sessions with good intentions but without considering the potential consequences.

Let me share two stories of refactoring sessions that led to unintended consequences and the lesson behind them.

## Changing Entities and Value Objects

At a past job, a team member decided to refactor the entire solution before working on his task.

He changed every Domain Entity, [Value Object]({% post_url 2022-12-21-WhenToChooseValueObjects %}), and database table. What he found wasn't "scalable" in his experience.

The project was still in its early stage and the rest of the team was waiting for his task.

One week later, we were still discussing about names, [folder structure]({% post_url 2022-12-15-CreateProjectStructureWithDotNetCli %}), and the need for that refactoring in the first place.

We all were blocked waiting for him to finish the mess he had created.

## Changing Class and Table Names

At another job, our team's architect decided to work over the weekend.

And the next thing we knew next Monday morning was that almost all class and table names had been changed. The architect decided to rename everything. He simply didn't like the initial naming conventions. Arrrggg!

We found an email in our inboxes listing the things he had broken along the way.

We spent weeks migrating user data from the old database schema to the new one.

These are two examples of refactoring sessions that went sideways. Nobody asked those guys to change anything in the first place.

Even there was no need or business case for that in the first place.

I have a term for these refactoring sessions: **massive unrequested refactoring.**

<figure>
<img src="https://images.unsplash.com/photo-1634586648651-f1fb9ec10d90?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY4NDg3OTg0NA&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="A room with some tools in it" />

<figcaption>Another massive but unfinished refactoring...Photo by <a href="https://unsplash.com/@st_lehner?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Stefan Lehner</a> on <a href="https://unsplash.com/photos/biRt6RXejuk?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## The Need for Refactoring

I'm not saying we shouldn't refactor our code.

I believe in the "leave the basecamp cleaner than the way you found it" mantra.

But, before embarking on a massive refactoring, let's ask ourselves if it's truly necessary and if the team can afford it, not only in terms of money but also time and dependencies.

Often, we get too focused on [naming variables, functions, and classes]({% post_url 2022-12-07-BanningSomeNamingConventions %}) to see the bigger picture and the overall project in perspective.

"Perfect is the enemy of good."

And if there isn't a viable alternative, let's split that massive refactoring into [separate, focused, and short Pull Requests]({% post_url 2022-12-19-LessonsAsReviewer %}) that can be reviewed in a single review session without much back and forth.

**The best refactorings are the small ones that slowly and incrementally improve the health of the overall project. One step at a time. Not the massive unrequested ones.**

Voilà! That's my take on massive unrequested refactorings. Have you ever done one too? What impact did it have? Did it turn out well? Remember, all code we write should move the project closer to its finish line. Often, massive unrequested refactorings don't do that.

In my two stories, those refactoring sessions ended up blocking people and creating more work.

These refactorings remind me of the analogy that [coding is like living in a house]({% post_url 2021-01-25-LivableCode %}). A massive unrequested refactoring would be like a full home renovation while staying there!

_Happy coding!_