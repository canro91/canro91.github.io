---
layout: post
title: "Two Alternatives to Assertion Messages — and Two Ideas if You Do Want To Keep Them"
tags: csharp
---

I got this question from Ankush on my contact page:

> "I want to override the Assert method to avoid using Assert.True without a failure message. How can I achieve it?"

Here are 2 alternatives to assertion messages and 2 ideas if you do want them:

## 1. Don't use assertion messages. Write better test names instead.

[Test naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}), like the UnitOfWork_Scenario_Result, impose some order and structure to names. You won't have that inside assertion messages.

If you don't have too many assertions in your tests, with a good test name it's easy to figure out what failed and why.

## 2. Use assertion libraries with better messages.

Like [FluentAssertions](https://github.com/fluentassertions/fluentassertions) or [Shoudly](https://github.com/shouldly/shouldly). They have clearer and more verbose messages when an assertion fails.

Here's what MSTest, FluentAssertions, and Shoudly show when an assertion fails:

```csharp
[TestClass]
public class UnitTest1
{
    [TestMethod]
    public void ADummyTestToShowFailureMessages()
    {
        var anyBool = false;

        // With MSTest
        Assert.IsTrue(anyBool);
        // Message:
        // Assert.IsTrue failed.

        // With FluentAssertions
        anyBool.Should().BeTrue();
        //  Message:
        // Expected anyBool to be True, but found False.

        // With Shouldly
        anyBool.ShouldBe(true);
        //   Message: 
        // Test method AssertionLibraries.UnitTest1.ADummyTestToShowFailureMessages threw exception: 
        // Shouldly.ShouldAssertException: anyBool
        //    should be
        // True
        //    but was
        // False
    }
}
```

That's if you want assertion messages for the lack of good failure messages.

## Now, if you do want assertion messages for whatever reason:

## 3. Write custom assertion methods

Wrap MSTest, NUnit, XUnit or the testing library you're using inside custom methods with the assertion messages as required parameters. Like,

```csharp
AcmeCorp.CustomAssert.IsTrue(actual, yourMessageHereAsARequiredParam);
```

If you're doing code reviews, that's something to share with your team and enforce during reviews.

## 4. Create a custom analyzer to check the absence of assertion messages

Code reviews can be daunting. And even if all test methods in your test suite have assertion messages, anyone can decide not to use them.

Automate the boring part with an analyzer that warns you if you're not passing a message to every assertion.

Here's an analyzer from [xunit.analyzer](https://github.com/xunit/xunit.analyzers/blob/main/src/xunit.analyzers/X2000/AssertEqualShouldNotBeUsedForNullCheck.cs). That's a good place to start.

Voilà!

To read more about assertions, check [how to write better assertions]({% post_url 2021-07-19-WriteBetterAssertions %}) and [how to write custom Assertions to improve your tests]({% post_url 2021-08-16-WriteCustomAssertions %}). Don't miss the rest of my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}).
