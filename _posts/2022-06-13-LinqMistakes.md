---
layout: post
title: "Five common LINQ mistakes and how to fix them"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Coffee cup spilled on a book" 
---

It's not that complicated to start working with LINQ to replace `for`, `foreach`, and other loops. With [a handful of LINQ methods]({% post_url 2022-05-16-LINQMethodsInPictures %}), we have our backs covered. But, often we make some common mistakes when working with LINQ. Let's learn five common mistakes we make when working with LINQ for the first time and how to fix them.

## Mistake 1: Use Count instead of Any

We should always prefer `Any` over `Count` to check if a collection is empty or has at least one element that meets a condition.

Let's write,

```csharp
movies.Any()
```

Instead of,

```csharp
movies.Count() > 0
```

The `Any` method returns when it finds at least one element. The `Count` method could use the size of the underlying collection. But, it could evaluate the entire LINQ query for other collection types. And, this could be a performance hit for large collections.

## Mistake 2: Use Where followed by Any

We can use a condition with `Any` directly, instead of filtering first with `Where` to then use `Any`.

Let's write,

```csharp
movies.Any(movie => movie.Rating == 5)
```

Instead of,

```csharp
movies.Where(movie => movie.Rating == 5).Any()
```

The same applies to the `Where` method followed by `FirstOrDefault`, `Count`, or any other method that receives a filter condition. We could use the filtering condition directly instead of relying on the `Where` method first.

<figure>
<img src="https://images.unsplash.com/photo-1613963969191-2a77db9811d2?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY1MTkzODI4MA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Spilled coffee on a street" />

<figcaption>Ooops...Photo by <a href="https://unsplash.com/@jontyson?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Jon Tyson</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Mistake 3: Use FirstOrDefault instead of SingleOrDefault with unique values

We should prefer `SingleOrDefault` over `FirstOrDefault` to find one and only one element matching a condition inside a collection.

Let's write,

```csharp
var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1995, 4.6f),
    new Movie("Terminator 2", 1999, 4.7f),
    new Movie("Avatar", 2010, 5),
    new Movie("Platoon", 1986, 4),
    // We have a tie here...        
    new Movie("My Neighbor Totoro", 1988, 5)
};

// SigleOrDefault expects only one element...but there are two of them
var theBest = movies.SingleOrDefault(movie => movie.Rating == 5);
//            ^^^^^^
// System.InvalidOperationException: 'Sequence contains more than one matching element'
//
Console.WriteLine($"{theBest.Name}: [{theBest.Rating}]");
Console.ReadKey();

record Movie(string Name, int ReleaseYear, float Rating);
```

Instead of,

```csharp
var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1995, 4.6f),
    new Movie("Terminator 2", 1999, 4.7f),
    new Movie("Avatar", 2010, 5),
    new Movie("Platoon", 1986, 4),
    // We have a tie here...        
    new Movie("My Neighbor Totoro", 1988, 5)
};

// FirstOrDefault remains quiet if there's more than one matching element...
var theBest = movies.FirstOrDefault(movie => movie.Rating == 5);

Console.WriteLine($"{theBest.Name}: [{theBest.Rating}]");
Console.ReadKey();

record Movie(string Name, int ReleaseYear, float Rating);
```

The `SigleOrDefault` method throws an exception when it finds more than one element matching a condition. But, with multiple matching elements, the `FirstOrDefault` method returns the first of them without signaling any problem.

Let's pick between `FirstOrDefault` and `SingleOrDefault` to show the query intent. Let's prefer `SingleOrDefault` to retrieve a unique matching element from a collection.

## Mistake 4: Use FirstOrDefault without null checking

Let's always check if we have a result when working with `FirstOrDefault`, `LastOrDefault`, and `SingleOrDefault`.

When any of the three above methods don't find results, they return the default value of the collection type.

For objects, the default value would be a `null` reference. And, do you know what happens when we access a property or method on a `null` reference?... Yes, It throws the fearsome `NullReferenceException`. Arrggg!

We have this mistake in the following code sample. We forgot to check if the `worst` variable has a value. An `if (worst != null)` would solve the problem.

```csharp
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

// We forgot to check for nulls after using FirstOrDefault
// It will break	
Console.WriteLine($"{worst.Name}: [{worst.Rating}]");
//                  ^^^^^^^^^^^^ 
// System.NullReferenceException: 'Object reference not set to an instance of an object.'
//
// worst was null.
Console.ReadKey();

record Movie(string Name, int ReleaseYear, float Rating);
```

Notice we wrote a LINQ query with `FirstOrDefault` looking for the first movie with a rating lower than 2. But, we don't have any movie that matches that condition. The `FirstOrDefault` method returned `null` and we forgot to check if the `worst` variable was different from `null` before using it.

There are other altervatives to get rid of the `NullReferenceException` like [nullable reference types from C# 8.0]({% post_url 2021-09-13-TopNewCSharpFeatures %}), [the DefaultOrEmpty method]({% post_url 2020-11-17-DefaultOrEmpty %}) or .NET6 FirstOrDefault with an default value.

## Mistake 5: Expect LINQ queries to be cached

LINQ queries are lazy-evaluated. It means the actual result of a LINQ query is evaluated when we loop through the result, not when we declare the query. And, the query is evaluated every time we loop through it.

Let's avoid looping through the result of a LINQ query multiple times expecting it to be cached the first time we run it.

```csharp
var movies = new List<Movie>
{
    new Movie("The Fifth Element", 1995, 4.6f),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5)
};

var favorites = movies.Where(movie =>
{
    // Let's put a debugging message here...
    Console.WriteLine("Beep, boop...");
    return movie.Rating == 5;
});

// 1. Let's print our favorite movies
foreach (var movie in favorites)
{
    Console.WriteLine($"{movie.Name}: [{movie.Rating}]");
}
Console.WriteLine();

// 2. Let's do something else with our favorite movies
foreach (var movie in favorites)
{
    Console.WriteLine($"Doing something else with {movie.Name}");
}
Console.ReadKey();

record Movie(string Name, int ReleaseYear, float Rating);

// Output
// Beep, boop...
// Beep, boop...
// Beep, boop...
// My Neighbor Totoro: [5]
//
// Beep, boop...
// Beep, boop...
// Beep, boop...
// Doing something else with My Neighbor Totoro
```

Notice we wrote a debugging statement inside the `Where` method and we looped through the result twice. The output shows the debugging statements twice. One for every time we looped through the result. There was no caching whatsoever. The LINQ query was evaluated every time.

Instead of expecting a LINQ query to be cached, we could use the `ToList` or `ToArray` methods to break the lazy evaluation and force the LINQ query to be evaluated only once.

```csharp
var movies = new List<Movie>
{
    new Movie("The Fifth Element", 1995, 4.6f),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5)
};

var favorites = movies.Where(movie =>
{
    // Let's put a debugging message here...
    Console.WriteLine("Beep, boop...");
    return movie.Rating == 5;
}).ToList();
// ^^^^^^
// We break the lazy evaluation with ToList

// 1. Let's print our favorite movies
foreach (var movie in favorites)
{
    Console.WriteLine($"{movie.Name}: [{movie.Rating}]");
}
Console.WriteLine();

// 2. Let's do something else with our favorite movies
foreach (var movie in favorites)
{
    Console.WriteLine($"Doing something else with {movie.Name}");
}
Console.ReadKey();

record Movie(string Name, int ReleaseYear, float Rating);

// Output
// Beep, boop...
// Beep, boop...
// Beep, boop...
// My Neighbor Totoro: [5]
//
// Doing something else with My Neighbor Totoro
```

Notice the output only shows the debugging messages once, even though we looped through the collection twice. We forced the query to be evaluated only once with the `ToList` method.

Voilà! Those are the five most common LINQ mistakes. I know they seem silly, but we often overlook them. Especially we often forgot about the lazy evaluation of LINQ queries. If you want to take a deeper look at LINQ and all of its features, check my [Quick Guide to LINQ]({% post_url 2021-01-18-LinqGuide %}), these [five common LINQ methods in Pictures]({% post_url 2022-05-16-LINQMethodsInPictures %}) and [how to use LINQ GroupBy method]({% post_url 2022-05-30-HowToUseLinqGroupBy %}).

{%include linq_course.html %}

_Happy coding!_