---
layout: post
title: My Visual Studio 2019 setup (theme, settings, extensions)
description: Visual Studio 2019 is out. These are my settings, layout and extensions
tags: productivity visualstudio
---

Visual Studio 2019 is out! Either you installed it from scratch or you updated from a previous version, it's time to sharpen your axe! Or maybe, you came back from your vacations and the IT team decided to uninstall previous versions of Visual Studio, leaving the new one without any of your customizations. _This is a true story, it happened to a friend of a friend of mine._

My Visual Studio setup is heavily inspired by [De-Cruft Visual Studio](https://jackmott.github.io/programming/tools/editor/ide/visual/studio/2016/07/11/decruft-visual-studio.html). It aims to leave more space to the text editor. Here are the settings and extensions I use:

## Settings

* Color theme: Dark
* Text Editor theme: [Solarized](https://ethanschoonover.com/solarized/) Dark
* Font: [FiraCode](https://github.com/tonsky/FiraCode) 14pt
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
* Settings:
	* Disable **CodeLens**: Only activate **Show Test Status** and **C# References**
	* Enable **Line numbers**
	* Hide **Navigation Bar** and **Code Outlining**
	* Unselect **Selection and Indicator** margins
	* Unselect **Ctrl + click** to go to definition
	* Unselect **Compress blank lines** and **Compress lines that do not have any alphanumeric characters** after you install "Productivity Power Tools" extension
	* Use **Handle all with Visual Studio** after you install "VSVim" extension
* Shortcuts
	* `Ctrl+Shift+w`: Close all documents

{% include image.html name="VSSetup.PNG" caption="My Visual Studio opened with a sample Console project" alt="My Visual Studio 2019 setup" width="800px" %}

## Extensions

* ~~HideMainMenu/HideTitleBar~~ Not available in VS2019 yet
* [VSVim](https://github.com/jaredpar/VsVim) It enables [Vim](https://www.vim.org/) keybindings in the text editor
* [Productivity Power Tools](https://marketplace.visualstudio.com/items?itemName=VisualStudioProductTeam.ProductivityPowerTools)
	* Editor Guidelines: _Add a Solarized Magenta guideline at column 80_
	* Fixed Mixed Tabs
	* Custom Document Well
	* Match Margin
* [VSColorOutput](https://github.com/mike-ward/VSColorOutput) It gives you a fancy Output tab
* [SaveAllTheTime](https://github.com/pragmatrix/SaveAllTheTime) No more `Ctrl + S`. It saves automatically all modified files. Why this feature isn't included in Visual Studio out-of-the-box? It's already present in Visual Studio Code!
* [SolutionColor](https://marketplace.visualstudio.com/items?itemName=Wumpf.SolutionColor) It colors the solution bar per project. No more editing production code without noticing it. _Use Solarized theme, too. Red for Beta and Magenta for Production_
* [LocateInTFS](https://marketplace.visualstudio.com/items?itemName=AlexPendleton.LocateinTFS2017) It finds the location of the selected file in the Source Control Explorer tab
* [AddNewFile](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.AddNewFile) It adds new files directly from the Solution Explorer.  Forget about `Right Click -> Add -> New Folder`, to then add the file you want. You can create folders and files in a single operation. You only need to hit `Shift + F2` and type the path and name of your new file.
* [SemanticColorizer](https://github.com/hicknhack-software/semantic-colorizer) It colors fields, classes, methods and more. _Make extension methods italics, only_
* [NUnit 3 Test Adapter](https://marketplace.visualstudio.com/items?itemName=NUnitDevelopers.NUnit3TestAdapter). A must-have
* [MappingGenerator](https://marketplace.visualstudio.com/items?itemName=54748ff9-45fc-43c2-8ec5-cf7912bc3b84.mappinggenerator) It creates mappings from one object to another and from a list of parameters to an object. You need to initialize an object with sample values? In your tests for example? MappingGenerator does it for you!
* [CodeMaid](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid) It cleans and formats your files. It remove extra blank lines. It removes and sorts your using statements. It removes extra spaces before and after parenthesis. _You got the idea_.
* [AsyncMethodNameFixer](https://github.com/priyanshu92/AsyncMethodNameFixer) To not to forget to add the `Async` suffix on async method name.
* [Multiline Search and Replace](https://marketplace.visualstudio.com/items?itemName=PeterMacej.MultilineSearchandReplace) No need to copy and paste your code into Notepad++ to replace multiple lines.
* [Line Endings Unifier](https://marketplace.visualstudio.com/items?itemName=JakubBielawa.LineEndingsUnifier) Yes, it unifies the line endings of your files. You can choose the line ending you want to use in your files. Depending on the number of files in your soulution, it could take a couple of seconds. But it does its job!

 Voilà! That's how I use Visual Studio 2019 for C# coding.
