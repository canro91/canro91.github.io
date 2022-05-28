---
layout: post
title: "TIL: LINQ DefaultIfEmpty method in C#"
tags: todayilearned csharp
---

Today while I was reading the AutoFixture source code I found a LINQ method I didn't know about: DefaultIfEmpty. This is what the LINQ DefaultIfEmpty method does.

**LINQ DefaultIfEmpty method returns a collection containing a single default element if the source collection is empty. Otherwise, it returns the same source collection.**

For example, let's find all the movies with a rating greater than 9. Otherwise, return our all-time favorite movie.

```csharp
var movies = new List<Movie>
{
    new Movie("Titanic", 5),
    new Movie("Back to the Future", 7),
    new Movie("Black Hawk Down", 6)
};

var movieToWatch = movies.Where(movie => movie.Score >= 9)
                    .DefaultIfEmpty(new Movie("Fifth Element", 10))
                    .First();

// Movie { Name="Fifth Element", Score=10 }
```

If I had to implement it on my own, it would be like this,

```csharp
public static IEnumerable<T> DefaultIfEmpty<T>(this Enumerable<T> source, T @default)
    => source.Any() ? source : new[]{ @default };
```

Voilà! DefaultIfEmpty is helpful to make sure we always have a default value when filtering a collection. It's a good alternative to FirstOrDefault followed by checking for null values.

To learn more about LINQ, check my [Quick Guide to LINQ]({% post_url 2021-01-18-LinqGuide %}). Don't miss my [C# Definitive Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}) for a list of subjects every intermediate C# developer should know.

{%include linq_course.html %}

_Source_: [Enumerable.DefaultIfEmpty Method](https://docs.microsoft.com/en-us/dotnet/api/system.linq.enumerable.defaultifempty?view=net-5.0)
