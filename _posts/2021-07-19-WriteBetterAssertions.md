---
layout: post
title: "How to write better assertions in your tests"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Unit Testing Best Practices"
---

There's a lot to say about how to [write good unit tests]({% post_url 2020-11-02-UnitTestingTips %}). This time, let's focus on best practices to write better assertions on our tests.

Here you have 5 tips to write better assertions on your unit tests.

> TL;DR
> 1. Follow the Arrange/Act/Assert (AAA) pattern
> 2. Separate each A of the AAA pattern with line breaks
> 3. Don't put logic in your assertions
> 4. Have a single Act and Assert parts in each test
> 5. Use the right Assertion methods

## 1. Follow the Arrange/Act/Assert (AAA) pattern

If you could take home only one thing: **follow the Arrange/Act/Assert (AAA) pattern**.

The Arrange/Act/Assert (AAA) pattern states that each test should contain three parts: Arrange, Act and Assert.

In the Arrange part, we create classes and input values needed to call the entry point of the code under test.

In the Act part, we call the method to trigger the logic being tested.

In the Assert part, we verify the code under test did what we expected. We check if it returned the right value, threw an exception or called another component.

For example, let's bring back one test for [Stringie](https://github.com/canro91/Testing101), a (fictional) library to manipulate strings, to show the AAA pattern. Notice how each test has these 3 parts.

For the sake of the example, we have put comments in each AAA part. You don't need to do that on your own tests.

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Stringie.UnitTests
{
    [TestClass]
    public class RemoveTests
    {
        [TestMethod]
        public void Remove_ASubstring_RemovesThatSubstring()
        {
            // Arrange
            string str = "Hello, world!";

            // Act
            string transformed = str.Remove("Hello");

            // Assert
            Assert.AreEqual(", world!", transformed);
        }

        [TestMethod]
        public void Remove_NoParameters_ReturnsEmpty()
        {
            // Arrange
            string str = "Hello, world!";

            // Arrange
            string transformed = str.Remove();

            // Arrange
            Assert.AreEqual(0, transformed.Length);
        }
    }
}
```

ICYMI, we've been using Stringie to [write our first unit tests in C#]({% post_url 2021-03-15-UnitTesting101 %}) and to learn about [4 common mistakes when writing tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}).

## 2. Separate each A of the AAA pattern

**Use line breaks to visually separate the AAA parts of each test.**

Let's take a look at the previous tests without line breaks between each AAA part.

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Stringie.UnitTests
{
    [TestClass]
    public class RemoveTests
    {
        [TestMethod]
        public void Remove_ASubstring_RemovesThatSubstring()
        {
            string str = "Hello, world!";
            string transformed = str.Remove("Hello");
            Assert.AreEqual(", world!", transformed);
        }

        [TestMethod]
        public void Remove_NoParameters_ReturnsEmpty()
        {
            string str = "Hello, world!";
            string transformed = str.Remove();
            Assert.AreEqual(0, transformed.Length);
        }
    }
}
```

Not that bad. The larger the tests, the harder it gets.

**Have the three AAA parts separated to make your tests easier to read.**

In case you're wondering about those weird method names, they follow one of the most common [test naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}).

<figure>
<img src="https://images.unsplash.com/photo-1613083093144-bfa5c3eb8337?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjIzNjkzMzU2&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Three paths on the snow" />

<figcaption>Separate each A of the AAA pattern. Photo by <a href="https://unsplash.com/@polarmermaid?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Anne Nygård</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 3. Don't put logic in your assertions

**Don't repeat the logic under test in your assertions.** And, please, don't copy the tested logic and paste it into private methods in your test files to use it in your assertions. That's [the most common mistake when writing tests]({% post_url 2021-10-11-DontRepeatLogicInAssertions %}).

Use known, pre-calculated values. Declare constants for common expected values.

```csharp
[TestMethod]
public void Remove_ASubstring_RemovesThatSubstringFromTheEnd()
{
    string str = "Hello, world! Again, Hello";

    string transformed = str.Remove("Hello").From(The.End);

    // Notice how we hardcode an expected value here
    Assert.AreEqual("Hello, world! Again,", transformed);
}
```

Notice how we hardcoded an expected value in the Assert part. We didn't use any other method or copy the logic under test to find the expected substring.

## 4. Have a single Act and Assert

**Have a single Act and Assert parts in your tests**. Use parameterized tests to test the same scenario with different test values.

And, don't put the test values inside an array to loop through it to then assert on each value.

This is a parameterized test with MSTest.

```csharp
[DataTestMethod]
[DataRow("Hello")]
[DataRow("HELLO")]
[DataRow("HeLlo")]
public void Remove_SubstringWithDifferentCase_RemovesSubstring(string substringToRemove)
{
    var str = "Hello, world!";

    var transformed = str.RemoveAll(substringToRemove).IgnoringCase();

    Assert.AreEqual(", world!", transformed);
}
```

## 5. Use the right Assertion methods

**Use the right assertion methods of your testing framework**. And, don't roll your own assertion framework.

For example, prefer `Assert.IsNull(result);` over `Assert.AreEqual(null, result);`. And, prefer `Assert.IsTrue(result)` over `Assert.AreEqual(true, result);`.

When working with strings, prefer `StringAssert` methods like `Contains()`, `StartsWith()` and `Matches()` instead of exactly comparing two strings. That would make your tests easier to maintain.

Voilà! These are 5 tips to write better assertions. If you want a more complete list of best practices to write your unit tests, check my post [Unit Testing Best Practices: A Checklist]({% post_url 2021-07-05-UnitTestingBestPractices %}). And, don't miss [how to write custom assertions]({% post_url 2021-08-16-WriteCustomAssertions %}) to write even more readable tests.

If you're new to unit testing, start reading [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}) and [4 common unit testing mistakes]({% post_url 2021-03-29-UnitTestingCommonMistakes %}). For more advanced tips, check [how to write good unit tests]({% post_url 2020-11-02-UnitTestingTips %}) and [always write failing tests]({% post_url 2021-02-05-FailingTest %}).

_Happy testing!_