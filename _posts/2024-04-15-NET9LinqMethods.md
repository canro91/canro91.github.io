---
layout: post
title: "Two new LINQ methods in .NET 9: CountBy and Index"
tags: tutorial csharp
cover: Cover.png
cover-alt: "a vintage camera" 
---

LINQ doesn't get new features with each release of the .NET framework. It just simply works. This time, .NET 9 introduced two new LINQ methods: `CountBy()` and `Index()`. Let's take a look at them.

## 1. CountBy

**CountBy groups the elements of a collection by a key and counts the occurrences of each key. With CountBy, there's no need to first group the elements of a collection to count its occurrences.**

For example, let's count all movies in our catalog by release year, of course, using `CountBy()`,

```csharp
var movies = new List<Movie>
{
    new Movie("Titanic", 1997, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("Forrest Gump", 1994, 4.3f),
    new Movie("Terminator 2", 1991, 4.7f),
    new Movie("Armageddon", 1998, 3.35f),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5),
    new Movie("Pulp Fiction", 1994, 4.3f),
};

var countByReleaseYear = movies.CountBy(m => m.ReleaseYear);
//                              ^^^^^^^
foreach (var (year, count) in countByReleaseYear)
{
    Console.WriteLine($"{year}: [{count}]");
}

// Output
// 1997: [2]
// 1994: [2]
// 1991: [1]
// 1998: [1]
// 1986: [1]
// 1988: [1]

Console.ReadKey();

record Movie(string Name, int ReleaseYear, float Rating);
```

`CountBy()` returns a collection of `KeyValuePair` with the key in the first position and the count in the second one.

By the way, if that Console application doesn't look like one, it's because we're using [three recent C# features]({% post_url 2021-09-13-TopNewCSharpFeatures %}): the Top-level statements, records, and global using statements.

Before .NET 9.0, we needed to use [GroupBy() with a second parameter]({% post_url 2022-05-30-HowToUseLinqGroupBy %}) to transform each group, like this,

```csharp
var countByReleaseYear = movies.GroupBy(
  x => x.ReleaseYear,
  (releaseYear, movies) => new
  // ^^^^^
  {
      Year = releaseYear,
      Count = movies.Count()
      //      ^^^^^
  });
```

`CountBy()` has the same spirit of [DistinctBy, MinBy, MaxBy, and other LINQ methods from .NET 6.0]({% post_url 2022-06-27-NET6LinqMethods %}). With these methods, we apply an action direcly on a collection using a key selector. We don't need to filter or group a collection first to apply that action.

<figure>
<img src="https://images.unsplash.com/photo-1440404653325-ab127d49abc1?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTcxMDk3NzY4Mw&ixlib=rb-4.0.3&q=80&w=600" alt="Cinematographer's room">

<figcaption>Photo by <a href="https://unsplash.com/@imnoom?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Noom Peerapong</a> on <a href="https://unsplash.com/photos/two-reels-2uwFEAGUm6E?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a></figcaption>
</figure>

## 2. Index

**Index projects every element of a collection alongside its position in the collection.**

Let's "index" our catalog of movies,

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

foreach (var (index, movie) in movies.Index())
//                                    ^^^^^
{
    Console.WriteLine($"{index}: [{movie.Name}]");
}

// Output
// 0: [Titanic]
// 1: [The Fifth Element]
// 2: [Terminator 2]
// 3: [Avatar]
// 4: [Platoon]
// 5: [My Neighbor Totoro]

Console.ReadKey();

record Movie(string Name, int ReleaseYear, float Rating);
```

Unlike `CountBy()`, `Index()` returns named tuples. It returns `IEnumerable<(int Index, TSource Item)>`.

Before, we had to use the `Select()` overload or roll our own extension method. In fact, this is one of the [helpful extension methods I use to work with collections]({% post_url 2022-12-16-HelperMethodsOnCollections %}). But I call it `Enumerated()`.

If we take a look at the [Index source code on GitHub](https://github.com/dotnet/runtime/blob/main/src/libraries/System.Linq/src/System/Linq/Index.cs), it's a `foreach` loop with a counter in its body. Nothing fancy!

Voilà! Those are two new LINQ methods in .NET 9.0: `CountBy()` and `Index()`. It seems the .NET team is bringing to the standard library the methods we needed to roll ourselves before.

To learn about LINQ and other methods, check my [quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}), [five common LINQ mistakes and how to fix them]({% post_url 2022-06-13-LinqMistakes %}), and [peeking into LINQ DistinctBy source code]({% post_url 2022-07-11-LinqDistinctBySourceCode %}).

{%include linq_course.html %}

_Happy coding!_