---
layout: post
title: The C# Definitive Guide
description: A very opinionated guide to C# for beginners and intermediate developers
---

Hello, if you are a beginner programmer or you just took a programming course at school, and you want to find a pathway to be _"fluent"_ in C#, this is the right place for you!

## Environment
	
> _Give me six hours to chop down a tree and I will spend the first four sharpening the axe._ Abraham Lincon

Visual Studio is the de-facto IDE for C#. Although, Visual Studio Code has gained a lot attention recently. Since you will spend most of your workdays with Visual Studio, you should sharpen your tools.

* Find a colorscheme you like, [Solarized](https://ethanschoonover.com/solarized/)
* Learn the basic shortcuts
	* `Ctrl + Shift + b`: Build your solution
	* `Ctrl + ,`: Navigate to any method in your solution
	* `Ctrl + .`: Apply a refactor or any action in the current code block
	* `Ctrl + q`: Search and execute settings or menus of Visual Studio
* Install some plugins to make your life easier
	* [Productivity Power Tools](https://marketplace.visualstudio.com/items?itemName=VisualStudioPlatformTeam.ProductivityPowerTools)
	* [Auto Save](https://github.com/anaisbetts/SaveAllTheTime/issues), no more `Ctrl + S`
	* [AddNewFile](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.AddNewFile), `Alt + F2` to add a bunch of files in with a single shortcut
	* [VsVim](https://marketplace.visualstudio.com/items?itemName=JaredParMSFT.VsVim), if you are fan of Vim. You don't know Vim? C'mmon!
	* [Wumpf Solution Color](https://marketplace.visualstudio.com/items?itemName=Wumpf.SolutionColor), you don't want to mess with your production codebase. You can change your Visual Studio menu bar color based on your folder solution.
	* [VS Color Output](https://marketplace.visualstudio.com/items?itemName=MikeWard-AnnArbor.VSColorOutput)
* C# Interactive. You don't have to create a dummy Console project just to try things out. With C# interactive, you have a [C# REPL](https://dzone.com/articles/c-interactive-in-visual-studio) at your disposition. You can load a dll of your own or from a Nuget package, load a C# script (.csx file) or simply try a few lines of C#. From Visual Studio, head to View Menu, Other Windows and click C# Interactive.

## Git and Github

### Git

Git is a version control system. A time machine to go back in time, create alternate stories from a point in time and make alternate stories join your present. You got the analogy?. So if you are creating a zip file with your code and named it after the date of your latest change, Git is a better way.

* Install [Git](https://git-scm.com/downloads) locally
* Learn the basic commands: `init`, `add`, `status`, `commit`, `push`
* Use Git inside of your IDE. You use an IDE, right?
* [Udacity Git course](https://www.udacity.com/course/version-control-with-git--ud123)

### Github

Programming is about collaboration. Github is the programmers social network to show your own code, ask for features in a library, report bugs in the software you use, read and make questions about someone else's code. Microsoft, Facebook, Google have some of their own code available on Github.

* [Udacity Github course](https://www.udacity.com/course/how-to-use-git-and-github--ud775)

## Design Patterns and OOP Principles

Desing patterns are recipes to solve common problems in code. This is, given a certain problem, there is a blueprint or an outline that will help you to solve that problem.

* Recognize some of the most common patterns and learn to use them. For example: Factory, Builder, Composite, Command, Template, Strategy, Null Object, Adapter.
* Learn Uncle Bob's SOLID principles

## Dealing with large codebases

Programming is also about [reading code](https://changelog.com/posts/one-sure-fire-way-to-improve-your-coding). So you should get used to navigate throught large codebases.

* Find a library or a tool you have already used or you find useful. For example, [DateTimeExtensions](https://github.com/joaomatossilva/DateTimeExtensions), [ByteSize](https://github.com/omar/ByteSize), [Insight Database](https://github.com/jonwagner/Insight.Database)
* Where are the unit tests? Do they follow a folder structure? Identify a naming convention for them
* Does the project follow certain code convention? For example: are braces written on the same line?
* Grab a copy and compile it yourself
* Debug a test case scenario for a feature you would like to know about
* Find out how a feature was implemented

## Unit tests

An unit test is a "safety net" to make sure you don't break things when you add new features or modify your code base. An unit test is a piece of code that uses your code base from a "user" point of view and verifies a given behaviour.

* Learn a test naming convention. For example, [Roy Osherove's convention](http://osherove.com/blog/2005/4/3/naming-standards-for-unit-tests.html)
* Learn what unit test really means [Unit Test - Definition](http://artofunittesting.com/definition-of-a-unit-test/)
* Watch [Understand Test Driven Development](https://www.youtube.com/watch?v=q5Xd1tmIgec)
* Write some unit tests for some parts of your codebase or practice writing unit tests for a library you know
* Read Roy Osherove's _The Art of Unit Testing_. [Four takeaways]({% post_url 2020-03-06-TheArtOfUnitTetsReview %})

## Linq

Language-Integrated Query, Linq, is the declarative way for C# to operate with or "query" collections or anything that looks like one. Instead of writing the looping and the business logic with `foreach`, `for` or `while`, you should try to do it with Linq.

**Example**: Given a string of emails separated by commas, create an array with the trimmed emails

```csharp
string emails = "email1@yourdomain.com,    email2@yourdomain.com,email2@yourdomain.com";
string[] trimmed = emails.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                         .Select(t => t.Trim())
                         .ToArray();

```

* Learn the most frequently used methods: `Where`, `Select`, `FirstOrDefault`, `Any`, `GroupBy`, `Distinct`.
* Learn about lambda expressions. `Predicate`, `Action` and `Func`. [What the Func, Action?]({% post_url 2019-03-22-WhatTheFuncAction %})

## Regular Expressions

Have you ever used `*.txt` in the file explorer to find all text files in a folder? You have already used a regular expression. But, `*.txt` is just the tip of the iceberg. Regular expressions give you a search syntax to find patterns of text in a string. For example, find all phone numbers like this one `(+57) 3XX XXX-XXX`, you could use `(\(\+\d{2}\))\s(\d{3})\s(\d{3})\-(\d{3})`. 

* Learn the basics 
	* Character sets: `[]` and `[^]`
	* Shorthand: `\d` for digits, `\w` for alphanumeric chars, `\s` for whitespace.
	* Repetions: `*`, `?`, `{min,max}`
	* Any character: the dot `.`
	* Escape reserved characters: `^$()[]\|-.*+`
	* Groups
* Learn how to match and replace a regex in C#. Take a look at `Match`, `IsMatch`, `Replace` methods in `Regex` class. 
* Learn how to acess named groups in C#
* Read [Regular expressions Quickstart](https://www.regular-expressions.info/quickstart.html)


## async/await

Asyncronous code is code that doesn't block when executing long-running operations.

* Learn the flow of control of a method marked with `async` and `await`. The flow of execution is return to the caller method in the `await` statement and the rest of the method is executed later in a context. Read [async and await](http://blog.stephencleary.com/2012/02/async-and-await.html)
* Learn to await your code all-the-way-down to avoid deadlocks. Read [Don't block on async code](http://blog.stephencleary.com/2012/07/dont-block-on-async-code.html)
* Avoid `async void` methods, use `async Task` instead
* Learn how to use `Task.WhenAny` and `Task.WhenAll`
* [The Ultimate Guide to Asynchronous Programming in C# and ASP.NET](https://exceptionnotfound.net/asynchronous-programming-in-asp-net-csharp-ultimate-guide/)

## Some new features in C# since version 6

These are one of the new features in C# since version 6.0 you can use more often. All the new features are available [here](https://docs.microsoft.com/en-us/dotnet/csharp/whats-new/)

* Before `string.Format("Hello, {0}", name)`, after `$"Hello, {name}"`

* Before `int count = 0; int.TryParse(readFromKey, out count)`, after `int.TryParse(readFromKey, out var count)`

* Before,

```csharp
string name = ReadNameFromSomewhere();
if (name == null)
    name = "none";
else
    name.Trim();
```

After,

```csharp
string name = ReadNameFromSomewhere();
name?.Trim() ?? "none"
```

* Now, one-line functions are truly one liners, `public int OneLineFunction() => 0;`

* Before,

```csharp
Tuple<string, string> Greet() { }
var greeting = Greet()
var name = greeting.Item1;
```

After,

```csharp
(string Salutation, string Name) Greet() { }
var greeting = Greet()
greeting.Name
```

* Now, `async` Main method in Console apps is available

```csharp
public static async Task Main(string[] args)
{
    await DoSomethingAsync();
}
```

* Static imports

```csharp
import static System.Console;

static void Main()
{
    WriteLine("Hello, world!");
}
```

* `nameof` operator

```csharp
public void Method(string param1)
{
    if (string.IsNullOrEmpty(param1))
        throw new ArgumentNullException(nameof(param1));
}
```

## Bonus Points

* Learn how to type with all your fingers
* Learn some Vim. Take a look at _Practical Vim_
* Learn about C# [extensions methods](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/extension-methods)
* Read _The Art of Readable Code_ or _Clean Code_ books. [A review and takeaways]({% post_url 2020-01-06-CleanCodeReview %})
