---
layout: post
title: "A Quick Lesson After A Long Debugging Session (And Almost Pulling My Hair Off)"
tags: coding
---

I almost pulled my hair off.

I debugged an issue in a Blazor grid for over two half days. I followed my own advice from [Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=quick-lesson-long-debugging-session):
* Isolated the problem
* Removed all irrelevant parts
* Discussed it with a rubber duck

Just to keep seeing the same error message: _TypeError: Cannot read properties of null (reading 'removeChild')_.

StackOverflow says it was Blazor trying to remove an orphan element. So I removed everything except for my grid and wrapped it around a div.

Same mistake.

After questioning my career choices and almost removing "Senior" from my title, I asked for help.

My coworker pulled my branch and reproduced the issue. To my surprise, the issue wasn't only in my grid. It was in all other grids, all over the app. It was an issue in the Blazor component itself we were using for grids. Arrggg!

Sometimes you just need to ask for help earlier. Like [one of my mentors told me and the team]({% post_url 2025-10-25-LessonsFromMentor %}), _"you have nothing to prove. Ask for help."_ And that's something I cover on Chapter #2 of _Street-Smart Coding_.
