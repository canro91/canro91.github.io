---
layout: post
title: A case of primitive obsession. A real example in C#
tags: tutorial csharp
---

These days I was working with Stripe API to take payments. And I found a case of primitive obsession. Keep reading to learn how to get rid of it.

Primitive obsession is when developers choose primitive types (strings, integers, decimals) to represent entities of the business domain. For example, plain strings for usernames or decimals for currencies. To solve this code smell, create classes to model the business entities. And, use those classes to enforce the appropriate business rules.

## Using Stripe API

Stripe API uses units to represent amounts. All amounts are multiplied by 100. This is 1USD = 100 units. Also, you can only use amounts between $0.50 USD and $999,999.99 USD. This isn't the case for all currencies, but let's keep it simple. For more information, check [Stripe documentation for currencies](https://stripe.com/docs/currencies#zero-decimal).

The codebase I was working with used two extension methods on the `decimal` type to convert between amounts and units. Those two method were something like `ToUnits` and `ToAmount`. But, besides variable names, there wasn't anything preventing to use a `decimal` instead of Stripe units. It was the same `decimal` type for both concepts. Anyone could forget to convert things and charge someone's credit card more than expected. _Arggg!_

<figure>
<img src="https://images.unsplash.com/photo-1563013544-824ae1b704d3?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop" alt="A case of primitive obsession" />

<figcaption><span>Photo by <a href="https://unsplash.com/@rupixen?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">rupixen.com</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## Getting rid of primitive obsession

### An alias

As an alternative to encode units of measure on names, we can use a type alias. Let's declare `using Unit = System.Decimal` and change the correct parameters to use `Unit`. But, the compiler won't warn if we pass `decimal` instead of `Unit`. See the snippet below.

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace GettingRidOfPrimitiveObsession
{
    using Unit = System.Decimal;

    [TestClass]
    public class ConvertBetweenAmountAndUnits
    {
        [TestMethod]
        public void UseTypeAlias()
        {
            decimal amount = 100;
            Unit chargeAmount = amount.ToUnit();

            var paymentService = new PaymentService();
            paymentService.Pay(chargeAmount);

            paymentService.Pay(amount);
            // ^^^^ It compiles
        }
    }

    public class PaymentService
    {
        public void Pay(Unit amountToCharge)
        {
            // Magic goes here
        }
    }

    public static class DecimalExtensions
    {
        public static Unit ToUnits(this decimal d)
            => d * 100;
    }
}
```

Using a type alias is more expressive than encoding the unit of measure in variable names and parameters. But, it doesn't force us to use one type instead of the other. Let's try a better alternative.

### A class

Now, let's create a `Unit` class and pass it around instead of `decimal`. In the constructor, we can check if the input amount is inside the bounds. Also, let's use a method to convert units back to normal amounts.

```csharp
public class Unit
{
    internal decimal Value { get; }

    private Unit(decimal d)
    {
        if (d < 0.5m || d > 999_999.99m)
        {
            throw new ArgumentException("Amount outside of bounds");
        }

        Value = d * 100m;
    }

    public static Unit FromAmount(decimal d)
      => new Unit(d);

    public decimal ToAmount()
        => Value / 100m;
}
```

After using a class instead of an alias, the compiler will warn us if we switch the two types by mistake. And, it's clear from a method signature if it works with amounts or units.

If needed, we can overload the `+` and `-` operators to make sure we're not adding oranges and apples.

```csharp
[TestMethod]
public void UseAType()
{
    decimal amount = 100;
    Unit chargeAmount = Unit.FromAmount(amount);

    var paymentService = new PaymentService();
    paymentService.Pay(chargeAmount);

    // paymentService.Pay(amount);
    // ^^^^ cannot convert from 'decimal' to 'GettingRidOfPrimitiveObsession.Unit'
}
```

Voilà! That's how we can get rid of primitive obsession. A type alias was more expressive than encoding units of measure on names. But, a class was a better alternative. By the way, F# supports [unit of measures](https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/units-of-measure) to variables. And, the compiler will warn you if you forget to use the right unit of measure.

Looking for more content on C#? Check my post series on [C# idioms]({% post_url 2019-11-19-TwoCSharpIdioms %}) and my [C# definitive guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %})

_Happy coding!_
