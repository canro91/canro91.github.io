---
layout: post
title: "Don't duplicate logic in Asserts: The most common mistake on unit testing"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Don't duplicate logic in Asserts"
---

We have covered some [common mistakes when writing unit tets]({% post_url 2021-03-29-UnitTestingCommonMistakes %}). Some of them may seem obvious. But, we all have made this one mistake when we started to write unit tests. This is the most common mistake when writing unit tests and how to fix it.

**Don't repeat the logic under test when verifying the expected result of a test. Instead, use known, hard-coded, pre-calculated values.**

Let's write some tests for [Stringie](https://github.com/canro91/Testing101), a (fictional) library to manipulate strings with  a fluent interface. Stringie has a `Remove()` method to remove substrings from the end of a string.

We can use Stringie `Remove()` method like this,

```csharp
var hello = "Hello, world!";

string removed = hello.Remove("world!").From(The.End);
// "Hello,"
```

## Don't Copy and Paste the tested logic

**When writing unit tests, don't copy the tested logic and paste it into private methods to use them inside assertions.**

If we bring the tested logic to private methods in our tests, we will have code, and bugs, in two places. Duplication is the root of all evil. Even, inside our tests.

Please, don't write assertions like the one in this test.

```csharp
[TestMethod]
public void Remove_ASubstring_RemovesThatSubstringFromTheEnd()
{
    string str = "Hello, world!";

    string transformed = str.Remove("world!").From(The.End);

    Assert.AreEqual(RemoveFromEnd(str, "world!"), transformed);
}

private string RemoveFromEnd(string str, string substring)
{
    var index = str.IndexOf(substring);
    return index >= 0 ? str.Remove(index, substring.Length) : str;
}
```

<figure>
<img src="https://images.unsplash.com/photo-1533046652171-aecb6943c03a?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzMTcyMTIyMw&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="building of apartments" />

<figcaption>That's a lot of duplication. Photo by <a href="https://unsplash.com/@joshchai?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Joshua  Chai</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Don't make internals public

Also, by mistake, we expose internals of the tested logic to use them in assertions. We make private methods public and static. Even to test those private methods directly.

From our [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}), we learned to write unit tests through public methods. We should test the observable behavior of our tested code. A returned value, a thrown exception or an external invocation made.

Again, don't write assertions like the one in this test.

```csharp
[TestMethod]
public void Remove_ASubstring_RemovesThatSubstringFromTheEnd()
{
    string str = "Hello, world!";

    string transformed = str.Remove("world!").From(The.End);

    Assert.AreEqual(Stringie.PrivateMethodMadePublicAndStatic(str), transformed);
}
```

## Use known values to Assert

**Instead of duplicating the tested logic, by exposing internals or copy-pasting code into assertions, use a known expected value.**

If we end up using the same expected values, we can create constants for them. Like `const string Hello = "Hello";` or `const string HelloAndComma = "Hello,";` for our example.

For our sample test, simply use the expected substring `"Hello,"`. Like this,

```csharp
[TestMethod]
public void Remove_ASubstring_RemovesThatSubstringFromTheEnd()
{
    string str = "Hello, world!";

    string transformed = str.Remove("world!").From(The.End);

    // Let's use a known value in our assertions
    Assert.AreEqual("Hello,", transformed);
}
```

Voilà! That's the most common mistake when writing unit tests. It seems silly! But, often we duplicate Math operations and string concatenations and it passes unnoticed. Remember, don't put too much logic in your tests. Tests should be only assignments and method calls.

If you're new to unit testing, read my post on [how to write your first unit tests in C# with MSTest]({% post_url 2021-03-15-UnitTesting101 %}) and check the [4 common mistakes when writing your first tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}). Also, don't miss my [Unit Testing Best Practices]({% post_url 2021-07-05-UnitTestingBestPractices %}). You can have them in a pdf file for free.

_Happy testing!_