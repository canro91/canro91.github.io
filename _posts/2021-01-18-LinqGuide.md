---
layout: post
title: A quick guide to LINQ with examples
tags: tutorial csharp
description: All you need to know about LINQ in 15 minutes or less
cover: LinqGuide.png
cover-alt: A quick guide to LINQ with examples
---

Today a friend asked me about LINQ. I guess she was studying for a technical interview. So, dear Alice, this is what LINQ is and these are the most common LINQ methods with examples. All you need to know in 15 minutes or less.

**Language-Integrated Query (LINQ) is the declarative way of working with collections in C#. LINQ can be used with databases and xml files too. LINQ can be found as an API syntax, using extensions methods on the IEnumerable type, or as a language-level query syntax, using a SQL-like syntax.**

## LINQ is declarative

**LINQ is declarative.** It means you write your code stating the results you want, instead of doing every step to get those results.

With LINQ, you write code to _"filter a collection based on a condition"_. Instead of writing code to _"grab an element, check if it satisfies a condition, then move to the next element, check again..."_, etc.

LINQ is a better alternative to query collections using `for`, `foreach` or any other loop. Because, with LINQ you can write more expressive and compact code.

### Our first example: Movies

Let's see an example. Let's start with the collection of movies we have watched. We have a `Movie` class with a name, release year and rating. Let's find our favorite movies, the ones with rating greater than 4.5.

<figure>
<img src="https://images.unsplash.com/photo-1524985069026-dd778a71c7b4?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=800" alt="Waiting at a cinema before a movie starts" />

<figcaption><span>Photo by <a href="https://unsplash.com/@ewitsoe?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Erik Witsoe</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

A console program to print our favorite movies looks like the next code listing. Notice the `foreach` loop and the comparison using an `if` statement to look for ratings greater than 4.5.

```csharp
using System;
using System.Collections.Generic;

namespace QuickLinqGuide
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            var movies = new List<Movie>
            {
                new Movie("Titanic", 1998, 4.5f),
                new Movie("The Fifth Element", 1997, 4.6f),
                new Movie("Terminator 2", 1991, 4.7f),
                new Movie("Avatar", 2009, 5),
                new Movie("Platoon", 1986, 4),
                new Movie("My Neighbor Totoro", 1988, 5)
            };

            var favorites = new List<Movie>();
            foreach (var movie in movies)
            {
                if (movie.Rating > 4.5)
                {
                    favorites.Add(movie);
                }
            }

            foreach (var favorite in favorites)
            {
                Console.WriteLine($"{favorite.Name}: [{favorite.Rating}]");
            }

            Console.ReadKey();
        }
    }

    internal class Movie
    {
        public Movie(string name, int releaseYear, float rating)
        {
            Name = name;
            ReleaseYear = releaseYear;
            Rating = rating;
        }

        public string Name { get; set; }
        public int ReleaseYear { get; set; }
        public float Rating { get; set; }
    }
}
```

For our sample movies, the above program will print the next four movies.

```bash
The Fifth Element: [4.6]
Terminator 2: [4.7]
Avatar: [5]
My Neighbor Totoro: [5]
```

Change the example to use your own movies and see which ones are your favorite movies!

### Our first LINQ method: Where

LINQ methods are extension methods on the `IEnumerable` type. This type represents objects we can loop through. Like, arrays, lists, dictionaries, among others.

_In case you missed it_...You can add methods to a type without modifying it with extension methods. They are static methods defined outside the declaration of a type. But, they look like normal methods when you use them.

To work with LINQ, you need to be comfortable with delegates and lambda functions. A lambda function is a method with only the parameters and the body. To learn more about delegates and lambda functions, check my post [What the Func, Action?]({% post_url 2019-03-22-WhatTheFuncAction %})

Now, to the actual example. To start using LINQ methods, let's add the using statement `using System.Linq`.

Next, we want to filter our list of movies to keep only the ones with rating greater than 4.5. The LINQ method to filter collections is `Where`. **`Where` returns a new collection with all the elements that meet a condition.**

Let's replace the first `foreach` statement from our example with the `Where` method. And use the condition inside the `if` statement as the filter condition for the `Where` method. Our example looks like this:

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

namespace QuickLinqGuide
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            var movies = new List<Movie>
            {
                new Movie("Titanic", 1998, 4.5f),
                new Movie("The Fifth Element", 1995, 4.6f),
                new Movie("Terminator 2", 1999, 4.7f),
                new Movie("Avatar", 2010, 5),
                new Movie("Platoon", 1986, 4),
                new Movie("My Neighbor Totoro", 1988, 5)
            };

            var favorites = movies.Where(movie => movie.Rating > 4.5);

            foreach (var favorite in favorites)
            {
                Console.WriteLine($"{favorite.Name}: [{favorite.Rating}]");
            }

            Console.ReadKey();
        }
    }

    // The Movie class remains the same
}
```

We replaced the `foreach` and `if` statements with a single line of code:

`var favorites = movies.Where(movie => movie.Rating > 4.5);`

_More compact, isn't it?_ Also, we turned the condition inside the `if` statement into a lambda function.

**Instead of lambda functions, you can use private methods with LINQ**. For our example, let's create a method that recevies `Movie` as parameter and returns `bool`. For example,

```csharp
private bool IsFavorite(Movie movie)
{
    return movie.Rating > 4.5;
}
```

Then, we can use `IsFavorite` inside the `Where` method to filter our movies. Like this,

`var favorites = movies.Where(movie => IsFavorite(movie));`

**LINQ methods don't change the original collection.** They return a result without modifying the original collection. From our example, when we used the `Where` method, it returned a new collection. It didn't remove any elements from the original `movies` list.

## Most common LINQ methods

So far, we have seen only one LINQ method, `Where`. Let's see other common methods.

### Select

**With `Select`, you can transform every element of a collection.** It applies a function on every element.

Let's find only the names of our favorite movies.

```csharp
var favorites = movies.Where(movie => movie.Rating > 4.5)
                      .Select(movie => movie.Name);

foreach (var name in favorites)
{
    Console.WriteLine(name);
}

// The Fifth Element
// Terminator 2
// Avatar
// My Neighbor Totoro
```

Notice, how this time we have nested two LINQ methods. The result from `Where` will be the input of `Select`.

For more readability, we often align the nested LINQ methods vertically by the (.) dot.

### Any

**The `Any` method check if a collection is empty.** Also, it checks if a collection has at least one element matching a condition. It returns either `true` or `false`. It doesn't return a new collection.

Let's see if we have watched movies with a low rating.

```csharp
var hasAnyMovies = movies.Any();
// true

var hasBadMovies = movies.Any(movie => movie.Rating < 2);
// false
```

### All

Unlike `Any`, **`All` check if every elements inside a collection matches a condition**. It also return either `true` of `false` instead of a new collection.

Let's see if we have only watched really good movies.

```csharp
var weHaveSeenReallyGoodMovies = movies.All(movie => movie.Rating >= 4.5);
// false
```

### GroupBy

**`GroupBy` groups the elements of a collection based on a key.** It returns a collection of "groups"  or "buckets" organized by a key.

Let's group our movies by rating.

```csharp
var groupedByRating = movies.GroupBy(movie => movie.Rating);

foreach (var group in groupedByRating)
{
    Console.WriteLine($"Rating: {group.Key}");

    foreach (var movie in group)
    {
        Console.WriteLine($"{movie.Name}");
    }
    Console.WriteLine();
}
```

This will be the output.

```bash
Rating: 4.5
Titanic

Rating: 4.6
The Fifth Element

Rating: 4.7
Terminator 2

Rating: 5
Avatar
My Neighbor Totoro

Rating: 4
Platoon
```

Also, **`GroupBy` allows you to transform each group.** This time, let's count the movies with the same rating.

```csharp
var groupedByRating = movies.GroupBy(movie => movie.Rating,
                                    (rating, movies) => new { Rating = rating, Count = movies.Count() });

foreach (var group in groupedByRating)
{
    Console.WriteLine($"{group.Rating}: [{group.Count}]");
}
```

Notice the second parameter of the `GroupBy`. It's a `Func` with the key and the elements of each group. We also used an anonymous object `new { Rating=..., Count=... }`. It's like a regular object, but we didn't specify a name.

And this is the output of counting movies by rating.

```bash
4.5: [1]
4.6: [1]
4.7: [1]
5: [2]
4: [1]
```

### First/FirstOrDefault

**`First` and `FirstOrDefault` return the first element in a collection.** `First` throws an exception if the collection is empty. Unlike `First`, `FirstOrDefault` returns a default value if the collection is empty.

Also, `First` and `FirstOrDefault` return the first element matching a condition.

Let's find the oldest movie we have watched.

```csharp
var oldest = movies.OrderBy(movie => movie.ReleaseYear)
                   .First();

// Platoon
```

This time, we used the `OrderBy` to sort the movies collection by release year. _Two examples for the price of one!_

In the same spirit of `First` and `FirstOrDefault`, you have `Last` and `LastOrDefault`. But, they return the last element instead of the first one.

Recently, I learned about [the DefaultIfEmpty LINQ method]({% post_url 2020-11-17-DefaultOrEmpty %}). It returns a new collection with a default value if the given collection is empty. _Good to know!_

### Cheatsheet

There are more LINQ methods than the ones we've seen so far. These are some of them.

| Method | Function |
|---|---|
| `Where` | Filter a collection |
| `Select` | Transform every element of a collection | 
| `Any` | Check if a collection is empty |
| `All` | Check if every element satisfies a condition | 
| `Count` | Count all elements of a collection |
| `Distinct` | Find the unique elements of a collection |
| `GroupBy` | Group the elements of a collection based on a key | 
| `OrderBy` | Sort a collection based on a key  |
| `First` | Find the first element of a collection. Throw if the collection is empty | 
| `FirstOrDefault` | Same as `First`, but it returns a default value if it's empty | 
| `Last` | Find the last element of a collection. Throw if the collection is empty |
| `LastOrDefault` | It returns a default value if it's empty, instead |
| `Single` | Find only one element in a collection matching a condition. Throw, otherwise |
| `SingleOrDefault` | It returns a default value if there isn't one matching element, instead |
| `Take` | Pick the first _n_ consecutive elements of a collection |
| `TakeWhile` | Pick the first consecutive elements that satisfy a condition |
| `Skip` | Return a collection without the first _n_ consecutive elements |
| `SkipWhile` | Return a collection without the first consecutive elements that satisfy a condition |
| `Sum` | Sum the elements of a collection |
| `Min`, `Max` | Find the smallest and largest element of a collection |
| `ToDictionary` | Convert a collection into a dictionary |

## Query syntax: A matter of taste

Up to this point, we have seen LINQ as extension methods. But, you can find LINQ as language-level query syntax too.

This is the same example to find our favorite movies using language-level query syntax.

```csharp
var bestOfAll = from movie in movies
                where movie.Rating > 4.5
                select movie;
```

_It looks like SQL, isn't it?_ And, this is the same code using extension methods. We've seen this before.

```csharp
var bestOfAll = movies.Where(movie => movie.Rating > 4.5);
```

**Which LINQ syntax should you use? Prefer the syntax used in your current codebase.** If your code uses extensions methods on `IEnumerable`, continue to do that.

<figure>
<img src="https://images.unsplash.com/photo-1523207911345-32501502db22?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=800" alt="Popcorn" />

<figcaption>Speaking of taste. <span>Photo by <a href="https://unsplash.com/@christianw?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Christian Wiediger</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

But, there is one advantage of using query syntax over extension methods. You can create intermediate variables with the `let` keyword.

Let's find all files inside our Desktop folder larger than 10MB. And, let's use `let` to create a variable.

```csharp
using System;
using System.IO;
using System.Linq;

namespace QuickLinqGuide
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
            var desktop = new DirectoryInfo(desktopPath);

            var largeFiles = from file in desktop.GetFiles()
                             let sizeInMb = file.Length * 1024 * 1024
                             where sizeInMb > 10
                             select file.Name;

            foreach (var file in largeFiles)
            {
                Console.WriteLine(file);
            }

            Console.ReadKey();
        }
    }
}
```

From the above example, the file size is in bytes. Then, notice how we declared an intermediate variable. Like this `let sizeInMb = file.Length * 1024 * 1024`. 

## Common mistakes

Now that we know what LINQ is and the most common LINQ methods, let's go through three common mistakes we make when using LINQ methods in our code.

### Count vs Any

Always prefer `Any` over `Count` to check if a collection has elements or if it has elements that meet a condition.

Do `movies.Any()` instead of `movies.Count() > 0`.

### Where follow by Any

You can use a condition with `Any` instead of filtering first with `Where` to then use `Any`.

Do

```csharp
movies.Any(movie => movie.Rating == 5)
```

Instead of

```csharp
movies.Where(movie => movie.Rating == 5).Any()
```

The same applies to the `Where` method followed by `FirstOrDefault`, `Count` or any other method that receives a filter condition. 

### FirstOrDefault, LastOrDefault and SingleOrDefault

Make sure to always check if you have a result when working with `FirstOrDefault`, `LastOrDefault` and `SingleOrDefault`. In case there isn't one, you will get the default value of the collection type.

```csharp
private static void Main(string[] args)
{
    var movies = new List<Movie>
    {
        new Movie("Titanic", 1998, 4.5f),
        new Movie("The Fifth Element", 1995, 4.6f),
        new Movie("Terminator 2", 1999, 4.7f),
        new Movie("Avatar", 2010, 5),
        new Movie("Platoon", 1986, 4),
        new Movie("My Neighbor Totoro", 1988, 5)
    };

    var worst = movies.FirstOrDefault(movie => movie.Rating < 2);

    Console.WriteLine($"{worst.Name}: [{worst.Rating}]");
    //                  ^^^^^^^^^^^^ 
    // System.NullReferenceException: 'Object reference not set to an instance of an object.'
    //
    // worst was null.

    Console.ReadKey();
}
```

For objects, the default value would be a `null` reference. And you know what happens when you try to access a property or method on a `null` reference?...Yes, It thows `NullReferenceException`.

## Conclusion

Voilà! That's it, Alice. That's all you need to know to start working with LINQ in your code in 15 minutes or less. There's also this project [MoreLINQ](https://github.com/morelinq/MoreLINQ) with more extension methods, like `CountBy`, `DistinctBy`, `MinBy` and `MaxBy`. With LINQ you can write more compact and expressive code. The next time you need to write logic using loops, give LINQ a try!

Learn how to use LINQ to refactor conditionals on [C# idioms]({% post_url 2019-11-19-TwoCSharpIdioms %}). For more C# content, check [C# Definitively Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}) for a list of subjects every intermediate C# developer should know. And, my [top 10 or so best C# features]({% post_url 2021-09-13-TopNewCSharpFeatures%}) for other cool C# features.

_Happy LINQ time!_
