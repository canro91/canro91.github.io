---
layout: post
title: "LINQ Aggregate Method Explained with Pictures"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Pile of stones" 
---

This is not [one of the most used LINQ methods]({% post_url 2022-05-16-LINQMethodsInPictures %}). We won't use it every day. But, it's handy for some scenarios. Let's learn how to use the `Aggregate` method.

**The Aggregate method applies a function on a collection carrying the result to the next element. It "aggregates" the result of a function over a collection.**

The `Aggregate` method takes two parameters: a seed and an aggregating function that takes the accumulated value and one element from the collection.

## How does Aggregate work?

Let's reinvent the wheel to understand `Aggregate` by finding the maximum rating in our movie catalog. Of course, LINQ has a `Max` method. And, [.NET 6 introduced new LINQ methods]({% post_url 2022-06-27-NET6LinqMethods %}), among those: `MaxBy`.

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

var maxRating = movies.Aggregate(0f, (maxSoFar, movie) => MaxBetween(maxSoFar, movie.Rating));
//                     ^^^^^^^^^
Console.WriteLine($"Maximum rating on our catalog: {maxRating}");

// Output:
// Comparing 0 and 4.5
// Comparing 4.5 and 4.6
// Comparing 4.6 and 4.7
// Comparing 4.7 and 5
// Comparing 5 and 4
// Comparing 5 and 5
// Maximum rating on our catalog: 5

Console.ReadKey();

float MaxBetween(float maxSoFar, float rating)
{
    Console.WriteLine($"Comparing {maxSoFar} and {rating}");
    return rating > maxSoFar ? rating : maxSoFar;
}

record Movie(string Name, int ReleaseYear, float Rating);
```

Notice we used `Aggregate()` with two parameters: `0f` as the seed and the delegate `(maxSoFar, movie) => MaxBetween(maxSoFar, movie.Rating)` as the aggregating function. `maxSoFar` is the accumulated value from previous iterations, and `movie` is the current movie while `Aggregate` iterates over our list. The `MaxBetween()` method returns the maximum between two numbers.

Notice the order of the debugging messages we printed every time we compare two ratings in the `MaxBetween()` method.

On the first iteration, the `Aggregate()` method executes the `MaxBetween()` aggregating function using the seed (`0f`) and the first element ("Titanic" with 4.5) as parameters.

{% include image.html name="Iteration1.png" caption="Aggregate first iteration" alt="Aggregate first iteration on a list of movies" %}

Next, it calls `MaxBetween()` with the previous result (4.5) as the `maxSoFar` and the next element of the collection ("The Fifth Element" with 4.6f).

{% include image.html name="Iteration2.png" caption="Aggregate second iteration" alt="Aggregate second iteration on a list of movies" %}

In the last iteration, `Aggregate()` finds the `maxSoFar` from all previous iterations and the last element ("My Neighbor Totoro" with 5). And it returns the last value of `maxSoFar` as a result.

{% include image.html name="LastIteration.png" caption="Aggregate last iteration" alt="Aggregate last iteration on a list of movies" %}

In our example, we used `Aggregate()` with a seed. But, `Aggregate()` has an overload without it, then it uses the first element of the collection as the seed. Also, `Aggregate()` has another parameter to transform the result before returning it.

Voilà! That's how the `Aggregate` method works. Remember, it returns an aggregated value from a collection instead of another collection. This is one of those methods we don't use often. I've used it only a couple of times. One of them was in my parsing library, [Parsinator]({% post_url 2019-03-08-ATaleOfAPdfParser %}), to apply a list of modification functions on the same input object [here](https://github.com/canro91/Parsinator/blob/master/Parsinator/Extensions/ISkipExtensions.cs#L8).

If you want to read more about LINQ and its features, check [my quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}), [five common LINQ mistakes and how to fix them]({% post_url 2022-06-13-LinqMistakes %}) and [what's new in LINQ with .NET6]({% post_url 2022-06-27-NET6LinqMethods %}).

{%include linq_course.html %}

_Happy coding!_