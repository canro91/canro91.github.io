---
layout: post
title: "Unit Testing 101: From Zero to Hero"
tags: tutorial csharp
cover: Cover.png
permalink: UnitTesting
---

Do you want to start writing unit tests, but don’t know where to start? Do you want to adopt unit testing in your team? I can help you!

If you’re a beginner or a seasoned developer new to unit testing, this is the place for you. No prerequisites are needed.

## Write it

Learn to [write your first unit tests with MSTest]({% post_url 2021-03-15-UnitTesting101 %}). Read what a unit test is, why we need unit tests, and what makes a good unit test. And understand [why we shouldn't try to test private methods]({% post_url 2024-11-30-TestingPrivateMethods %}).

Identify and fix these [four common mistakes]({% post_url 2021-03-29-UnitTestingCommonMistakes %}) when writing your first unit tests. Learn one of these [four naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}) and stick to it. Don't worry about long test names.

<div class="message">Find the first posts from this series plus a summary of "The Art of Unit Testing" and my best tips from this series on my free ebook “Unit Testing 101”. <a href="https://imcsarag.gumroad.com/l/unittesting101" target="_blank" rel="noopener noreferrer" data-goatcounter-click="UnitTesting101eBook-Link">Download your free copy on my Gumroad page</a> or click on the image below.</div>

<figure>
<a href="https://imcsarag.gumroad.com/l/unittesting101" rel="noopener noreferrer" target="_blank" data-goatcounter-click="UnitTesting101eBook-Image"><img src="/assets/posts/2021-08-30-UnitTesting/GrabYourOwnCopy.png" alt="Grab your own copy of Unit Testing 101" /></a>
</figure>

When writing your unit tests, make sure you [don't duplicate logic in Asserts]({% post_url 2021-10-11-DontRepeatLogicInAssertions %}). That's THE most common mistake in unit testing. Tests should only contain assignments and method calls.

## Improve it

Learn how to write good unit tests, avoiding [complex setup scenarios and hidden test values]({% post_url 2020-11-02-UnitTestingTips %}).

Make sure to always [write a failing test first]({% post_url 2021-02-05-FailingTest %}). And make it fail for the right reasons.

Write tests easy to follow [using simple test values]({% post_url 2022-12-14-SimpleTestValues %}).

Use [Builders to create test data]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}). And, learn [how to write tests that use DateTime.Now]({% post_url 2021-05-10-WriteTestsThatUseDateTimeNow %}).

Strive for a set of always-passing tests, a "Safe Green Zone." For example, [use a culture when parsing numeric strings]({% post_url 2020-12-04-UseCultureWhenParsing %}), instead of relying on a default culture on developers' machines.

## Fake it

Learn [what fakes are in unit testing]({% post_url 2021-05-24-WhatAreFakesInTesting %}) and the difference between stubs and mocks. Follow these [tips for better stubs and mocks in C#]({% post_url 2021-06-07-TipsForBetterStubsAndMocks %}).

Read [how to create fakes with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}), an easy to use mocking library.

If you find yourself using lots of fakes, take advantage of [automocking with TypeBuilder and AutoFixture]({% post_url 2021-06-21-WriteSimplerTestsTypeBuilderAndAutoFixture %}) to write simpler tests.

## Master it

Read all the tips from this series on [Unit Testing Best Practices]({% post_url 2021-07-05-UnitTestingBestPractices %}).

Deep into assertions, check [how to write better assertions]({% post_url 2021-07-19-WriteBetterAssertions %}) and [how to write custom assertions]({% post_url 2021-08-16-WriteCustomAssertions %}).

To see how to put these best practices in place, see how I refactored these real-world tests:

* [generating report in a payment system]({% post_url 2021-08-02-LetsRefactorATest %}),
* [storing and updating OAuth connections]({% post_url 2022-12-08-TestingOAuthConnections %}),
* [removing duplicated email addresses]({% post_url 2022-12-22-TestingDuplicatedEmails %}),
* [updating email statuses]({% post_url 2023-05-15-TestingEmailStatusUpdates %}), and,
* [speeding up a slow test suite]({% post_url 2023-05-29-SpeedingUpSomeTests %}).

If you work with ASP.NET Core, learn how to write tests for [HttpClient]({% post_url 2022-12-01-TestingHttpClient %}), [Authorization filters]({% post_url 2022-12-03-TestingAspNetAuthorizationFilters %}), and [logging and logging messages]({% post_url 2022-12-04-TestingLoggingAndLogMessages %}).

{%include ut201_course.html %}

_Happy testing!_