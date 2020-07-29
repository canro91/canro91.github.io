---
layout: post
title: Two CSharp idioms
tags: tutorial csharp
---

> [Another Two C# idioms - Part 2]({% post_url 2020-07-28-AnotherTwoCSharpIdioms %})

Two useful C# idioms you can find and its alternative solutions.

* **Instead of lots of or’s, use an array**. You can find this code when checking preconditions or validating objects.

```csharp
if (myVar == 2 || myVar == 5 || myVar == 10)
    DoSomeOperation();
```

```csharp
var allowedValues = new int[] { 2, 5, 10 };
if (allowedValues.Any(t => myVar == t))
    DoSomeOperations();
```

If you need to validate a new value, you add it in the array instead of adding a new condition in the `if` statement.

* **Instead of lots of if to find a value, use an array of** `Func` and pick the first value different from `null` or a default value. You can find this code when finding a value among multiple choices.

```csharp
var someKey = FindKey();
if (someKey == null)
    someKey = FindAlternateKey();
if (someKey == null)
    someKey = FindDefaultKey();
```

```csharp
var fallback = new List<Func<SomeObject>>
{
    FindKey(),
    FindAlternateKey(),
    FindDefaultKey()
};
var someKey = fallback.FirstOrDefault(t => t != null);
```

But, you could take advantage of _Null coleasing operator (??)_ if these choice functions return `null` when a value isn't found.

```csharp
var someKey = FindKey() ?? FindAlternateKey() ?? FindDefaultKey();
```

Similarly, if you need to add a new alternative, either you add it in the array or nest it instead of adding the new alternative in the `if` statement.

> I have found these two idioms more readable. But, make sure to follow the conventions in your codebase.