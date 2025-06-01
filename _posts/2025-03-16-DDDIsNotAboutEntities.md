---
layout: post
title: "Domain-Driven Design Isn't Just About Entities and Value Objects"
tags: coding
---

What's the first thing that comes to mind when you think of Domain-Driven Design (DDD)? Entities and value objects?

These days, I came across this question on [Reddit](https://www.reddit.com/r/csharp/comments/1jaq72n/what_are_your_thoughts_on_ddd/) about DDD:

> _I've been struggling lately to understand the idea and the reason behind Domain Driven Design. However, I have come up with the understanding that DDD is just the implementation of the core domain in Rich-Domain models, creating a ubiquitous language to make technical development easier, bounded contexts and design patterns like aggregates, value objects, strongly typed IDs and so on._

It's easy to confuse DDD with using entities and [value objects]({% post_url 2022-12-21-WhenToChooseValueObjects %}). But that's not the point.

At a past job, I had the chance to use DDD in small projects. Every two months or so, we started short projects to improve a hotel management software.

## In most of those projects we used, and abused, DDD.

Here are two examples where we abused DDD:

#1. We used it on a CRUD application to text guests upon arrival. The project got behind schedule, in part due to forcing DDD on a project with a tight schedule. From that project, [I learned some good lessons]({% post_url 2022-12-17-LessonsOnAFailedProject %}).

#2. In another project, slightly more complex, but still not business logic heavy, we followed DDD by the book. Almost literally we followed [this book]({% post_url 2022-10-03-HandsOnDDDTakeaways %}). We ended up with [too many layers and mappings between layers]({% post_url 2023-08-07-TooManyLayers %}) just to read data from the database. Arrggg!

If we judge DDD by using entities, value objects, and aggregate roots, in these two examples, we did DDD. But we overengineered a solution that we could have simply done with an n-tier architecture or commands and queries.

## DDD isn't about aggregate roots, entities, and value objects.

DDD is about collaboration and understanding.

It's about collaboration between stakeholders and developers to create a shared understanding of the business rules. And it's about expressing that understanding in a shared language. From product people in user stories to developers, all the way through the code, and up to table and column names.

Aggregate roots, entities, and value objects are mechanisms to encapsulate that understanding inside boundaries in the code.
