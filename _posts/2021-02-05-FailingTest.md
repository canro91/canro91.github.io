---
layout: post
title: "How to write good unit tests: Write failing tests first"
tags: tutorial csharp
cover: FailingTest.png
cover-alt: How to write good unit tests? Have a failing test
---

A passing test isn't always the only thing to look for. It's important to see our test failing. I learned this lesson the hard way. Let's see why we should start writing failing tests.

**To write reliable unit tests, always start writing a failing test. And make sure it fails for the right reasons. Follow the Red, Green, Refactor principle of Test-Driven Development (TDD). Write a failing test, make it pass, and refactor the code. Don't skip the failing test part.**

## The Passing test

Let's continue with the same example from our previous post on [how to write good unit tests by reducing noise and using obvious test values]({% post_url 2020-11-02-UnitTestingTips %}).

From our last example, we had a controller to create, update, and suspend user accounts. Inside its constructor, this controller validated some email addresses from an injected configuration object.

After we refactored our test from the last post, we ended up with this:

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
        MakeAccountController(emailConfig));
        // ^^^^^
}

private AccountController MakeAccountController(
    IOptions<EmailConfiguration> emailConfiguration)
    // ^^^^^
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
            // ^^^^^
            httpContextAccessor.Object);
}
```

<figure>
<img src="https://images.unsplash.com/photo-1521925410155-c49b38ec65ac?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Always start writing a failing test" />

<figcaption>Always start writing a failing test. <span>Photo by <a href="https://unsplash.com/@loveneora?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Neora Aylon</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## A false positive

This time, I had a new requirement. I needed to add a new method to our `AccountController`. This new method [read another configuration object]({% post_url 2020-08-21-HowToConfigureValues %}) injected into the controller.

To follow the convention of [validating required parameters inside constructors]({% post_url 2022-12-02-ValidateInputParameters %}), I also checked for this new configuration object. I wrote a new test and a new `MakeAccountController()` builder method to call the constructor with only the parameters I needed.

```csharp
[TestMethod]
public void AccountController_NoNewConfig_ThrowsException()
{
    var options = Options.Create<SomeNewConfig>(null);

    Assert.ThrowsException<ArgumentNullException>(() =>
        MakeAccountController(options));
}

// A new builder method
private AccountController MakeAccountController(IOptions<SomeNewConfig> someNewConfig)
{
    var emailConfig = new Mock<IOptions<EmailConfiguration>());
    return CreateAccountController(emailConfig.Object, someNewConfig);
}

private AccountController MakeAccountController(
    IOptions<EmailConfiguration> emailConfig,
    IOptions<SomeNewConfig> someNewConfig)
{
    // It calls the constructor with mocks, except for emailConfig and someNewConfig
}
```

And the constructor looked like this:

```csharp
public class AccountController : Controller
{
  public AccountController(
      IMapper mapper,
      ILogger<AccountController> logger,
      IAccountService accountService,
      IAccountPersonService accountPersonService,
      IEmailService emailService,
      IOptions<EmailConfiguration> emailConfig,
      IHttpContextAccessor httpContextAccessor,
      IOptions<SomeNewConfig> someNewConfig)
  {
      var emailConfiguration = emailConfig?.Value
            ?? throw new ArgumentNullException($"EmailConfiguration");
      if (string.IsNullOrEmpty(emailConfiguration.SenderEmail))
      {
          throw new ArgumentNullException($"SenderEmail");
      }

      var someNewConfiguration = someNewConfig?.Value
            ?? throw new ArgumentNullException($"SomeNewConfig");
      if (string.IsNullOrEmpty(someNewConfiguration.SomeKey)
      {
          throw new ArgumentNullException($"SomeKey");
      }

      // etc...
  }
}
```

I ran the test and it passed. Move on! But...Wait! There's something wrong with that test! Did you spot the issue?

## Make your tests fail for the right reasons

Of course, that test is passing. The code throws an `ArgumentNullException`. But, that exception is coming from the wrong place. It comes from the validation for the email configuration, not from our new validation.

I forgot to use a valid email configuration in the new `MakeAccountController()` builder method. I used a mock reference without setting up any values. I only realized that after getting my code reviewed. Point for the code review!

```csharp
private AccountController MakeAccountController(IOptions<SomeNewConfig> someNewConfig)
{
    var emailConfig = new Mock<IOptions<EmailConfiguration>());
    //  ^^^^^
    // Here we need to setup a valid EmailConfiguration
    return CreateAccountController(emailConfig.Object, someNewConfig);
}
```

**Let's make sure to start always by writing a failing test. And, this test should fail for the right reasons.**

If we write our tests after writing our production code, let's comment some parts of our production code to see if our tests fail or change the assertions on purpose.

When we make a failed test pass, we're testing the test. We're making sure it fails and passes when it should. We know we aren't writing buggy tests or introducing false positives into our test suite.

A better test for our example would check the exception message. Like this:

```csharp
[TestMethod]
public void AccountController_NoSomeNewConfig_ThrowsException()
{
    var options = Options.Create<SomeNewConfig>(null);

    var ex = Assert.ThrowsException<ArgumentNullException>(() => 
        MakeAccountController(options));
    StringAssert.Contains(ex.Message, nameof(SomeNewConfig));
}
```

Voilà! This task reminded me to see my tests fail for the right reasons. Do you have passing tests? Do they pass and fail when they should? I hope they do after reading this post.

For more tips on how to write good unit tests, check my follow-up on [using simple test values]({% post_url 2022-12-14-SimpleTestValues %}). Don't miss the rest of my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I also cover mocking, assertions, and best practices.

_Happy unit testing!_