---
layout: post
title: "TIL: How to Remove a File From a Git Commit"
tags: git todayilearned
---

I've hired AI as my code reviewer.

[When I write code, AI reviews it]({% post_url 2026-01-26-AnotherAIRule %}). For that, I feed Copilot with a diff to review. But [I always have to Google]({% post_url 2025-10-22-Googling %}) how to diff two branches. 

To avoid Googling it every time, here it is:

```shell
$ git diff development..mybranch > diff
```

Today, by accident, I committed the actual diff. So I had to remove it from a commit. I wasn't sure if I needed a `git rebase` or something else. I had to Google it.

Again, to avoid Googling it every time, [\[Source\]](https://stackoverflow.com/a/15321456)

```shell
$ git reset --soft HEAD~1  # Undo the last commit, keeping the changes
$ # Do your thing
$ git commit -c ORIG_HEAD  # Commit, using the last message
```

Et voilà!
