---
layout: post
title: "Build Real Coding Skills—Then Use AI (In That Order)"
tags: coding
---

In the days of StackOverflow, we had to verify answers. Now, too often, we accept AI's output without question.

## Catching AI red-handed

Today, in another adventure with AI, [I asked Copilot]({% post_url 2025-10-14-AIRule %}) to turn a couple of SQL table definitions into mapping classes for Entity Framework Core. It was the classical 1-to-many relationship.

The problem came when I asked it to generate an API endpoint to store a parent record with a bunch of child records. Something like: create a parent record, then read a table to create its children.

Its first solution was to persist the parent record. Then inside a loop, persist every child record. The classical N+1 problem. Well, the inverse one. Arrggg!

When I prompted it to change it, saying there was no need for the loop, it replied with a _"Yes, you can simplify it that way."_ Caught you Copilot!

## Why coding skills still matter

The N+1 problem was something I could find on the spot.

Now imagine how many AI answers we blindly accept without question. When coding, documenting, researching, testing...

_Coding skills still matter. Without them, we wouldn't even notice the problem._

Blindly trusting AI is what makes us say [AI kills CS degrees]({% post_url 2025-12-22-AIRuiningDegrees %}), what [makes us dangerously lazy]({% post_url 2025-07-13-TheProblemWithAI %}).

Reviewing the code AI spits out puts in [the top 50% of coders]({% post_url 2026-02-06-AIStats %}). The other 50% don't always review. You need your coding muscles for that.

AI is like a semi-autonomous car. It always needs hands on the wheel. Build skills. Then leverage AI.

To help you build hype-proof skills, I wrote [Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=build-real-coding-skills-use-ai). Because syntax alone won't make you stand out.
