---
layout: post
title: "Why Coding Skills Still Matter (Even When AI Is Faster, Better, and Stronger)"
tags: coding
---

In the days of StackOverflow, we had to verify answers. Now, too often, we accept AI's output without question.

## Catching AI red-handed

Today, in another adventure with AI, [I asked Copilot]({% post_url 2025-10-14-AIRule %}) to turn a couple of SQL table definitions into mapping classes for Entity Framework Core. It was the classical 1-to-many relationship. Easy peasy!

The problem came when I asked it to generate an API endpoint to store a parent record with a bunch of child records. Something like: _create a parent record from this request object, then read this table to create its children._

Its first solution was to persist the parent record. Then inside a loop, persist every child record. The classical N+1 problem. Well, the inverse one: I was writing, not reading. Arrggg!

When I prompted it to change it, saying there was no need for the loop, it replied with a _"Yes, you can simplify it that way."_ Caught you Copilot!

## Why coding skills still matter

The N+1 problem was something I could find on the spot.

Now imagine how many AI answers we blindly accept without question. When coding, documenting, researching, testing...

_Coding skills still matter. Without them, we wouldn't even notice the problem in the first place._

Blindly trusting AI is what makes us say [AI kills CS degrees]({% post_url 2025-12-22-AIRuiningDegrees %}), what gets us into trouble, and what [makes us dangerously lazy]({% post_url 2025-07-13-TheProblemWithAI %}).

Reviewing what AI spits out puts you ahead of like 99% of coders who trust AI without questions—OK, I'm making that number up. And you still need your coding muscles to tell whether AI-generated code is garbage and to fix it.

AI is like a semi-autonomous car. It always needs hands on the wheel. Build skills. Then leverage AI. In that order—Keep your hands on the wheel all the time.

To help you build hype-proof skills, I wrote [Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=why-coding-skills-still-matter). Because syntax alone won't make you stand out.
