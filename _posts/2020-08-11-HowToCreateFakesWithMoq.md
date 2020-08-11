---
layout: post
title: How to create fakes with Moq? And what I don't like about it?
tags: tutorial csharp showdev
---

A recurring task when writing unit tests is creating fake implementations of collaborators. If you're writing an unit test for an order delivery system, you don't want to use a real payment gateway. You can create a payment gateway you control. So, you can make it return or throw anything you want to test the logic around it.

You can create your own fakes. They're often called test doubles. _Yes, like the body doubles in movies_. If you apply the [Dependency Inversion Principle]( https://en.wikipedia.org/wiki/Dependency_inversion_principle ), _the D of SOLID_, your collaborators are well abstracted using interfaces. To create a fake, create a class that inherits from an interface. Then, on Visual Studio, from "Quick Refactorings", choose "Implement interface". _Et voilà!_ you have your own fake.

But, if you need to create lots of fakes collaborators, a mocking library can make things easier. Mocking libraries are an alternative to roll your own fakes or doubles. They offer a friendly API to create fakes from an interface or a class. _Let's see Moq, one of them!_

### Moq

[Moq](https://github.com/Moq/moq4) is a mocking library that _"is designed to be a very practical, unobtrusive and straight-forward way to quickly setup dependencies for your tests"_.

> _Moq, _"the most popular and friendly mocking library for .NET"_
>
> From [moq](https://github.com/Moq/moq4#moq)

#### Create fakes with Moq...Action!

_Let's see Moq in action!_ Suppose you have an `OrderService` that uses a `IPaymentGateway` and  `IStockService`.  This `OrderService` checks if there is stock available to then charge a credit card when placing a new order. Something like this, 

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

To create an unit test for this service, let's create fakes for the payment gateway and the stock service. For our test name, let's follow the naming convention from [The Art of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %}).

```csharp
[TestClass]
public class OrderServiceTests
{
  [TestMethod]
  public void PlaceOrder_OrderInStock_CallsProcessPayment()
  {
    var fakePaymentGateway = new Mock<IPaymentGateway>();

    var fakeStockService = new Mock<IStockService>();
    fakeStockService.Setup(t => t.IsStockAvailable(It.IsAny<Order>()))
                    .Returns(true);
    var orderService = new OrderService(fakePaymentGateway.Object, fakeStockService.Object);

    var order = new Order();
    orderService.PlaceOrder(order);

    fakePaymentGateway.Verify(t => t.ProcessPayment(order), Times.Once);
  }
}
```

_What happened here?_ First, it creates a fake for `IPaymentGateway` with `new Mock<IPaymentGateway>()`. Moq can create fakes for interfaces and classes. Then, it creates a fake for `IStockService`. This fake returns `true` when the method `IsStockAvailable` is called with any order. Next, it uses the `Object` property of `Mock` to create an instance of the fake. Finally, it checks if the method `ProcessPayment` was called once with the `Verify` method. _A passing test now!_

#### Cut!...What I don't like about Moq?

Moq is easy to use. You can start using it in minutes! You only need to read the README and the quickstart files in the documentation. But...

For Moq, everything is a mock, `Mock<T>`. But, strictly speaking, everything isn't a mock. [XUnit Tests Patterns](http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html) presents a detailed category of fakes or doubles: fakes, stubs, mocks, dummies and spies. [The Art of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %}) reduces this classification to only three types: fakes, stubs and mocks. Other libraries use `Fake` , `Substitute` or `Stub` vs `Mock` instead of `Mock`. Moq has chosen this simplification to make it easier to use. But, this could lead to misusing the term _mock_.

For Moq, `MockRepository` is a factory of mocks. You can verify all mocks created from this factory in a single call. But, a repository is a pattern to abstract creating and accessing records in a data store. You will find `OrderRepository` or `EmployeeRepository`. Are `MockSession` or `MockGroup` better alternatives?

### Conclusion

Moq is a great library! It keeps its promise. It's an straight-forward library to setup dependencies in your tests. You need to know a few method to start using it: `Setup`, `Returns`, `Throws` and `Verify`. It has chosen to lower the barrier of writing tests. Give it a try! _To mock or not to mock!_

_Happy mocking time!_
