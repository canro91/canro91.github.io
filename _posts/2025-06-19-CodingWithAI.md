---
layout: post
title: "How Copilot Has Helped Me Code Faster—With These 5 Boring Tasks"
tags: coding
---

This week, I've been running a coding experiment.

Every time I sit to code, I open Copilot (on a browser, not inside my IDE) and look for tasks to delegate.

Yesterday, while migrating a legacy Visual Basic application, I found myself doing some mundane and repetitive work. So I hired Copilot as my junior coder. And here are the tasks it helped me with:

## #1. Populate an enum.

I had a large `While` loop full of `If` statements on the VB side.

It used magic strings for the comparisons. I gave the original VB code and asked Copilot to populate an existing C# enum with the missing magic strings.

## #2. Use comments to emulate named parameters.

A method with dozens of parameters isn't that weird in a legacy app.

To make it easier to port, I gave Copilot the signature of a method and a code block that invoked it, and asked it to use comments to document each parameter name.

Later, I found out VB has named parameters. Arrggg! Anyway, that wasn't code I was planning to commit. It was just to make it easier to read and port to C#.

## #3. Avoid jumping between files.

Why create constants when we could use magic strings, right? Another common mistake on legacy apps.

In a unit test, in the Arrange part, I needed to generate identical objects, except for the values for a pair of properties.

The problem? I needed to look at three VB files to come up with the right combination of values for each object. So I gave Copilot the three code blocks and asked it to generate a 3-column table with the values I needed. No more jumping between files.

## #4. Convert stored procedures into Entity Framework Core queries.

I'm not going to discuss which one is better. Stored procedures or ORMs.

But I found myself migrating stored procedures with fairly simple queries to LINQ-like queries with Entity Framework. So I gave Copilot my entity classes and asked to generate the equivalent queries.

This might not work for large and complex queries inside stored procedures.

## #5. Review a patch looking for typos.

Before opening PRs, I asked Copilot to look for typos and suggest more descriptive class, method, and variable names.

Naming is hard and it always generates a lot of back and forth in code reviews. To avoid long discussions, I gave Copilot a git diff of my changes and asked it to be my code reviewer.

I've found Copilot shines at text-heavy processing tasks and filling the blanks of well-defined tasks. I've already tried [these five tasks]({% post_url 2025-05-24-CodingWithAI %}). But it's not great at vague instructions like "migrate this to C#" or "refactor this code block." With clear instructions, it's the best intern for tedious tasks.
