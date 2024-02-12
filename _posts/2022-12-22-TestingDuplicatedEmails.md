---
layout: post
title: "Let's refactor a test: Remove duplicated emails"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Stamped envelops with letters"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

Recently, I've been [reviewing pull requests]({% post_url 2022-12-05-LeadingQuestionsOnCodeReviews %}) as one of my main activities. This time, let's refactor two tests I found on one code review session. The two tests check if an email doesn't have duplicated addresses before sending it. But, they have a common mistake: testing private methods directly. Let's refactor these tests to use the public facade of methods.

**Always write unit tests using the public methods of a class or a group of classes. Don't make private methods public and static to test them directly. Test the observable behavior of classes instead.**

## Here are the test to refactor

These tests belong to an email component in a Property Management Solution. This component stores all emails before sending them.

These are two tests to check we don't try to send an email to the same addresses. Let's pay attention to the class name and method under test.

```csharp
public class SendEmailCommandHandlerTests
{
    [Fact]
    public void CreateRecipients_NoDuplicates_ReturnsSameRecipients()
    {
        var toEmailAddresses = new List<string>
        {
            "toMail1@mail.com", "toMail2@mail.com"
        };
        var ccEmailAddresses = new List<string>
        {
            "ccMail3@mail.com", "ccMail4@mail.com"
        };

        var recipients = SendEmailCommandHandler.CreateRecipients(toEmailAddresses, ccEmailAddresses);
        //                                       ^^^^^
        
        recipients.Should().BeEquivalentTo(
          new List<Recipient>
          {
              Recipient.To("toMail1@mail.com"),
              Recipient.To("toMail2@mail.com"),
              Recipient.Cc("ccMail3@mail.com"),
              Recipient.Cc("ccMail4@mail.com")
          });
    }

    [Fact]
    public void CreateRecipients_Duplicates_ReturnsRecipientsWithoutDuplicates()
    {
        var toEmailAddresses = new List<string>
        {
            "toMail1@mail.com", "toMail2@mail.com", "toMail1@mail.com"
        };
        var ccEmailAddresses = new List<string>
        {
            "ccMail1@mail.com", "toMail2@mail.com"
        };

        var recipients = SendEmailCommandHandler.CreateRecipients(toEmailAddresses, ccEmailAddresses);
        //                                       ^^^^^

        recipients.Should().BeEquivalentTo(
          new List<Recipient>
          {
              Recipient.To("toMail1@mail.com"),
              Recipient.To("toMail2@mail.com"),
              Recipient.Cc("ccMail1@mail.com"),
          });
    }
}
```

I slightly changed some names. But those are the real tests I had to refactor.

What's wrong with those tests? Did you notice it? Also, can you point out where the duplicates are in the second test?

To have more context, here's the `SendEmailCommandHandler` class that contains the `CreateRecipients()` method,

```csharp
using MediatR;
using Microsoft.Extensions.Logging;
using MyCoolProject.Commands;
using MyCoolProject.Shared;

namespace MyCoolProject;

public class SendEmailCommandHandler : IRequestHandler<SendEmailCommand, TrackingId>
{
    private readonly IEmailRepository _emailRepository;
    private readonly ILogger<SendEmailCommandHandler> _logger;

    public CreateDispatchCommandHandler(
        IEmailRepository emailRepository,
        ILogger<CreateDispatchCommandHandler> logger)
    {

        _emailRepository = emailRepository;
        _logger = logger;
    }

    public async Task<TrackingId> Handle(SendEmailCommand command, CancellationToken cancellationToken)
    {
        // Imagine some validations and initializations here...

        var recipients = CreateRecipients(command.Tos, command.Ccs);
        //               ^^^^^
        var email = Email.Create(
            command.Subject,
            command.Body,
            recipients);

        await _emailRepository.CreateAsync(email);

        return email.TrackingId;
    }

    public static IEnumerable<Recipient> CreateRecipients(IEnumerable<string> tos, IEnumerable<string> ccs)
    //                                   ^^^^^
        => tos.Select(Recipient.To)
              .UnionBy(ccs.Select(Recipient.Cc), recipient => recipient.EmailAddress);
    }
}

public record Recipient(EmailAddress EmailAddress, RecipientType RecipientType)
{
    public static Recipient To(string emailAddress)
        => new Recipient(emailAddress, RecipientType.To);

    public static Recipient Cc(string emailAddress)
        => new Recipient(emailAddress, RecipientType.Cc);
}

public enum RecipientType
{
    To, Cc
}
```

The `SendEmailCommandHandler` processes all requests to send an email. It grabs the input parameters, creates an `Email` class, and stores it using a repository. It uses the [free MediatR library](https://github.com/jbogard/MediatR) to roll commands and command handlers. 

Also, it parses the raw email addresses into a list of `Recipient` with the `CreateRecipients()` method. That's the method under test in our two tests. Here the `Recipient` and `EmailAddress` work like [Value Objects]({% post_url 2022-12-21-WhenToChooseValueObjects %}).

Now can you notice what's wrong with our tests?

## What's wrong?

Our two unit tests test a private method directly. That's not the appropriate way of writing unit tests. We shouldn't test internal state and private methods. We should test them through the public facade of our logic under test.

In fact, someone made the `CreateRecipients()` method public to test it,

{% include image.html name="Diff.png" caption="Someone made the internals public to write tests" alt="Diff showing a private method made public" %}

Making private methods public to test them is [the most common mistake on unit testing]({% post_url 2021-10-11-DontRepeatLogicInAssertions %}).

For our case, we should write our tests using the `SendEmailCommand` class and the `Handle()` method.

## Don't expose private methods 

Let's make the `CreateRecipients()` private again. And let's write our tests using the `SendEmailCommand` and `SendEmailCommandHandler` classes.

This is the test to validate that we remove duplicates,

```csharp
[Fact]
public async Task Handle_DuplicatedEmailInTosAndCc_CallsRepositoryWithoutDuplicates()
{
    var duplicated = "duplicated@email.com";
    //  ^^^^^
    var tos = new List<string> { duplicated, "tomail@mail.com" };
    var ccs = new List<string> { duplicated, "ccmail@mail.com" };

    var fakeRepository = new Mock<IDispatchRepository>();

    var handler = new CreateDispatchCommandHandler(
        fakeRepository.Object,
        Mock.Of<ILogger<SendEmailCommandHandler>>());

    // Let's write a factory method that receives these two email lists
    var command = BuildCommand(tos: tos, ccs: ccs);
    //            ^^^^^
    await handler.Handle(command, CancellationToken.None);

    // Let's write some assert/verifications in terms of the Email object
    fakeRepository
        .Verify(t => t.CreateAsync(It.Is<Email>(/* Assert something here using Recipients */), It.IsAny<CancellationToken>());
    // Or, even better let's write a custom Verify()
    //
    // fakeRepository.WasCalledWithoutDuplicates();
}

private static SendEmailCommand BuildCommand(IEnumerable<string> tos, IEnumerable<string> ccs)
    => new SendEmailCommand(
        "Any Subject",
        "Any Body",
        tos,
        ccs);
```

Notice we wrote a `BuildCommand()` method to create a `SendEmailCommand` only with the email addresses. That's what we care about in this test. This way we [reduce the noise in our tests]({% post_url 2020-11-02-UnitTestingTips %}). And, to make our test values obvious, we declared a `duplicated` variable and used it in both destination email addresses.

To write the Assert part of this test, we can use the `Verify()` method from the fake repository to check that we have the `duplicated` email only once. Or we can use the Moq `Callback()` method to capture the `Email` being saved and write some assertions. Even better, we can create a [custom assertion]({% post_url 2021-08-16-WriteCustomAssertions %}) for that. Maybe, we can write a `WasCalledWithoutDuplicates()` method.

That's one of the two original tests. The other one is left as an exercise to the reader.

Voilà! That was today's refactoring session. To take home, we shouldn't test private methods and always write tests using the public methods of the code under test. We can remember this principle with the mnemonic: "Don't let others touch our private parts." That's how I remember it.

For more refactoring sessions, check these two: [store and update OAuth connections]({% post_url 2022-12-08-TestingOAuthConnections %}) and [generate payment reports]({% post_url 2021-08-02-LetsRefactorATest %}). Don't miss my [Unit Testing 101 series]({%  post_url 2021-08-30-UnitTesting %}) where I cover from naming conventions to best practices.

_Happy coding!_