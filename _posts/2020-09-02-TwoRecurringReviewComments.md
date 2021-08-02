---
layout: post
title: How to get rid of two recurring review comments (Git hook, VS extension)
tags: productivity git visualstudio
---

During code review, one or two of your coworkers look at your code to spot any potential issues. But, often, code reviews end up checking only style issues. This is how I get rid of two recurrent comments I got getting my code reviewed.

For a project I was working on, I had to include the ticket number in every commit message and add `Async` suffix to all asynchronous C# methods. I forgot these two conventions every time I created my Pull Requests.

## How to add ticket numbers in commit messages

**Add ticket numbers in Git commit messages using a prepare-commit-msg hook. This hook formats commit messages before committing the changes. Use this hook to enforce naming conventions and run custom actions before committing changes**.

I was already naming my feature branches with the ticket number. Then, with a bash script I could read the ticket number from the branch name and prepends it to the commit message.

This is a prepare-commit-msg hook to prepend commits message with the ticker number from branch names.

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

If I name my feature branch `feat/ABC-123-my-awesome-branch`. Then when I commit my code, Git  will rewrite my commit messages to look like `ABC-123 My awesome commit`. 

I wrote about this hook on my list of [Programs that saved you 1000 hours]({% post_url 2020-04-13-ProgramThatSave100Hours %}). Also, you can find Git aliases, Visual Studio extensions and other online tools to save you some valuable time.

## Async suffix on asynchronous C# methods

Another convention I always forgot about was adding `Async` suffix on asynchronous C# methods.

After Googling a bit, a coworker came up with [this StackOverflow answer](https://stackoverflow.com/questions/53972941/how-do-i-get-a-warning-in-visual-studio-when-async-methods-dont-end-in-async) to use a `.editorconfig` file to get errors on async methods missing the `Async` suffix on any C# methods.

An `.editorconfig` file to enforce the `Async` suffix looks like the one below.

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

But, the `.editorconfig` enforces `Async` suffix even `Main` method and tests names. `MainAsync` looks weird. Also, it misses method declarations returning `Task` or `Task<T>` on interfaces.

**To add a warning on asynchronous C# methods missing the Async suffix, use the AsyncMethodNameFixer extension on Visual Studio.**

With the [AsyncMethodNameFixer](https://github.com/priyanshu92/AsyncMethodNameFixer) extension, you get warnings to include the `Async` suffix on methods and interfaces. It doesn't catch the `Main` method and test methods.

But, to enforce this convention with a Visual Studio extension, you rely on developers to have it installed. With the `.editorconfig` your naming rules travels with the code itself when you clone the repository.

Voilà! That's how I got rid of these two recurring comments while code review. For more productive code reviews, read my [Tips and Tricks for Better Code Reviews](https://canro91.github.io/2019/12/17/BetterCodeReviews/).

For more extensions to make you more productive with Visual Studio, check [my Visual Studio Setup]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}).

If you're new to Git, check my [Git Guide for Beginners]({% post_url 2020-05-29-HowToVersionControl %}) and my [Git guide for TFS Users]({% post_url 2019-11-11-GitGuideForTfsUsers %}).

_Happy coding!_
