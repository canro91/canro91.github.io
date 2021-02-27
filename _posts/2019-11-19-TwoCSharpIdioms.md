---
layout: post
title: Two C# idioms
tags: tutorial csharp
series: C# idioms
---

You have heard about Pythonic code? Languages have an expressive or "native" way of doing things. But, what about C#? Is there C-Sharpic code?

In this series of posts, I wil attempt to present some idioms or "expressions" to write more expressive C# code. I collected these idioms after reviewing code and getting mine reviewed too.

In this first part, you have two useful C# idioms on conditionals and its alternative solutions.

## Instead of lots of or’s, use an array of possible values

Use an array of known or correct values, instead of a bunch of comparison inside an `if` statement. You can find this code when checking preconditions or validating objects.

Before,

```csharp
if (myVar == 2 || myVar == 5 || myVar == 10)
    DoSomeOperation();
```

After,

```csharp
var allowedValues = new int[] { 2, 5, 10 };
if (allowedValues.Any(t => myVar == t))
    DoSomeOperations();
```

If you need to check for a new value, you add it in the array instead of adding a new condition in the `if` statement.

## Instead of lots of `if`'s to find a value, use an array of `Func`

Replace consecutive `if` statements to find a value with an array of `Func` or small choice functions. Then, pick the first result different from a default value or `null`. You can find this code when finding a value among multiple choices.

Before,

```csharp
var someKey = FindKey();
if (someKey == null)
    someKey = FindAlternateKey();
if (someKey == null)
    someKey = FindDefaultKey();
```

After,

```csharp
var fallback = new List<Func<SomeObject>>
{
    FindKey(),
    FindAlternateKey(),
    FindDefaultKey()
};
var someKey = fallback.FirstOrDefault(t => t != null);
```

Also, you could take advantage of the **Null Coleasing Operator** (??) if these choice functions return `null` when a value isn't found.

```csharp
var someKey = FindKey() ?? FindAlternateKey() ?? FindDefaultKey();
```

Similarly, if you need to add a new alternative, either you add it in the array or nest it instead of adding the new alternative in the `if` statement.

Voilà! These are our first two idioms on conditionals. I have found these two idioms more readable in some scenarios. But, don't start to rewrite or refactor your code to follow any convention you find online. Make sure to follow the conventions in your own codebase, first.

_Happy coding!_
