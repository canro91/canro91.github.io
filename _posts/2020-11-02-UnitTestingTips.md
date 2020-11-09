---
layout: post
title: How to write good unit tests? Avoid these two issues
tags: tutorial csharp
cover: WriteUnitTests.png
cover-alt: Two issues to avoid to write good unit test
---

These days, I needed to update some tests. I found two issues on them. Please, continue to read. Maybe, you're a victim of those issues, too.

The tests were for an ASP.NET Core API controller, `AccountController`. This controller created, updated and suspended user accounts. Also, it sent a welcome email to new users.

These tests checked a configuration object for the sender, reply-to and contact-us email addresses. The welcome email contained the three. If one of the email addresses were null or empty, the controller threw an exception from its constructor.

Let's see one of the tests. This test checks for the sender email. _Can you spot any issues?_

```csharp
[TestMethod]
public Task AccountController_SenderEmailIsNull_ThrowsException()
{
    var mapper = new Mock<IMapper>();
    var logger = new Mock<ILogger<AccountController>>();
    var accountService = new Mock<IAccountService>();
    var accountPersonService = new Mock<IAccountPersonService>();
    var emailService = new Mock<IEmailService>();
    var emailConfig = new Mock<IOptions<EmailConfiguration>>();
    var httpContextAccessor = new Mock<IHttpContextAccessor>();

    emailConfig.SetupGet(options => options.Value)
        .Returns(new EmailConfiguration()
        {
            ReplyToEmail = "email@email.com",
            SupportEmail = "email@email.com"
        });

    Assert.ThrowsException<ArgumentNullException>(() =>
        new AccountController(
            mapper.Object,
            logger.Object,
            accountService.Object,
            accountPersonService.Object,
            emailService.Object,
            emailConfig.Object,
            httpContextAccessor.Object
        ));

    return Task.CompletedTask;
}
```

The tests used [Moq](https://github.com/moq/moq4), a mocking library for .NET. I already wrote about the things [I like and dislike about Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}). Let's see the two issues with this test.

Two issues to avoid when writing unit tests are **noise** and **hidden test scenarios**. First, tests are often full of noise in the form of complex arrange or setup scenarios. And, test values aren't obvious. Test names states an scenario, but you have to dig into the test to find the test values. Remember, readability is king when writing unit tests.

_Did you spot these issues on our sample test? No. It wasn't the naming convention._

<figure>
<img src="https://images.unsplash.com/32/6Icr9fARMmTjTHqTzK8z_DSC_0123.jpg?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop&ixid=eyJhcHBfaWQiOjF9" alt="Adjusting dials on a mixer" />

<figcaption><span>Photo by <a href="https://unsplash.com/@drewpatrickmiller?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Drew Patrick Miller</a> on <a href="https://unsplash.com/photos/73o_FzZ5x-w?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## Reduce the noise

Our sample test only cares about one object, `IOptions<EmailConfiguration>`. All other objects are noise. They don't have anything to do with scenario under test.

**Use builder methods to reduce complex setup scenarios.**

Let's reduce the noise from our example with a `MakeAccountController` method. It will receive the only parameter the test needs.

After this change, our test looked like this:

```csharp
[TestMethod]
public void AccountController_SenderEmailIsNull_ThrowsException()
{
    var emailConfig = new Mock<IOptions<EmailConfiguration>>();
    emailConfig.SetupGet(options => options.Value)
        .Returns(new EmailConfiguration
        {
            ReplyToEmail = "email@email.com",
            SupportEmail = "email@email.com"
        });

    Assert.ThrowsException<ArgumentNullException>(() =>
        MakeAccountController(emailConfig.Object));
}

private AccountController MakeAccountController(IOptions<EmailConfiguration> emailConfiguration)
{
    var mapper = new Mock<IMapper>();
    var logger = new Mock<ILogger<AccountController>>();
    var accountService = new Mock<IAccountService>();
    var accountPersonService = new Mock<IAccountPersonService>();
    var emailService = new Mock<IEmailService>();
    var emailConfig = new Mock<IOptions<EmailConfiguration>>();
    var httpContextAccessor = new Mock<IHttpContextAccessor>();

    return new AccountController(
            mapper.Object,
            logger.Object,
            accountService.Object,
            accountPersonService.Object,
            emailService.Object,
            emailConfiguration,
            httpContextAccessor.Object
        ));
}
```

Also, since our test doesn't have any asynchronous code, we could remove the return statement and make our test a `void` method.

With this refactor, our test started to look simplier and easier to read. Now, it's clear this test only cares about the email configuration.

## Make your test values obvious

In our example, the test name says the sender email is null. Anyone reading this test would expect to see a variable set to null and passed around. But, that's not the case.

**Make your scenario under test and test value extremely obvious**. Please, don't make developers to decode your tests.

To make the test scenario obvious in our example, let's add `SenderEmail = null`.

```csharp
[TestMethod]
public void AccountController_SenderEmailIsNull_ThrowsException()
{
    var emailConfig = new Mock<IOptions<EmailConfiguration>>();
    emailConfig.SetupGet(options => options.Value)
        .Returns(new EmailConfiguration
        {
            SenderEmail = null,
            ReplyToEmail = "email@email.com",
            SupportEmail = "email@email.com"
        });

    Assert.ThrowsException<ArgumentNullException>(() =>
        CreateAccountController(emailConfig.Object));
}
```

Finally, as an aside, we don't need a mock on `IOptions<EmailConfiguration>`. We can use `Option.Create` instead. Let's do it.

```csharp
[TestMethod]
public void AccountController_SenderEmailIsNull_ThrowsException()
{
    var emailConfig = Options.Create(new EmailConfiguration
    {
        SenderEmail = null,
        ReplyToEmail = "email@email.com",
        SupportEmail = "email@email.com"
    });

    Assert.ThrowsException<ArgumentNullException>(() =>
        CreateAccountController(emailConfig));
}
```

Voilà! That's easier to read. Do you have those two issues on your own tests? Remember, readability is one of the pillars of unit testing.

For other tips on writing unit tests, you can check my takeaways from the book [The Art of Unit Testing]({% post_url 2020-03-06-TheArtOfUnitTestingReview %}) and my post on [how to write fakes with Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}).

_Happy unit testing!_
