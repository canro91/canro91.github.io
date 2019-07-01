---
layout: post
title: My Visual Studio Setup, sharpening the axe
description: VisualStudio 2019 is out. These are my settings, layout and extensions
---

VisualStudio 2019 is out! Either you installed it from scratch or you updated from a previous version, it's time to sharpen your axe! Or maybe, you came back from your vacations and the IT decided to uninstall previous versions of VS, leaving the new one without your customization. This is a true story, and it happened to a friend of a friend of mine.

This VS setup is heavily inspired by [De-Cruft Visual Studio](	https://jackmott.github.io/programming/tools/editor/ide/visual/studio/2016/07/11/decruft-visual-studio.html). It aims to leave more space to the text editor. Here it is:

* Color theme: Dark
* Text Editor theme: Solarized Dark
* Font: FiraCode 14pt
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
		* C# Interactive: A C# REPL, so you don't have to create a Console project to try things out
* Settings:
	* Disable **CodeLens**: Only activate **Show Test Status** and **C# References**
	* Enable **Line numbers**
	* Hide **Navigation Bar** and **Code Outlining**
	* Unselect **Selection and Indicator** margins
* Plugins
	* ~~HideMainMenu/HideTitleBar~~ Not available in VS2019 yet
	* [VSVim](https://github.com/jaredpar/VsVim) It enables Vim keybindings in the text editor
	* [Productivity Power Tools](https://marketplace.visualstudio.com/items?itemName=VisualStudioProductTeam.ProductivityPowerTools)
		* Editor Guidelines: _Add a Solarized Magenta guideline at column 80_
		* Fixed Mixed Tabs
		* Custom Document Well
		* Match Margin
	* [VSColorOutput](https://github.com/mike-ward/VSColorOutput) It gives you a fancy Output tab
	* [SaveAllTheTime](https://github.com/pragmatrix/SaveAllTheTime) No more `Ctrl + S`. It saves automatically modified files. Why this feature isn't included in VS out-of-the-box? It's already present in VisualStudioCode!
	* [SolutionColor](https://marketplace.visualstudio.com/items?itemName=Wumpf.SolutionColor) It colors the solution bar per project. No more editing production code without noticing it. _Use Solarized theme, too. Red for Beta and Magenta for Production_
	* [LocateInTFS](https://marketplace.visualstudio.com/items?itemName=AlexPendleton.LocateinTFS2017) It finds the location of the selected file in the Source Control Explorer
	* [AddNewFile](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.AddNewFile) It adds  new files directly from the Solution Explorer 
	* [SemanticColorizer](https://github.com/hicknhack-software/semantic-colorizer) It colors fields, classes, methods and more. _Make extension methods italics, only_
	* [NUnit 3 Test Adapter](https://marketplace.visualstudio.com/items?itemName=NUnitDevelopers.NUnit3TestAdapter). A must-have

 Voilà!