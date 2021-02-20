---
layout: post
title: How to get rid of two recurring review comments (Git hook, VS extension)
tags: productivity git visualstudio
---

During code review, one or two of your coworkers look at your code to spot any potential issues and to check if the code follows existing conventions. Sometimes, code review ends up checking style issues. _Brackets in the same line, disorganized using statements, extra blank lines_. You can use extensions on your IDE or linters to format your code.

For a project I was working on, **I had to include the ticket number in every commit message and add `Async` suffix to all asynchronous C# methods**. I used a Git hook to add the ticket number in the commit messages. And, an `.editorconfig` file (and, alternatively a Visual Studio extension) to raise an error if the `Async` suffix was missed.

## Ticket number in commit messages

A Git hook can format the commit message before commiting the changes. You can define Git hooks globally or per projects.

I was already including the ticket number in my feature branches. A bash script can read the ticket number from the branch name and prepends it to the commit message.

```bash
#!/bin/bash
FILE=$1
MESSAGE=$(cat $FILE)
TICKET=[$(git branch --show-current | grep -Eo '^(\w+/)?(\w+[-_])?[0-9]+' | grep -Eo '(\w+[-])?[0-9]+' | tr "[:lower:]" "[:upper:]")]
if [[ $TICKET == "[]" || "$MESSAGE" == "$TICKET"* ]];then
  exit 0;
fi

echo "$TICKET $MESSAGE" > $FILE
```

If I name my feature branch `feat/ABC-123-my-awesome-branch`. Then when I commit my code, I don't need to include the branch name. Git will do that for me. My commit messages will look like `ABC-123 My awesome commit`. 

I wrote about this hook on my list of [Programs that saved you 1000 hours](https://canro91.github.io/2020/04/13/ProgramThatSave100Hours/). Also, you can find Git aliases, Visual Studio extensions and other online tools to save you some valuable time.

## Async suffix on asynchronous C# methods

I used an `.editorconfig` file to enforce naming conventions on the C# project. After Googling, a coworker came up with [this StackOverflow answer](https://stackoverflow.com/questions/53972941/how-do-i-get-a-warning-in-visual-studio-when-async-methods-dont-end-in-async) to get an error if I forgot to include the `Async` suffix on any C# methods.

```
[*.cs]

# Async methods should have "Async" suffix
dotnet_naming_rule.async_methods_end_in_async.symbols = any_async_methods
dotnet_naming_rule.async_methods_end_in_async.style = end_in_async
dotnet_naming_rule.async_methods_end_in_async.severity = error

dotnet_naming_symbols.any_async_methods.applicable_kinds = method
dotnet_naming_symbols.any_async_methods.applicable_accessibilities = *
dotnet_naming_symbols.any_async_methods.required_modifiers = async

dotnet_naming_style.end_in_async.required_prefix = 
dotnet_naming_style.end_in_async.required_suffix = Async
dotnet_naming_style.end_in_async.capitalization = pascal_case
dotnet_naming_style.end_in_async.word_separator =
```

The `.editorconfig` forces to include the `Async` suffix even in your `Main` method and in your tests methods. It hurts readability of your tests. And `MainAsync` looks weird. It misses methods returning `Task` or `Task<T>` in interfaces.

Instead, I found the [AsyncMethodNameFixer](https://github.com/priyanshu92/AsyncMethodNameFixer) extension. It makes you to include the `Async` suffix in only methods and interfaces. It doesn't catch the `Main` method and test methods. But, it relies on developers to have this extension installed to keep consistency in your project. With the `.editorconfig` your naming rules travels with the code itself.

Voilà! That's how I got rid of these two recurring comments while code review. You can read [my Tips and Tricks for Better Code Reviews](https://canro91.github.io/2019/12/17/BetterCodeReviews/). For more extensions to make you more productive with Visual Studio, check [my Visual Studio Setup](https://canro91.github.io/2019/06/28/MyVSSetupSharpeningTheAxe/).

_Happy coding!_
