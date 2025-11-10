---
layout: post
title: "4 Practical Use Cases Where AI Shines in Coding"
tags: coding
---

Like many developers, I've struggled to find the right way to use AI.

So far, I've settled on using [AI as my assistant]({% post_url 2025-10-14-AIRule %}), but I don't let it touch my code.

I haven't followed a strict approach to testing AI. I just use it to offload some boring tasks, like [this]({% post_url 2025-05-24-CodingWithAI %}) and [this]({% post_url 2025-06-19-CodingWithAI %}).

Here are the use cases where I've found AI shines:

**#1. Generate unit tests:** I give a sample test class I wrote myself and ask it to use as a guideline to generate tests for a similar object. Especially helpful when I'm not doing TDD but still want [unit tests]({% post_url 2021-03-15-UnitTesting101 %}).

**#2. Generate CRUD code:** I've always dreamed of automating CRUDs. It seems we're closer with AI.

I give AI a handler signature, explain the steps, and let it fill in details. I also provide database object definitions, repository signatures, and legacy code blocks, when [I'm in migration mode]({% post_url 2025-09-18-LegacyMigration %}).

**#3. Improve naming:** OK, this is one of the hardest tasks in coding. I describe what my class or method does and ask AI to critique or suggest names.

**#4. Review code:** This is one of my most frequent use cases. I like to feed AI with a diff of my changes and ask it to look for typos and places where I broke conventions. AI has caught me copy-pasting a lot. I tend to forget to update API routes. Oops!

I almost added searching (bye Google!) as a fifth point, but I trust StackOverflow and random people's blogs more. I'm not sure when AI is simply hallucinating or actually answering correctly.

Lesson: Use AI for pattern matching and boilerplate code. Don't use it to generate entire modules, make architectural decisions, or ask it to "double check answers and not to make mistakes."

And if you're starting out, [set strict AI rules]({% post_url 2025-09-15-ShouldIUseAI %}) or you won't grow strong coding muscles. [Use AI as a learning assistant]({% post_url 2025-03-24-NewCodersAndAI %}) instead.

It's tempting to default to AI for its speed. But to shine as a coder, you need more than just speed. Coding is problem-solving, collaboration, and clear communication. That's why I wrote, _Street-Smart Coding: 30 Ways to Get Better at Coding,_ the roadmap I wish I had on my path to becoming a senior coder. Because coding is more than mastering syntax.

_[Get your copy of Street-Smart Coding here](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=practical-use-cases-ai-shines-coding)_
