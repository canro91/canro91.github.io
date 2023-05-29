---
layout: post
title: "Let's refactor a test: Update email statuses"
tags: csharp
cover: Cover.png
cover-alt: "Letters on a table" 
---

Let's continue refactoring some tests for an email component. Last time, we refactored two tests that [remove duplicated email addresses]({% post_url 2022-12-22-TestingDuplicatedEmails %}) before sending an email. This time, let's refactor two more tests. But these ones check that we change an email status once we receive a "webhook" from a third-party email service. Let's refactor them.

## Here are the tests to refactor

If you missed the [last refactoring session]({% post_url 2022-12-22-TestingDuplicatedEmails %}), these tests belong to an email component in a Property Management Solution. This component stores all emails before sending them and keeps track of their status changes.

These two tests check we change the recipient status to either "delivered" or "complained." Of course, the original test suite had more tests. We only need one or two tests to prove a point.

```csharp
using Moq;

namespace AcmeCorp.Email.Tests;

public class UpdateStatusCommandHandlerTests
{
    [Fact]
    public async Task Handle_ComplainedStatusOnlyOnOneRecipient_UpdatesStatuses()
    {
        var fakeRepository = new Mock<IEmailRepository>();
        var handler = BuildHandler(fakeRepository);

        var command = BuildCommand(withComplainedStatusOnlyOnCc: true);
        //                         ^^^^^
        await handler.Handle(command, CancellationToken.None);

        fakeRepository.Verify(t => t.UpdateAsync(
            It.Is<Email>(d =>
                d.Recipients[0].LastDeliveryStatus == DeliveryStatus.ReadyToBeSent
                //         ^^^^^
                && d.Recipients[1].LastDeliveryStatus == DeliveryStatus.Complained)),
                //            ^^^^^
            Times.Once());
    }

    [Fact]
    public async Task Handle_DeliveredStatusToBothRecipients_UpdatesStatuses()
    {
        var fakeRepository = new Mock<IEmailRepository>();
        var handler = BuildHandler(fakeRepository);

        var command = BuildCommand(withDeliveredStatusOnBoth: true);
        //                         ^^^^^
        await handler.Handle(command, CancellationToken.None);

        fakeRepository.Verify(t => t.UpdateAsync(
            It.Is<Email>(d =>
                d.Recipients[0].LastDeliveryStatus == DeliveryStatus.Delivered
                //         ^^^^^
                && d.Recipients[1].LastDeliveryStatus == DeliveryStatus.Delivered)),
                //            ^^^^^
            Times.Once());
    }

    private static UpdateStatusCommandHandler BuildHandler(
        Mock<IEmailRepository> fakeRepository)
    {
        fakeRepository
            .Setup(t => t.GetByIdAsync(It.IsAny<Guid>()))
            .ReturnsAsync(BuildEmail());

        return new UpdateStatusCommandHandler(fakeRepository.Object);
    }

    private static UpdateStatusCommand BuildCommand(
        bool withComplainedStatusOnlyOnCc = false,
        bool withDeliveredStatusOnBoth = false
        // Imagine more flags for other combination
        // of statuses. Like opened, bounced, and clicked
    )
        // Imagine building a large object graph here
        // based on the parameter flags
        => new UpdateStatusCommand();

    private static Email BuildEmail()
        => new Email(
            "A Subject",
            "A Body",
            new[]
            {
                Recipient.To("to@email.com"),
                Recipient.Cc("cc@email.com")
            });
}
```

I slightly changed some test and method names. But those are some of the real tests I had to refactor.

What's wrong with those tests? Did you notice it?

These tests use [Moq to create a fake]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) for the `IEmailRepository` and the `BuildHandler()` and `BuildCommand()` factory methods to [reduce the noise]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) and keep our test simple.

<figure>
<img src="https://images.unsplash.com/photo-1634562876572-5abe57afcceb?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY4MDY1MjQxMQ&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="A pen sitting in top of a piece of paper" />

<figcaption>Photo by <a href="https://unsplash.com/@towfiqu999999?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Towfiqu barbhuiya</a> on <a href="https://unsplash.com/photos/6FpGIdn45_A?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## What's wrong?

Let's take a look at the first test. Inside the `Verify()` method, why is the `Recipient[1]` the one expected to have `Complained` status? what if we change the order of recipients?

Based on the [scenario in the test name]({% post_url 2021-04-12-UnitTestNamingConventions %}), _"complained status only on one recipient"_, and the `withComplainedStatusOnlyOnCc` parameter passed to `BuildCommand()`, we might think `Recipient[1]` is the email's cc address. But, the test hides the order of recipients. We would have to inspect the `BuildHandler()` method to see the email injected into the handler and check the order of recipients.

In the second test, since we expect all recipients to have the same status, we don't care much about the order of recipients.

**We shouldn't hide anything in builders or helpers and later use those hidden assumptions in other parts of our tests. That makes our tests difficult to follow. And we shouldn't make our readers decode our tests.**

## Explicit is better than implicit

Let's rewrite our tests to avoid passing flags like `withComplainedStatusOnlyOnCc` and `withDeliveredStatusOnBoth`, and verifying on a hidden recipient order. Instead of passing flags for every possible combination of status to `BuildCommand()`, let's create one [object mother]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}) per status explicitly passing the email addresses we want.

Like this,

```csharp
public class UpdateStatusCommandHandlerTests
{
    [Fact]
    public async Task Handle_ComplainedStatusOnlyOnOneRecipient_UpdatesStatuses()
    {
        var addresses = new[] { "to@email.com", "cc@email.com" };
        var repository = new Mock<IEmailRepository>()
                            .With(EmailFor(addresses));
                            //    ^^^^^
        var handler = BuildHandler(repository);

        var command = UpdateStatusCommand.ComplaintFrom("to@email.com");
        //                                ^^^^^
        await handler.Handle(command, CancellationToken.None);

        repository.VerifyUpdatedStatusFor(
        //         ^^^^^
            ("to@email.com", DeliveryStatus.Complained),
            ("cc@email.com", DeliveryStatus.ReadyToBeSent));
    }

    [Fact]
    public async Task Handle_DeliveredStatusToBothRecipients_UpdatesStatuses()
    {
        var addresses = new[] { "to@email.com", "cc@email.com" };
        var repository = new Mock<IEmailRepository>()
                            .With(EmailFor(addresses));
                            //    ^^^^^
        var handler = BuildHandler(repository);

        var command = UpdateStatusCommand.DeliveredTo(addresses);
        //                                ^^^^^
        await handler.Handle(command, CancellationToken.None);
                
        repository.VerifyUpdatedStatusForAll(DeliveryStatus.Delivered);
        //         ^^^^^
    }
}
```

First, instead of creating a fake `EmailRepository` with a hidden email object, we wrote a `With()` method. And to make things more readable, we renamed `BuilEmail()` to `EmailFor()` and passed the destinations explicitly to it. We can read it like `mock.With(EmailFor(anAddress))`.

Next, instead of using a single `BuildCommand()` with a flag for every combination of statuses, we created one object mother per status: `ComplaintFrom()` and `DeliveredTo()`. Again, we passed the email addresses we expected to have either complained or delivered statuses.

Lastly, for our Assert part, we created two [custom Verify methods]({% post_url 2021-08-16-WriteCustomAssertions %}): `VerifyUpdatedStatusFor()` and  `VerifyUpdatedStatusForAll()`. In the first test, we passed to `VerifyUpdatedStatusFor()` an array of tuples with the email address and its expected status.

Voilà! That was another refactoring session. When we write unit tests, we should strive for a balance between implicit code to reduce the noise in our tests and explicit code to make things easier to follow.

In the original version of these tests, we hid the order of recipients when building emails. But then we relied on that order when writing assertions. Let's not be like magicians pulling code we had hidden somewhere else.

Also, let's use extension methods and object mothers like `With()`, `EmailFor()`, and `DeliveredTo()` to create a small "language" in our tests, striving for readability. The next person writing tests will copy the existing ones. That will make his life easier.

For more refactoring sessions, check these two: [store and update OAuth connections]({% post_url 2022-12-08-TestingOAuthConnections %}) and [generate payment reports]({% post_url 2021-08-02-LetsRefactorATest %}). And don't miss my [Unit Testing 101 series]({%  post_url 2021-08-30-UnitTesting %}) where I cover from naming conventions to best practices.

_Happy testing!_