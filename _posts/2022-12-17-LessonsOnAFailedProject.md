---
layout: post
title: 'Three lessons I learned after a "failed" project'
tags: career
cover: Cover.png
cover-alt: "Past due invoices" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

While thinking about what to write next for my Advent Calendar, I thought about sharing some of the lessons I learned on one of my "failed" projects. I put failed between quotes because our team delivered the project. But I think we made some mistakes, and I learned some lessons.

Before sharing the lessons, let me give you some context about this project. It was a one-month project to integrate a Property Management System (PMS) with a third-party Guest Messaging System. The idea was to sync reservations and guest data to this third-party system, so hotels could send their guests reminders and Welcome messages.

After some reflection, these are three lessons I learned.

## 1. Minimize Moving Parts

Before starting the project, we worked with an N-tier architecture. Controllers call Services that use Repositories to talk to a database. But, the new guideline was to "start doing DDD." That's not a bad thing per se. The thing was: almost nobody in the team was familiar with DDD. I had worked with some of the DDD artifacts before. But, we didn't know what the upper management wanted with "start doing DDD." 

With this decision, a one-month project ended up being a three-month project. After reading posts and sneaking into GitHub template projects, two or three weeks later, we agreed on the project structure, aggregate and entity names, and an overall approach. We were already late.

For such a small project with a tight schedule, there was no room for experimentation.

_"The best tool for a job is the tool you already know."_ I found this idea these days. I wish I could credit the source, but I don't remember where I found it. Maybe, it was on Reddit or Hacker News. At that time, the best tool for my team was N-tier architecture.

For my future projects, I will minimize the moving parts.

## 2. Define a Clear Path

We agreed on reading the "guests" and "reservations" tables inside a [background processor]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}) to call the third-party APIs. And we stared working on it. But another team member was analyzing how to implement an Event-Driven solution with a message queue.

Our team member didn't count that his solution required "touching" some parts of the Reservation lifecycle. With all the Development and Testing effort implied. Although that could be the right solution in theory, we already chose the low-risk solution. He wasted some time we could have used on something else. 

For my future projects, I will define a clear path and have everybody on-boarded.

## 3. Don't Get Distracted. Cross the Finish Line

With a defined solution and everybody working on it, we started to estimate with poker planning. During some of the planning sessions, we joked about putting "in one month" as the completion date for all tickets and stopped doing those meetings. Why make everybody in the team vote for an estimation on a task somebody else was already working on? We all knew what we needed to do and what everybody else was doing. 

It was time to focus on the goal and not get distracted by unproductive ceremonies or meetings. I don't mean stop writing unit tests or doing code reviews. 

For my future projects, I will focus on crossing the finish line.

Voilà! These are the lessons I learned from this project. Although tech choice plays a role in the success of a project, I found that "people and interactions" are way more important. I bet we can find fail projects using the most state-of-the-art technology or programming languages.

For more career lessons, check my [five lessons after five years as a software developer]({% post_url 2019-08-19-FiveLessonsAfterFiveYears %}), [ten lessons learned after one year of remote work]({% post_url 2020-08-08-LessonsOnRemoteWork %}) and [things I wished I knew before working as a software engineer]({% post_url 2022-12-12-ThingsToKnowBeforeBeingSoftwareEngineer %}).

_Happy coding!_