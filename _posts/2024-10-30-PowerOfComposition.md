---
layout: post
title: "The Power of Function Composition — to Find If an Array Is Special"
tags: csharp
---

Passing the result of a function to another isn't the only way to compose two functions.

From math classes, we're used to composing two functions like this `compose(f, g) = x => f(g(x))`. But it turns out there are more ways.

That's my main takeaway from the talk "The Power of Function Composition" by Conor Hoekstra at NDC Conference 2024.

Here's the YouTube recording,

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/fuX4bQefvWQ?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

The talk shows how to find if an array is special using languages like Python, Haskell, and other obscure and esoteric ones to show function composition.

These are the lessons I learned, translating some code examples to C#.

## A simple solution to find if an array is special

Let's find if an array is special.

> An array is special if every pair of consecutive elements contains two numbers with different parity. For example, `[4,3,1,6]` isn't special. It has three pairs: `4,3`, `3,1`, and `1,6`. The second pair has two odd numbers, which makes our array "not special."

Here's the [LeetCode problem](https://leetcode.com/problems/special-array-i/description/) if you want to try it yourself.

And here's my solution before using any of the new concepts from the talk,

```csharp
IEnumerable<(int First, int Second)> Pairs(int[] array)
{
    for (int i = 0; i < array.Length - 1; i++)
    {
        yield return (array[i], array[i + 1]);
    }
    // Or simply:
    // return array.Zip(array.Skip(1));
}

bool HasDifferentParity((int First, int Second) pair)
    => pair.First % 2 != pair.Second % 2;

bool IsSpecial(int[] array)
    => Pairs(array).All(HasDifferentParity);

IsSpecial([1, 2, 3, 4]) // true
IsSpecial([4, 3, 1, 6]) // false
```

It uses `Pairs()` to generate the pairs of consecutive elements, `HasDifferentParity()` to find if both numbers in a pair are even or odd, and `All()` from LINQ. Nothing fancy!

## Apart from the "usual" composition, there are other ways of composing functions

Here are some of them, in pseudo-code:

```
def i(x) = x
def k(x, y) = x
def ki(x, y) = y

def s(f, g) = \x => f(x, g(x))
def b(f, g) = \x => f(g(x)) // <--

def c(f) = \x, y => f(y, x)
def w(f) = \x => f(x, x)

def d(f, g) = \x, y => f(x, g(y))
def b1(f, g) = \x, y => f(g(x, y))
def psi(f, g) = \x, y => f(g(x), g(y)) // <--
def phi(f, g, h) = \x => g(f(x), h(x))
```

Let's take a close look at two of them.

`b` is the composition we all know. It passes the result of the second function to the first one. And `psi` passes two values to the second function and then calls the first one with both results.

## Let's find if an array is special again, but composing functions

Let's revisit `IsSpecial()` but using "psi" this time,

```csharp
IEnumerable<(int First, int Second)> Pairs(int[] array)
    => array.Zip(array.Skip(1));

bool IsEven(int x) => x % 2 == 0;
bool NotEqual(bool x, bool y) => x != y;

// A more general signature would be:
// Func<T1,T1,T3> Psi<T1, T2, T3>(Func<T2,T2,T3> f, Func<T1,T2> g)
// But to make things easier:
Func<int, int, bool> Psi(Func<bool, bool, bool> f, Func<int, bool> g)
//                   ^^^
    => (x, y) => f(g(x), g(y));

var hasDifferentParity = Psi(NotEqual, IsEven); // <--
bool IsSpecial(int[] array)
    => Pairs(array).All(pair => hasDifferentParity(pair.First, pair.Second));

// or
bool IsSpecial(int[] array)
    => Pairs(array).All(pair => Psi(NotEqual, IsEven)(pair.First, pair.Second));
    //                          ^^^

IsSpecial([1, 2, 3, 4]) // true
IsSpecial([1, 2, 4, 3]) // false
```

Instead of `HasDifferentParity()`, it uses `Psi(NotEqual, IsEven)`.

And again, here's the pseudo-code of psi: `psi(f, g) = \x, y => f(g(x), g(y))`.

`Psi(NotEqual, IsEven)` receives two integers, calls `IsEven` with each of them, and passes both results to `NotEqual`.

That's a new way of composition.

## Let's do it the Haskell way using MapAdjacent

From [Haskell official docs](https://hackage.haskell.org/package/utility-ht-0.0.17.2/docs/Data-List-HT.html), `MapAdjacent` transforms every pair of consecutive elements.

Here's `IsSpecial()` one more time, but using `MapAdjacent()`,

```csharp
// Pairs, IsEven, NotEqual, and Psi are the same as before...

bool IsSpecial(int[] array)
    => array.Select(IsEven).MapAdjacent(NotEqual).And();

// or
bool IsSpecial(int[] array)
    => array.MapAdjacent(Psi(NotEqual, IsEven)).And();

IsSpecial([1, 2, 3, 4]) // true
IsSpecial([1, 2, 4, 3]) // false
```

It transforms our array into an array of booleans--if every number is even--with `Select()`, then finds if every pair of booleans is different with `MapAdjacent()` and lastly collapses all the results with `And()`.

As an alternative, it uses `MapAdjacent()` with `Psi(NotEqual, IsEven)` to avoid using `Select()` first. This alternative is closer to the previous one with `Pairs()` and `All()`.

Since we don't have `MapAdjancent()` and `And()`, here are their C# versions,

```csharp
public static class Enumerable
{
    public static IEnumerable<TResult> MapAdjacent<TSource, TResult>(
            this IEnumerable<TSource> source,
            Func<TSource, TSource, TResult> func)
        => source.Zip(source.Skip(1), (first, second) => func(first, second));

    public static bool And(this IEnumerable<bool> source)
        => source.All(x => x);
}
```

`MapAdjacent()` is a wrapper of `Zip()` and `And()` is a wrapper of `All()`.

This is one of the talks to replay multiple times if you want to grasp its concepts, since they're not that common. Also, it covers the same example in other less known languages that I don't even remember their names.

Since you won't use those obscure languages, learn the composition part of the talk. It's mind blowing. In any case, if you want to start with Functional Programming, you'll need [simpler concepts]({% post_url 2024-10-29-FPOnDotNet %}).

