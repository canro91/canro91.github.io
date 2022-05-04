---
layout: post
title: "Unit Testing Best Practices: Let's refactor a test"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Unit Testing Best Practices: Let's refactor a test"
---

Let's refactor a test to follow our [unit testing best practices]({% post_url 2021-07-05-UnitTestingBestPractices %}). This test is based on a real test I had to modify in one of my client's projects.

Imagine this test belongs to a payment gateway. The system takes payments on behalf of partners. At the end of every month, the partners get the collected payments discounting any fees. This process is called a payout.

Partners can generate a report with all the transactions associated with a payout. This report can show dates in a different timezone, if the user wants it.

This is the test we're going to refactor. This test is for the `GetPayoutDetailsAsync()` method. This method find the payouts in a date range. Then, it shows all transactions related to those payouts. This method feeds a report in Microsoft Excel or any other spreadsheet software.

```csharp
[TestMethod]
public async Task GetPayoutDetailsAsync_HappyPath_SuccessWithoutTimezone()
{
    var account = TestAccount;

    var payouts = TestPayouts;
    var balanceTransactions = TestBalanceTransactions;
    var payments = TestPayments;

    var request = new PayoutRequest
    {
        PageSize = 10,
        AccountId = "AnyAccountId",
        DateRange = new DateRange
        {
            StartDate = DateTime.Now.AddDays(-15),
            EndDate = DateTime.Now
        }
    };

    var builder = new TypeBuilder<PayoutDetailsService>()
        .WithAccount(account)
        .WithPayouts(payouts)
        .WithBalanceTransactions(balanceTransactions)
        .WithPayments(payments);

    var service = builder.Build();

    var result = await service.GetPayoutDetailsAsync(request);

    Assert.IsTrue(result.Any());

    builder.GetMock<IAccountService>().Verify(s => s.GetAsync(It.IsAny<string>()), Times.Once);
    builder.GetMock<IPayoutWrapper>()
        .Verify(s => s.GetPayoutsByDateRangeAsync(It.IsAny<string>(), It.IsAny<DateRange>()), Times.Once);
    builder.GetMock<IBalanceTransactionWrapper>()
        .Verify(
            s => s.GetBalanceTransactionsByPayoutsAsync(It.IsAny<string>(), It.IsAny<string>(),
                It.IsAny<CancellationToken>()), Times.Once);
}
```

This test uses [automocking with TypeBuilder]({% post_url 2021-06-21-WriteSimplerTestsTypeBuilderAndAutoFixture %}). This `TypeBuilder<T>` creates an instance of a class with its dependencies replaced by [fakes using Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}).

Also, this test uses the [Builder pattern]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}) to create fakes with some test values before building a new instance. This test relies in object mothers to create input values for the stubs.

## 1. Separate the Arrange/Act/Assert parts

Let's start by grouping related code to follow [the Arrange/Act/Assert (AAA) principle]({% post_url 2021-07-19-WriteBetterAssertions %}).

To achieve this, let's declare variables near its first use and inline the ones used in a single place.

```csharp
[TestMethod]
public async Task GetPayoutDetailsAsync_HappyPath_SuccessWithoutTimezone()
{
    // Notice we inlined all input variables
    var builder = new TypeBuilder<PayoutDetailsService>()
        .WithAccount(TestAccount)
        .WithPayouts(TestPayouts)
        .WithBalanceTransactions(TestBalanceTransactions)
        .WithPayments(TestPayments);
    var service = builder.Build();

    // Notice we moved the request variable near its first use
    var request = new PayoutRequest
    {
        PageSize = 10,
        AccountId = "AnyAccountId",
        DateRange = new DateRange
        {
            StartDate = DateTime.Now.AddDays(-15),
            EndDate = DateTime.Now
        }
    };
    var result = await service.GetPayoutDetailsAsync(request);

    Assert.IsTrue(result.Any());

    builder.GetMock<IAccountService>().Verify(s => s.GetAsync(It.IsAny<string>()), Times.Once);
    builder.GetMock<IPayoutWrapper>()
        .Verify(s => s.GetPayoutsByDateRangeAsync(It.IsAny<string>(), It.IsAny<DateRange>()), Times.Once);
    builder.GetMock<IBalanceTransactionWrapper>()
        .Verify(
            s => s.GetBalanceTransactionsByPayoutsAsync(It.IsAny<string>(), It.IsAny<string>(),
                It.IsAny<CancellationToken>()), Times.Once);
}
```

Notice we inlined all input variables and move the `request` variable closer to the `GetPayoutDetailsAsync()` method where it's used.

Remember, **declare variables near its first use**.

## 2. Show the scenario under test and the expected result

Now, let's look at the test name.

```csharp
[TestMethod]
public async Task GetPayoutDetailsAsync_HappyPath_SuccessWithoutTimezone()
{
    // Notice the test name
    // The rest of the test remains the same,
    // but not for too long
}
```

It states the `GetPayoutDetailsAsync()` method should work without a timezone. That's the scenario of our test.

Let's follow the "UnitOfWork_Scenario_ExpectedResult" naming convention to show the scenario under test in the middle part of the test name.

Also, let's avoid the filler word "Success". In this test, success means the method returns the details without showing the transactions in another timezone. We learned to avoid filler words in our tests names when we learned the [4 common mistakes when writing tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}).

Let's rename our test.

```csharp
[TestMethod]
public async Task GetPayoutDetailsAsync_NoTimeZone_ReturnsDetails()
{
    // Test body remains the same
}
```

After this refactor, it's a good idea to add another test passing a timezone and checking that the found transactions are in the same timezone.

## 3. Make test value obvious

In the previous refactor, we renamed our test to show it works without a timezone.

Anyone reading this test should expected a variable named `timezone` assigned to `null` or a method `WithoutTimeZone()` in a builder. Let's [make the test value explicit]({% post_url 2020-11-02-UnitTestingTips %}).

```csharp
[TestMethod]
public async Task GetPayoutDetailsAsync_NoTimeZone_ReturnsDetails()
{
    var builder = new TypeBuilder<PayoutDetailsService>()
        .WithAccount(TestAccount)
        .WithPayouts(TestPayouts)
        .WithBalanceTransactions(TestBalanceTransactions)
        .WithPayments(TestPayments);
    var service = builder.Build();

    var request = new PayoutRequest
    {
        PageSize = 10,
        AccountId = "AnyAccountId",
        DateRange = new DateRange
        {
            StartDate = DateTime.Now.AddDays(-15),
            EndDate = DateTime.Now
        },
        // Notice we explicitly set no timezone
        TimeZone = null
    };
    var result = await service.GetPayoutDetailsAsync(request);

    Assert.IsTrue(result.Any());

    builder.GetMock<IAccountService>().Verify(s => s.GetAsync(It.IsAny<string>()), Times.Once);
    builder.GetMock<IPayoutWrapper>()
        .Verify(s => s.GetPayoutsByDateRangeAsync(It.IsAny<string>(), It.IsAny<DateRange>()), Times.Once);
    builder.GetMock<IBalanceTransactionWrapper>()
        .Verify(
            s => s.GetBalanceTransactionsByPayoutsAsync(It.IsAny<string>(), It.IsAny<string>(),
                It.IsAny<CancellationToken>()), Times.Once);
}
```

If we have more than one test without timezone, we can use a constant `NoTimeZome` or an object mother for the `PayoutRequest`, something like `NoTimeZonePayoutRequest`.

## 4. Remove over-specification

For our last refactor, let's remove those `Verify()` calls. We don't need them. [We don't need to assert on stubs]({% post_url 2021-06-07-TipsForBetterStubsAndMocks %}).

If any of the stubs weren't in place, probably we will get a `NullReferenceException` somewhere in our code. Those extra verifications make our test harder to maintain.
		
```csharp
[TestMethod]
public async Task GetPayoutDetailsAsync_NoTimeZone_ReturnsDetails()
{
    var builder = new TypeBuilder<PayoutDetailsService>()
        .WithAccount(TestAccount)
        .WithPayouts(TestPayouts)
        .WithBalanceTransactions(TestBalanceTransactions)
        .WithPayments(TestPayments);
    var service = builder.Build();

    var request = new PayoutRequest
    {
        PageSize = 10,
        AccountId = "AnyAccountId",
        DateRange = new DateRange
        {
            StartDate = DateTime.Now.AddDays(-15),
            EndDate = DateTime.Now
        },
        TimeZone = null
    };
    var result = await service.GetPayoutDetailsAsync(request);

    Assert.IsTrue(result.Any());
    // We stopped verifying on stubs
}
```

Voilà! That looks better! Unit tests got our back when changing our code. It's better to keep them clean too. They are our safety net.

If you're new to unit testing, read [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}), [4 common mistakes when writing your first tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}) and [4 test naming conventions]({% post_url 2021-04-12-UnitTestNamingConventions %}).

For more advanced content on unit testing, check [what are fakes in unit testing]({% post_url 2021-05-24-WhatAreFakesInTesting %}), [how to write fakes with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) and these [tips to write better stubs and mocks]({% post_url 2021-06-07-TipsForBetterStubsAndMocks %}).

_Happy testing!_