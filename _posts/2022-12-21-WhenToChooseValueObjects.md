---
layout: post
title: "To Value Object or Not To: How I choose Value Objects"
tags: csharp tutorial
cover: Cover.png
cover-alt: "Person holding a clock in his palm" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

Today I reviewed a Pull Request and had a conversation about when to use Value Objects instead of primitive values. This is the code that started the conversation and my rationale to promote a primitive value to a Value Object.

**Prefer Value Objects to encapsulate validations or custom methods on a primitive value. Otherwise, if a primitive value doesn't have a meaningful "business" sense and is only passed around, consider using the primitive value with a good name for simplicity.**

In case you're not familiar with Domain-Driven Design and its artifacts. A Value Object represents a concept in a domain without requiring an "identifier." Value objects are immutable and compared by value. Value Objects represent elements of "broader" concepts. For example, in a Reservation Management System, we can use a Value Object to represent the payment method of a Reservation.

## TimeStamp vs DateTime

This is the piece of code that triggered my comment during the code review.

```csharp
public class DeliveryNotification : ValueObject
{
    public Recipient Recipient { get; init; }
    
    public DeliveryStatus Status { get; init; }
    
    public TimeStamp TimeStamp { get; init; }
    //     ^^^^^^

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Recipient;
        yield return Status;
        yield return TimeStamp;
    }
}

public class TimeStamp : ValueObject
{
    public DateTime Value { get; }

    private TimeStamp(DateTime value)
    {
        Value = value;
    }
    
    public static TimeStamp Create()
    {
        return new TimeStamp(SystemClock.Now);
    }

    protected override IEnumerable<object> GetEqualityComponents()
    {
        yield return Value;
    }
}

public enum DeliveryStatus
{
    Created,
    Sent,
    Opened,
    Failed
}
```

We wanted to record when an email is sent, opened, and clicked. We relied on a third-party Email Provider to notify our system about these email events. The `DeliveryNotification` has an email address, status, and timestamp.

The `ValueObject` base class is [Vladimir Khorikov's ValueObject implementation](https://enterprisecraftsmanship.com/posts/value-object-better-implementation/).

Notice the `TimeStamp` class. It's only a wrapper around the `DateTime` class. Mmmm... 

<figure>
<img src="https://images.unsplash.com/photo-1578923931302-7fd9b3495be7?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY3MTQ5OTI3Mw&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Sand clock" />

<figcaption>Photo by <a href="https://unsplash.com/@alexandar_todov?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Alexandar Todov</a> on <a href="https://unsplash.com/s/photos/timer?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Promote Primitive Values to Value Objects

I'd dare to say that using a `TimeStamp` instead of a simple `DateTime` in the `DeliveryNotification` class was an overkill. I guess when "when we have a hammer, everything looks like a finger."

This is my rationale to choose between value objects and primitive values:

* If we need to enforce a domain rule or perform a business operation on a primitive value, let's use a Value Object.
* If we only pass a primitive value around and it represents a concept in the language domain, let's wrap it around a record to give it a meaningful name.
* Otherwise, let's stick to the plain primitive values.

In our `TimeStamp` class, apart from `Create()`, we didn't have any other methods. We might validate if the inner date is in this century. But that won't be a problem. I don't think that code will live that long.

And, there are cleaner ways of [writing tests that use DateTime]({% post_url 2021-05-10-WriteTestsThatUseDateTimeNow %}) than using a static `SystemClock`. Maybe, if we can overwrite the `SystemClock` internal date.

I'd take a simpler route and use a plain `DateTime` value. I don't think there's a business case for `TimeStamp` here.

```csharp
public class DeliveryNotification : ValueObject
{
    public Recipient Recipient { get; init; }
    
    public DeliveryStatus Status { get; init; }
    
    public DateTime TimeStamp { get; init; }
    //     ^^^^^^

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Recipient;
        yield return Status;
        yield return TimeStamp;
    }
}

// Or alternative, to use the same language
//
// public record TimeStamp(DateTime Value);

public enum DeliveryStatus
{
    Created,
    Sent,
    Opened,
    Failed
}
```

If in the "email sending" domain, business analysts or stakeholders use "timestamp," for the sake of a ubiquitous language, we can add a simple record `TimeStamp` to wrap the date. Like `record TimeStamp(DateTime value)`.

Voilà! That's a practical option to decide when to use Value Objects and primitive values. For me, the key is asking if there's a meaningful domain concept behind the primitive value.

If you want to read more about Domain-Driven Design, check my takeaways from these books [ Hands-on Domain-Driven Design with .NET Core]({% post_url 	2022-10-03-HandsOnDDDTakeaways%}) and [Domain Modeling Made Functional]({% post_url 2021-12-13-DomainModelingMadeFunctional %}).

_Happy coding!_