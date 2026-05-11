---
layout: post
title: "TIL: How to Fix the Missing Deps File in Visual Studio"
tags: todayilearned visualstudio
---

After updating Visual Studio last week, I woke up with this error message: _The local resource "C:/Some/Path/Somefile.Deps" doesn't not exist._

None of the projects inside my solution compiled.
I cleaned it, recompiled it, and even restarted Visual Studio.
None of that worked.

The problem was a broken NuGet source left behind after running [my digital decluttering plan]({% post_url 2025-12-29-Decluttering %}).

To honor [the 20-min rule]({% post_url 2024-09-09-WritingIdeas %}), buried in [this StackOverflow answer](https://stackoverflow.com/a/78694300) was the solution:

1. List all the Nuget sources with `dotnet nuget list source`
2. Remove the broken source with `dotnet nuget remove source <source-name>`

Et voilà!

_Mastering your IDE is just one of the 30 lessons in [Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=fix-missing-deps-file-visual-studio)—the roadmap I wish I had on my journey from junior to senior._
