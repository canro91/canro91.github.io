---
layout: post
title: Programs that saved you 100 hours (Online tools, Git aliases and Visual Studio extensions)
tags: productivity git visualstudio
---

Today I saw this Hacker News thread about [Programs that saved you 100 hours](https://news.ycombinator.com/item?id=22849208). So I want to show some of the tools that have saved me a lot of time. _Probably not 100 hours yet._

## Online

* [JSON Utils](https://jsonutils.com/) It converts a json file into C# classes. You could choose the property annotations and the casing for names. Visual Studio 2019 has this feature as "Paste JSON as Classes". But, it doesn't change the property names from camelCase in your JSON to PascalCase in your C# class.

* [NimbleText](https://nimbletext.com/Live) It applies a replace pattern on every single item of a input dataset. You don't need to type crazy key sequences. _Like playing the drums_ For example, it's useful to generate SQL insert or updates statements from sample data in CSV format.

* [jq play](https://jqplay.org/) An online version of [jq](https://stedolan.github.io/jq/), a JSON processor. It allows to slice, filter, map and transform JSON data.

## Git

### Aliases

I use Git from the command line most of the time. I have <del>created</del> copied some aliases for every day workflows. For example,

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

Not Git related, but I have also created some aliases to use the Pomodoro technique

```bash
alias pomo='sleep 1500 && echo "Pomodoro" && tput bel' 
alias sb='sleep 300 && echo "Short break" && tput bel' 
alias lb='sleep 900 && echo "Long break" && tput bel'
```

### Hook

I work in a project that uses a branch naming convention. You need to include the type of task and the task number in the branch name. Every commit message should include the task number too. [You can automate that with a prepare-commit-msg hook](https://medium.com/better-programming/how-to-automatically-add-the-ticket-number-in-git-commit-message-bda5426ded05).

No more mental burden to memorize every task number. Specially when task numbers end up like virus names :D

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

## Visual Studio extensions

* [CodeMaid](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid) It's like a janitor. It helps you to clean extra spaces and blank lines, remove and sort using statements, insert blank line between properties and much more.

* [MappingGenerator](https://marketplace.visualstudio.com/items?itemName=54748ff9-45fc-43c2-8ec5-cf7912bc3b84.mappinggenerator) I found this extension recently and it has been a time saver. You need to initialize an object with default values? You need to create a view model or DTO from a business object? MappingGenerator got you covered!

Voilà! These are the tools that have saved me 100 hours!

_Happy coding!_
