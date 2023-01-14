---
layout: post
title: "Hands-on Domain-Driven Design with .NET Core: Takeaways"
tags: books
cover: Cover.png
cover-alt: "Handcrafting a piece of clay"
---

If you're new to Domain-Driven Design, this book is a good starting point. It's a "hands-on" book. It walks through a sample marketplace for ads. It shows from what Domain-Driven Design is to how to evolve a system. Also, it contains a couple of chapters with a good introduction to Event Sourcing. These are my takeaways.

## DDD and Ubiquitous Language

The main point of Domain-Driven Design (DDD) is sharing the domain language between domain experts and developers in meetings, documentation, and even in code. That's what we call a "Ubiquitous Language."

In our code, we should make all domain concepts explicit and express intent clearly. For example, in a software system to register Paid time off, what do `StartDate`, `EndDate`, and `HalfDate` mean? Does `StartDate` refer to the last day at work or the first non-working day? What about: `FirstDayNotAtWork`, `CameBackToWork`, and `LeftDuringWorkday`?

A ubiquitous language makes sense in a context. For example, a product doesn't mean the same thing for the Sales, Purchasing, and Inventory departments.

Therefore, we should avoid God-classes like `Product` or `Customer` with properties for all possible views of the physical object, since not all properties need to be populated at a given time.

<figure>
<img src="https://images.unsplash.com/photo-1585849834908-3481231155e8?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY2Mzk1MjgxNw&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Half of a red onion on a white background" />

<figcaption>Does your architecture make you cry too? Photo by <a href="https://unsplash.com/@k8_iv?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">K8</a> on <a href="https://unsplash.com/s/photos/onion?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Onion Architecture and CQRS

This book advocate using the Onion Architecture and Command-query Responsibility Segregation (CQRS) when implementing DDD.

When following the Onion Architecture, the Domain is the center of everything, and everything depends on it. Application services and Infrastructure are layers around this core. Apart from standard libraries and some base classes, the Domain shouldn't have any references.

> _"A good rule of thumb here is that the whole domain model should be testable without involving any infrastructure. Primarily, in your domain model tests, you should not use test harnesses and mocks."_

CQRS distinguishes between write and read operations using commands that mutate the system and queries that return the system state.

{% include image.html name="CQRS.png" alt="CQRS commands and queries" caption="CQRS commands and queries flow" %}

To implement CQRS, we can use database-mapped domain objects to mutate the system and SQL queries to retrieve the system, ignoring the domain model.

## DDD Mechanics

To implement a domain model in code, DDD has some recognizable types of objects like entities, value objects, events, and services.

**Entities** should have an Id, accessible from the outside. IDs are database unique keys or GUIDs. We shouldn't change an entity by changing its properties from outside the entity.

**Value objects** should be immutable. Two entities are the same by their identity but value objects by their value. To validate entity invariants, we can use a `EnsureValidState()` method.

**Events** are reactions to executions of commands. Events represent data in commands and other details from the changed entity, like the Id. Events should only contain primitive types. With events, we can notify changes in one part of the system.

**Application services** accept commands and use the Domain to handle the operation. An application service is responsible for translating primitive types to value objects. Often, all application services follow a similar script: they retrieve an entity from the database, mutate it and update the database.

**Aggregate Roots** work like a parent entity that changes its state as a whole. We should only reference, access, and manipulate child objects of an aggregate through the aggregate boundary.

## Queries, Repositories, and Databases

_"A domain model exists on its own, and it is designed to deal with business rules and invariants, and not to deal with the database."_

There's a distinction between repositories and queries. Repositories deal with the aggregate state. In a `ClassifiedAdRepository`, we only should get `ClassifiedAds`. For all other data access, we should use queries.

We should write queries using the Ubiquitous Language too. For example, let's write `GetAdsPendingReview()` instead of `GetAds(ad => ad.State == State.PendingReview)`. And we can access the storage directly on our query handlers. That's fine.

For example, this is a query to return active classified ads,

```csharp
public static class Queries
{
    public static async Task<IEnumerable<PublicClassifiedAdListItem>> QueryPublishedClassifiedAds(
        this DbConnection someDbConnection,
        QueryModels.GetPublishedClassifiedAds query)
    {
        await someDbConnection.QueryAsync<PublicClassifiedAdListItem>("Plain old SQL query",
            new
            {
                State = (int)ClassifiedAdState.Active,
                PageSize = query.PageSize,
                Offset = Offset(query.Page, query.PageSize)
            });
    }
}
```

## Parting Thoughts

Voilà! Those are my takeaways. I'd say it's a good book to learn about DDD for the first time. There are things I liked and didn't like about this book.

I liked that the book contains a practical example, a marketplace for ads, not only theory. If you want to follow along with the code sample, read these chapters: 4, 5, 6, 7, and 9. Skip most of chapter 8 if you already know how to set up EntityFramework. Skim through all others.

I liked how the sample application doesn't use interfaces just for the sake of it. I've seen so many single-implementation interfaces to only use a dependency container and test it with mocks. And I also liked how query handlers use SQL statements directly instead of using another layer of indirection.

But, I didn't like that the sample application ended up with "application services" instead of "command handlers." I was expecting a command handler per each command and API method. The only sample application service has a huge switch statement to handle every command. Argggg!

For more takeaways, check [Domain Modeling Made Functional: Takeaways]({% post_url 2021-12-13-DomainModelingMadeFunctional %}). Don't miss [A case of Primitive Obsession]({% post_url 2020-12-10-PrimitiveObsession %}), it shows how to put in place classes (or records) to replace primitive types. And, my heuristics to [choose Value Objects]({% post_url 2022-12-21-WhenToChooseValueObjects %}).

_Happing coding!_