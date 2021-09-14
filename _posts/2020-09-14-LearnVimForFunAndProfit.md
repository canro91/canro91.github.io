---
layout: post
title: Just Vim It! Learning Vim For Fun and Profit
tags: tutorial productivity vim
description: Have you ever pressed Esc or Alt + F4 to close this weird text editor? Have you ever Googled how to exit Vim? Let's see why you should learn Vim and how to start using it!
cover: Cover.png
cover-alt: Learning Vim For Fun and Profit
---

Have you ever heard about Vim? You might know it only as the text editor you can't even close if you don't know a key combination. But, once you know Vim, you can edit text files at the speed of light. Let's see why you should learn it and how to start using it!

## What is Vim?

From [Vim's official page](https://www.vim.org/), Vim

> _"...is a highly configurable text editor built to make creating and changing any kind of text very efficient"._

Vim is short for _Vi IMproved_. Vim is a fork of the Unix vi editor. Vim is free and open-source. It dates back to the times where the arrow keys and the Esc key were in the middle row of keyboards.

Vim is a command line editor. However, you can find it these days outside the command line with a graphical user interface. You can even bring the Vim experience to some IDE's using plugins or extensions.

## What makes Vim different?

**Vim is a distraction-free text editor**. You won't find fancy toolbars full of icons. You will find a blank canvas ready to start.

**Vim works in modes**. Vim has three modes: normal, insert, and visual. In each mode you can perform only certain type of actions. In normal mode, you can run commands on your text; copy and paste, for example. In insert mode, you can type words and symbols. In visual mode, you can select text.

**Vim includes the concept of macros**. You can record a sequence of actions and repeat it over a stream of text. Using macros, you don't need to retype the same key combination over and over on the text you want to edit.

**Vim integrates with your command line**. If you need to compile, run your tests or do any other action in the command line, you can do it without leaving your editor. Even you can import the output of a command right into your text.

**Vim can be extended and customized**. You can bring your favorite color scheme and define your own key shortcuts. There are lots of plugins to enhance your experience with Vim.

<figure>
<img src="https://source.unsplash.com/AgQaMOQFWeA/800x400" alt="Macro typewriter ribbon" />

<figcaption><span>Photo by <a href="https://unsplash.com/@anhdung?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Dung Anh</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## Why you should learn Vim? A note on Productivity

Vim helps you to stay away from your mouse. It reduces the small context switching of reaching your mouse making you a bit faster. You can move inside your files and edit them without leaving your keyboard. Your hands will be in the middle row of your keyboard all the time.

Vim can go to almost anywhere in a file with a few keystrokes. You can go to the previous or next word, to the beginning or end of your line and file, to any character in the current line.

Vim uses text object motions. You can copy, change or delete anything inside parenthesis, braces, brackets and tags.

### Change the parameter list of a method

Let's say your cursor is at the beginning of a line and you need to change the parameter list of a method. How would you do it? What keystrokes do you need?

Without Vim, you place your cursor in the opening parenthesis with the mouse. Then, while holding Control and Shift, you press the right arrow until the closing parenthesis.

{% include image.html name="ChangeParametersWithoutVim.gif" caption="Change the parameter list of a method without Vim" alt="Change the parameter list of a method without Vim" width="600px" %}

But, with Vim, you need fewer keystrokes. You go to the opening parenthesis with `f(`. Then press `ci(` to change everything inside the parenthesis. Faster, isn't it?

{% include image.html name="ChangeParametersWithVim.gif" caption="Change the parameter list of a method with Vim inside Visual Studio" alt="Change the parameter list of a method with Vim inside Visual Studio" width="600px" %}

## How to start learning Vim

Vim has a step learning curve. Don't try to do your everyday work with Vim right from the beginning.

If you're only used to `Control + C` and `Control + V` from other editors, you will have to learn new shortcuts for everything. Literally, everything. It can be frustrating and unproductive when you first open Vim.

**To learn Vim, learn the basic motions and commands, and start editing files from the command line or from an online Vim emulator outside of everyday work. Have a cheatsheet at hand.**

If you are working in an Unix-based operating system, chances are you have Vim already installed. If not, you can install it from its official site or with a package manager, such as brew, apt-get or chocolatey, depending on your operating system.

### How to exit Vim

#### Let's answer the question from the beginning of the post once and for all.

First, how can you exit Vim if, by any change, you end up inside it? Did you try to commit from the command line without changing the default editor? Press `:q!` and Enter. It will exit Vim and discard any changes. That's it!

To exit saving your changes, press `:wq` and Enter. Also, you can press `ZZ` and Enter. Your changes will be saved this time.

### How to enter and exit Vim modes

You need to switch back and forth between the three modes: normal, insert and visual modes. In a normal text editor, you work in the three modes at the same time. But with Vim, you need to switch between them.

To open a file with Vim, from the command line type `vim <your-file>`. Change `<your-file>` with the actual name of the file. When you open a file, you will be in normal mode.

To start editing your file, you need to switch to insert mode. Press `i`. You will see the `-- INSERT --` label in the status bar. Now, you can type any text. To exit insert mode, press `Esc`. You're back to normal mode.

To select text, switch to visual mode pressing `v`. The status bar will display `-- VISUAL --`. You can select lines of text like using the mouse. Again, to switch back to normal mode, you need `Esc`. Don't worry! Once you're used to these modes, you will switch almost unconsciously.

### How to move through a file with Vim

With Vim, you can use the arrow keys to move your cursor around. But, to keep your hands in the middle row, you can use `h, j, k, l` instead of Left, Down, Up and Right, respectively.

Instead of using arrow keys to move the cursor one position at a time, learn some basic motions.

These are some of the basic Vim motions:

| Vim | Action |
|---|---|
| `b`| Go to the previous word |
| `w`| Go to the next word |
| `0`| Go to the beginning of the current line |
| `$`| Go to the end of the current line |
| `gg`| Go to the beginning of the file |
| `G`| Go to the end of the file |
| `<number>gg`| Go to line with number `<number>` |
| `f<char>`| Go to the next instance of `<char>` in the current line |
| `I`| Go to the beginning of the current line and enter insert mode |
| `A`| Go to the end of the current line and enter insert mode |
| `{`| Go to the previous paragraph |
| `}`| Go to the next paragraph |

#### Add a semicolon at the end of a line with Vim

Do you want to see motions in action? Did you forget to add a semicolon at the end of a line? In normal mode, type `A;` on the line missing the semicolon.

| Vim | Action |
|---|---|
| `<number>gg` | Go to the line number `<number>`. The line missing the semicolon |
| `A` | Go to the end of the line and enter insert mode |
| `;` | Insert ; |
| `Esc` | Go back to normal mode |

{% include image.html name="AddSemicolon.gif" caption="Add a missing semicolon to a line with Vim" alt="Add a missing semicolon to a line with Vim" width="600px" %}

### How to copy and paste in Vim

A common task while programming and editing text in general is to copy and paste. Vim can copy and paste too. Well, how do we copy and paste with Vim? Vim calls these actions **yank** and **put**.

To copy, enter visual mode, select some text and press `y`. Then move to the desired place and press `p`. Vim will put the _yanked_ text below the cursor position. You can copy an entire line with `yy`.

{% include image.html name="CopyPaste.gif" caption="Copy and paste a line with Vim" alt="Copy and paste a line with Vim" width="600px" %}

What about cut and paste? Vim **deletes** and **puts**. To cut and paste, instead of pressing `y` to copy, you need to use `d` to delete. Then, `p` to put the cut text in the desired location. Similarly, to delete an entire line, you need `dd`.

Besides `y` and `d`, you can change some text with `c`. It will remove the selected text and enter insert mode.

### Text objects

You can use `y`, `d` and `c` to edit text inside parenthesis `(`, braces `{`, brackets `[`, quotes `'"` and tags `<>`. These patterns of text are called text objects.

Text objects are useful to edit text inside or around some programming constructs. Parameter list, elements of an array, an string, a method body and everything inside an HTML tag.

That's why to change a parameter list, you can use `ci(` to change everything inside ().

## How to start using Vim?

Once you are comfortable editing and moving around your files with Vim, you can use it inside your IDE. You can start using Vim inside Visual Studio installing [VsVim](https://marketplace.visualstudio.com/items?itemName=JaredParMSFT.VsVim) extension and inside Visual Studio Code with [VSCodeVim](https://github.com/VSCodeVim/Vim).

Make sure to have a cheatsheet next to you. So you can look up commands if you get stuck. Don't try to learn all the commands at once. Learn one or two commands at a time and practice them.

## Conclusion

Voilà! Now you know how to exit Vim, to switch between modes and move around a file. That's what you need to get started with Vim.

There are more things to cover, like searching and replacing, undoing and redoing, and using tabs, among other features. It's true that Vim has a step learning curve. Give it a try! You might find yourself Viming the next time.

> _This post was originally published on [exceptionnotfound.net](https://exceptionnotfound.net/learning-vim-for-fun-and-profit/) as part of the Guest Writer Program. I'd like to thank Matthew for editing this post._

If you want to boost your productivity with Visual Studio, check my [Visual Studio Setup]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}) to see the theme, settings and extensions I use.
 
_Happy Vim time!_