---
layout: post
title: "The Hardest Lesson I Learned Migrating Legacy Code (Again)"
tags: career coding
---

I definitely can't escape from legacy code.

This time, it's an old WebForms application written in VB. Yes, that old. It's a family business. Dad started it. And years later, his two sons got involved. It's funny when during the standup meetings I hear, "Hey Dad..."

## The problem

The code is a mess. Sorry, I mean it needs a lot of care.

I don't blame them. It was the easy route with WebForms. Just drag and drop, double-click, and dump all your logic. It's just like that framework encouraged people to copy and paste.

I've worked with at least 3 legacy apps with WebForms. All of them were pure spaghetti code. [Zero best practices]({% post_url 2024-12-25-BestPractices %}). "Coincidence? I don't think so." (Insert Toy Story character wearing a chicken suit)

The code needs care, but the database needs even more attention.

It doesn't have foreign keys, and queries don't use JOINs. If you want to join two tables, one of them has a string column with a list of IDs separated by a pipe (`12|34|56`). You fetch records separately and then loop through them to join them. Arrggg!

And please, let's not talk about stored procedures...

## The lesson

But from this project I've learned that if we don't pay close attention to the initial database design, the backend side gets wildly crazy. A lot of hacks and patches to make up for a poor DB design.

There's no need to go crazy with database normalization. Just:
* Every table should have an auto-incremented ID.
* Use a separate table instead of a column with a list of IDs.
* Keep data types consistent across tables. All "Status" columns should be either `BIT` or an `INT`. Otherwise, [conversions could go wild]({% post_url 2022-02-07-WhatAreImplicitConversions %}).
* [Add audit fields]({% post_url 2022-12-11-AuditFieldsWithOrmLite %}) ("createdAt" and "updatedAt") to every table.

I wish they had followed those simple guidelines 10 years ago.

But more surprisingly, I learned that you don't need a perfectly clean codebase to have a successful business. You will suffer? Sure. But running a business and writing good code are two completely separate skill sets.

The freshly graduated me thought I was only going to always create systems from scratch following all principles and practices to the tee. But working with legacy code taught me more than any coding course.

That's why I made it one of the 30 proven strategies in my book, _Street-Smart Coding: 30 Ways to Get Better at Coding._ That's the roadmap I wish I had when I was starting out.

_[Grab your copy of Street-Smart Coding here](https://imcsarag.gumroad.com/l/streetsmartcoding)_
