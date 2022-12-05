---
layout: post
title: Programs that saved you 100 hours (Online tools, Git aliases and Visual Studio extensions)
tags: productivity git visualstudio
---

Today I saw this Hacker News thread about [Programs that saved you 100 hours](https://news.ycombinator.com/item?id=22849208). I want to show some of the tools that have saved me a lot of time. Probably not 100 hours yet.

## 1. Online Tools

* [JSON Utils](https://jsonutils.com/) It converts a json file into C# classes. We can generate C# properties with attributes and change their casing. Visual Studio has this feature as "Paste JSON as Classes". But, it doesn't change the property names from camelCase in our JSON strings to PascalCase in our C# class.

* [NimbleText](https://nimbletext.com/Live) It applies a replace pattern on every single item of a input dataset. I don't need to type crazy key sequences. Like playing the drums. For example, it's useful to generate SQL insert or updates statements from sample data in CSV format.

* [jq play](https://jqplay.org/) An online version of [jq](https://stedolan.github.io/jq/), a JSON processor. It allows to slice, filter, map and transform JSON data.

## 2. Git Aliases and Hooks

### Aliases

I use Git from the command line most of the time. I have <del>created</del> copied some aliases for my everyday workflows. These are some of my Git aliases:

```bash
alias gs='git status -sb' 
alias ga='git add ' 
alias gco='git checkout -b ' 
alias gc='git commit ' 
alias gacm='git add -A && git commit -m ' 
alias gcm='git commit -m ' 

alias gpo='git push origin -u ' 
alias gconf='git diff --name-only --diff-filter=U'
```

Not Git related, but I have also created some aliases to use the Pomodoro technique.

```bash
alias pomo='sleep 1500 && echo "Pomodoro" && tput bel' 
alias sb='sleep 300 && echo "Short break" && tput bel' 
alias lb='sleep 900 && echo "Long break" && tput bel'
```

I don't need fancy applications or distracting websites. Only three aliases.

### Hook to format commit messages

I work in a project that uses a branch naming convention. I need to include the type of task and the task number in the branch name. For example, `feat/ABC123-my-branch`. And, every commit message should include the task number too. For example, `ABC123 My awesome commit`. I found a way to [automate that with a prepare-commit-msg hook](https://medium.com/better-programming/how-to-automatically-add-the-ticket-number-in-git-commit-message-bda5426ded05).

With this hook, I don't need to memorize every task number. I only ned to include the ticket number when creating my branches. This is the Git hook I use,

```bash
#!/bin/bash
FILE=$1
MESSAGE=$(cat $FILE)
TICKET=[$(git rev-parse --abbrev-ref HEAD | grep -Eo '^(\w+/)?(\w+[-_])?[0-9]+' | grep -Eo '(\w+[-])?[0-9]+' | tr "[:lower:]" "[:upper:]")]
if [[ $TICKET == "[]" || "$MESSAGE" == "$TICKET"* ]];then
  exit 0;
fi

echo "$TICKET $MESSAGE" > $FILE
```

This hook grabs the ticket number from the branch name and prepend it to my commit messages.

## 3. Visual Studio extensions

I use Visual Studio almost every working day. I rely on extensions to simplify some work. These are some the extensions I use,

* [CodeMaid](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid) It's like a janitor. It helps me to clean extra spaces and blank lines, remove and sort using statements, insert blank line between properties and much more.

* [MappingGenerator](https://marketplace.visualstudio.com/items?itemName=54748ff9-45fc-43c2-8ec5-cf7912bc3b84.mappinggenerator) I found this extension recently and it has been a time saver. You need to initialize an object with default values? You need to create a view model or DTO from a business object? MappingGenerator got us covered!

Voilà! These are the tools that have saved me 100 hours! If you want to try more Visual Studio extension, check my [Visual Studio Setup for C#]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}). If you're new to Git, check my [Git Guide for Beginners]({% post_url 2020-05-29-HowToVersionControl %}) and my [Git guide for TFS Users]({% post_url 2019-11-11-GitGuideForTfsUsers %}).

_Happy coding!_
