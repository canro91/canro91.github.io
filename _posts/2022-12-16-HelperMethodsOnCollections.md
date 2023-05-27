---
layout: post
title: "Six helpful extension methods I use to work with Collections"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Collection of clocks hang in a wall" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

LINQ is the perfect way to work with collections. It's declarative and immutable. But, from time to time, I take some extension methods with me to the projects I work with. These are some extension methods to work with collections.

## 1. Check if a collection is null or empty

These are three methods to check if a collection is null or empty. They're wrappers around [the LINQ Any method]({% post_url 2022-05-16-LINQMethodsInPictures %}).

```csharp
public static bool IsNullOrEmpty<T>([NotNullWhen(false)] this IEnumerable<T>? collection)
    => collection == null || collection.IsEmpty();

public static bool IsNotNullOrEmpty<T>([NotNullWhen(true)] this IEnumerable<T>? collection)
    => !collection.IsNullOrEmpty();

public static bool IsEmpty<T>(this IEnumerable<T> collection)
    => !collection.Any();
```

Notice we used the `[NotNullWhen]` attribute to let the compiler know if the source collection is null. This way, when we turn on the [nullable references feature]({% post_url 2021-09-13-TopNewCSharpFeatures %}), the compiler can generate more accurate warnings. If we don't add this attribute, we get some false positives. Like this one,

```csharp
IEnumerable<Movie>? movies = null;

if (movies.IsNotNullOrEmpty())
{
    movies.First();
    // ^^^^^
    // CS8604: Possible null reference argument for parameter 'source'
    //
    // But we don't want this warning here...
}
```

## 2. EmptyIfNull

In the same spirit of [DefaultIfEmpty]({% post_url 2020-11-17-DefaultOrEmpty %}), let's create a method to return an empty collection if the source collection is null. This way, we can "go with the flow" by nesting this new method with other LINQ methods.

```csharp
public static IEnumerable<T> EmptyIfNull<T>(this IEnumerable<T>? enumerable)
   => enumerable ?? Enumerable.Empty<T>();
```

For example, we can write,

```csharp
someNullableCollection.EmptyIfNull().Select(DoSomething);
//                     ^^^^^
```

Instead of writing,

```csharp
someNullableCollection?.Select(DoSomeMapping) ?? Enumerable.Empty<SomeType>();
```

I found this idea in [Pasion for Coding's Null Handling with Extension Methods](https://coding.abel.nu/2012/02/null-handling-with-extension-methods/). 

## 3. Enumerated

The LINQ `Select()` method has an overload to map elements using their position in the source collection. We can use it like this,

```csharp
movies.Select((movie, position) => DoSomething(movie, position))));
```

Inspired by [Swift Enumerated method](https://developer.apple.com/documentation/swift/array/enumerated()), we can write a wrapper around this `Select()` overload. Like this,

```csharp
public static IEnumerable<(int Index, TResult Item)> Enumerated<TSource, TResult>(this IEnumerable<TSource> source, Func<TSource, TResult> selector)
    => source.Select((t, index) => (index, selector(t)));

public static IEnumerable<(int Index, TSource Item)> Enumerated<TSource>(this IEnumerable<TSource> source)
    => source.Enumerated(e => e);
```

For example, we can write,

```csharp
foreach (var (index, movie) in movies.Enumerated())
{
    Console.WriteLine($"[{index}]: {movie.Name}")l
}
```

Voilà! These are some of my favorite extension methods to work with collections. Some of them are workarounds to [avoid the NullReferenceException]({% post_url 2023-02-20-WhatNullReferenceExceptionIs %}) when working with collections. What extension methods do you use often?

If you want to learn more about LINQ, read my [Quick Guide to LINQ]({% post_url 2021-01-18-LinqGuide %}).

{%include linq_course.html %}

_Happy coding!_