---
layout: post
title: "Goodbye, NullReferenceException: Nullable Operators and References"
tags: tutorial csharp
cover: Cover.png
cover-alt: "<PutYourCoverAltHere>" 
---

In the [previous post of this series]({% post_url 2023-02-20-WhatNullReferenceExceptionIs %}), we covered two ideas to avoid the NullReferenceException: we should check for `null` before accessing the members of an object and check the input parameters of our methods.

Let's see some new C# operators to simplify null checking and a new feature to better signal possible `null` references.

## 1. C# Nullable Operators

C# has introduced new operators to simplify our null checks: `?.`, `??`, and `??=`. These operators don't prevent us from having `null` in the first place, but they help us to easily write our null checks.

### Without Nullable Operators

Let's start with an example and refactor it to use these new operators.

```csharp
string path = null;

if (HttpContext.Current == null 
    || HttpContext.Current.Request == null 
    || HttpContext.Current.Request.ApplicationPath  == null)
{
    path = "/some-default-path-here";
}
else
{
    path = HttpContext.Current.Request.ApplicationPath;
}
```

If you have worked with the [old ASP.NET framework]({% post_url 2020-03-23-GuideToNetCore %}), you might have done something like that. If not, don't worry. We're only accessing a property down in a property chain, but any of those properties could be `null`.

Notice that to defend against `null`, we checked if every property was `null` to "fail fast" and use a default value.

### With Nullable Operators

Now, let's use the new nullable operators instead,

```csharp
var path = HttpContext.Current?.Request?.ApplicationPath
//                           ^^^      ^^^
              ?? "/some-default-path-here";
//           ^^^^
```

More compact, right?

With the **null-conditional operator** (`?.`), we access the property or method of an object only if the object isn't `null`. Otherwise, the entire expression evaluates to `null`. For our example, we retrieve `ApplicationPath` only if `Request` isn't `null` and `Current` isn't `null`, and `HttpContext` isn't `null`.

Then, with the **null-coalescing operator** (`??`), we evaluate an alternative expression if the one on the left of the `??` operator isn't `null`. For our example, if any of the properties in the chain to retrieve `ApplicationPath` is `null`, the whole expression is `null`, and the `path` variable gets assigned to the default string.

With the **null-coalescing assignment operator** (`??=`), we assign a new value to a variable only if it's `null`. We could also write our example like this,

```csharp
var path = HttpContext.Current?.Request?.ApplicationPath;
path ??= "/some-default-path-here";
//  ^^^^
//
// The same as
//if (path == null)
//{
//    path = "/some-default-path-here"; 
//}
```

Notice how we refactored our original example to only two lines of code with these three new operators. Again we could still have `null` values. These nullable operators make our lives easier by simplifying our null checks.

<figure>
<img src="https://images.unsplash.com/photo-1517420704952-d9f39e95b43e?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY4MDY0OTcyNw&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Electronic devices in a workbench" />

<figcaption>What if we could tell when something is null? Photo by <a href="https://unsplash.com/@nicolasthomas?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Nicolas Thomas</a> on <a href="https://unsplash.com/photos/3GZi6OpSDcY?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 2. C# Nullable References

To solve the NullReferenceException, we should check for `null`. We got that! But the thing is knowing when we should do it or not. That's precisely what C# 8.0 solves with Nullable References.

**With C# 8.0, all reference variables are non-nullable by default. Accessing the member of nullable references results in compiler warnings or errors.**

This is a breaking change. Therefore we need to turn on this feature at the project level in our csproj files. Like these,

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net6.0</TargetFramework>
    <!--             ^^^^^^ -->
    <!-- We could use netcoreapp3.1|net5.0|net6.0|.net7.0 too -->
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <!--      ^^^^^^ -->
    <!-- We could use enable|disable|warning too -->
    <WarningsAsErrors>nullable</WarningsAsErrors>
    <!--              ^^^^^^^^ -->
    <!-- We can take the extreme route -->

  </PropertyGroup>

</Project>
```

To use Nullable References, we need to target .NET Core 3 and upward. And inside the `Nullable` node in our csproj files, we could use: `enable`, `disable`, or `warning`. Even, we can take the extreme route and consider all nullable warnings as compilation errors.

### With Nullable References On

Let's see what our motivating example looks like with Nullable References turned on,

```csharp
string path = null;
//            ^^^^
// CS8600: Converting null literal or possible null value to non-nullable type

if (HttpContext.Current == null
    || HttpContext.Current.Request == null
    || HttpContext.Current.Request.ApplicationPath == null)
{
    path = "/some-default-path-here";
}
else
{
    path = HttpContext.Current.Request.ApplicationPath;
}

// This isn't the real HttpContext class...
// We're writing some dummy declarations to prove a point
public class HttpContext
{
    public static HttpContext Current;
    //                        ^^^^^^^^
    // CS8618: Non-nullable field 'Current' must contain
    // a non-nullable value when exiting constructor

    public HttpContext()
    //     ^^^^^^^^^^^
    // CS8618: Non-nullable field 'Current' must contain
    // a non-nullable value when exiting constructor
    {
    }

    public Request Request { get; set; }
}

public record Request(string ApplicationPath);
```

Notice we have a warning when initializing `path` to `null`. And another one in the declaration of our `HttpContext` class if we don't initialize any non-nullable fields. That's not the real `HttpContext` by the way but bear with me. Also, we don't need to check for `null` when retrieving the `ApplicationPath` since all our references aren't nullable by definition.

To declare a variable that can be `null`, we need to add to its type declaration a `?`. In the same way, we have always declared nullable primitive types like `int?`.

### Without Null Checks

Let's change our example to have nullable references and no null checks,

```csharp
// Notice the ? symbol here
//   vvv
string? path = HttpContext.Current.Request.ApplicationPath;
//             ^^^^^^^^^^^
// CS8602: Deference of a possibly null value

// This isn't the real HttpContext class...
// We're writing some dummy declarations to prove a point
public class HttpContext
{
    public static HttpContext? Current;
    //                      ^^^
    // Notice the ? symbol here

    public HttpContext()
    //     ^^^
    // No more warnings here
    {
    }

    public Request Request { get; set; }
}

public record Request(string? ApplicationPath);
```

Notice this time, when declaring the variable `path`, we have a warning because we're accessing the `Current` property, which might be `null`. Also, notice we changed, inside the `HttpContext` class, the `Current` property to have the `HttpContext?` type (with a `?` at the end of the type).

Now with Nullable References, we have a way of telling when we should check for `null` by looking at the signature of our methods.

Voilà! Those are the new C# operators to simplify our null checks. We said "new" operators, but we have had them since C# 6.0. And that's how we can tell if our references can be `null` or not using Nullable References.

We have these nullable operators available even if we're using the old .NET Framework. But, to use Nullable References, we should upgrade at least to .NET Core 3.0.

In the next post, we will cover [the Option type as an alternative to null]({% post_url 2023-03-20-UseOptionInsteadOfNull %}) and how to avoid the NullReferenceException when working with LINQ.

If you want to read more C# content, check [my C# Definitive Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}) and my [top of recent C# features]({% post_url 2021-09-13-TopNewCSharpFeatures %}). These three operators and the nullable references are some of them.

_Happy coding!_