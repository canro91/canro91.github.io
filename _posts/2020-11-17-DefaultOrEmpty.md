---
layout: post
title: "TIL: LINQ DefaultIfEmpty method in C#"
tags: todayilearned csharp
---

Today I was reading the AutoFixture source code in GitHub and I found a LINQ method I didn't know about: `DefaultIfEmpty`.

**DefaultIfEmpty returns a collection containing a single element if the source collection is empty. Otherwise, it returns the same source collection.**

For example, let's find all the movies with a rating greater than 9. Otherwise, return our all-time favorite movie.

```csharp
// We don't have movies with rating greater than 9
var movies = new List<Movie>
{
    new Movie("Titanic", 5),
    new Movie("Back to the Future", 7),
    new Movie("Black Hawk Down", 6)
};

var allTimesFavorite = new Movie("Fifth Element", 10);
var movieToWatch = movies.Where(movie => movie.Score >= 9)
                    .DefaultIfEmpty(allTimesFavorite)
                    // ^^^^^
                    .First();

// Movie { Name="Fifth Element", Score=10 }
```

If I had to implement it on my own, it would be like this,

```csharp
public static IEnumerable<T> DefaultIfEmpty<T>(this Enumerable<T> source, T @default)
    => source.Any() ? source : new[]{ @default };
```

Voilà! `DefaultIfEmpty` is helpful to make sure we always have a default value when filtering a collection. It's a good alternative to `FirstOrDefault` followed by a null guard.

To learn more about LINQ, check my [Quick Guide to LINQ with Examples]({% post_url 2021-01-18-LinqGuide %}).

{%include linq_course.html %}

_Happy coding!_
