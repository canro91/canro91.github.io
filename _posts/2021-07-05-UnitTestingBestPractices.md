---
layout: post
title: "Unit Testing Best Practices: A checklist"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Unit Testing Best Practices"
---

In the last couple of months, we've covered the subject of Unit Testing quite a lot. From [how to write your first unit tests]({% post_url 2021-03-15-UnitTesting101 %}) to [create test data with Builders]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}) to [how to write better fakes]({% post_url 2021-06-07-TipsForBetterStubsAndMocks %}). I hope I've helped you to start writing unit tests or write even better unit tests.

This time, I'm bringing some of the tips and best practices from my previous posts in one place. 

## On Naming

### Choose a naming convention and stick to it.

**Every test name should tell the scenario under test and the expected result**. Don't worry about long test names. But, don't name your tests: `Test1`, `Test2` and so on.

**Describe in your test names what you're testing in a language easy to understand even for non-programmers.**

**Don't prefix your test names with "Test".** If you're using a testing framework that doesn't need keywords in your test names, don't do that. With MSTest, there are attributes like `[TestClass]` and `[TestMethod]` to mark methods as tests. Other testing frameworks have similar attributes. 

**Don't use filler words like "Success" or "IsCorrect" in test names**. Instead, tell what "success" and "correct" means for that test. Is it a successful test because it doesn't throw exceptions? Is it successful because it returns a value different from null? Make your test names easy to understand.

<div class="message">If you want to learn more about naming your tests, check <a href="/2021/04/12/UnitTestNamingConventions">How to name your test: 4 naming conventions</a> where we write test names for the same methods using 4 different naming conventions.</div>

## On Organization

### Make your tests easy to find.

**Put your unit tests in a test project named after the project they test.** Use the suffix "Tests" or "UnitTests". For example, if you have a library called `MyLibrary`, name your test project: `MyLibrary.UnitTests`.

**Put your unit tests separated in files named after the unit of work or entry point of the code you're testing.** Use the suffix "Tests". For a class `MyClass`, name your test file: `MyClassTests`.

<figure>
<img src="https://images.unsplash.com/photo-1426927308491-6380b6a9936f?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjIxNTY2NDk2&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Workbench full of tools" />

<figcaption>Keep your tests organized and easy to find. Photo by <a href="https://unsplash.com/@barnimages?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Barn Images</a> on <a href="https://unsplash.com/s/photos/organization?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## On Assertions

### Follow the Arrange/Act/Assert (AAA) principle.

**Separate the body of your tests.** Use line breaks to visually separate the three AAA parts in the body of your tests.

**Don't repeat the logic under test in your assertions.** And, please, don't copy the tested logic and paste it into private methods in your test files to use it in your assertions. Use known/pre-calculated values, instead.

**Don't make private methods public to test them.** Test private methods when calling your code under test through its public methods.

**Have a single Act and Assert parts in your tests.** Don't put test values inside a collection to loop through it and assert on each value. Use parameterized tests to test the same scenario with different test values.

**Use the right assertion methods of your testing framework.** For example, use `Assert.IsNull(result);` instead of `Assert.AreEqual(null, result);`.

**Prefer assertion methods for strings** like `Contains()`, `StartsWith()` and `Matches()` instead of exactly comparing two strings.

<div class="message">If you want to learn more about writing better assertions, check <a href="/2021/03/29/UnitTestingCommonMistakes/">4 common unit testing mistakes</a> where we learn not to duplicate logic in your assertions.</div>

## On Test Data

### Keep the amount of details at the right level

**Give enough details to your readers**, but not too many to make your tests noisy.

**Use factory methods** to reduce complex Arrange scenarios.

**Make your scenario under test and test values extremely obvious.** Don't make developers to decode your tests. Create constants for common test data and expected values.

**Use object mothers to create input test values.** Have a factory method or property holding a ready-to-use input object. Then, change what you need to match the scenario under test.

**Prefer Builders to create complex object graphs.** Object mothers are fine if you don't have lots of variations of the object being constructed. If that's the case, use the Builder pattern. Compose builders to create complex objects in your tests.

<div class="message">Do you want to see examples of Object Mothers and Builders? Check <a href="/2021/04/26/CreateTestValuesWithBuilders/">How to create test data with the Builder pattern </a> where we test a credit card validator.</div>

## On Stubs and Mocks

### Write dumb fakes

**Use fakes when you depend on external systems you don't control.** Check your code makes the right calls,  with the right messages.

**Avoid complex logic inside your fakes.** For example, don't add flags to your stubs to return one value or another. Write separate fakes, instead.

**Don't write assertions for stubs.** Assert on the output of your code under test or use mocks.

**Keep one mock per test.** Don't use multiple mocks per test. Write separate tests, instead.

**Make tests set their own values for fakes.** Avoid magic values inside your stubs.

**Use descriptive names in your fakes.** Name your stubs to indicate the value they return or the exception they throw. For example, `ItemOutOfStockStockService` and `FixedDateClock`.

<div class="message">Do you know what are stubs and mocks? Check <a href="/2021/05/24/WhatAreFakesInTesting">What are fakes in unit testing</a> to learn the difference between them. Check these <a href="/2021/06/07/TipsForBetterStubsAndMocks">Tips to write better stubs and mocks</a>.</div>

Voilà! Those are my best practices to write ~~better~~ great unit tests. Don't forget to always start writing failing tests. And, make sure they fail for the right reasons. If you don't follow Test-Driven Development, comment some of your code under test or change the assertions on purpose to see your tests failing.

If you want to have these best practices next to you, grab your own free copy of "Unit Testing 101". Feel free to share it.

<figure>
<a href="/UnitTesting"><img src="/assets/posts/2021-07-05-UnitTestingBestPractices/UnitTesting101.png" alt="Grab your own copy of Unit Testing 101" /></a>
<figcaption>For free. No email asked!</figcaption>
</figure>

Remember, not because you don't ship your tests to your end users, it doesn't mean you shouldn't care about the quality of them. Unit tests got your back when changing your code. They're your safety net.

_Happy testing!_