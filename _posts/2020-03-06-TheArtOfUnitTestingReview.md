---
layout: post
title: "The Art of Unit Testing: Takeaways"
tags: books
---

This is THE book to learn how to write unit tests. It starts from the definition of a unit test to how to implement them in your organization. It covers the subject extensively.

"The Art of Unit Testing" teaches us to treat unit tests with the same attention and care we treat production code. For example, we should have test reviews instead of only code reviews.

These are some of the main ideas from "The Art Of Unit Testing."

> TL;DR
> 
> 1. Write trustworthy tests
> 2. Have a unit test project per project and a test class per class
> 3. Keep a set of always-passing unit tests
> 4. Use "UnitOfWork_Scenario_ExpectedBehaviour" for your test names
> 5. Use builders instead of SetUp methods

## 1. Write Trustworthy Tests

**Write trustworthy tests**. A test is trustworthy if you don't have to debug it to make sure it passes.

To write trustworthy tests, avoid any logic in your tests. If you have conditionals and loops in your tests, you have logic in them.

You can find logic in helper methods, fakes, and assert statements. Avoid logic in the assert statements, use hardcoded values instead. 

Tests with logic are hard to read and replicate. A unit test should consist of method calls and assert statements. 

## 2. Organize Your Tests

**Have a unit test project per project and a test class per class**. You should easily find tests for your classes and methods.

Create separate projects for your unit and integration tests. Add the suffix _"UnitTests"_ and _"IntegrationTests"_ accordingly. For a project `Library`, name your tests projects `Library.UnitTests` and `Library.IntegrationTests`.

Create tests inside a file with the same name as the tested code adding the suffix _"Tests"_. For `MyClass`, your tests should be inside `MyClassTests`. Also, you can group features in separate files by adding the feature name as a suffix. For example, `MyClassTests.AnAwesomeFeature`.

## 3. Have a Safe Green Zone

**Keep a set of always-passing unit tests**. You will need some configurations for your integration tests: a database connection, environment variables, or some files in a folder. Integration tests will fail if those configurations aren't in place. So, developers could ignore some failing tests, and real issues, because of those missing configurations. 

Therefore, **separate your unit tests from your integration tests**. Put them into different projects. This way, you will distinguish between a missing setup and an actual problem with your code.

**A failing test should mean a real problem, not a false positive**.

<figure>
<img src="https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="The Art of Unit Testing Takeaways" />

<figcaption>Whangarei Falls, Whangarei, New Zealand. <span>Photo by <a href="https://unsplash.com/@timswaanphotography?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Tim Swaan</a> on <a href="https://unsplash.com/s/photos/outdoor?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## 4. Use a Naming Convention

**Use UnitOfWork_Scenario_ExpectedBehaviour for your test names**. You can read it as follow: when calling *"UnitOfWork"* with *"Scenario"*, then it *"ExpectedBehaviour"*. 

In this naming convention, a Unit of Work is any logic exposed through public methods that return value, change the system state, or make an external invocation.
	
With this naming convention is clear the logic under test, the inputs, and the expected result. You will end up with long test names, but it's OK to have long test names for the sake of readability.

## 5. Prefer Builders over SetUp methods

**Use builders instead of SetUp methods**. Tests should be isolated from other tests. Sometimes, SetUp methods create shared state among your tests. You will find tests that pass in isolation but don't pass alongside other tests and tests that need to be run many times to pass. 

Often, SetUp methods end up with initialization for only some tests. Tests should create their own world. **Initialize what's needed inside every test using builders**.

Voilà! These are my main takeaways. Unit testing is a broad subject. The Art of Unit Testing cover almost all you need to know about it. The main lesson from this book is to write readable, maintainable, and trustworthy tests. Remember, the next person reading your tests will be you.

> "Your tests are your safety net, so do not let them rot."

If you're new to unit testing, start reading my [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}). You will write your first unit test in C# with MSTest. For more naming conventions, check [how to name your unit tests]({% post_url 2021-04-12-UnitTestNamingConventions %}).

_Happy testing!_