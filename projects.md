---
layout: page
title: Projects
---

These are some coding projects I've written for past employees and clients, and some of my open source contributions.

## Parsinator

I wrote [Parsinator](https://github.com/canro91/Parsinator), a library to extract relevant data from text-based PDFs and plain text files. I used Parsinator to connect 4 clients with legacy software to a Documents API by parsing PDFs and plain-text files into input XML files.

Here's [how I designed Parsinator]({% post_url 2019-03-08-ATaleOfAPdfParser %}) and the motivation behind it.

[![canro91/parsinator - GitHub](https://gh-card.dev/repos/canro91/parsinator.svg)](https://github.com/canro91/parsinator)

## BaseXml

I wrote [BaseXml](https://github.com/canro91/BaseXml) to manipulate and validate XML files. I used BaseXml to add, read, update, and validate nodes and attributes from standard XML documents on an electronic invoicing system.

I used BaseXml to avoid serializing complex XML files.

[![canro91/basexml - GitHub](https://gh-card.dev/repos/canro91/basexml.svg)](https://github.com/canro91/basexml)

## The Slow Room Search

I improved the [response time of the room search functionality of a booking page]({% post_url 2020-09-23-TheSlowRoomSearch %}) by a factor of ~1.5X. I removed N+1 problems and nested loops and [added a caching layer with ASP.NET Core and Redis]({% post_url 2020-06-29-HowToAddACacheLayer %}).

From this task, I learned to always measure before rushing to optimize anything.

## Other Projects

From time to time, I contribute to the open source projects I use by opening issues and sending pull requests.

For example, I've contributed to:

* [DateTimeExtensions](https://github.com/joaomatossilva/DateTimeExtensions/pull/85), adding holidays for my country,
* [ServiceStack.OrmLite](https://github.com/ServiceStack/ServiceStack/pull/1321), fixing an issue while tagging SQL queries
* [Ardalis.GuardClauses](https://github.com/ardalis/GuardClauses/pull/350), adding support for custom exceptions on guard methods.

{% include 7day_email_course_longer.html %}