---
layout: post
title: "The Real Definition of Legacy Code (After 10 Years in the Trenches)"
tags: coding
---

When you hear "legacy code," what's the first thing that comes to mind?

If you're a .NET developer, maybe that's an old ASP.NET WebForms application written in VB.NET and powered by stored procedures.

And if you're familiar with _Working Effectively with Legacy Code_, you would say "Code without tests."

But after 10 years with complex codebases, I challenge those assumptions.

## What legacy code really means

**Legacy code is simply code we don't understand and want to stay away from.**

A codebase doesn't need dead languages or outdated frameworks to fit that definition. 

Of course we don't understand a codebase when we find it for the first time. But the real issue is _the cognitive load we need to work with it._

With that definition, code with tests can still be legacy code.

I've seen it! At a past job, I worked in a hotel management solution. There were two teams working on different parts of the application. One team used the shiniest and brightest: ASP.NET Core, Entity Framework Core, you name it. But still nobody else touched their code. It was too messy.

Did it have tests? Sure! And 100% coverage to make upper management happy. But those tests gave no confidence to refactor. They only exercised [mocks]({% post_url 2021-05-24-WhatAreFakesInTesting %}).

Legacy code boils down to context and understanding.

That's why it's so tempting to [rewrite legacy code]({% post_url 2025-11-13-LegacyTakeOver %}). We have to rebuild all the shared knowledge when writing the new version.

As a junior coder, I thought I'd only work on shiny projects with the latest tools. In reality, every job has involved legacy system. And each one taught me valuable skills that I included in my book, _Street-Smart Coding: 30 Ways to Get Better at Coding._

[Grab your copy of Street-Smart Coding here](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=real-definition-legacy-code). It's the roadmap I wish I had moving from junior to senior, and the one I hope guides you too.

