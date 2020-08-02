---
layout: post
title: Another two C# idioms - Part 3
tags: tutorial csharp
---

> [Two C# idioms - Part 1]({% post_url 2019-11-19-TwoCSharpIdioms %}), [Another Two C# idioms - Part 2]({% post_url 2020-07-28-AnotherTwoCSharpIdioms %})

* **Instead of checking if a dictionary contains an item before adding it, use `TryAdd`**. It will return if the item was added or not. Unlike `Add`, if the given key is already in the dictionary, `TryAdd` won't throw any exception. It will simply do nothing.

```csharp
var myDictionary = new Dictionary<string, string>();
myDictionary.Add("foo", "bar");

// System.ArgumentException: An item with the same key has already been added. Key: foo
myDictionary.Add("foo", "baz");
```

```csharp
var myDictionary = new Dictionary<string, string>();

if (!myDictionary.ContainsKey("foo"))
  myDictionary.Add("foo", "bar");
```

```csharp
var myDictionary = new Dictionary<string, string>();
myDictionary.TryAdd("foo", "bar"); // true

myDictionary.Add("foo", "baz");
myDictionary.TryAdd("foo", "bar"); // false
```

* **Avoid `KeyNotFoundException` with `TryGetValue` or `GetValueOrDefault`**. At least now, the `KeyNotFoundException` message contains the key name. _The old days chasing the not-found key are over._

`TryGetValue` uses an output parameter with the found value. It outputs a default value when the dictionary doesn't contain the item. `TryGetValue` dates back to the days without tuples.

`GetValueOrDefault` returns a default value or one you provide.

```csharp
var dict = new Dictionary<string, string>();

// System.Collections.Generic.KeyNotFoundException: The given key 'foo' was not present in the dictionary.
dict["foo"];
```

```csharp
var dict = new Dictionary<string, string>();

dict.TryGetValue("foo", out var foo); // false, foo -> null

dict.Add("foo", "bar");
dict.TryGetValue("foo", out foo); // true, foo -> "bar"
```

```csharp
var dict = new Dictionary<string, string>();

dict.GetValueOrDefault("foo"); // null
dict.GetValueOrDefault("foo", "withoutFoo"); // "withoutFoo"

dict.Add("foo", "bar");
dict.GetValueOrDefault("foo", "withoutFoo"); // "bar"
```

_Happy coding!_
