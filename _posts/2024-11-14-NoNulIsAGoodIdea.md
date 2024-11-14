---
layout: post
title: "Getting Rid of Nulls Is Indeed A Good Idea"
tags: csharp
---

These days I found a Medium article titled: [Why Eliminating NULLs From Your Code Will Not Make Your App Better](https://levelup.gitconnected.com/why-eliminating-nulls-from-your-code-will-not-make-your-app-better-f64082f9a162).

Its point is that when we stop using null, we replace checking for null with checking for a default value or a wrapper like Result. And there's no major gain.

But there is.

The advantage of returning a wrapper like [Option or Result instead of null]({% post_url 2023-03-20-UseOptionInsteadOfNull %}) is making the implicit explicit.

Instead of getting a [NullReferenceException]({% post_url 2023-02-20-WhatNullReferenceExceptionIs %}) and saying "ooops, that method returned null," we look at a method signature and say "Hey, that method might return null. We're better off checking for that."

That's **Method Signature Honesty**. When the parameters and return types of a method show what it does, even for edge cases.

For example, what does this method do?

```csharp
Movie GetMovieById(int movieId);
```

What if there was no movie found? What if there was more than one? Does the method throw an exception? Returns null? Returns a Movie.Empty? We can't tell just by looking at the signature.

But what about?

```csharp
Option<Movie> GetMovieById(int movieId);
// or
Result<Movie, MovieError> GetMovieById(int movieId);
```

At least, it's obvious from that signature that there's a special case we need to handle. It's up to the caller to decide what to do with it.

The original article has a point that replacing a null checking like,

```csharp
var movie = GetMovieById(someId);
if (movie != null)
{
    // Do something here
}
```

With,

```csharp
var result = GetMovieById(someId)
                 .Map(movie => /* Do something here */);

// And at some point later:
result.OrElse(() => /* Nothing found. Do something else here */);
```

is a design choice. For C#, the first one looks like more "native."

In either case, at some point, we have to convert the absence of data (either a null or a None) to something else like a status code or error message.

C# didn't take the wrapper route and introduced [nullable references]({% post_url 2023-03-06-NullableOperatorsAndReferences %}) instead.

With nullable references turned on, all our object references are not null by default. If we want a reference to accept null, we should annotate the type with a ?. The same way we do it for nullable ints.

```csharp
Movie? GetMovieById(int movieId);
//  ^^^
// It might be null.
```

Yes, that name is kind of misleading. It should be "not nullable" references.

That's a feature we should turn on and make all nullable warnings as errors.

With Option, Result, or nullable references, we make our method signatures honest. That's already a gain.
