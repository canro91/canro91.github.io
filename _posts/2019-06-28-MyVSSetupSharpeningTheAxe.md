---
layout: post
title: My Visual Studio Setup, sharpening the axe
description: Visual Studio 2019 is out. These are my settings, layout and extensions
tags: productivity visualstudio
---

Visual Studio 2019 is out! Either you installed it from scratch or you updated from a previous version, it's time to sharpen your axe! Or maybe, you came back from your vacations and the IT team decided to uninstall previous versions of Visual Studio, leaving the new one without any of your customizations. _This is a true story, it happened to a friend of a friend of mine._

This Visual Studio setup is heavily inspired by [De-Cruft Visual Studio](	https://jackmott.github.io/programming/tools/editor/ide/visual/studio/2016/07/11/decruft-visual-studio.html). It aims to leave more space to the text editor. Here it is:

* Color theme: Dark
* Text Editor theme: [Solarized](https://ethanschoonover.com/solarized/) Dark
* Font: [FiraCode](https://github.com/tonsky/FiraCode) 14pt
* Windows:
	* Left
		* Source Control Explorer
		* Test Explorer
	* Right
		* Team Explorer
		* Properties
		* Solution Explorer
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
* Shortcuts
	* 	`Ctrl+Shift+w`: Close all documents
* Plugins
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
	* [AddNewFile](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.AddNewFile) It adds new files directly from the Solution Explorer.  Forget about `Right Click -> Add -> New Folder`, to then add the file you want. You can create folders and files in a single operation. You only need to hit `Shift + F2` and type the path of your new file.
	* [SemanticColorizer](https://github.com/hicknhack-software/semantic-colorizer) It colors fields, classes, methods and more. _Make extension methods italics, only_
	* [NUnit 3 Test Adapter](https://marketplace.visualstudio.com/items?itemName=NUnitDevelopers.NUnit3TestAdapter). A must-have
	* [MappingGenerator](https://marketplace.visualstudio.com/items?itemName=54748ff9-45fc-43c2-8ec5-cf7912bc3b84.mappinggenerator) It creates mappings from one object to another and from a list of parameters to an object. You need to initialize an object with sample values? In your tests for example? It does it for you!

 Voilà!