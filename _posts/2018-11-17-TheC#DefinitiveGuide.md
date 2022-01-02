---
layout: post
title: The C# Definitive Guide
description: A very opinionated guide to C# for beginners and intermediate developers
tags: tutorial csharp
cover: Cover.png
cover-alt: The C# Definitive Guide
---

Are you looking for a learning path to be "fluent" in C#? This is the right place for you! This is my definitive guide to what every beginner and intermediate C# developer should know.

**Every intermediate C# developer should know how to productively work with Visual Studio or Visual Studio Code, use async/await keywords, most common LINQ methods and regular expressions. Also, to get around large codebases and be aware of the latest C# features.**

## Environment

Visual Studio is the de-facto Integrated Development Environment (IDE) for C#. Since we will spend most of our workdays with Visual Studio, we should setup Visual Studio to make use more productive.

* Find a colorscheme you like. For example, I prefer [Solarized](https://ethanschoonover.com/solarized/)
* Learn the basic shortcuts:
	* `Ctrl + Shift + b`: Build your solution
	* `Ctrl + ,`: Navigate to any method in your solution
	* `Ctrl + .`: Apply a refactor or any action in the current code block
	* `Ctrl + q`: Search and execute settings or menus of Visual Studio
	* `Ctrl + Shift + F12`: Go to the next error
* Install some plugins to make your life easier.
	* [Productivity Power Tools](https://marketplace.visualstudio.com/items?itemName=VisualStudioPlatformTeam.ProductivityPowerTools)
	* [Auto Save](https://github.com/anaisbetts/SaveAllTheTime), no more `Ctrl + S`
	* [AddNewFile](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.AddNewFile), `Alt + F2` to add a bunch of files in with a single shortcut
	* [VsVim](https://marketplace.visualstudio.com/items?itemName=JaredParMSFT.VsVim), if you are fan of Vim. You don't know Vim? C'mmon!
	* [Wumpf Solution Color](https://marketplace.visualstudio.com/items?itemName=Wumpf.SolutionColor) changes the Visual Studio menu bar color based on a folder solution. Don't mess with the wrong environment code.
	* [VS Color Output](https://marketplace.visualstudio.com/items?itemName=MikeWard-AnnArbor.VSColorOutput) makes the Output tab colorful.
* C# Interactive. You don't have to create a dummy Console project just to try things out. With C# interactive, you have a C# REPL at your disposition. You can load a NuGet package or your own dll's, load a C# script (.csx file) or simply try a few lines of C# code. From Visual Studio, head to View Menu, Other Windows and click C# Interactive.

For more settings and extensions, check [my Visual Studio setup for C#]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}).

<figure>
<img src="https://images.unsplash.com/photo-1499750310107-5fef28a66643?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="The C# Definitive Guide" />

<figcaption>Have everything ready to level up your C#. <span>Photo by <a href="https://unsplash.com/@andrewtneel?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Andrew Neel</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## Git and Github

### Git

Git is a version control system. A time machine to go back in time, create alternate stories from a point in time and make alternate stories join your present. You got the analogy?

If you are creating a zip file with your code and naming it after the date of your latest change, Git is a better way.

* Install Git locally
* Learn the basic commands: `init`, `add`, `status`, `commit`, `push`
* Learn to use Git inside Visual Studio
* Check [Udacity Git course](https://www.udacity.com/course/version-control-with-git--ud123)
* Read my [beginner's guide to Git and GitHub]({% post_url 2020-05-29-HowToVersionControl %})

### GitHub

Programming is about collaboration. GitHub is the social network for programmers.

With GitHub, you can show your own code, ask for new features in a library, report bugs in the software you use, read and make questions about someone else's code.

Microsoft, Facebook, Google have some of their own code available on GitHub.

* Check [Udacity Github course](https://www.udacity.com/course/how-to-use-git-and-github--ud775)

## Design Patterns and Object-Oriented Design Principles

Desing patterns are recipes to solve common problems in code. This is, given a certain problem, there is a blueprint or an outline that will help you to solve that problem.

* Recognize some of the most common patterns and learn to use them. For example: Factory, Builder, Composite, Command, Template, Strategy, Null Object, Adapter.
* Check my take on the [Decorator]({% post_url 2021-02-10-DecoratorPattern %}) and [Pipeline]({% post_url 2020-02-14-PipelinePattern %}) patterns.
* Learn Uncle Bob's SOLID principles.

## Dealing with large codebases

Programming is also about reading code. Get used to navigate throught large codebases.

* Find a library or a tool you have already used or you find useful. For example, [DateTimeExtensions](https://github.com/joaomatossilva/DateTimeExtensions), [ByteSize](https://github.com/omar/ByteSize), [Insight.Database](https://github.com/jonwagner/Insight.Database)
* Where are the unit tests? Do they follow a folder structure? Identify a naming convention for them
* Does the project follow certain code convention? For example, are braces written on the same line?
* Grab a copy and compile it yourself
* Debug a test case scenario for a feature you would like to know about
* Find out how a feature was implemented

For more guidelines about reading code, check [Changelog One sure-fire way to improve your coding](https://changelog.com/posts/one-sure-fire-way-to-improve-your-coding).

## Unit tests

A unit test is a "safety net" to make sure you don't break things when you add new features or modify your codebase. A unit test is a piece of code that uses your code base from a "user" point of view and verifies a given behavior.

* Read my [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}) to get started writing unit tests with C# and MSTest
* Learn what unit test really means. Read [Roy Osherove Unit Test Definition](http://artofunittesting.com/definition-of-a-unit-test/)
* Learn a test naming convention. I compiled a post with [four test naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %})
* Watch [Understand Test Driven Development](https://www.youtube.com/watch?v=q5Xd1tmIgec)
* Write some unit tests for some parts of your codebase or practice writing unit tests for a library you know
* Read my takeaways from [The Art of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %})

## LINQ

Language-Integrated Query, LINQ, is the declarative way to work with collections in C# or anything that looks like one. Instead of writing the looping and the business logic with `foreach`, `for` or `while`, you should try to do it with LINQ.

For example, given a string of emails separated by commas, the next lines show how to create an array with the trimmed emails using LINQ.

```csharp
string emails = "email1@yourdomain.com,    email2@yourdomain.com,email2@yourdomain.com";
string[] trimmed = emails.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                         .Select(t => t.Trim())
                         .ToArray();

```

* Learn about lambda expressions. Read my take on the [difference between Func and Action]({% post_url 2019-03-22-WhatTheFuncAction %})
* Check my [quick guide to LINQ with examples]({% post_url 2021-01-18-LinqGuide %})
* Learn the most frequently used methods: `Where`, `Select`, `FirstOrDefault`, `Any`, and `GroupBy`.

## Regular Expressions

Have you ever used `*.txt` in the file explorer to find all text files in a folder? If so, you have already used a regular expression. But, `*.txt` is just the tip of the iceberg.

Regular expressions give you a search syntax to find patterns of text in a string. For example, find all phone numbers like this one `(+57) 3XX XXX-XXX`, you could use `(\(\+\d{2}\))\s(\d{3})\s(\d{3})\-(\d{3})`. 

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

* Learn the flow of control of a method marked with `async` and `await`. Read [Stephen Cleary async and await](http://blog.stephencleary.com/2012/02/async-and-await.html)
* Await your code all-the-way-down to avoid deadlocks. Read [Don't block on async code](http://blog.stephencleary.com/2012/07/dont-block-on-async-code.html)
* Avoid `async void` methods, use `async Task` instead
* Learn how to use `Task.WhenAny` and `Task.WhenAll`
* Read [The Ultimate Guide to Asynchronous Programming in C# and ASP.NET](https://exceptionnotfound.net/asynchronous-programming-in-asp-net-csharp-ultimate-guide/)

## Some new features in C# since version 6

C# is an evolving language. With every new version, we have more features to write more concise code. These are some of the new features in C# we use more often.

### C# 6.0

#### String interpolation

Before we wrote,

```csharp
string.Format("Hello, {0}", name);
```

Now we can write,

```csharp
$"Hello, {name}";
```

#### Null-conditional operators

There are two new operators to check for null values: `??` and `?.`.

Before,

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

### C# 7.X

#### Inlined out variables

Now, we can inline the variable declaration next to the `out` keyword.

Before,

```sql
int count = 0;
int.TryParse(readFromKey, out count);
```

After,

```csharp
int.TryParse(readFromKey, out var count)
```

Or even,

```csharp
int.TryParse(readFromKey, out _)
```

#### Reference Tuple Members by Name

We can access values inside tuples by name, instead of `Item1` or `Item2`.

Before,

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

### C# 8.0

#### Null-coalescing assignment

Now, there is the operator `??=` to only assign a variable if its value isn't null.

Before,

```csharp
int? magicNumber = null;

if (magicNumber == null)
    magicNumber = 7;
```

After,

```csharp
int? magicNumber = null;

magicNumber ??= 7;
```

#### Using declarations

A variable preceded by `using` is disposed at the end of the scope.

Before,

```csharp
using (var reader = new StreamReader(fileName))
{
    string line; 
    while ((line = reader.ReadLine()) != null)  
    {  
        // Do something  
    }  
}
```

After,

```csharp
using var reader = new StreamReader(fileName);

string line; 
while ((line = reader.ReadLine()) != null)  
{  
    // Do something  
}
```

#### Nullable reference types

All reference variables are non-nullable by default. Any attempt to dereference a nullable reference gets a warning from the compiler. _Goodbye, NullReferenceException!_. Be aware, you need to turn on this feature at the project level. Add `<Nullable>enable</Nullable>` inside the `PropertyGroup` in your csproj files.

Before,

```csharp
int notNull = null; // <- error CS0037: Cannot convert null to 'int'
int? canBeNull = null;

string name = null;
SayHi(name) // <- System.NullReferenceException

void SayHi(string name) => Console.WriteLine(name.Trim()); 
```

After,

```csharp
string name = null;
// ^^^^^
// warning CS8600: Converting null literal or possible null value to non-nullable type.

string? canBeNullName = null;
SayHi(name);
// ^^^^^
// warning CS8604: Possible null reference argument for parameter 'name'
```

### C# 9.0

#### Records

A record is an immutable reference type with built-in equality methods. When you create a record, the compiler creates a `ToString` method, a value-based equality methods and other methods for you. Records are helpful to replace value-objects in your code.

```csharp
public record Movie
{
    public string Title { get; }
    public int ReleaseYear { get; }
    
    public Movie(string title, int releaseYear) => (Title, ReleaseYear) = (title, releaseYear);
}
```

#### Top-level statements

All the boilerplate is now gone from `Main` methods.

Before,

```csharp
using System;

namespace HelloWorld
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!");
        }
    }
}
```

After,

```csharp
using System;

Console.WriteLine("Hello World!");
```

To learn about other C# features, check my [top 10 or so best C# features]({% post_url 2021-09-13-TopNewCSharpFeatures%}).

## Bonus Points

* Learn how to type with all your fingers. _At least you will impress people_.
* Learn some Vim. Read my post on [Learning Vim For Fun and Profit]({% post_url 2020-09-14-LearnVimForFunAndProfit %}). If you want to master every detail, take a look at the book "Practical Vim".
* Learn about C# [extensions methods](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/extension-methods). You will find them often.
* Read books on Clean Code. Check my takeaways for [The Art of Readable Code]({% post_url 2021-12-20-TheArtOfReadableCodeReview %}) and [Clean Code]({% post_url 2020-01-06-CleanCodeReview %}).

Voilà! That's my take on what every intermediate C# developer should know! Don't be overwhelm by the amount of things to learn. Don't try to learn everything at once, either. Learn one subject at a time! And, start using it in your every day coding as you learn it.

_Happy coding!_