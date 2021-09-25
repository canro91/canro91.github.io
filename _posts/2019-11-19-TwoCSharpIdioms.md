---
layout: post
title: Two C# idioms
tags: tutorial csharp
series: C# idioms
cover: Cover.png
cover-alt: Two C# idioms
---

You have heard about Pythonic code? Languages have an expressive or "native" way of doing things. But, what about C#? Is there C-Sharpic code?

In this series of posts, I will attempt to present some idioms or "expressions" to write more expressive C# code. I collected these idioms after reviewing code and getting mine reviewed too.

In this first part, you have two useful C# idioms on conditionals and its alternative solutions.

## Instead of lots of or’s, use an array of possible values

Use an array of known or valid options, instead of a bunch of comparison inside an `if` statement.

Use this idiom when checking preconditions or validating objects.

Before, we used comparison with `||` inside an `if` statement.

```csharp
if (myVar == 2 || myVar == 5 || myVar == 10)
{
    DoSomeOperation();
}
```

After, we can use an array of valid options.

```csharp
var allowedValues = new int[] { 2, 5, 10 };
if (allowedValues.Any(t => myVar == t))
{
    DoSomeOperations();
}
```

If you need to check for a new value, you add it in the array instead of adding a new condition in the `if` statement.

## Instead of lots of if's to find a value, use an array of Func

Replace consecutive `if` statements to find a value with an array of `Func` or small choice functions. Then, pick the first result different from a default value or `null`.

Use this idiom when finding a value among multiple choices.

Before, we used consecutive `if` statements.

```csharp
var someKey = FindKey();
if (someKey == null)
    someKey = FindAlternateKey();
if (someKey == null)
    someKey = FindDefaultKey();
```

After, we use a list of `Func`.

```csharp
var fallback = new List<Func<SomeObject>>
{
    FindKey(),
    FindAlternateKey(),
    FindDefaultKey()
};
var someKey = fallback.FirstOrDefault(t => t != null);
```

You can take advantage of the **Null-coalescing operator** (??) if these choice functions return `null` when a value isn't found.

The Null-coalescing operator returns the expression on the left it it isn't null. Otherwise, it evaluates the expression on the right.

```csharp
var someKey = FindKey() ?? FindAlternateKey() ?? FindDefaultKey();
```

Similarly, if you need to add a new alternative, either you add it in the array or nest it instead of adding the new alternative in the `if` statement.

### Validate a complex object with an array of Func

Also, this last idiom is useful when validating an object against a list of rules or conditions. Create a function for every rule, then use `All()` LINQ method to find if the input object or value satisfy all required rules.

```csharp
var toValidate = new ComplexObject();

Func<ComplexObject, bool> Validation = (obj) => /* Validate something here...*/;
Func<ComplexObject, bool> AnotherValidation = (obj) => /* Validate something else here...*/;

var validations = new List<Func<ComplexObject, bool>>
{
    Validation,
    AnotherValidation
}
var isValid = validations.All(validation => validation(toValidate));
```

Voilà! These are our first two idioms on conditionals. I have found these two idioms more readable in some scenarios. But, don't start to rewrite or refactor your code to follow any convention you find online. Make sure to follow the conventions in your own codebase, first.

These two first idioms rely on `Func` and LINQ, if you need to learn more on these subjects, check [What the Func, Action!]({% post_url 2019-03-22-WhatTheFuncAction %}) and [Quick Guide to LINQ]({% post_url 2021-01-18-LinqGuide %}).

_Happy coding!_
