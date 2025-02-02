---
layout: post
title: "Goodbye, NullReferenceException: What it is and how to avoid it"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Dream catcher" 
---

If you're here, I bet you already have found the exception message: _"Object reference not set to an instance of an object."_

In this series of posts, let's see some techniques to completely eliminate the NullReferenceException from our code. Let's start by understanding when NullReferenceException is thrown and a strategy to fix it.

**NullReferenceException is thrown when we access a property or method of an uninitialized variable of a reference type. The easier way to solve this exception is to check for null before accessing the members of an object. But C# has introduced new operators and features to avoid this exception.**

Let's write an example that throws NullReferenceException,

```csharp
var movie = FindMovie();
Console.Write(movie.Name);
//            ^^^^^
// System.NullReferenceException: 'Object reference not set to an instance of an object.'
//
// movie was null.

Console.ReadKey();

static Movie FindMovie()
{
    // Imagine this is a database call that might
    // or might not return a movie
    return null;
    //     ^^^^
}

record Movie(string Name, int ReleaseYear, float Rating);
```

Notice we returned `null` from `FindMovie()`. That caused the NullReferenceException. But, it could be a method that accessed a database and didn't find anything or an API controller method that didn't receive a required input parameter.

In our last example, we got a NullReferenceException when we returned `null` from a method. But, we could also find this exception when we try to loop through a `null` list or array, for example.

Speaking of returning `null`, **one way to prevent the NullReferenceException is to never pass null between objects**. Instead of returning `null`, let's use empty lists and strings, or the Null Object pattern. And let's [use intention-revealing defaults]({% post_url 2021-09-27-TwoCSharpIdiomsPart4 %}) for that.

<figure>
<img src="https://images.unsplash.com/photo-1570645053711-5767083d2518?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY3Njc3NjY0Nw&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Multicolored dream catcher" />

<figcaption>Don't catch it! Photo by <a href="https://unsplash.com/@drderp94?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">David Restrepo Parrales</a> on <a href="https://unsplash.com/photos/zgeYcpeussI?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 1. Don't catch the NullReferenceException

To fix the NullReferenceException, we might be tempted to write a `try/catch` block around the code that throws it. But, let's not catch the NullReferenceException.

Let me say that again: **don't throw or catch NullReferenceException**.

By any means, please, let's not write something like this,

```csharp
try
{
    AMethodThatMightThrowNullReferenceException();
}
catch (NullReferenceException)
{
    // ...
    // Beep, beep, boop
    // Doing something with the exception here
}
```

A NullReferenceException is a symptom of an unhandled and unexpected scenario in our code, and catching it won't handle that. A NullReferenceException is a developer's mistake.

## 2. Check for null

**The solution for the NullReferenceException is to check for nulls and defense against them.**

Let's fix our previous example by adding a null check. Like this,

```csharp
var movie = FindMovie();
if (movie != null)
//  ^^^^^
{
    // We're safe here...
    //
    // No more System.NullReferenceException
    // at least due to a movie being null 
    Console.Write(movie.Name);
}

Console.ReadKey();

static Movie FindMovie()
{
    // Imagine this is a database call that might
    // or might not return a movie
    return null;
    //     ^^^^
}

record Movie(string Name, int ReleaseYear, float Rating);
```

Notice we checked if the `movie` variable wasn't `null`. As simple as that.

### Alternatives to check for null

The lack of options isn't an excuse to not check for `null`. Since [some recent C# versions]({% post_url 2021-09-13-TopNewCSharpFeatures %}), and thanks to pattern matching, we have a couple of new ways to check for `null`. We can use any of these:

* `if (movie != null) { //... }`,
* `if (movie is not null) { //... }`,
* `if (movie is { }) { //... }`, and,
* `if (movie is object) { //... }`

Some of those don't look like C# anymore. I still prefer the old `if (movie != null) ...`. Which one do you prefer?

## 3. Defense against null

If the solution to NullReferenceException were to simply check for `null`, that wouldn't be the Billion-Dollar mistake. And I wouldn't be writing this series. But the thing is knowing when a reference might be `null` or not and, therefore, when we should check for it. That's when we should protect ourselves against `null`.

To protect against `null`, inside our methods, let's check our input parameters and throw a more detailed exception. C# has an exception for missing parameters: ArgumentNullException.

The ArgumentNullException stack trace contains the name of the parameter that was `null`. That will help us to better troubleshoot our code. Often, the NullReferenceException stack trace doesn't include what was `null` in the first place. Happy debugging time!

Let's check our input parameters, 

```csharp
public void DoSomething(Movie movie)
{
    if (movie == null)
    {
        throw new ArgumentNullException(nameof(movie))
    }
    // Since C# 10, we can also write:
    // ArgumentNullException.ThrowIfNull(movie);

    // Beep, beep, boop
    // Doing something here...
}
```

Notice that instead of waiting for NullReferenceException, we proactively prevented it by checking for a required parameter and throwing a controlled ArgumentNullException.

Voilà! That's the NullReferenceException and how to fix it by checking for `null`. Remember, we shouldn't catch this exception but prevent and prepare for it.

Don't miss the other posts in this series! In the next post, we cover how to use [Nullable Operators and Nullable References]({% post_url 2023-03-06-NullableOperatorsAndReferences %}) to prevent the NullReferenceException. In future posts, we're covering [the Option type and LINQ XOrDefault methods]({% post_url 2023-03-20-UseOptionInsteadOfNull %}) and [a design technique to encapsulate optional state]({% post_url 2023-04-03-SeparateStateIntoSeparateObjects %}).

{%include nre_course.html %}

_Happy coding!_