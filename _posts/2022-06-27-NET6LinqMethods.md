---
layout: post
title: "Four new LINQ methods in .NET 6: Chunk, DistinctBy, Take, XOrDefault"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Vintage film cameras in a shelf" 
---

LINQ isn't a new feature in the C# language. It was released back in C# version 3.0 in the early 2000s. And, after more than ten years, it was finally updated with the .NET 6 release. These are four of the new LINQ methods and overloads in .NET 6.

**.NET 6 introduced new LINQ methods like Chunk, DistinctBy, MinBy, and MaxBy. Also, new overloads to existing methods like Take with ranges and FirstOrDefault with an optional default value. Before this update, to use similar methods, custom LINQ methods or third-party libraries were needed.**

## 1. Chunk

**Chunk splits a collection into buckets or "chunks" of at most the same size. It receives the chunk size and returns a collection of collections.**

For example, let's say we want to watch all movies we have in our catalog. But, we can only watch three films on a single weekend. Let's use the `Chunk` method for that.

```csharp
// This is a Console app without the Main class declaration
// and with global using statements
var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("Terminator 2", 1991, 4.7f),
    new Movie("Avatar", 2009, 5),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5)
};

// Split the movies list into chunks of three movies
var chunksOf3 = movies.Where(movie => movie.Rating > 4.5f)
                      .Chunk(3);

foreach (var chunk in chunksOf3)
{
    PrintMovies(chunk);
}

// Output:
// The Fifth Element,Terminator 2,Avatar
// My Neighbor Totoro

static void PrintMovies(IEnumerable<Movie> movies)
{
    Console.WriteLine(string.Join(",", movies.Select(movie => movie.Name)));
}

record Movie(string Name, int ReleaseYear, float Rating);
```

Notice, we used three [recent C# features]({% post_url 2021-09-13-TopNewCSharpFeatures %}): the Top-level statements, records from C# 9.0, and global using statements from C# 10.0. We don't need all the boilerplate code to write a Console application and simple objects anymore.

The Chunk method returns chunks with at most the given size. It returns fewer elements in the last bucket when there aren't enough elements in the source collection.

## 2. DistinctBy

**Unlike Distinct, DistinctBy receives a delegate to select the property to use as the comparison key and returns the objects containing the distinct values, not only the distinct values themselves.**

Let's find the movies containing unique ratings, not just the ratings.

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

var distinctRatings = movies.DistinctBy(movie => movie.Rating);
PrintMovies(distinctRatings);

// Output:
// Titanic,The Fifth Element,Terminator 2,Avatar,Platoon
```

Also, there are similar alternatives to existing methods such as MinBy, MaxBy, [ExceptBy, IntersectBy, and UnionBy]({% post_url 2022-08-22-IntersectUnionAndExcept %}). They work with a delegate to select a property to use as the comparison key and return the "containing" objects, not only the result.

<figure>
<img src="https://images.unsplash.com/photo-1526007413281-c202e21eedf3?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY0MDc5ODA3MQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Vintage movie camera" />

<figcaption>Photo by <a href="https://unsplash.com/@jhanks787?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Joshua Hanks</a> on <a href="https://unsplash.com/s/photos/cinema?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 3. Take with Ranges

**Take receives a range of indexes to pick a slice of the input collection, not only the first consecutive elements. Take with a range replaces Take followed by Skip to choose a slice of elements.**

Let's choose a slice of our catalog using `Take` with [ranges and the index-from-end operator]({% post_url 2021-09-13-TopNewCSharpFeatures %}).

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

var rangeOfMovies = movies.Take(^5..3);
PrintMovies(rangeOfMovies);

// Output
// The Fifth Element,Terminator 2
```

Notice `Take(^5..3)` selects elements starting from the fifth position from the end (`^5`) up to the third position from the start (`3`). We didn't need to use the `Skip` method for that.

Now that we have Take with Ranges is easier to find the last "n" elements of a collection. We would need `Take(^n...)`. For example, let's find the last three movies on our catalog.

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

var lastThreeMovies = movies.Take(^3..);
PrintMovies(lastThreeMovies);

// Output
// Avatar,Platoon,My Neighbor Totoro
```

Notice `Take()` did all the trick. Before this .NET update, we had to use `Skip(movies.Count - 3).Take(3)`. More compact.

## 4. XOrDefault methods with an optional default value

**FirstOrDefault has a new overload to return a default value when the collection is empty or doesn't have any elements that satisfy the given condition. Other methods with the suffix 'OrDefault' have similar overloads.**

Let's find in our catalog of movies a "perfect" film. Otherwise, let's return our favorite movies from all times.

Before this update, we had to check if a LINQ query with FirstOrDefault returned a non-null value, or we had to use the [LINQ DefaultIfEmpty method]({% post_url 2020-11-17-DefaultOrEmpty %}). Like this,

```csharp
var allTimesFavorite = new Movie("Back to the Future", 1985, 5);

// Using the Null-coalescing assignment ??= operator
var favorite = movies.FirstOrDefault(movie => movie.Rating == 10);
favorite ??= allTimesFavorite;

// Or
// Using the DefaultIfEmpty method
var favorite = movies.Where(movie => movie.Rating == 10)
                     .DefaultIfEmpty(allTimesFavorite)
                     .First();
```

With the new overload, we can pass a safe default. Like this,

```csharp
var allTimesFavorite = new Movie("Back to the Future", 1985, 5);

var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("Terminator 2", 1991, 4.7f),
    new Movie("Avatar", 2009, 5),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5)
};

// We have a safe default now. See the second parameter
var favorite = movies.FirstOrDefault(movie => movie.Rating == 10, allTimesFavorite);
// We don't need to check for null here
Console.WriteLine(favorite.Name);

// Output:
// Back to the future
```

Notice the second parameter we passed to the `FirstOrDefault` method.

To use these new methods and overloads, install on your machine the latest version of the .NET 6 SDK from the [.NET official page](https://dotnet.microsoft.com/en-us/download) and use as target framework `.net6` in your csproj files. For example, this is a sample csproj file for a Console app using `.net6`,

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
  </PropertyGroup>

</Project>
```

Voilà! These are four new LINQ methods released in the .NET 6 updated. I really like the FirstOrDefault with a safe default. That help us to prevent one of the [common LINQ mistakes]({% post_url 2022-06-13-LinqMistakes %}): using the `XOrDefault` methods without null checking afterwards.

To learn about LINQ and other methods, check my [quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}), these [five common LINQ methods in Pictures]({% post_url 2022-05-16-LINQMethodsInPictures %}) and [how to use LINQ GroupBy method]({% post_url 2022-05-30-HowToUseLinqGroupBy %}). For more C# content, check [C# Definitive Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}) for a list of subjects every intermediate C# developer should know.

{%include linq_course.html %}

_Happy coding!_