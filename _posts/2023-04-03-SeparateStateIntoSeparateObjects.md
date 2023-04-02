---
layout: post
title: "Goodbye, NullReferenceException: Separate State in Separate Objects"
tags: tutorial csharp
cover: Cover.png
cover-alt: "US Capitol" 
---

So far in this series about NullReferenceException, we have used [nullable operators and C# 8.0 Nullable References]({% post_url 2023-03-06-NullableOperatorsAndReferences %}) to avoid `null` and learned about [the Option type]({% post_url 2023-03-20-UseOptionInsteadOfNull %}) as an alternative to `null`. Let's see how to design our classes to avoid `null` when representing optional values.

## Multiple state in the same object

Often we keep all possible combinations of properties of an object in a single class.

For example, on an e-commerce site, we create a `User` class with a name, password, and credit card. But since we don't need the credit card details to create new users, we declare the `CreditCard` property as nullable.

Let's write a class to represent either regular or premium users. We should only store credit card details for premium users to charge a monthly subscription.

```csharp
public record User(Email email, SaltedPassword password)
{
    public CreditCard? CreditCard { get; internal set; }
    //              ^^^
    // Only for Premium users. We declare it nullable

    public void BecomePremium(CreditCard creditCard)
    {
        // Imagine we sent an email and validate credit card
        // details, etc
        //
        // Beep, beep, boop
    }

    public void ChargeMonthlySubscription()
    {
        // CreditCard might be null here.
        //
        // Nothing is preventing us from calling it
        // for regular users
        CreditCard.Pay();
        // ^^^^^
        // Boooom, NullReferenceException
    }
}
```

Notice that the `CreditCard` property only has value for premium users. We expect it to be `null` for regular users. And nothing is preventing us from calling `ChargeMonthlySubscription` with regular users (when `CreditCard` is `null`). We have a potential source of NullRefernceException.

We ended up with a class with nullable properties and methods that only should be called when some of those properties aren't `null`.

Inside `ChargeMonthlySubscription`, we could add some null checks before using the `CreditCard` property. But, if we have other methods that need other properties not to be `null`, our code will get bloated with null checks all over the place.

## Separate State in Separate Objects

Instead of checking for `null` inside `ChargeMonthlySubscription`, let's create two separate classes to represent regular and premiums users.

```csharp
public record RegularUser(Email Email, SaltedPassword Password)
{
    // No nullable CreditCard anymore

    public PremiumUser BecomePremium(CreditCard creditCard)
    {
        // Imagine we sent an email and validate credit card
        // details, etc
        return new PremiumUser(Email, Password, CreditCard);
    }
}

public record PremiumUser(Email Email, SaltedPassword Password, CreditCard CreditCard)
{
    // Do stuff of Premium Users...

    public void ChargeMonthlySubscription()
    {
        // CreditCard is not null here.
        CreditCard.Pay();
    }
}
```

Notice we wrote two separate classes: `RegularUser` and `PremiumUser`. We don't have methods that should be called only when some optional properties have value. And we don't need to check for `null` anymore. For premium users, we're sure we have their credit card details. We eliminated a possible source of NullReferenceException.

**Instead of writing a large class with methods that expect some nullable properties to be not null at some point, we're better off using separate classes to avoid dealing with null and getting NullReferenceException.**

I learned about this technique after reading [Domain Model Made Functional]({% post_url 2021-12-13-DomainModelingMadeFunctional %}). The book uses the mantra: "Make illegal state unrepresentable." In our example, the illegal state is the `CreditCard` being `null` for regular users. We made it unrepresentable by writing two classes.

Voilà! This is another technique to prevent `null` and NullReferenceException by avoiding classes that only use some optional state at some point of the object lifecycle. We should split all possible combinations of the optional state into separate classes. Put separate state in separate objects.

Don't miss the other posts in this series, [what is the NullReferenceException]({% post_url 2023-02-20-WhatNullReferenceExceptionIs %}), [Nullable Operators and References]({% post_url 2023-03-06-NullableOperatorsAndReferences %}), and [the Option type and LINQ XOrDefault methods]({% post_url 2023-03-20-UseOptionInsteadOfNull %}).

_Happy coding!_