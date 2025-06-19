---
layout: post
title: "How Copilot Has Helped Me Code Faster—With These 4 Boring Tasks"
tags: coding
---

This week, I've been running a coding experiment.

Every time I sit to code, I open Copilot and look for tasks to delegate.

Yesterday, while migrating a legacy Visual Basic application, I found myself doing some mundane and repetitive work. So I hired Copilot as my junior coder. And here are the tasks it helped me with:

**#1. Populate an enum.** I had a large `While` loop full of `If` statements on the VB side. It used magic strings for the comparisons. I gave the original VB code and asked Copilot to populate a C# enum with the missing magic strings.

**#2. Use comments to emulate named parameters.** A method with dozens of parameters isn't that weird in a legacy app. To make it easier to port, I gave Copilot the signature of a method and a code block that invokes it, and asked it to use comments to document each parameter name. Later, I found out VB has named parameters. Arrggg! Anyway, that wasn't code I was planning to commit. It was just to make it easier to read and port to C#.

**#3. Avoid jumping between files.** Why create constants when we could use magic strings, right? In a unit test, I needed to generate similar objects with different values for a pair of properties. The problem? I needed to look at three VB files to come up with the right combination of values for each object. So I gave Copilot the three code blocks and asked it to generate a 3-column table with the values I needed. No more jumping between files.

**#4. Review a patch looking for typos.** Before opening PRs, I ask Copilot to look for typos and suggest more descriptive class, method, and variable names. I gave it a git diff of my changes and asked it to be my code reviewer.

I've found Copilot shines at text-heavy processing tasks and filling the blanks of well-defined tasks. I've already tried [these five tasks]({% post_url 2025-05-24-CodingWithAI %}). But it's not great at vague instructions like "migrate this to C#." With clear instructions, it's the best intern for tedious tasks.
