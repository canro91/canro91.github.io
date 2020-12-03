---
layout: post
title: TIL&colon; LINQ DefaultIfEmpty method in C#
tags: todayilearned csharp
---

LINQ `DefaultIfEmpty` extension method returns a collection containing a single element if the given collection is empty. Otherwise, it returns the same collection.

Example: Find all the movies with score greater than 9. Otherwise, return your all-time favorite movie.

```csharp
var movies = new List<Movie>
{
    new Movie("Titanic”, 5),
    new Movie("Back to the Future”, 7),
    new Movie("Black Hawk Down”, 6)
};

var movieToWatch = movies.Where(movie => movie.Score >= 9)
                    .DefaultIfEmpty(new Movie("Fifth Element", 10))
                    .First();

// Movie { Name="Fifth Element", Score=10 }
```

If I had to implement it on my own, it would be like this:

```csharp
public static IEnumerable<T> DefaultIfEmpty<T>(this Enumerable<T> source, T @default)
    => source.Any() ? source : new[]{ @default };
```

_Source_: [Enumerable.DefaultIfEmpty Method](https://docs.microsoft.com/en-us/dotnet/api/system.linq.enumerable.defaultifempty?view=net-5.0)
