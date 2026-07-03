---
layout: post
title: "The Joy of Old-School Coding After a Stupid Mistake"
tags: coding
---

Yesterday, it happened again.

I had an error message that [made me scratch my head]({% post_url 2025-12-09-Debugging %}).
For a moment, I thought, _"God, why am I doing this? I should start a garden or something."_

I copy-pasted the error message into Google.
StackOverflow didn't help that much.
I was [tempted to go to Copilot]({% post_url 2025-07-13-TheProblemWithAI %}).
But I held my horses.

A few moments later, _"Oooohh, here it is!"_
A one-line code change fixed it.
Stupid Entity Framework Core!

I was in a rush a few days before and I missed a small detail:
I used a collection to [map a one-to-one relationship]({% post_url 2026-03-11-OneToOne %}).
Simple! I know. Only integration tests caught it.

For a moment, an error message made me want to quit.
A second later, I was back in the game.
Yet again. For the nth time.

I guess AI doesn't give you that feeling—or does it?

_Whether you code the old way or with AI, check out [Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=joy-of-oldschool-coding-stupid-mistake)—It covers debugging, testing, and many 28 more lessons to help you code like a pro._


