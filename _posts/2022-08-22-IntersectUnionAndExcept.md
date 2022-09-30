---
layout: post
title: "Three set-like LINQ methods: Intersect, Union, and Except"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Sewing threads" 
---

So far we have covered some of the [most common LINQ methods]({% post_url 2022-05-16-LINQMethodsInPictures %}). This time let's cover three LINQ methods that work like set operations: Intersect, Union, and Except. Like [the Aggregate method]({% post_url 2022-07-25-LinqAggregateExplained %}), we don't use these methods every day, but they will come in handy from time to time.

Let's use our catalog of movies from previous posts in this series.

## 1. Intersect

**The Intersect() method finds the common elements between two collections.**

Let's find the movies we both have watched and rated in our catalogs.

```csharp
var mine = new List<Movie>
{
    // We have not exactly a tie here...
    new Movie("Terminator 2", 1991, 4.7f),
    //        ^^^^^^^^^^^^^^
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("My Neighbor Totoro", 1988, 5f)
    //        ^^^^^^^^^^^^^^^^^^^^
};

var yours = new List<Movie>
{
    new Movie("My Neighbor Totoro", 1988, 5f),
    //        ^^^^^^^^^^^^^^^^^^^^
    new Movie("Pulp Fiction", 1994, 4.3f),
    new Movie("Forrest Gump", 1994, 4.3f),
    // We have not exactly a tie here...
    new Movie("Terminator 2", 1991, 5f)
    //        ^^^^^^^^^^^^^^
};

var weBothHaveSeen = mine.Intersect(yours);
Console.WriteLine("We both have seen:");
PrintMovies(weBothHaveSeen);

// Output:
// We both have seen:
// My Neighbor Totoro

Console.ReadKey();

static void PrintMovies(IEnumerable<Movie> movies)
{
    Console.WriteLine(string.Join(",", movies.Select(movie => movie.Name)));
}

record Movie(string Name, int ReleaseYear, float Rating);
```

Notice that, this time, we have two lists of movies, `mine` and `yours`, with the ones I've watched and the ones I guess you have watched, respectively. Also, notice we both have watched "My Neighbor Totoro" and "Terminator 2."

To find the movies we both have seen (the intersection between our two catalogs), we used the `Intersect()` method. But, our example only shows "My Neighbor Totoro." What happened here?

If we pay close attention, we both have watched "Terminator 2," but we gave it different ratings. Since we're using [records from C# 9.0]({% post_url 2021-09-13-TopNewCSharpFeatures %}), records have member-wise comparison. Therefore, our two "Terminator 2" instances aren't exactly the same, even though they have the same name. That's why `Intersect()` doesn't return it.

To find the common movies using only the movie name, we can try any of these alternatives:

* pass a custom comparer to `Intersect()`,
* override the default `Equals` and `GetHashCode` methods of the `Movie` record, or,
* use the new `IntersectBy()` method [introduced in .NET6]({% post_url 2022-06-27-NET6LinqMethods %}).

Let's use the `IntersectBy()` method. Like this,

```csharp
var weBothHaveSeen = mine.IntersectBy(
        yours.Select(yours => yours.Name),
        //    ^^^^^^
        // Your movie names
        (movie) => movie.Name);
        //               ^^^^
        // keySelector: Property to compare by

Console.WriteLine("We both have seen:");
PrintMovies(weBothHaveSeen);

// Output:
// We both have seen:
// Terminator 2,My Neighbor Totoro
```

**Unlike Intersect(), IntersectBy() expects a "keySelector," a delegate with the property to use as the comparing key. And a second collection with the same type as the keySelector.**

<figure>
<img src="https://images.unsplash.com/photo-1569003280089-4f68b6367743?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2MDYwNDQxMA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Colorful apartments in a building" />

<figcaption>Photo by <a href="https://unsplash.com/@martfoto1?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Martin Woortman</a> on <a href="https://unsplash.com/s/photos/boxes?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 2. Union

**The Union() method finds the elements from both collections without duplicates.**

Let's find all the movies we have in our catalogs.

```csharp
var mine = new List<Movie>
{
    new Movie("Terminator 2", 1991, 5f),
    //        ^^^^^^^^^^^^^^
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("My Neighbor Totoro", 1988, 5f)
    //        ^^^^^^^^^^^^^^^^^^^^
};

var yours = new List<Movie>
{
    new Movie("My Neighbor Totoro", 1988, 5f),
    //        ^^^^^^^^^^^^^^^^^^^^
    new Movie("Pulp Fiction", 1994, 4.3f),
    new Movie("Forrest Gump", 1994, 4.3f),
    new Movie("Terminator 2", 1991, 5f)
    //        ^^^^^^^^^^^^^^
};

var allTheMoviesWeHaveSeen = mine.Union(yours);
Console.WriteLine("All the movies we have seen:");
PrintMovies(allTheMoviesWeHaveSeen);

// Output:
// All the movies we have seen:
// Terminator 2,Titanic,The Fifth Element,My Neighbor Totoro,Pulp Fiction,Forrest Gump

Console.ReadKey();

static void PrintMovies(IEnumerable<Movie> movies)
{
    Console.WriteLine(string.Join(",", movies.Select(movie => movie.Name)));
}

record Movie(string Name, int ReleaseYear, float Rating);
```

This time we gave the same rating to our shared movies: "Terminator 2" and "My Neighbor Totoro." And, `Union()` showed all the movies from both collections, showing duplicates only once. It works the same way as the union operation in our Math classes.

LINQ has a similar method to "combine" two collections into a single one: `Concat()`. But, unlike `Union()`, `Concat()` returns all elements from both collections without removing the duplicated ones.

.NET 6 also has a `UnionBy()` method to "union" two collections with a keySelector. And, unlike `IntersectBy()`, we don't need the second collection to have the same type as the keySelector.

## 3. Except

**The Except() method finds the elements in one collection that are not present in another one.**

This time, let's find the movies only I have watched.

```csharp
var mine = new List<Movie>
{
    new Movie("Terminator 2", 1991, 5f),
    new Movie("Titanic", 1998, 4.5f),
    //         ^^^^^^^
    new Movie("The Fifth Element", 1997, 4.6f),
    //         ^^^^^^^^^^^^^^^^^
    new Movie("My Neighbor Totoro", 1988, 5f)
};

var yours = new List<Movie>
{
    new Movie("My Neighbor Totoro", 1988, 5f),
    new Movie("Pulp Fiction", 1994, 4.3f),
    new Movie("Forrest Gump", 1994, 4.3f),
    new Movie("Terminator 2", 1991, 5f)
};

var onlyIHaveSeen = mine.Except(yours);
Console.WriteLine();
Console.WriteLine("Only I have seen:");
PrintMovies(onlyIHaveSeen);

// Output:
// Only I have seen:
// Titanic,The Fifth Element

Console.ReadKey();

static void PrintMovies(IEnumerable<Movie> movies)
{
    Console.WriteLine(string.Join(",", movies.Select(movie => movie.Name)));
}

record Movie(string Name, int ReleaseYear, float Rating);
```

With `Except()`, we found the movies in `mine` that are not in `yours`. When working with `Except()`, we should pay attention to the order of the collection because this method isn't commutative. This means, `mine.Except(yours)` is not the same as `yours.Except(mine)`.

Likewise, we have `ExceptBy()` that receives a KeySelector and a second collection with the same type as the keySelector type.

Voilà! These are the `Intersect()`, `Union()`, and `Except()` methods. They work like the Math set operations: intersection, union, and symmetrical difference, respectively. Of the three, I'd say `Except` is the most common method.

If you want to read more about LINQ, check [my quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}), [five common LINQ mistakes and how to fix them]({% post_url 2022-06-13-LinqMistakes %}) and [what's new in LINQ with .NET6]({% post_url 2022-06-27-NET6LinqMethods %}).

{%include linq_course.html %}

_Happy coding!_