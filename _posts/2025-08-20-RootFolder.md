---
layout: post
title: "TIL: How to Navigate to the Root Folder of a Git Repo"
tags: todayilearned git
---

Recently I found myself `cd`ing to find the folder with a `.sln` file. You know to run `dotnet` commands.

Being a lazy coder, I thought of a better solution with a Bash script. But it turned out to be way easier with a Git command,

```shell
$ cd `git rev-parse --show-toplevel`
```

That would take you to the root folder of a git repo. And since my solution file is at the root, bingo! Kudos to [this SO answer](https://stackoverflow.com/a/56048850).

And the next lazy step was to [create an alias]({% post_url 2020-04-13-ProgramThatSave100Hours %}),

```shell
alias groot='cd "$(git rev-parse --show-toplevel)"'
```

Et voilà!
