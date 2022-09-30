---
layout: post
title: "Five LINQ Methods in Pictures"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Cover" 
---

One of the best C# features is LINQ. I would say it's the most distinctive of all [C# features]({% post_url 2021-09-13-TopNewCSharpFeatures %}). These are five of the most common LINQ method in pictures.

**LINQ is the declarative, immutable, and lazy-evaluated way of working with collections in C#. Some frequently used LINQ methods are Where, Select, Any, GroupBy, and FirstOrDefault.**

Let's work with a list of our favorite movies. Let's write a `Movie` class with a name, release year, and a rating.

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
```

## 1. Where

**The Where method returns a new collection with only the elements that meet a given condition.**

The `Where` method works like a filter on collections. Think of `Where` as a replacement for a `foreach` with an `if` in it. 

Let's filter our list of movies to keep only those with a rating greater than or equal to 4.5.

```csharp
var favorites = movies.Where(movie => movie.Rating >= 4.5);
```

This query would be something like this,

{% include image.html name="Where.png" caption="Let's keep the films with a rating greater than 4.5" alt="Favorite films filtered by rating" %}

We're using arrows to display our LINQ queries. But, the output of a LINQ query is lazy-evaluated. It means the actual result of a LINQ query is evaluated until we loop through its result. 

## 2. Select

**The Select method applies a function to transform every element of a collection.**

Let's find only the names of our favorite movies.

```csharp
var namesOfFavorites = movies.Where(movie => movie.Rating >= 4.5)
                             .Select(movie => movie.Name);
```

This query would be,

{% include image.html name="WhereAndSelect.png" caption="Let's keep only the names of our favorite films" alt="Name of our favorite films filtered by rating" %}

<figure>
<img src="https://images.unsplash.com/photo-1542204165-65bf26472b9b?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzOTI1ODI5OA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="8mm filmrolls" />

<figcaption>Photo by <a href="https://unsplash.com/@dmjdenise?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Denise Jans</a> on <a href="https://unsplash.com/s/photos/film?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 3. Any

**The Any method checks if a collection has at least one element matching a condition. Unlike Where and Select, Any doesn't return a new collection, but either true or false.**

Let's see if we have watched movies with a low rating.

```csharp
var hasBadMovies = movies.Any(movie => movie.Rating < 2);
```

This query would be,

{% include image.html name="Any.png" caption="Do we have films with a low rating?" alt="At least one film with a low rating" %}

## 4. GroupBy

**The GroupBy method returns a collection of "buckets" organized by a key. Also, GroupBy transforms each bucket of elements.**

Let's count the films with the same rating.

```csharp
var groupedByRating = movies.GroupBy(movie => movie.Rating,
                            (rating, moviesWithSameRating) => new
                            {
                                Rating = rating,
                                Count = moviesWithSameRating.Count()
                            });
```

The second parameter of the `GroupBy` is a `Func` with the grouping key and the elements of each group as parameters. This `Func` works like a mapping function to transform each group or bucket found.

This query would be,

{% include image.html name="GroupByGroups.png" caption="Let's count the films with the same rating" alt="Count of films grouped by rating" %}

[GroupBy has other use-cases]({% post_url 2022-05-30-HowToUseLinqGroupBy %}), like grouping by more than one property.

## 5. First & FirstOrDefault

**The First and FirstOrDefault methods return the first element in a collection or the first one matching a condition. Otherwise, First throws an exception, and FirstOrDefault returns the default value of the collection type.**

Let's find the oldest film we have watched.

```csharp
var oldest = movies.OrderBy(movie => movie.ReleaseYear)
                   .First();
```

This query would be,

{% include image.html name="First.png" caption="Let's find the oldest film we have watched" alt="Oldest film we have watched" %}

Voilà! These are five LINQ methods I use often: Where, Select, Any, Group, and FirstOrDefault. Of course, LINQ has more methods like [Aggreate]({% post_url 2022-07-25-LinqAggregateExplained %}), [Intersect, Union, and Except]({% post_url 2022-08-22-IntersectUnionAndExcept %}), and [new overloads in .NET6]({% post_url 2022-06-27-NET6LinqMethods %}). But, you will get your back covered with the five methods we covered here.

To learn about LINQ and other methods, check my [quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}). All you need to know to start working with LINQ, in 15 minutes or less. For more C# content, check [C# Definitive Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}) for a list of subjects every intermediate C# developer should know. And, my [top 10 best C# features]({% post_url 2021-09-13-TopNewCSharpFeatures%}) for other cool C# features.

{%include linq_course.html %}

_Happy LINQ time!_