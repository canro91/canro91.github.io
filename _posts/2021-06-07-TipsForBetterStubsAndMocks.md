---
layout: post
title: "Five tips for better stubs and mocks in C#"
tags: tutorial csharp
cover: Cover.png
cover-alt: "5 tips for better stubs and mocks in C#"
---

Last time, we covered [what fakes are in unit testing]({% post_url 2021-05-24-WhatAreFakesInTesting %}) and the types of fakes. We wrote two tests for an `OrderService` to show the difference between stubs and mocks.

In case you missed it, fakes are like test "simulators." They replace external dependencies with testable components. Stubs and mocks are two types of fakes. Stubs are "simulators" that provide values or exceptions. And mocks are "simulators" that record method calls.

Before we start with the tips, let's bring back the `OrderService` class from our last post.

```csharp
public class OrderService 
{
    private readonly IPaymentGateway _paymentGateway;
    private readonly IStockService _stockService;

    public OrderService(IPaymentGateway paymentGateway, IStockService stockService)
    {
        _paymentGateway = paymentGateway;
        _stockService = stockService;
    }

    public OrderResult PlaceOrder(Order order)
    {
        if (!_stockService.IsStockAvailable(order))
        {
            throw new OutOfStockException();
        }

        _paymentGateway.ProcessPayment(order);

        return new PlaceOrderResult(order);
    }
}
```

In our last post, we chose certain names for our fakes like `AlwaysAvailableStockService` and `FixedDateClock`. Let's see why those names and what to do and not to do when working with fakes.

> TL;DR
> * Don't assert on stubs
> * Keep one mock per test
> * Avoid logic inside your fakes
> * Make tests set their own values for fakes
> * Name your fakes properly

## 1. Don't assert on stubs

Let's remember that stubs are there to provide values indirectly to our code under test. We make fakes return a value or throw an exception.

**Don't write assertions for stubs. We don't need them. Let's assert on the result of our tests or use mocks.**

Please, don't do this.

```csharp
[TestClass]
public class OrderServiceTests
{
    [TestMethod]
    public void PlaceOrder_ItemInStock_CallsPaymentGateway()
    {
        var paymentGateway = new FakePaymentGateway();
        var stockService = new AlwaysAvailableStockService();
        var service = new OrderService(paymentGateway, stockService);

        var order = new Order();
        service.PlaceOrder(order);

        Assert.IsTrue(paymentGateway.WasCalled);
        // We don't need this assertion
        Assert.IsTrue(stockService.IsStockAvailable(order));
        // ^^^^^
    }
}
```

In this test, let's notice this assertion,

```csharp
Assert.IsTrue(stockService.IsStockAvailable(order));
```

It's redundant. It will never fail because we wrote the fake to always return true. We can get rid of it!

If we use a [mocking library like Moq to write our fakes]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) and if we forget to set up our stubs, we will get a [NullReferenceException]({% post_url 2023-02-20-WhatNullReferenceExceptionIs %}). Our code expects some values that the stubs didn't provide. With that exception thrown, we will have a failing test.

If we write assertions for our stubs, we're testing the mocking library, not our code.

## 2. Keep one mock per test

In the same spirit of keeping a single assertion per test, let's keep one mock per test. Let's have small and well-named tests.

Let's say that in our `OrderService`, we need to log every request we made to charge a credit card and we add an `ILogger<AccountService>` to our service.

Please, don't write tests with more than one mock. Like this one,

```csharp
[TestClass]
public class OrderServiceTests
{
    [TestMethod]
    public void PlaceOrder_ItemInStock_CallsPaymentGatewayAndLog()
    {
        var logger = new FakeLogger();
        var paymentGateway = new FakePaymentGateway();
        var stockService = new AlwaysAvailableStockService();
        var service = new OrderService(logger, paymentGateway, stockService);

        var order = new Order();
        service.PlaceOrder(order);

        Assert.IsTrue(paymentGateway.WasCalled);
        Assert.IsTrue(logger.WasCalled);
        // ^^^^^
        // Let's keep one mock per test
    }
}
```

**Don't use multiple mocks per test. Let's write separate tests, instead.**

And, when [testing logging and logging messages]({% post_url 2022-12-04-TestingLoggingAndLogMessages %}), asserting on the logging message isn't a good idea.

<figure>
<img src="https://images.unsplash.com/flagged/photo-1579750481098-8b3a62c9b85d?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjE5NzExMzk1&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Cockpit of Airbus A330-200" />

<figcaption>Stubs and mocks are like test "simulators". Photo by <a href="https://unsplash.com/@dallimonti?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Andrés Dallimonti</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
  </figcaption>
</figure>

## 3. Avoid logic inside your fakes

**Write dumb fakes. Let's avoid complex logic inside fakes.**

For example, let's not add flags to our stubs to return one value or another. Let's write separate fakes, instead.

Let's test the `OrderService` with and without stock. As a counterexample, let's use a single `FakeStockService` with a flag to signal the two scenarios.

```csharp
[TestClass]
public class OrderServiceTests
{
    [TestMethod]
    public void PlaceOrder_ItemInStock_CallsPaymentGateway()
    {
        var paymentGateway = new FakePaymentGateway();
        // Make the stock service have stock
        var stockService = new FakeStockService
        {
            ItemInStock = true
            // ^^^^^
        };
        var service = new OrderService(paymentGateway, stockService);

        var order = new Order();
        service.PlaceOrder(order);

        Assert.IsTrue(paymentGateway.WasCalled);
    }

    [TestMethod]
    public void PlaceOrder_ItemOutOfStock_ThrowsException()
    {
        var paymentGateway = new FakePaymentGateway();
        // Make the stock service have NO stock
        var stockService = new FakeStockService
        {
            ItemInStock = false
            // ^^^^^
        };
        var service = new OrderService(paymentGateway, stockService);

        var order = new Order();

        Assert.ThrowsException<OutOfStockException>(() => service.PlaceOrder(order));
    }
}
```

Our `FakeStockService` would look like this,

```csharp
public class FakeStockService : IStockService
{
    public bool ItemInStock { get; set; }
    
    public bool IsStockAvailable(Order order)
    {
        return ItemInStock;
    }
}
```

Here our fake service uses a `bool`, but it could start getting more complex if we need to support more test scenarios.

Let's not use a single fake for both scenarios. Instead, let's write two separate fakes and make each test use a different one. Let's name these two fakes: `ItemInStockStockService` and `ItemOutOfStockStockService`. Inside them, we always return `true` and `false`, respectively.

```csharp
[TestClass]
public class OrderServiceTests
{
    [TestMethod]
    public void PlaceOrder_ItemInStock_CallsPaymentGateway()
    {
        var paymentGateway = new FakePaymentGateway();
        // One fake for the "in stock" scenario
        var stockService = new ItemInStockStockService();
        //                     ^^^^^
        var service = new OrderService(paymentGateway, stockService);

        var order = new Order();
        service.PlaceOrder(order);

        Assert.IsTrue(paymentGateway.WasCalled);
    }

    [TestMethod]
    public void PlaceOrder_ItemOutOfStock_ThrowsException()
    {
        var paymentGateway = new FakePaymentGateway();
        // Another fake for the "out of stock" scenario
        var stockService = new ItemOutOfStockStockService();
        //                     ^^^^^
        var service = new OrderService(paymentGateway, stockService);

        var order = new Order();
        Assert.ThrowsException<OutOfStockException>(() => service.PlaceOrder(order));
    }
}
```

Don't worry about creating lots of fakes. Fakes are cheap. Any decent IDE can create a class implementing an interface or an abstract class with a few clicks or a single keyboard shortcut.

## 4. Make tests set their own values for fakes

**Avoid magic values in your stubs. Let's make tests pass their own values instead of having hard-coded values in stubs.**

Let's say that `StockService` returns the units available instead of a simple `true` or `false`. Check this test,

```csharp
[TestMethod]
public void PlaceOrder_NotEnoughStock_ThrowsException()
{
    var paymentGateway = new FakePaymentGateway();
    var stockService = new FakeStockService();
    var service = new OrderService(paymentGateway, stockService);

    var order = new Order
    {
        Quantity = 2
    };
    Assert.ThrowsException<OutOfStockException>(() => service.PlaceOrder(order));
}
```

Why should it throw? Why is that `Quantity = 2` there? Because we buried somewhere in the `FakeStockService` not enough stock. Something like this,

```csharp
public class FakeStockService : IStockService
{
    public int StockAvailable(Order order)
    {
        return 1;
    }
}
```

Instead, let the test set its own faked value,

```csharp
[TestMethod]
public void PlaceOrder_NoEnoughStock_ThrowsException()
{
    var paymentGateway = new FakePaymentGateway();
    var stockService = new FakeStockService
    {
        UnitsAvailable = 1
        // ^^^^^
    };
    var service = new OrderService(paymentGateway, stockService);

    var order = new Order
    {
        Quantity = 2
        // ^^^^^
    };
    Assert.ThrowsException<OutOfStockException>(() => service.PlaceOrder(order));
}
```

It makes more sense! There's only 1 unit available and we're placing an order for 2 items. Let's make tests fake their own values.

## 5. Name your fakes properly

Again for our last tip, let's talk about names. Naming is hard!

**Name stubs to indicate the value they return or the exception they throw.**

We named our fake stock provider `AlwaysAvailableStockService` to show it always returns stock available. It obvious from its name what is the return value.

When we needed two stock providers to test the `OrderService` without stock, we named our fakes: `ItemInStockStockService` and `ItemOutOfStockStockService`.

Also, do you remember why we named our fake `FixedDateClock`? No? You can tell it by its name. It returns a fixed date, the `DateTime` you pass to it.

Voilà! Those are five tips to write better stubs and mocks. Remember, write dumb fakes. Don't put too much logic in them. Let the tests fake their own values.

If you want to start using a mocking library, read my post on [how to write fakes with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}). If you find yourself writing lots of fakes for a single component, check [automocking with TypeBuilder and AutoFixture]({% post_url 2021-06-21-WriteSimplerTestsTypeBuilderAndAutoFixture %}). And don't miss the rest of my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I cover more subjects like this one.

_Happy testing!_