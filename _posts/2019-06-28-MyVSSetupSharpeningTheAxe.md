---
layout: post
title: Visual Studio 2019 setup for C# (theme, settings, extensions)
description: Visual Studio 2019 is out. These are my settings, layout and extensions
tags: productivity visualstudio
---

Visual Studio is the de facto IDE for C#. You will spend countless hours inside Visual Studio. You are better off spending some time to customize it to boost your productivity.

My Visual Studio setup is heavily inspired by [De-Cruft Visual Studio](https://jackmott.github.io/programming/tools/editor/ide/visual/studio/2016/07/11/decruft-visual-studio.html). It aims to leave more space to the text editor by removing unneeded menus and bars.

These are the theme, settings and extensions I use to be more productive with Visual Studio.

## Theme and Layout

* Color theme: Dark
* Text Editor theme: [Solarized Dark](https://ethanschoonover.com/solarized/)
* Font: [FiraCode](https://github.com/tonsky/FiraCode) 14pt
* Zoom: 110%
* Windows:
	* Left
		* Test Explorer
		* Source Control Explorer
	* Right
		* Properties
		* Solution Explorer
		* Git Changes
		* Team Explorer
	* Bottom
		* Output
		* Error List
		* C# Interactive: A [C# REPL](https://dzone.com/articles/c-interactive-in-visual-studio), so you don't have to create a Console project to try things out

{% include image.html name="VSSetup.PNG" caption="My Visual Studio opened with a sample Console project" alt="My Visual Studio 2019 setup" width="500px" %}

## Settings

To change your Visual Studio settings, go to "Tools" menu and then to "Options".

On the left pane, you will find Visual Studio settings groupped by features, languages and extensions.

In "Text Editor", unselect **Enable mouse click to perform Go to Definition**, **Selection Margin** and **Indicator margin**.

{% include image.html name="ControlClick.png" caption="Text Editor - General settings" alt="Visual Studio Text Editor settings" width="500px" %}

Next, uncheck **Disable CodeLens**. Only activate **Show Test Status** and **Show C# References**.

{% include image.html name="CodeLens.png" caption="Text Editor - All Languages - CodeLens settings" alt="Visual Studio CodeLens settings" width="500px" %}

Next, in C# specific settings, enable **Line numbers**. And, hide **Navigation Bar** and **Code Outlining**.

{% include image.html name="LineNumbers.png" caption="C# - General settings" alt="Visual Studio C# settings" width="500px" %}

Go down to Advanced settings to **Add missing using directives on paste**. Yeap, Visual Studio can add missing using staments when you paste some code. That's a time saver!

{% include image.html name="Advanced.png" caption="C# - Advanced settings" alt="Visual Studio C# - Advanced settings" width="500px" %}

After installing "Productivity Power Tools" extension, unselect **Compress blank lines** and **Compress lines that do not have any alphanumeric characters**. Code looks weird compressed.
 
{% include image.html name="ProductivityPowerTools.png" caption="Productivity Power Tools settings" alt="Visual  Studio Productivity Power Tools settings" width="500px" %}

Speaking of extensions, after installing "VSVim" extension, use **Handle all with Visual Studio**. This way, we have the best of both worlds. And, we still have `Control + C` and `Control + V`.

{% include image.html name="VsVim.png" caption="VsVim settings" alt="Visual  Studio VsVim settings" width="500px" %}

For shortcuts, add `Ctrl+Shift+w` to easily close all documents from the keyboard.

## Extensions

* [VSVim](https://github.com/jaredpar/VsVim) It enables Vim keybindings in the text editor
* [Productivity Power Tools](https://marketplace.visualstudio.com/items?itemName=VisualStudioPlatformTeam.ProductivityPowerPack2017)
	* Editor Guidelines: **Add a Solarized Magenta guideline at column 120**
	* Fixed Mixed Tabs
	* Custom Document Well
	* Match Margin
* [VSColorOutput](https://github.com/mike-ward/VSColorOutput) It gives you a fancier Output tab with colors
* [SaveAllTheTime](https://github.com/pragmatrix/SaveAllTheTime) No more `Ctrl + S`. It saves automatically all modified files. Why this feature isn't included in Visual Studio out-of-the-box? It's already present in Visual Studio Code!
* [SolutionColor](https://marketplace.visualstudio.com/items?itemName=Wumpf.SolutionColor) It colors the solution bar per project. No more editing production code without noticing it. **Use Solarized theme, too. Red for Beta and Magenta for Production**
* [LocateInTFS](https://marketplace.visualstudio.com/items?itemName=AlexPendleton.LocateinTFS2017) It finds the location of the selected file in the Source Control Explorer tab
* [AddNewFile](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.AddNewFile) It adds new files directly from the Solution Explorer.  Forget about `Right Click -> Add -> New Folder`, to then add the file you want. You can create folders and files in from a single pop-up window. You only need to hit `Shift + F2` and type the path, name and extension of your new file.
* [SemanticColorizer](https://github.com/hicknhack-software/semantic-colorizer) It colors fields, classes, methods and more. **Make extension methods italics, only**
* [NUnit 3 Test Adapter](https://marketplace.visualstudio.com/items?itemName=NUnitDevelopers.NUnit3TestAdapter). A must-have
* [MappingGenerator](https://marketplace.visualstudio.com/items?itemName=54748ff9-45fc-43c2-8ec5-cf7912bc3b84.mappinggenerator) It creates mappings from one object to another and from a list of parameters to an object. You need to initialize an object with sample values? In your tests for example? MappingGenerator does it for you!
* [CodeMaid](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid) It cleans and formats your files. It remove extra blank lines. It removes and sorts your using statements. It removes extra spaces before and after parenthesis. You got the idea!.
* [AsyncMethodNameFixer](https://github.com/priyanshu92/AsyncMethodNameFixer) To not to forget to add the `Async` suffix on async method names.
* [Multiline Search and Replace](https://marketplace.visualstudio.com/items?itemName=PeterMacej.MultilineSearchandReplace) No need to copy and paste your code into Notepad++ to replace multiple lines at once.
* [Line Endings Unifier](https://marketplace.visualstudio.com/items?itemName=JakubBielawa.LineEndingsUnifier) Yes, it unifies the line endings of your files. You can choose the line ending you want to use in your files. Depending on the number of files in your solution, it could take a couple of seconds. But it does its job!
* [Moq.Autocomplete](https://github.com/Litee/moq.autocomplete) If you use [Moq to create fakes]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}), this extension is for you. Inside the `Setup()` methods, it autocompletes the parameter list of the faked method using `It.IsAny<T>()` for each parameter. A time saver! I use this extension along with these [snippets for Moq]({% post_url 2021-02-22-VisualStudioMoqSnippets %}).

## Presentation mode

Fire a new instance from Visual Studio Developers Tools command prompt, using

```bash
devenv /RootSuffix Demo
```

It will open a separate and clean instance with no configurations or extensions. Any changes made to this instance won't affect the "normal" instance next time you open Visual Studio.

{% include image.html name="VSPresentationMode.png" caption="My Visual Studio in Presentation mode opened with a sample Console project" alt="My Visual Studio 2019 setup in Presentation Mode" width="500px" %}

To make Visual Studio work in Presentation mode:

* Remove Navigation Outline, Server Explorer, Toolbox, Git changes, and Properties. Only keep Solution Explorer.
* Use Cascadia Mono, 14pt.
* Optionally install the [MarkdownEditor extension](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.MarkdownEditor) to present using markdown files.

Voilà! That's how I use Visual Studio 2019 for C# coding. If you're wondering what's Vim and why you should learn it, check my post [Learning Vim for Fun and Profit]({% post_url 2020-09-14-LearnVimForFunAndProfit %}).

For more productivity tools and tricks, check these [programs that saved me 100 hours]({% post_url 2020-04-13-ProgramThatSave100Hours %}) and how I used a Visual Studio extension and a Git feature to [get rid of two recurrent review comments]({% post_url 2020-09-02-TwoRecurringReviewComments %}).

_Happy coding!_
