---
layout: post
title: "Two C# idioms: On Dictionaries"
tags: tutorial csharp
series: C# idioms
cover: Cover.png
cover-alt: Two C# idioms - Dictionaries
---

This part of the C# idioms series is only about dictionaries. Let's get rid of exceptions when working with dictionaries.

## Instead of checking if a dictionary contains an item before adding it, use TryAdd

`TryAdd()` will return if an item was added or not to the dictionary. Unlike `Add()`, if the given key is already in the dictionary, `TryAdd()` won't throw any exception. It will simply do nothing. The item is already there.

Before, if we added an item that already exists on the dictionary, we got an `ArgumentException`.

```csharp
var myDictionary = new Dictionary<string, string>();
myDictionary.Add("foo", "bar");

myDictionary.Add("foo", "baz");
// ^^^
// System.ArgumentException:
//     An item with the same key has already been added. Key: foo
```

After, we checked first if the dictionary contains the item.

```csharp
var myDictionary = new Dictionary<string, string>();

if (!myDictionary.ContainsKey("foo"))
  myDictionary.Add("foo", "bar");
```

Even better, let's use `TryAdd()`.

```csharp
var myDictionary = new Dictionary<string, string>();
myDictionary.TryAdd("foo", "bar"); // true

myDictionary.Add("foo", "baz");
myDictionary.TryAdd("foo", "bar"); // false
```

<figure>
<img src="https://images.unsplash.com/photo-1583361703300-bf0a4dc1723c?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjIwMTY5MjE4&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="A plain old dictionary" />

<figcaption>Do you imagine a big book when you hear 'dictionary'? Photo by <a href="https://unsplash.com/@edhoradic?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Edho Pratama</a> on <a href="https://unsplash.com/s/photos/dictionary?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Avoid KeyNotFoundException with TryGetValue or GetValueOrDefault

At least now, the `KeyNotFoundException` message contains the name of the not-found key. The old days chasing the not-found key are over.

On one hand, `TryGetValue()` uses an output parameter with the found value. It outputs a default value when the dictionary doesn't contain the item. `TryGetValue()` dates back to the days without tuples.

On another hand, `GetValueOrDefault()` returns a default value or one you provide if the key wasn't found.

Before, if we tried to retrieve a key that didn't exist on a dictionary, we got a `KeyNotFoundException`.

```csharp
var dict = new Dictionary<string, string>();

dict["foo"];
// ^^^
// System.Collections.Generic.KeyNotFoundException:
//     The given key 'foo' was not present in the dictionary.
```

After, we used `TryGetValue()`.

```csharp
var dict = new Dictionary<string, string>();

dict.TryGetValue("foo", out var foo); // false, foo -> null

dict.Add("foo", "bar");
dict.TryGetValue("foo", out foo); // true, foo -> "bar"
```

Even better, we use `GetValueOrDefault()`.

```csharp
var dict = new Dictionary<string, string>();

dict.GetValueOrDefault("foo"); // null
dict.GetValueOrDefault("foo", "withoutFoo"); // "withoutFoo"

dict.Add("foo", "bar");
dict.GetValueOrDefault("foo", "withoutFoo"); // "bar"
```

Voilà! That's how to get rid of exception when working with dictionaries. Use `TryAdd()` and `GetValueOrDefault()`. Or, if you prefer output parameters, `TryGetValue()`.

Don’t miss the [previous C# idioms]({% post_url 2020-07-28-AnotherTwoCSharpIdioms %}) to separate view models into versions and the [next two C# idioms]({% post_url 2021-09-27-TwoCSharpIdiomsPart4 %}) to better work with defaults and switches.

_Happy coding!_
