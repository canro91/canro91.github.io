---
layout: post
title: "Two Lessons I learned after a finished project"
tags: career
cover: Cover.png
cover-alt: "Two businessmen shaking their hands" 
---

Today I want to take a moment and reflect on a finished project. Last year, I worked as an independent contractor and engaged in short projects with a client. This project was a six-month effort to support group events, like weddings, conferences, and retreats, in a property management system.

This small project taught me more about leadership and communication than programming in general. These are the two lessons I learned from this project.

## Lesson 1: Have uncomfortable conversations earlier

Inside our team, we all started to notice "certain" behavior in a team member.

He delayed [Pull Requests]({% post_url 2019-12-17-BetterCodeReviews %}) for minor things, interrupted meetings with off-topic questions, and asked for 100% detailed and distilled assignments.

Even once, he made last-minute changes, blocking other team members before a deadline. It wasn't a [massive unrequested refactoring]({% post_url 2023-09-04-AgainstMassiveUnrequestedRefactorings %}), but it frustrated some people.

From the outside, it might have appeared he was acting to jeopardize the team's progress.

It was time to virtually sit and talk to him. But nobody did it. And things started to get uncomfortable, eventually escalating the situation to upper management, leading to a team reorganization. There was "no chemistry with the team."

An empathetic conversation could have clarified this situation. Maybe the "problematic" team member had good intentions, but the team misinterpreted them. Who knows?

This whole situation taught me to have uncomfortable conversations earlier.

<figure>
<img src="https://images.unsplash.com/photo-1604881988758-f76ad2f7aac1?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTcwNTk1OTM1MA&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Woman in black long sleeves holding a mug">

<figcaption>I hope that's not an uncomfortable conversation...Photo by <a href="https://unsplash.com/@priscilladupreez?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Priscilla Du Preez</a> on <a href="https://unsplash.com/photos/woman-in-black-long-sleeve-shirt-holding-black-ceramic-mug-K8XYGbw4Ahg?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a></figcaption>
</figure>

## Lesson 2: Once you touch it, you own it

At some point, we needed to extend an existing feature. We needed to import an Excel file with a list of guests into a group event.

"You only have to add your changes on top of this existing component. It's already working." I bet you have heard that, too. That was what our Product Owner told us.

The next thing we knew was that the already-working component had issues. The original team was [laid off]({% post_url 2023-08-21-OnLayoffs %}), and we couldn't get our questions answered or count on them to fix those issues.

What was a simple coding task turned out to be a longer one.

Before starting to work on top of an "already-working" feature, I learned to test it and give a list of existing issues. Otherwise, those existing issues will appear as bugs in our changes. And people will start asking questions: "Why are you taking so much time on this? It's a simple task."

Lesson learned! Once you touch it, you own it!

Voilà! These are the lessons I learned from this project: have uncomfortable conversations and test already-working features. Also, this project made me think it's better to hire a decent developer who can be mentored and coached than a "rock star" who can't get along with the team. 

For more career lessons, check [five lessons from my first five years as a software engineer]({% post_url 2019-08-19-FiveLessonsAfterFiveYears %}), [three lessons I learned after a "failed" project]({% post_url 2022-12-17-LessonsOnAFailedProject %}) and [things I wished I knew before working as a software engineer]({% post_url 2022-12-12-ThingsToKnowBeforeBeingSoftwareEngineer %}).