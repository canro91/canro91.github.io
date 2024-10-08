---
layout: post
title: "How to use LINQ GroupBy method: Two more use cases"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Pieces of a game board" 
---

Last time, I showed [five of the most common LINQ methods with pictures]({% post_url 2022-05-16-LINQMethodsInPictures %}). Let's take a deeper look at one of them: `GroupBy`.

**The GroupBy method groups the elements of a collection based on a grouping key. This method returns a collection of "groups" or "buckets" organized by that key.**

Let's continue to work with our catalog of movies and group our movies by rating.

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

// Group our catalog of movies based on their rating
var groupedByRating = movies.GroupBy(movie => movie.Rating);
//                           ^^^^^^^

foreach (var group in groupedByRating)
{
    // Each group or bucket has a Key property  
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
//
//Rating: 4.6
//The Fifth Element
//
//Rating: 4.7
//Terminator 2
//
//Rating: 5
//Avatar
//My Neighbor Totoro
//
//Rating: 4
//Platoon

record Movie(string Name, int ReleaseYear, float Rating);
```

We used three [recent C# features]({% post_url 2021-09-13-TopNewCSharpFeatures %}): the Top-level statements, records, and global using statements. Now we can write Console applications without the Main declaration. All boilerplate code is gone!

The `GroupBy` method [receives a delegate as a parameter]({% post_url 2019-03-22-WhatTheFuncAction %}) with the property to use as a key when grouping elements. In our previous example, we used the `Rating` property and wrote `movie => movie.Rating`.

## What does GroupBy return?

**The result of GroupBy is a collection of groups or buckets. It returns `IEnumerable<IGrouping<TKey, TSource>>` where TKey is the type of the grouping key and TSource is the type of the elements inside the collection.**

{% include image.html name="GroupByReturn.png" caption="GroupBy return type" alt="LINQ GroupBy method signature" %}

The `IGrouping` interface is a wrapper for a collection and its grouping key. Each group or bucket has a `Key` property.

In our example, the type of the return collection was `IEnumerable<IGrouping<float, Movie>>`. That's why we needed two `foreach` loops to print the movies in each group. One to print the ratings and another to print all movies in each rating.

<figure>
<img src="https://images.unsplash.com/photo-1515165616480-efd71925068f?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY0MzA2MDU3Nw&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Magazine stand" />

<figcaption>We're grouping films, not magazines. Photo by <a href="https://unsplash.com/@charissek?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Charisse Kenion</a> on <a href="https://unsplash.com/s/photos/pile?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## How to transform every group

Also, the `GroupBy` method transforms each group or bucket.

Let's count the movies with the same rating this time.

```csharp
// This is a Console app without the Main class declaration
// and with Global using statements
var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("Terminator 2", 1991, 4.7f),
    new Movie("Avatar", 2009, 5),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5)
};

// Transform every group into a RatingCount type
var countByRating = movies.GroupBy(movie => movie.Rating,
//                                  vvvvvvv
                                    (rating, groupedMovies) => new RatingCount(rating, groupedMovies.Count());

foreach (var group in countByRating)
{
    Console.WriteLine($"{group.Rating}: [{group.Count}]");
}
// Output:
//4.5: [1]
//4.6: [1]
//4.7: [1]
//5: [2]
//4: [1]

record Movie(string Name, int ReleaseYear, float Rating);
record RatingCount(float Rating, int Count);
```

We passed a second parameter to the `GroupBy` method. The first parameter was still the grouping key. But, the second one was a delegate that received the grouping key and the elements of each group,`Func<TKey, IEnumerable<TSource>, TResult>`. We named the two parameters: `rating` and `groupedMovies`.

Since we wanted to count the movies with the same rating, we used another LINQ method: `Count`.

**As its name implies, the Count method returns the number of elements in a collection**.

With the ratings and the movies per rating, we transformed every group of movies into a new object, `RatingCount`.

## How to group by more than one property

In the two previous examples, we used the `Rating` property as the grouping key. But we can group the elements of a collection by more than one grouping property.

**With the GroupBy method, to group a collection by more than one property, use a custom object as the grouping key.**

Let's group our movies by release year and rating.

```csharp
var movies = new List<Movie>
{
    new Movie("Titanic", 1998, 4.5f),
    new Movie("The Fifth Element", 1997, 4.6f),
    new Movie("Terminator 2", 1991, 4.7f),
    new Movie("Avatar", 2009, 5),
    new Movie("Platoon", 1986, 4),
    new Movie("My Neighbor Totoro", 1988, 5),
    new Movie("Life Is Beautiful", 1997, 4.6f),
    new Movie("Saving Private Ryan", 1998, 4.5f),
    new Movie("Léon: The Professional", 1994, 4.5f),
    new Movie("Forrest Gump", 1994, 4.5f)
};

// Group by our catalog of moves by release year and rating
var groupByReleasedYearAndRating = movies.GroupBy(movie => new { movie.ReleaseYear, movie.Rating });
//                                        ^^^^^^^

foreach (var group in groupByReleasedYearAndRating)
{
    var groupingKey = group.Key;
    Console.WriteLine($"Release Year/Rating: {groupingKey.ReleaseYear} - {groupingKey.Rating} ");

    foreach (var movie in group)
    {
        Console.WriteLine($"{movie.Name}");
    }
    Console.WriteLine();
}
// Output:
//Release Year/Rating: 1998 - 4.5
//Titanic
//Saving Private Ryan
//
//Release Year/Rating: 1997 - 4.6
//The Fifth Element
//Life Is Beautiful
//
//Release Year/Rating: 1991 - 4.7
//Terminator 2
//
//Release Year/Rating: 2009 - 5
//Avatar
//
//Release Year/Rating: 1986 - 4
//Platoon
//
//Release Year/Rating: 1988 - 5
//My Neighbor Totoro
//
//Release Year/Rating: 1994 - 4.5
//Léon: The Professional
//Forrest Gump

record Movie(string Name, int ReleaseYear, float Rating);
```

We used an anonymous object as the grouping key.

### What are anonymous objects in C#?

**An anonymous object is a temporary and immutable object defined without a class definition or a name.**

In our example, we wrote an anonymous object like this,

```csharp
new { ReleaseYear = movie.ReleaseYear, Rating = movie.Rating }
```

Inside anonymous objects, we can omit names while defining member properties if we want to keep the same names.

That's why we only wrote,

```csharp
new { movie.ReleaseYear, movie.Rating }
```

When we need to access properties from an anonymous object, we use their property names, as usual.

Voilà! That's the GroupBy method. It creates groups or buckets with the elements of a collection and transforms each group.

If you noticed the output of our previous examples, the `GroupBy` method grouped the elements without sorting them. For that, we would need the `OrderBy` method.

To learn about LINQ and other methods, check my [quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}) and [three set-like LINQ methods: Intersect, Union, and Except]({% post_url 2022-08-22-IntersectUnionAndExcept %}).

{%include linq_course.html %}

_Happy coding!_