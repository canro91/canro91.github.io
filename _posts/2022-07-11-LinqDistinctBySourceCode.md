---
layout: post
title: "Peeking into LINQ DistinctBy source code"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Looking inside a box" 
---

"Don't use libraries you can't read their source code." That's a bold statement I found and shared in a past [Monday Links]({% post_url 2022-01-17-MondayLinks %}). I decided to look into the LINQ DistinctBy source code. For a while, I thought the C# standard library was like a black box that only experienced ~~wizards~~ programmers could understand. I was wrong. Let's see what's inside the new LINQ DistinctyBy method.

## What LINQ DistinctBy method does?

**DistinctBy returns the objects containing unique values based on one of their properties. It works on collections of complex objects, not just on plain values.**

DistinctBy is one of the [new LINQ methods introduced in .NET 6]({% post_url 2022-06-27-NET6LinqMethods %}).

The next code sample shows how to find unique movies by release year.

```csharp
var movies = new List<Movie>
{
    new Movie("Schindler's List", 1993, 8.9f),
    new Movie("The Lord of the Rings: The Return of the King", 2003, 8.9f),
    new Movie("Pulp Fiction", 1994, 8.8f),
    new Movie("Forrest Gump", 1994, 8.7f),
    new Movie("Inception", 2010, 8.7f)
};

// Here we use the DistinctBy method with the ReleaseYear property
var distinctByReleaseYear = movies.DistinctBy(movie => movie.ReleaseYear);
//                                 ^^^^^^^^^^

foreach (var movie in distinctByReleaseYear)
{
    Console.WriteLine($"{movie.Name}: [{movie.ReleaseYear}]");
}

// Output:
// Schindler's List: [1993]
// The Lord of the Rings: The Return of the King: [2003]
// Pulp Fiction: [1994]
// Inception: [2010]

record Movie(string Name, int ReleaseYear, float Score);
```

Notice we used the `DistinctBy` method on a list of movies. We didn't use it on a list of released years to then find one movie for each unique release year found.

Before looking at DistinctBy source code, how would you implement it?

<figure>
<img src="https://images.unsplash.com/photo-1607451481819-dc811fca803a?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY0MDc5OTg4OA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Puppy looking inside a gift bag" />

<figcaption>Let's peek into DistinctBy source code. Photo by <a href="https://unsplash.com/@freestocks?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">freestocks</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## LINQ DistinctBy source code

This is the source code for the DistinctBy method. [Source](https://github.com/dotnet/runtime/blob/main/src/libraries/System.Linq/src/System/Linq/Distinct.cs#L48)

{% include image.html name="DistinctByCode.png" alt="DistinctBy source code" caption="DistinctBy source code" %}

Well, it doesn't look that complicated. Let's go through it.

First, `DistinctBy()` starts by checking its parameters and calling `DistinctByIterator()`. This is a common pattern in other LINQ methods. Check parameters in one method and then call a child iterator method to do the actual logic. (See 1. in the image above)

Then, the `DistinctByIterator()` initializes the underling enumerator of the input collection with a `using` declaration. The `IEnumerable` type has a `GetEnumerator()` method. (See 2.)

The `IEnumerator` type has a `MoveNext()` method to advance the enumerator to the next position and a `Current` property to hold the element at the current position.

If a collection is empty or if the iterator reaches the end of the collection, `MoveNext()` returns `false`. And, when `MoveNext()` returns `true`, `Current` gets updated with the element at that position. [Source](https://docs.microsoft.com/en-us/dotnet/api/system.collections.ienumerator?view=net-6.0)

Then, to start reading the input collection, the iterator is placed at the initial position of the collection calling `MoveNext()`. (See 3.) This first `if` avoids allocating memory by creating a set in the next step if the collection is empty.

After that, `DistinctByIterator()` creates a set with a default capacity and an optional comparer. This set keeps track of the unique keys already found. (See 4.)

{% include image.html name="DefaultCapacity.png" alt="DefaultInternalSetCapacity declaration" caption="DefaultInternalSetCapacity = 7" %}

The next step is to read the current element and add its key to the set. (See 5.)

If a set doesn't already contain the same element, `Add()` returns `true` and adds it to the set. Otherwise, it returns `false`. And, when the set exceeds its capacity, the set gets resized. [Source](https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1.add?view=net-6.0#System_Collections_Generic_HashSet_1_Add__0_)

If the current element's key was added to the set, the element is returned with the `yield return` keywords. This way, `DistinctByIterator()` returns one element at a time.

Step 5 is wrapped inside a `do-while` loop. It runs until the enumerator reaches the end of the collection. (See 6.)

Voilà! That's the DistinctBy source code. Simple but effective. Not that intimidating, after all. By no means I want to diminish the work of .NET contributors. On the contrary, it's a good exercise to read the source code of standard libraries to pick conventions and patterns.

To learn about LINQ, check my [quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}), [five common LINQ methods in Pictures]({% post_url 2022-05-16-LINQMethodsInPictures %}) and [What's new in LINQ with .NET 6]({% post_url 2022-06-27-NET6LinqMethods %}).

{%include linq_course.html %}

_Happy coding!_