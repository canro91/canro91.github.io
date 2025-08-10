---
layout: post
title: "I'm Stealing Some of Reddit's C# Extension Methods"
tags: misc
---

Today, I found [this Reddit question](https://www.reddit.com/r/csharp/comments/1mkrlcc/what_is_the_lowest_effort_highest_impact_helper/) asking for the lower effort extension methods we've written.

And like [any real C# programmer]({% post_url 2025-02-19-YouAreNotAProgrammerUntil %}), I have my own [set of extension methods to work with collections]({% post_url 2022-12-16-HelperMethodsOnCollections %}). But I ended up stealing one method from that thread: `Choose()`. It applies a transformation to a list and only returns the resulting values different from `null`.

It turns out, `Choose()` comes from F#'s `List` type. So my next step was to sneak into F#'s `List` type and steal some of its methods.

Here they are,

```csharp
public static IEnumerable<U> Choose<T, U>(this IEnumerable<T> source, Func<T, U?> selector) 
        where U : class
{
    foreach (var elem in source)
    {
        var projection = selector(elem);
        if (projection != null)
        {
            yield return projection;
        }
    }
}

public static U Pick<T, U>(this IEnumerable<T> source, Func<T, U?> selector)
        where U : class
    => source.Choose(selector).First();

public static U? TryPick<T, U>(this IEnumerable<T> source, Func<T, U?> selector)
        where U : class
    => source.Choose(selector).FirstOrDefault();

public static IEnumerable<T> Replicate<T>(this T source, int count)
{
    for (int i = 0; i < count; i++)
        yield return source;
}

public static IEnumerable<T> Singleton<T>(this T source)
{
    yield return source;
}
```

And here's a quick example of how to use them,

```csharp
var movies = new Dictionary<int, string>
{
    { 1999, "The Matrix" },
    { 2000, "Gladiator" },
    { 2008, "The Dark Knight"},
    { 2003, "Freaky Friday"}
};
var years = [1995, 1997, 2010, 2003, 1999, 2000];
years.Choose(movies.GetValueOrDefault)
// "Freaky Friday", "The Matrix", "Gladiator"

years.Pick(movies.GetValueOrDefault)
// "Freaky Friday"
```
