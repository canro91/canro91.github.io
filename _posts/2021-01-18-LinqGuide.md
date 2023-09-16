---
layout: post
title: A quick guide to LINQ with examples
tags: tutorial csharp
description: All you need to know about LINQ in 15 minutes or less
cover: LinqGuide.png
cover-alt: A quick guide to LINQ with examples
---

Today a friend asked me about LINQ. I guess she was studying for a technical interview. So, dear Alice, this is what LINQ is, and these are the most common LINQ methods with examples. All you need to know about LINQ in 15 minutes or less.

**Language-Integrated Query (LINQ) is the declarative way of working with collections in C#. LINQ works with databases and XML files too. But, LINQ has an API syntax, using extensions methods on the IEnumerable type, and a query syntax, using a SQL-like syntax.**

## 1. LINQ is declarative

**LINQ is declarative.** It means we write our code stating the results we want instead of doing every step to get those results.

With LINQ, we write code to _"filter a collection based on a condition."_ Instead of writing code to _"grab an element, check if it satisfies a condition, then move to the next element, check again..."_, etc.

LINQ is a better alternative to query collections using `for`, `foreach`, or any other loop. With LINQ, we write more expressive and compact code.

<figure>
<img src="https://images.unsplash.com/photo-1524985069026-dd778a71c7b4?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=800" alt="Waiting at a cinema before a movie starts" />

<figcaption><span>Photo by <a href="https://unsplash.com/@ewitsoe?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Erik Witsoe</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## 2. Our first example: A Catalog of Movies

Let's start with the collection of movies we have watched. We have a `Movie` class with a name, release year, and rating. Let's find our favorite movies, the ones with a rating greater than 4.5.

This is a Console application that prints our favorite movies,

```csharp
// Feel free to use your own movies and
// see which ones are your favorite movies!
var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("Terminator 2", 1991, 4.7f),
    new Movie("Avatar", 2009, 5),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5)
};

var favorites = new List<Movie>();
foreach (var movie in movies)
// ^^^^
{
    if (movie.Rating > 4.5)
    //  ^^^^^
    {
        favorites.Add(movie);
    }
}

Console.WriteLine("My favorites:");
PrintMovies(favorites);

// Output:
//
//My favorites:
//The Fifth Element: [4.6]
//Terminator 2: [4.7]
//Avatar: [5]
//My Neighbor Totoro: [5]

Console.ReadKey();

static void PrintMovies(IEnumerable<Movie> movies)
{
    foreach (var movie in movies)
    {
        Console.WriteLine($"{movie.Name}: [{movie.Rating}]");
    }
}

record Movie(string Name, int ReleaseYear, float Rating);
```

Let's notice we wrote a `foreach` loop and an `if` statement to find movies with a rating greater than 4.5. No LINQ so far!

Also, we used Top-level statements, records and Global usings from [recent C# versions]({% post_url 2021-09-13-TopNewCSharpFeatures %}). That's why we didn't write the Main class and import the `System.Linq` namespace.

## 3. Our first LINQ method: Where

To work with LINQ, we need to be comfortable with delegates and lambda functions.

In a few words: a delegate is a pointer to a method. And a lambda function is a method with only the parameters and the body. C# has two built-in delegates: [Func and Action]({% post_url 2019-03-22-WhatTheFuncAction %}).

### How to filter a collection with LINQ?

Now, let's update our example to use LINQ. We want to filter our list of movies to keep only those with a rating greater than 4.5. The LINQ method to filter collections is `Where()`.

**The Where method returns a new collection with only the elements that meet a condition.**

Let's replace our `foreach` loop with the `Where()` method. And let's use the condition inside the `if` statement as the filter condition for `Where()`. Like this,

```csharp
var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("Terminator 2", 1991, 4.7f),
    new Movie("Avatar", 2009, 5),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5)
};

var favorites = movies.Where(movie => movie.Rating > 4.5);
//                     ^^^^^

Console.WriteLine("My favorites:");
PrintMovies(favorites);

// Output:
//
//My favorites:
//The Fifth Element: [4.6]
//Terminator 2: [4.7]
//Avatar: [5]
//My Neighbor Totoro: [5]

Console.ReadKey();

static void PrintMovies(IEnumerable<Movie> movies)
{
    foreach (var movie in movies)
    {
        Console.WriteLine($"{movie.Name}: [{movie.Rating}]");
    }
}

record Movie(string Name, int ReleaseYear, float Rating);
```

We replaced the `foreach` and `if` statements with a single line of code:

```csharp
var favorites = movies.Where(movie => movie.Rating > 4.5);
```

More compact, isn't it? Also, we turned the condition inside the `if` statement into a lambda function. This is why we need to be comfortable working with delegates.

Let's notice the `Where()` method returned a new collection. It didn't remove any elements from the original `movies` list.

**LINQ methods don't change the original collection. They return a result without modifying the original one.**

### Separate methods instead of lambda functions

Instead of lambda functions, we can use separate methods as the filtering condition with `Where()`.

To replace the lambda function from our previous example, let's create an `IsFavorite()` method that receives `Movie` as a parameter and returns `bool`. For example,

```csharp
private bool IsFavorite(Movie movie)
  => movie.Rating > 4.5;
```

Then, we can use `IsFavorite()` inside the `Where()` method to filter our movies. Like this,

```csharp
var favorites = movies.Where(movie => IsFavorite(movie));
```

Let's simplify things even further. Since `IsFavorite()` only has one parameter, we can remove the parameter name, like this,

```csharp
var favorites = movies.Where(IsFavorite);
```

Way more compact and readable than our original version with a `foreach` and `if`.

## 4. Most common LINQ methods

So far we have seen only one LINQ method: `Where()`. Let's see other frequently-used methods.

### 1. Select

**Select transforms a collection by applying a mapping function to every element.**

Let's find only the names of our favorite movies.

```csharp
var favorites = movies.Where(movie => movie.Rating > 4.5)
                      .Select(movie => movie.Name);

foreach (var name in favorites)
{
    Console.WriteLine(name);
}

// The Fifth Element
// Terminator 2
// Avatar
// My Neighbor Totoro
```

This time we wrote two nested LINQ methods. For every favorite movie, we only picked only its name. Here the "mapping" function was the delegate: `movie => movie.Name`.

For more readability, we often align the nested LINQ methods vertically by the (`.`) dot.

### 2. Any

**Any checks if a collection is empty or has at least one element matching a condition. It doesn't return a new collection, but either true or false.**

Let's see if we have watched movies with a low rating.

```csharp
var hasAnyMovies = movies.Any();
// true

var hasBadMovies = movies.Any(movie => movie.Rating < 2);
// false
```

### 3. All

**Unlike Any, All checks if every element inside a collection matches a condition. It also returns either true or false instead of a new collection.**

Let's see if we have only watched really-good movies.

```csharp
var weHaveSeenReallyGoodMovies = movies.All(movie => movie.Rating >= 4.5);
// false
```

### 4. GroupBy

**GroupBy groups the elements of a collection based on a key. It returns a collection of "groups"  or "buckets" organized by a key.**

Let's group our movies by rating.

```csharp
var groupedByRating = movies.GroupBy(movie => movie.Rating);

foreach (var group in groupedByRating)
{
    Console.WriteLine($"Rating: {group.Key}");

    foreach (var movie in group)
    {
        Console.WriteLine($"{movie.Name}");
    }
    Console.WriteLine();
}

// Output:
//Rating: 4.5
//Titanic

//Rating: 4.6
//The Fifth Element

//Rating: 4.7
//Terminator 2

//Rating: 5
//Avatar
//My Neighbor Totoro

//Rating: 4
//Platoon
```

Let's notice we grouped our list of movies using only one property: `Rating`. But, [GroupBy has other use-cases]({% post_url 2022-05-30-HowToUseLinqGroupBy %}): transforming each group and grouping by more than one property.

### 5. First and FirstOrDefault

**First and FirstOrDefault return the first element in a collection or the first one matching a condition. First throws an exception if the collection is empty or doesn't have matching elements. And FirstOrDefault returns the default value of the element type, instead.**

Let's find the oldest film we have watched.

```csharp
var oldest = movies.OrderBy(movie => movie.ReleaseYear)
                   .First();

// Platoon
```

Here we first used `OrderBy()` to sort the movie collection by release year and then picked the first one. Two examples for the price of one!

In the same spirit of `First()` and `FirstOrDefault()`, we have `Last()` and `LastOrDefault()`. They return the last element instead of the first one.

[.NET6 introduced new LINQ methods and oveloads]({% post_url 2022-06-27-NET6LinqMethods %}). `FirstOrDefault()` and similar `XOrDefault()` methods have a new overload to pass an optional default value. And, we have methods like `MinBy()` we can use to replace an `OrderBy()` followed by `First()`.

If we [peek into the source code of DistinctBy]({% post_url 2022-07-11-LinqDistinctBySourceCode %}), one of those new LINQ methods, we will see it's not that intimidating after all. 

## 5. Cheatsheet

There are more LINQ methods than the ones we've seen so far. These are some of them.

| Method | Function |
|---|---|
| `Where` | Filter a collection |
| `Select` | Transform every element of a collection | 
| `Any` | Check if a collection is empty |
| `All` | Check if every element satisfies a condition | 
| `Count` | Count all elements of a collection |
| `Distinct` | Find the unique elements of a collection |
| `GroupBy` | Group the elements of a collection based on a key | 
| `OrderBy` | Sort a collection based on a key  |
| `First` | Find the first element of a collection. Throw if the collection is empty | 
| `FirstOrDefault` | Same as `First` but it returns a default value if it's empty | 
| `Last` | Find the last element of a collection. Throw if the collection is empty |
| `LastOrDefault` | It returns a default value if it's empty, instead |
| `Single` | Find only one element in a collection matching a condition. Throw, otherwise |
| `SingleOrDefault` | It returns a default value if there isn't one matching element, instead |
| `Take` | Pick the first _n_ consecutive elements of a collection |
| `TakeWhile` | Pick the first consecutive elements that satisfy a condition |
| `Skip` | Return a collection without the first _n_ consecutive elements |
| `SkipWhile` | Return a collection without the first consecutive elements that satisfy a condition |
| `Sum` | Sum the elements of a collection |
| `Min`, `Max` | Find the smallest and largest element of a collection |
| `ToDictionary` | Convert a collection into a dictionary |

That isn't an exhaustive list. Of course, LINQ has more methods we don't use often, like [Aggregate]({% post_url 2022-07-25-LinqAggregateExplained %}) and [Intersect, Union, and Except]({% post_url 2022-08-22-IntersectUnionAndExcept %}). They're helpful from time to time.

<figure>
<img src="https://images.unsplash.com/photo-1523207911345-32501502db22?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=800" alt="Popcorn" />

<figcaption>Speaking of taste. <span>Photo by <a href="https://unsplash.com/@christianw?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Christian Wiediger</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## 6. LINQ Method syntax vs Query syntax: A matter of taste

Up to this point, we have seen LINQ as extension methods on top of the `IEnumerable` type. But, LINQ has a language-level query syntax too.

Let's find our favorite movies using language-level query syntax this time. Like this,

```csharp
var bestOfAll = from movie in movies
                where movie.Rating > 4.5
                select movie;
```

It looks like SQL, isn't it? And this is the same code using extension methods,

```csharp
var bestOfAll = movies.Where(movie => movie.Rating > 4.5);
```

We can use any of the two! But let's favor the syntax used in the codebase we're working with. If our code uses extension methods on `IEnumerable`, let's continue to do that.

But there is one advantage of using query syntax over extension methods: we can create intermediate variables with the `let` keyword.

### Find large files on the Desktop folder

Let's find all files inside our Desktop folder larger than 10MB. And, let's use `let` to create a variable. Like this,

```csharp
var desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
var desktop = new DirectoryInfo(desktopPath);

var largeFiles = from file in desktop.GetFiles()
                 let sizeInMb = file.Length / 1024 / 1024
                 //  ^^^^^
                 // We can create intermediate variables with 'let'
                 where sizeInMb > 10
                 select file.Name;

foreach (var file in largeFiles)
{
    Console.WriteLine(file);
}

Console.ReadKey();
```

The `Length` property returns the file size in bytes. We declared an intermediate variable to convert it to megabytes. Like this,

```csharp
let sizeInMb = file.Length / 1024 / 1024
```

That's the advantage of using query syntax over extension methods when working with LINQ.

## 7. Three common LINQ mistakes

Now that we know what LINQ is and the most common LINQ methods, let's go through three common mistakes we make when using LINQ methods in our code.

### 1. Write Count instead of Any

Let's always prefer `Any()` over `Count()` to check if a collection has elements or an element that meets a condition.

Let's do,

```csharp
movies.Any()
```

Instead of,

```csharp
movies.Count() > 0
```

### 2. Write Where followed by Any

Let's use a condition with `Any()` instead of filtering first with `Where()` to later use `Any()`.

Let's do,

```csharp
movies.Any(movie => movie.Rating == 5)
```

Instead of,

```csharp
movies.Where(movie => movie.Rating == 5).Any()
```

The same applies to the `Where()` method followed by `FirstOrDefault()`, `Count()`, or any other method that receives a filter condition. 

### 3. Use FirstOrDefault without null checking

Let's always check the result when working with `FirstOrDefault()`, `LastOrDefault()`, and `SingleOrDefault()`. If there isn't one, they will return the default value of the collection type.

```csharp
// We don't have movies with a rating lower than 2.0
var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1995, 4.6f),
    new Movie("Terminator 2", 1999, 4.7f),
    new Movie("Avatar", 2010, 5),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5)
};

var worst = movies.FirstOrDefault(movie => movie.Rating < 2);

Console.WriteLine($"{worst.Name}: [{worst.Rating}]");
//                  ^^^^^^^^^^^^ 
// System.NullReferenceException: 'Object reference not set to an instance of an object.'
//
// worst was null.

Console.ReadKey();

record Movie(string Name, int ReleaseYear, float Rating);
```

For objects, the default value would be a `null` reference. And do you know what happens when we try to access a property or method on a `null` reference?... Yes, [it throws NullReferenceException]({% post_url 2023-02-20-WhatNullReferenceExceptionIs %}).

To make sure we always have a non-nullable result when working with `FirstOrDefault()`, let's use the [the DefaultIfEmpty method]({% post_url 2020-11-17-DefaultOrEmpty %}). It returns a new collection with a default value if the input collection is empty.

```csharp
var worst = movies.Where(movie => movie.Rating < 2)
                  .DefaultIfEmpty(new Movie("Catwoman", 2004, 3))
                  // ^^^^^
                  .First();
```

Also, by mistake, we forget about [the difference between Single and First and LINQ lazy evaluation]({% post_url 2022-06-13-LinqMistakes %}) expecting LINQ queries to be cached. These two are more subtle mistakes we make when working with LINQ for the first time.

## 8. Conclusion

Voilà! That's it, Alice. That's all you need to know to start working with LINQ in your code in 15 minutes or less. I know! There are lots of methods. But you will get your back covered with [five of the most common LINQ methods]({% post_url 2022-05-16-LINQMethodsInPictures %}).

With LINQ, we write more compact and expressive code. The next time we need to write logic using loops, let's give LINQ a try!

For more C# content, check [C# Definitively Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}) for a list of subjects every intermediate C# developer should know. And, my [top 10 or so best C# features]({% post_url 2021-09-13-TopNewCSharpFeatures%}) for other cool C# features.

{%include linq_course.html %}

_Happy LINQ time!_