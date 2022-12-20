---
layout: post
title: "TIL: How to replace keywords in a file name and content with Bash"
tags: todayilearned visualstudio
cover: Cover.png
cover-alt: "Pile of cds" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

These days I needed to rename all occurrences of one keyword with another in source files and file names. In one of my client's projects, I had to query one microservice to list a type of account to store it in an intermediate database. After a change in requirements, I had to query for another type of account and rename every place where I used the old one. This is what I learned.

## 1. Find and Replace inside Visual Studio

My original solution was to use Visual Studio to replace "OldAccount" with "NewAccount" in all `.cs` files in my solution. I used the "Replace in Files" menu by pressing: Ctrl + Shift + h,

{% include image.html name="ReplaceInFiles.png" caption="Visual Studio 'Replace in Files' menu" alt="Visual Studio 'Replace in Files' menu" width="400px" %}

After this step, I replaced all occurrences inside source files. For example, it renamed class names from `IOldAccountService` to `INewAccountService`. To rename variables, I repeated the same replace operation but using lowercase patterns.

With the "Replace in Files" menu, I covered file content. But I still had to change the filenames. For example, I needed to rename `IOldAccountService.cs` to `INewAccountService.cs`. I did it by hand. Luckily, I didn't have to replace many of them. There must be a better way!- I thought.

## 2. Find and Replace with Bash

After renaming my files by hand, I thought I could have used the command line to replace both the content and file names. I use Git Bash anyways. Therefore I have access to most of Unix commands. 

### Replace 'old' with 'new' inside all .cs files

This is how to replace "Old" with "New" in all `.cs` files, [Source](https://stackoverflow.com/a/12517022)

```bash
grep -irl --include \*.cs "Old" | xargs sed -i 's/Old/New/g'
```

With the `grep` command, we look for all `.cs` files (`--include \*.cs`) containing the "Old" keyword, no matter the case (`-i` flag), inside all child folders (`-r`), showing only the file path (`-l` flag).

We could use the first command, before the pipe, to only list the `.cs` files containing a keyword.

Then, with the `sed` command, we replace the file content in place (`-i` flag), changing all occurrences of "Old" with "New" (`s/Old/New/g`). Notice the `g` option in the replacement pattern.

This first command does what Visual Studio "Find in Files" does.

### Rename 'old' with 'new' in filenames

Instead of renaming files by hand, this is how to replace "Old" with "New" in file names, [Source](https://stackoverflow.com/a/71969517)

```bash
find . -path ./TestCoverageReport -prune -type f -o -name "*Old*" \
  | sed 'p;s/Old/New/' \
  | xargs -d '\n' -n 2 mv
```

This time, we're using the `find` command to "find" all files (`-type f`), with "Old" anywhere in their names (`-name "*Old*"`), inside the current folder (`.`), excluding the TestCoverageReport folder (`-path ./TestCoverageReport -prune`).

Optionally, we can exclude multiple files by wrapping them inside parenthesis, like, [Source](https://stackoverflow.com/a/4210072)

```bash
find . \( -path ./FolderToExclude -o -path ./AnotherFolderToExclude \) \
    -prune -type f -o -name "*Old*"
```

Then, we feed the `sed` command to generate new names replacing "Old" with "New." This time, we're using the `p` option to print the "before" pattern. Up to this point, our command returns something like this,

```bash
./Some/Folder/AFileWithOld.cs
./Some/Folder/AFileWithNew.cs
...
```

With the last part, we split the `sed` output by the newline character and passed groups of two filenames to the `mv` command to finally rename the files.

Another alternative to sed followed by mv would be to use the [rename command](http://plasmasturm.org/code/rename/), like this,

```bash
find . -path ./TestCoverageReport -prune -type f -o -name "*Old*" \
  | xargs rename 's/Old/New/g'
```

Voilà! That's how to replace a keyword in the content and name of files. It took me some time to figure this out. But, we can rename files with two one-liners. It will save us time in the future. Kudos to StackOverflow.

To read more productivity tips and tools, check these [programs that save me 100 hours]({% post_url 2020-04-13-ProgramThatSave100Hours %}), [how to format commit messages with hooks]({% post_url 2020-09-02-TwoRecurringReviewComments %}), and [how to rename Visual Studio projects]({% post_url 2022-12-09-RenameProjectsVisualStudio %}).

_Happy coding!_