---
layout: post
title: "For Cleaner Domains, Move IO to the Edges of Your App"
tags: tutorial csharp
cover: Cover.png
cover-alt: "A man climbing a mountain" 
---

Don't get too close with I/O.

That's how I'd summarize the talk "Moving IO to the edges of your app" by Scott Wlaschin at NDC Sydney 2024.

In case you don't know Scott Wlaschin's work, he runs the site [F# for Fun and Profit](https://fsharpforfunandprofit.com/) and talks about Functional Programming a lot. He's a frequent speaker at the NDC Conference.

Here's the YouTube video of the talk, in case you want to watch it:

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/P1vES9AgfC4?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

These are the main takeaways from that talk and how I'd follow them to refactor a piece of code from one of my past projects.

## I/O Is Evil: Keep It at Arm's Length

In a perfect world, all code should be pure. The same inputs return the same outputs with no side effects.

But we're not in a perfect world, and our code is full of impurities: retrieving the current time, accessing the network, and calling databases.

Instead of aiming for 100% pure code, the guideline is to **move I/O (or impurities) away from the business logic or rules**.

{% include image.html name="IoAtTheEdges.png" alt="IO at the edges" caption="Move IO to the Edges. Created based on speaker's slides" width="600px" %}

When we mix I/O with our domain logic, we make our domain logic harder to understand and test, and more error-prone.

So let's pay attention to functions with no inputs or no outputs. Often, they do I/O somewhere.

If you think we don't write functions with no outputs, let's take another look at our repositories.

Sure, our Create or Update methods might return an ID. But they're not deterministic. If we insert the same record twice, we get different IDs or even an error if we have unique constraints in our tables.

The guideline here is to write code that is:

* **Comprehensible**: it receives what it needs as input and returns some output.
* **Deterministic**: it returns the same outputs, given the same input.
* **Free of side effects**: it doesn't do anything under the hood.

## Just Return the Decision

This is the example shown in the talk:

Let's say we need to update a customer's personal information. If the customer changes their email, we should send a verification email. And, of course, we should update the new name and email in the database.

This is how we might do that,

```csharp
async static Task UpdateCustomer(Customer newCustomer)
{
    var existing = await CustomerDb.ReadCustomer(newCustomer.Id); // <--

    if (existing.Name != newCustomer.Name
        || existing.EmailAddress != newCustomer.EmailAddress)
    {
        await CustomerDb.UpdateCustomer(newCustomer); // <--
    }
    
    if (existing.EmailAddress != newCustomer.EmailAddress)
    {
        var message = new EmailMessage(newCustomer.EmailAddress, "Some message here...");
        await EmailServer.SendMessage(message); // <--
    }
}
```

We're mixing the database calls with our decision-making code. IO is "close" to our business logic.

Of course, we might argue static methods are a bad idea and pass two interfaces instead: `ICustomerDb` and `IEmailServer`. But we're still mixing IO with business logic.

This time, the guideline is to **create an imperative shell and just return the decision from our business logic**.

Here's how to update our customers "just returning the decision,"

```csharp
enum UpdateCustomerDecision
{
    DoNothing,
    UpdateCustomerOnly,
    UpdateCustomerAndSendEmail
}

// This is a good place for discriminated unions.
// But we still don't have them in C#. Sorry!
record UpdateCustomerResult(
    UpdateCustomerDecision Decision,
    Customer? Customer,
    EmailMessage? Message);

static UpdateCustomerResult UpdateCustomer(Customer existing, Customer newCustomer)
{
    var result = new UpdateCustomerResult(UpdateCustomerDecision.DoNothing, null, null);

    if (existing.Name != newCustomer.Name
        || existing.EmailAddress != newCustomer.EmailAddress)
    {
        result = result with
        {
            Decision = UpdateCustomerDecision.UpdateCustomerOnly,
            Customer = newCustomer
        };
    }

    if (existing.EmailAddress != newCustomer.EmailAddress)
    {
        var message = new EmailMessage(newCustomer.EmailAddress, "Some message here...");

        result = result with
        {
            Decision = UpdateCustomerDecision.UpdateCustomerAndSendEmail,
            Message = message
        };
    }

    return result;
}

async static Task ImperativeShell(Customer newCustomer)
{
    var existing = await CustomerDb.ReadCustomer(newCustomer.Id);

    var result = UpdateCustomer(existing, newCustomer);
    //           ^^^^^
    // Nothing impure here

    switch (result.Decision)
    {
        case DoNothing:
            // Well, doing nothing...
            break;

        case UpdateCustomerOnly:
            // Updating the database here...
            break;

        case UpdateCustomerAndSendEmail:
            // Update the database here...
            // And, send the email here...
            break;
    }
}
```

With the imperative shell, we don't have to deal with database calls and email logic inside our `UpdateCustomer()`. And we can unit test it without mocks.

As a side note, `UpdateCustomerDecision` and `UpdateCustomerResult` are a simple alternative to [discriminated unions]({% post_url 2024-08-19-DiscriminatedUnionSupport %}). Think of discriminated unions like enums where each member could be an object of a different type.

In more complex codebases, `ImperativeShell()` would be like a use case class or command handler.

## Pure Code Doesn't Talk to the Outside

When we push I/O to the edges, our pure code doesn't need exception handling or asynchronous logic. Our pure code doesn't talk to the outside world.
	
These are the three code smells the speaker shared to watch out for in our domain code:

1. **Is it async?** If so, you're doing I/O somewhere
2. **Is it catching exceptions?** Again, you're (probably) doing I/O somewhere
3. **Is it throwing exceptions?** Why not use a proper return value?

If any of these are true, we're doing IO inside our domain. And we should refactor our code. "All hands man your refactoring stations."

## Moving I/O to the Edges When Sending an Email

While watching this talk, I realized I could refactor some code I wrote for sending emails in a past project.

Before sending an email, we need to validate if we're sending it to valid domains. And, after calling a third-party email service, we should store a tracking number and update the email status. Something like this,

```csharp
public class Email
{
    // Imagine more properties like From, Subject, Body here...
    private readonly IEnumerable<Recipient> _recipients = new List<Recipient>();

    public async Task SendAsync(
        IEmailService emailService,
        IDomainValidationService validationService,
        CancellationToken cancellationToken)
    {
        try
        {
            await validationService.ValidateAsync(this, cancellationToken);

            // It assumes that ValidateAsync changes the recipient's status
            if (_recipients.Any(t => t.LastStatus != DeliveryStatus.FailedOnSend))
            {
                var trackingId = await emailService.SendEmailAsync(this, cancellationToken);
                SetTrackingId(trackingId);
                MarkAsSentToProvider();
            }
        }
        catch (Exception ex)
        {
            UpdateStatus(DeliveryStatus.FailedOnSend);
            throw new SendEmailException("Sending email failed.", ex);
        }
    }
}
```

But this code contains the three code smells we should avoid: it has asynchronous logic and throws and catches exceptions, and even our Domain is aware of cancellation tokens. Arrggg!

That was an attempt to do Domain Driven Design (DDD) at a past team. And probably, our team at that time picked those conventions from the book [Hands-on Domain-Driven Design with .NET Core]({% post_url 2022-10-03-HandsOnDDDTakeaways %}).

And the imperative shell that calls `SendAsync()` is something like this,

```csharp
public class SendEmailHandler : IEventHandler<EmailCreatedEvent>
{
    // Imagine some fields and a constructor here...

    public async Task Handle(EmailCreatedEvent evt, CancellationToken cancellationToken)
    {
        var email = await _emailRepository.GetByIdAsync(evt.EmailId);
                        ?? throw new EmailNotFoundException(evt.EmailId);

        try
        {
            await email.SendAsync(_emailService, _validationService, cancellationToken);

            await _emailRepository.UpdateAsync(email, cancellationToken);
        }
        catch (Exception ex)
        {
            email.SetFailedOnSend(ex.Message);
            await _emailRepository.UpdateAsync(email, cancellationToken);
        }
    }
}
```

And here's the same logic "returning the decision,"

```csharp
// This is a poor man's discriminated union
public abstract record SendingAttempt
{
    private SendingAttempt() { }

    public record SentToSome(Guid TrackingId, IEnumerable<Recipient> Recipients) : SendingAttempt;
    public record SentToNone() : SendingAttempt;
    public record FailedToSend(string Message): SendingAttempt;
}

public class Email
{
    // Imagine more properties like From, Subject, Body here...
    private readonly IEnumerable<Recipient> _recipients = new List<Recipient>();

    public Email Send(SendingAttempt attempt)
    {
        switch (attempt)
        {
            case SendingAttempt.SentToSome:
                // Set trackingId and mark as Sent for some recipients
		// Mark all other recipients as Invalid
		break;
            
            case SendingAttempt.SentToNone:
		// Mark all recipients as Invalid
		break;

            case SendingAttempt.FailedToSend:
                // Mark all recipients as Failed
		break;
        }
    }
}
```

In this refactored version, we've removed the asynchronous logic and exception handling. Now, it receives a `SendingAttempt` with the result of validating domains and email delivery to the email provider.

Also, it doesn't have any dependencies passed as interfaces. It embraces Dependency Rejection.

And here's the imperative shell,

```csharp
public class SendEmailHandler : IEventHandler<EmailCreatedEvent>
{
    // Imagine some fields and a constructor here...

    public async Task Handle(EmailCreatedEvent evt, CancellationToken cancellationToken)
    {
        var email = await _emailRepository.GetByIdAsync(evt.EmailId)
                        ?? throw new EmailNotFoundException(evt.EmailId);

        var result = await _validationService.ValidateAsync(email, cancellationToken);
        
        // Use result to find valid and invalid destinations...
	// Attempt to send email and catch any exceptions...
        var sendingAttempt = BuildASendingAttemptHere();

        email.Send(sendingAttempt);
	//    ^^^^
	// Nothing impure here

        await _emailRepository.UpdateAsync(email, cancellationToken);
    }
}
```

Now, the imperative shell validates email domains and tries to send the email, encapsulating all the I/O around `Send()`. After this refactoring, we should rename `Send()` inside our domain to something else.

Voila! That's one approach to have pure business logic, not the one and only approach.

Whether we follow Ports and Adapters, Clean Architecture, or Functional Core-Imperative Shell, the goal is to abstract dependencies and avoid "contaminating" our business domain.

For more content on architecture and modeling, check [Domain Modeling Made Functional: Takeaways]({% post_url 2021-12-13-DomainModelingMadeFunctional %}) and 
[To Value Object or Not To: How I choose Value Objects]({% post_url 2022-12-21-WhenToChooseValueObjects %}).