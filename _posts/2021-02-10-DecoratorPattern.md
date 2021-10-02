---
layout: post
title: Decorator pattern. A real example in C#
tags: tutorial csharp
---

I've been working with Stripe to take payments. Depending on the volume of requests you make to the Stripe API, you might exceed the maximum number of requests per second. This is how we can implement a retry mechanism using the Decorator pattern in C#.

**A Decorator wraps another object to extend its responsabilities, without modifying its existing behavior, while keeping the same signature of public methods. Decorators are used to add orthogonal responsibilities like logging, caching and retrying.**

Let's use Marvel movies to understand the Decorator pattern. When IronMan wore the HULKBUSTER suit in the Age of Ultron, he implemented the Decorator pattern. He had a new functionality, stopping the Hulk, while keeping his same functions, being IronMan. _I hope you got it!_

<figure>
<img src="https://images.unsplash.com/photo-1575676993399-3fa7ed2d7066?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Decorator pattern. A real example in C#" />

<figcaption>When you wear a jacket, you use the Decorator pattern too. <span>Photo by <a href="https://unsplash.com/@xieqizhi?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Archie</a> on <a href="https://unsplash.com/s/photos/winter?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## Naive Retry logic

Let's start with a `PaymentService`. This service collects everything it needs to start a payment with Stripe. For example, customer id, fees, destination account, etc. Then, it uses a `PaymentIntentService` to call Stripe API using its C# client.

This would be the `CreatePaymentIntentAsync()` method inside the `PaymentService`.

```csharp
public class PaymentService : IPaymentService
{
    private readonly IPaymentIntentService _paymentIntentService;
    private readonly IFeeService _feeService;

    public PaymentService(IPaymentIntentService paymentIntentService, IFeeService feeService)
    {
        _paymentIntentService = paymentIntentService;
        _feeService_ = feeService;
    }

    public async Task<PaymentIntentDetails> CreatePaymentIntentAsync(
        PaymentRequestViewModel request,
        IDictionary<string, string> metadata)
    {
        var currencyCode = request.CurrencyCode;
        var description = request.Description;
        var amountInUnits = request.Amount.ToMainUnits();
        var gatewayAccountId = request.GatewayAccountId;

        var applicationFee = _feeService.GetApplicationFee(request);
        metadata.AddFees(applicationFee);

        var paymentIntentOptions = new PaymentIntentCreateOptions
        {
            Amount = amountInUnits,
            Currency = currencyCode,
            ApplicationFeeAmount = applicationFee,
            Description = description,
            Metadata = metadata,
            Confirm = true,
            CaptureMethod = "manual",
            OnBehalfOf = gatewayAccountId,
            TransferData = new PaymentIntentTransferDataOptions
            {
                Destination = gatewayAccountId
            }
        };

        try
        {
            var paymentIntent = await _paymentIntentService.CreateAsync(paymentIntentOptions, GetRequestOptions());

            return GetSuccessfulPaymentIntentDetails(request, paymentIntent);
        }
        catch (StripeException stripeException)
        {
            return GetFailedPaymentIntentDetails(request, stripeException);
        }
    }
}
```

We want to retry the method `CreateAsync()` if it reaches the maximum number of allowed requests by Stripe at a given time.

We can add retry logic using a helper method. And, wrap the call to the `CreateAsync()` method inside the helper method. Something like this,

```csharp
try
{
    var paymentIntent = await RetryAsync(async () =>
    {
        return await _paymentIntentService.CreateAsync(paymentIntentOptions, GetRequestOptions());
    });

    return GetSuccessfulPaymentIntentDetails(paymentRequest, paymentIntent);
}
catch (StripeException stripeException)
{
    return GetFailedPaymentIntentDetails(paymentRequest, stripeException);
}
```

The `RetryAsync()` helper method will execute the API call a fixed number of times if it fails with a `TooManyRequests` status code. If it fails with a different exception or status code, it propagates the exception to the caller.

This is a simple implementation of a retry method.

```csharp
protected async Task<TResult> RetryAsync<TResult>(Func<Task<TResult>> apiCommand, int maxRetryCount = 3)
{
    var exceptions = new List<Exception>();
    var retryCount = 0;

    while (true)
    {
        try
        {
            return await apiCommand();
        }
        catch (StripeException ex) when (ex.HttpStatusCode == HttpStatusCode.TooManyRequests)
        {
            exceptions.Add(ex);

            if (retryCount == retryCountMax)
            {
                throw new AggregateException("Too many requests", exceptions);
            }

            retryCount++;
        }
    }
}
```

Later, we can replace this helper method with a more robust implementation using [Polly](https://github.com/App-vNext/Polly), for example. It can include incremental delays between failed attempts and timeouts.

But, using this helper method implies wrapping the methods to retry inside our helper method all over our codebase. Hopefully, if we have a singe place to take payments, that wouldn't be a problem. Also, our `PaymentService` mixes business logic with retry logic. That's smelly. We should keep responsabilities separated.

## Retry logic with Decorator pattern: Let's Decorate

For a more clean solution, let's use the Decorator pattern.

First, let's create a decorator called `RetryablePaymentIntentService` for the `PaymentIntentService`. Since we want to keep the same API of public methods, the decorator should inherit from the same interface, `IPaymentIntentService`.

```csharp
public class RetryablePaymentIntentService : IPaymentIntentService
{
    public Task<PaymentIntent> CreateAsync(PaymentIntentCreateOptions options, RequestOptions requestOptions = null, CancellationToken cancellationToken = default)
    {
        // We will fill the details in the next steps
    }
}
```

The decorator will only handle the retry logic. It will use the existing `PaymentIntentService` to call Stripe. The decorator will receive another `IPaymentIntentService` in its constructor.

```csharp
public class RetryablePaymentIntentService : IPaymentIntentService
{
    private readonly IPaymentIntentService _decorated;

    public RetryablePaymentIntentService(IPaymentIntentService decorated)
    {
        _decorated = decorated;
    }

    public Task<PaymentIntent> CreateAsync(PaymentIntentCreateOptions options, RequestOptions requestOptions = null, CancellationToken cancellationToken = default)
    {
        // We will fill the details in the next steps
    }
}
```

Notice, we named the field in the decorator, `_decorated`. And, yes, the decorator inherits and receives the same type. _That's the trick!_

Next, we need to fill in the details. To complete our decorator, let's use our previous `RetryAsync()` method. Our decorator will look like this,

```csharp
public class RetryablePaymentIntentService : PaymentIntentService
{
    private readonly PaymentIntentService _decorated;

    public RetryablePaymentIntentService(PaymentIntentService decorated)
    {
        _decorated = decorated;
    }

    public Task<PaymentIntent> CreateAsync(PaymentIntentCreateOptions options, RequestOptions requestOptions = null, CancellationToken cancellationToken = default)
    {
        return RetryAsync(async () =>
        {
            return await _decorated.CreateAsync(paymentIntentOptions, requestOptions, cancellationToken);
        });
    }
    
    // Same RetryAsync method as before...
}
```

Now, our decorator is ready to use it. In the `PaymentService`, we can replace the simple `PaymentIntentService` by our new `RetryablePaymentIntentService`. Both services implement the same interface.

We can create our decorator like this,

```csharp
new RetryablePaymentIntentService(new PaymentIntentService(/* Other dependencies */));
```

## Inject Decorators into ASP.NET Core container

### Let's register our decorator

But, if you're using an ASP.NET Core API project, we can use the dependency container to build the decorator. 

Let's use an extension method `AddPaymentServices()` to group the registration of our services. You can register your services directly into the `Startup` class. _No problem!_

```csharp
public static class ServiceCollectionExtensions
{
    public static void AddPaymentServices(this IServiceCollection services)
    {
        services.AddTransient<PaymentIntentService>();
        services.AddTransient<IPaymentIntentService>((provider) =>
        {
          var decorated = provider.GetRequiredService<PaymentIntentService>();
          return new RetryablePaymentIntentService(decorated);
        });
        services.AddTransient<IPaymentService, PaymentService>();
    }
}
```

This time, we registered the original `PaymentIntentService` without specifying an interface. We only used the `IPaymentIntentService` to register the decorator. When resolved, the `PaymentService` will receive the decorator instead of the original service without retry logic.

### Let's use Scrutor to register our decorator

Optionally, we can use [Scrutor](https://github.com/khellang/Scrutor) to register the decorated version of the `IPaymentIntentService`. Scrutor is a library that adds more features to the built-in dependencies container. Don't forget to install the Scrutor NuGet package into your project, if you choose this route.

In that case, our `AddPaymentServices()` will look like this,

```csharp
public static class ServiceCollectionExtensions
{
    public static void AddPaymentServices(this IServiceCollection services)
    {
        services.AddTransient<IPaymentIntentService, PaymentIntentService>();
        // With Scrutor, we need the method Decorate
        services.Decorate<IPaymentIntentService, RetryablePaymentIntentService>();
        services.AddTransient<IPaymentService, PaymentService>();
    }
}
```

Notice, this time we have explicitly register two entries for the `IPaymentIntentService`. The `Decorate()` method does the trick for us.

Voilà! That's how we can implement the Decorator pattern to retry API calls. We can also use the decorator pattern to bring logging or caching to our services. Check how you can use the Decorator pattern to [add a Redis caching layer with ASP.NET Core]({% post_url 2020-06-29-HowToAddACacheLayer %}).

For more real-world examples, check my post on [Primitive Obsession]({% post_url 2020-12-10-PrimitiveObsession %}). That's about handling Stripe currency units. If you want my take on another pattern, check my post about the [Pipeline pattern]({% post_url 2020-02-14-PipelinePattern %}).

_Happy coding!_
