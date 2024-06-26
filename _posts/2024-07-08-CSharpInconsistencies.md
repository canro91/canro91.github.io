---
layout: post
title: "What I Don't Like About C# Evolution: Inconsistency"
tags: csharp
cover: Cover.png
cover-alt: "Dashboard of tools" 
---

C# isn't just Java anymore.

That might have been true for the early days of C#. But the two languages took different paths.

People making that joke have missed at least the last ten years of C# history.

C# is open source and in constant evolution. In fact, you can upvote and discuss feature proposals in the [C# official GitHub repo](https://github.com/dotnet/csharplang).

Every .NET release comes with new C# features.

But I've stopped obsessing over new C# features. In fact, I stopped collecting [my favorite C# features by version]({% post_url 2021-09-13-TopNewCSharpFeatures %}). I feel I'm not missing much.

C# is not a consistent language anymore.

We now have many alternatives for the same task. Don't believe me?

## Objects, Arrays, and Null

First, here's how to create a new object,

```csharp
Movie m = new Movie("Titanic");
var m = new Movie("Titanic");
Movie m = new("Titanic");
//        ^^^^
```

The last one is the target-typed "new" expressions introduced in C# 9.0. That's one of the features I disable in a `.editorconfig` file.

Second, here's how to declare and initialize an array,

```csharp
Movie[] movies = new Movie[] { new Movie("Titanic") };

var movies = new Movie[] { new Movie("Titanic") };
var movies = new Movie[] { new("Titanic") };
//                         ^^^^^

var movies = new[] { new Movie("Titanic") };
//           ^^^^^

Movie[] movies = [ new Movie("Titanic") ];
Movie[] movies = [ new("Titanic") ];
//              ^^^
```

We combine "new" expressions and collection expressions introduced in C# 12.

And, lastly, here's [how to check if an object is not null]({% post_url 2023-02-20-WhatNullReferenceExceptionIs %}),

```csharp
var titanic = new Movie("Titanic")

titanic != null;
titanic is not null;
titanic is {};
titanic is object;
```

And I don't want to touch on primary constructors. It's like classes got jealous of records and started crying for a similar feature, like a baby boy jealous of his brother.

Voilà! That's what I don't like about C#. Don't take me wrong, C# is a great language with excellent tooling. But my favorite features are quite old: [LINQ]({% post_url 2021-01-18-LinqGuide %}), async/await, and extension methods.

Some new features have lowered the barrier to entry. Now a "Hello, world" is a single line of code: `Console.WriteLine("Hello, world!");`.

Other C# features are making the language inconsistent and easier to write but not easier to read.

For more C# content, read [my C# Definitive Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}), [how to avoid exceptions when working with Dictionaries]({% post_url 2020-08-01-AnotherTwoCSharpIdiomsPart3 %}), and [Six helpful extension methods to work with Collections]({% post_url 2022-12-16-HelperMethodsOnCollections %}).

_Happy coding!_
