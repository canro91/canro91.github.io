---
layout: post
title: How to name your unit tests. 4 test naming conventions
tags: tutorial csharp
cover: Cover.png
cover-alt: 4 test naming conventions
---

From our previous post, we learned about [4 common mistakes]({% post_url 2021-03-29-UnitTestingCommonMistakes %}) we make when writing our first unit tests. One of them is not to follow a naming convention. Let's see four naming conventions for our unit tests.

**Test names should tell the scenario under test and the expected result. Writing long names is acceptable since test names should show the purpose behind what they're testing. When writing tests, prefer good test names over assertion messages.**

These are 4 common naming conventions we can use. Let's continue to use Stringie, a (fictional) library to manipulate strings. Stringie has a `Remove()` method to remove a substring from the beginning or the end of an input string.

## 1. UnitOfWork_Scenario_ExpectedResult

```csharp
[TestClass]
public class RemoveTests
{
    [TestMethod]
    public void Remove_NoParameters_ReturnsEmpty() {}

    [TestMethod]
    public void Remove_ASubstring_RemovesOnlyASubstring() {}
}
```

We find this naming convention in the book [The Art of Unit Testing](https://www.manning.com/books/the-art-of-unit-testing-second-edition) ([my takeaways]({% post_url 2020-03-06-TheArtOfUnitTestingReview %})). This convention uses underscores to separate the unit of work or entry point, the test scenario and the expected behavior. 

With this convention, we can read our test names out loud like this: "When calling Remove with no parameters, then it returns empty".

<div class="message">
Grab a free copy of my <a href="/UnitTesting" target="_blank">Unit Testing 101 ebook</a> where I include these four naming conventions and three more chapters to start writing unit tests with C# and MSTest. 
</div>

## 2. Plain English sentence

```csharp
[TestClass]
public class RemoveTests
{
    [TestMethod]
    public void Returns_empty_with_no_parameters() {}

    [TestMethod]
    public void Removes_only_a_substring() {}
}
```

Unlike the "UnitOfWork_Scenario_ExpectedResult" convention, this convention strives for a less rigid name structure.

This convention uses sentences in plain English for test names. We describe in a sentence what we're testing in a language easy to understand even for non-programmers. For more readability, we separate in each word in our sentence with underscores.

This convention considers smells adding method names and filler words like "should" or "should be" in our test names. For example, instead of writing, "should_remove_only_a_substring", we should write "removes_only_a_substring".

You could read more about this convention in [You are naming your tests wrong!](https://enterprisecraftsmanship.com/posts/you-naming-tests-wrong/)

<figure>
<img src="https://images.unsplash.com/photo-1524411289573-283bf2f298e8?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=500&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjE2NDQ3NzQ3&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="jar of blueberries" />

<figcaption>Photo by <a href="https://unsplash.com/@hudsoncrafted?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Debby Hudson</a> on <a href="/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 3. Sentence from classes and methods names

```csharp
[TestClass]
public class RemoveGivenASubstring
{
    [TestMethod]
    public void RemovesThatSubstring() {}

    [TestMethod]
    public void RemovesThatSubstringFromTheEnd() {}
}
```
    
This naming convention uses sentences in plain English too. In this case, class names will act as the subject of our sentences and method names as the verb and the complement. We write units of work or entry points in class names and expected results in method names.

Also, we can split different scenarios in separate classes. We add the scenarios in class names with the keyword `Given` followed by the scenario under test.

For our `Remove()` method, we can name our test class `RemoveGivenASubstring` and our test methods `RemovesOnlyASubstring` and `RemovesSubstringFromTheEnd`.

With this convention, we can read our test names like full sentences in the "Test Explorer" menu in Visual Studio when we group our tests by class. Like this: "Remove, given a substring, removes that substring".

{% include image.html name="TestExplorerGroupByClasses.png" caption="Visual Studio 'Solution Explorer' showing our sample tests group by class" alt="Visual Studio Solution Explorer with our sample tests" %}

You can read more about this convention in [ardalis' Unit Test Naming Convention](https://ardalis.com/unit-test-naming-convention/)

## 4. Nested classes and methods

```csharp
[TestClass]
public class RemoveTests
{
    [TestMethod]
    public void ReturnsEmpty() {}
    
    [TestClass]
    public class GivenASubstring
    {
        [TestMethod]
        public void RemovesThatSubstring() {}

        [TestMethod]
        public void RemovesThatSubstringFromTheEnd() {}
    }
}
```

This last convention uses sentences splitted into class and method names too. Unlike the previous naming convention, each scenario has its own nested class.

For example, instead of having a test class `RemoveGivenASubstring`, we create a nested class `GivenASubstring` inside a `RemoveTests` class.

You can learn more about this last convention in Kevlin Henney's presentation [Structure and Interpretation of Test Cases](https://www.youtube.com/watch?v=tWn8RA_DEic).

Voilà! That's how we can name our unit tests. Remember naming things is hard. Pick one of these four naming convention and stick to it. But, if you inherit a codebase, prefer the convention already in used. I hope you can write more readable test names after reading this post.

If you want to practice naming unit tests, check my [Unit Testing 101](https://github.com/canro91/Testing101) repository. There you will find the test names that Stringie developers wrote. _Your mission, Jim, should you choose to accept it, is to write better names._

[![canro91/Testing101 - GitHub](https://gh-card.dev/repos/canro91/Testing101.svg)](https://github.com/canro91/Testing101)

If you're new to unit testing, read my post on [how to write your first unit tests in C#]({% post_url 2021-03-15-UnitTesting101 %}) and check the [4 common mistakes when writing your first tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}). Don't miss the rest of my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I also cover mocking, assertions and other best practices.

_Happy testing!_
