---
layout: post
title: How I got rid of two recurring review comments (Git hook, VS extension)
tags: productivity git visualstudio codereview
---

These are two things I always forgot to do when opening my code to code review. To save my reviewers and me some time, I decided to do something about it. This is how I get rid of two recurrent comments I got getting my code reviewed.

For a project I was working on, I had to include the ticket number in every commit message and add `Async` suffix to all asynchronous C# methods. I forgot these two conventions every time I created my Pull Requests.

## 1. How to add ticket numbers in commit messages

**Add ticket numbers in Git commit messages using a prepare-commit-msg hook. This hook formats commit messages before committing the changes. Use this hook to enforce naming conventions and run custom actions before committing changes**.

I was already naming my feature branches with the ticket number. Then, with a bash script I could read the ticket number from the branch name and prepends it to the commit message.

This is a prepare-commit-msg hook to prepend commit messages with the ticker number from branch names.

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

I wrote about this hook on my list of [Programs that saved me 1000 hours]({% post_url 2020-04-13-ProgramThatSave100Hours %}), where I listed the Git aliases, Visual Studio extensions and other online tools to save me some valuable time.

## 2. Don't miss Async suffix on asynchronous C# methods

Another convention I always forgot about was adding `Async` suffix on asynchronous C# methods.

### Use a .editorconfig file

After Googling a bit, a coworker came up with [this StackOverflow answer](https://stackoverflow.com/questions/53972941/how-do-i-get-a-warning-in-visual-studio-when-async-methods-dont-end-in-async) to use a `.editorconfig` file to get errors on async methods missing the `Async` suffix.

This is how to enforce the `Async` suffix inside an `.editorconfig` file,

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

But, the `.editorconfig` enforces `Async` suffix even `Main` method and tests names. `MainAsync` looks weird. Also, it misses method declarations returning `Task` or `Task<T>` on interfaces. Arrggg!

### AsyncMethodNameFixer Visual Studio extension

**To add a warning on asynchronous C# methods missing the Async suffix, use the AsyncMethodNameFixer extension on Visual Studio.**

With the [AsyncMethodNameFixer](https://github.com/priyanshu92/AsyncMethodNameFixer) extension, I get warnings when I don't include the `Async` suffix on methods and interfaces. It doesn't catch the `Main` method and test methods.

But, to enforce this convention across the team, I have to rely on the other developers to have this extension installed. With the `.editorconfig`, all the naming rules travels with the code itself when anyone clone the repository.

Voilà! That's how I got rid of these two recurring comments while code review. For more productive code reviews, read my [Tips and Tricks for Better Code Reviews](https://canro91.github.io/2019/12/17/BetterCodeReviews/).

For more extensions to make you more productive with Visual Studio, check [my Visual Studio Setup for C#]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}).

If you're new to Git, check my [Git Guide for Beginners]({% post_url 2020-05-29-HowToVersionControl %}) and my [Git guide for TFS Users]({% post_url 2019-11-11-GitGuideForTfsUsers %}).

_Happy coding!_
