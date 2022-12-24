---
layout: post
title: "TIL: How to rename Visual Studio projects and folders with Git"
tags: todayilearned visualstudio productivity showdev git
cover: Cover.png
cover-alt: "How to rename Visual Studio projects and folders with Git" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

These days I had to rename all the projects inside a Visual Studio solution and the folders containing them. From `SomeThing.Core` to `Something.Core`. That wasn't the exact typo. But that's the idea. Here it's what I learned. It wasn't as easy as only renaming the projects in Visual Studio.

## 1. Rename folders and projects manually

After digging into it, I found [this StackOverflow answer](https://stackoverflow.com/questions/2043618/proper-way-to-rename-solution-and-directories-in-visual-studio) to rename folders and projects inside a solution. It layouts a checklist of what to do. Here I'm bringing it with some extra steps:

First, **close Visual Studio**.

Then, **create a backup of the .sln file**. Just in case.

Next, **use `git mv` to rename the folder from `SomeThing` to `Something`.** This preserves the history of the file. Also, rename the csproj files to match the new name.  

Use the next bash script to rename the folders and csproj files inside the `src` and `tests` folders.  

```bash
# Replace these two values, please
old=SomeThing
new=Something

# Put here all others folders...
for folder in 'Core' 'Infrastructure'
do
git mv src/$old.$folder src/$old.$folder.Temp
git mv src/$old.$folder.Temp src/$new.$folder
git mv src/$new.$folder/$old.$folder.csproj src/$new.$folder/$new.$folder.csproj

git mv tests/$old.$folder.Tests tests/$old.$folder.Tests.Temp
git mv tests/$old.$folder.Tests.Temp tests/$new.$folder.Tests
git mv src/$new.$folder/$old.$folder.csproj src/$new.$folder/$new.$folder.csproj
done
```  

Notice that it uses a temp folder to rename the containing `SomeThing` folder. I found that workaround in [this StackOverflow answer](https://stackoverflow.com/questions/3011625/git-mv-and-only-change-case-of-directory). Git doesn't go along with different casings in file names.  

Next, **in the .sln file, edit all instances of `SomeThing` to be `Something`**, using a text editor like NotePad++.

Next, **restart Visual Studio**, and everything will work as before, but with the project in a different directory.

Next, right-click on the solution name and **run "Sync Namespaces."**

{% include image.html name="SyncNamespaces.png" caption="Fix all namespaces with 'Sync Namespaces' option" alt="Visual Studio Sync Namespaces option" width="600px" %}

Next, **use "Replace in Files" to clean leftovers**. For example, `launchSettings.json` and `appSettings.json` files.

{% include image.html name="ReplaceInFiles.png" caption="Fix all other leftovers with 'Replace In Files' option" alt="Visual Studio Replace In Files" width="600px" %}

Everything should compile. Horraaay!

That was a tedious process. Especially if, like me, you have to rename all source and tests projects in a big solution.

Given the amount of votes of the StackOverflow answer I followed, more than 400, I bet somebody else thought about automating this process.

Indeed.

## 2. Rename folders and projects with ProjectRenamer

[ProjectRenamer](https://github.com/ModernRonin/ProjectRenamer) is a dotnet tool that does all the heavy and repetitive work for us. It renames the folders, csproj files, and project references. Also, it could create a Git commit and build the solution.

ProjectRenamer expects the Git working directory to be clean. Stash or commit all other changes before using it. 

Using a Powershell prompt, from the folder containing the .sln file, run:

```bash
> renameproject.exe SomeThing.Core Something.Core --no-commit --no-review
```

With the `--no-commit` flag, ProjectRenamer will only stage the files. And, the `--no-review` skips the user confirmation. It's like the `-f` flag of some Unix commands.

Voilà! That's how to rename a project inside a Visual Studio solution. The painful and the quick way. Another [tool that saved me like 100 hours]({% post_url 2020-04-13-ProgramThatSave100Hours %}). For more productivity tricks, check [how to use Git to format commit messages]({% post_url 2020-09-02-TwoRecurringReviewComments %}) and my [Visual Studio setup for C#]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}). I never did it by hand again.

_Happy coding!_