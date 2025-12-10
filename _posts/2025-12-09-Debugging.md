---
layout: post
title: "A Quick Lesson After A Long Debugging Session (And Almost Pulling My Hair Off)"
tags: coding
---

I almost pulled my hair off.

I debugged an issue in a Blazor grid for over two half days. I followed my own advice from [Street-Smart Coding]({% post_url 2025-10-28-StreetSmartCoding %}): isolated the problem, remove all irrelevant parts...Just to keep seeing the same error message: _TypeError: Cannot read properties of null (reading 'removeChild')_.

After questioning my career choices, I asked for help.

My coworker pulled my branch and reproduced the issue. To my surprise, the issue wasn't only in my grid. It was in all other grids, all over the app. It was an issue in the Blazor component itself. Arrggg!

Sometimes you just need to ask for help earlier.
