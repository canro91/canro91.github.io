---
layout: post
title: "Let's refactor a test: Store and Update OAuth connections"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Cables connected to a switch"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

Last time, in the [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}), we [refactored a unit test]({% post_url 2021-08-02-LetsRefactorATest %}) for a method that fed a report of transactions in a payment system. This time, let's refactor another test. This test is based on a real test I had to refactor in one of my client's projects.

Before looking at our test, a bit of background. This test belongs to a two-way integration between a Property Management System and a third-party service. Let's call it: [Acme Corporation](https://en.wikipedia.org/wiki/Acme_Corporation). To connect one of our properties to Acme, we go throught an OAuth flow.

## A bit of background on OAuth flows

To start the OAuth flow, we call an Authorize endpoint in a web browser. Acme prompts us to enter a user and password. Then, they return a verification code. With it, we call a Token endpoint to grab the authentication and refresh tokens. We use the authentication token in a header in future requests.

Apart from the authentication and refresh codes, to make this integration work in both ways, we create some random credentials and send them to Acme. With these credentials, Acme calls some public endpoints on our side.

## Here's the test to refactor

With this background, let's look at the test we're going to refactor. This is an integration test that checks that we can create, update and retrieve Acme "connections" in our database.

```csharp
public class ConnectionRepositoryTests
{
    private const ClientId ClientId = new ClientId(123456);
    
    private static readonly AcmeCredentials AcmeCredentials
      = new AcmeCredentials("AnyAuthenticationToken", "AnyRefreshToken", SomeFutureExpirationDate);
    
    private static readonly AcmeCredentials OtherAcmeCredentials
      = new AcmeCredentials("OtherAuthenticationToken", "OtherRefreshToken", SomeFutureExpirationDate);

    private static readonly AcmeCompany AcmeCompany
      = new AcmeCompany(AcmeCompanyId, AcmeCompanyName);

    private readonly Mock<IAcmeService> _acmeConnectionServiceMock
      = new Mock<IAcmeService>();

    [Fact]
    public async Task GetConnectionAsync_ConnectionUpdated_ReturnsUpdatedConnection()
    {
        var repository = new AcmeConnectionRepository(AnySqlConnection);
        var acmeConnection = new AcmeConnection(ClientId);
        var acmeConnectionId = await repository.CreateAcmeConnectionAsync(acmeConnection);
        acmeConnection.GeneratePkce();
        acmeConnection = AcmeConnection.Load(
            acmeConnectionId,
            ClientId,
            pkce: acmeConnection.Pkce,
            acmeCredentials: AcmeCredentials,
            ourCredentials: OurCredentials.GenerateCredentials(ClientId));
        await repository.UpdateAcmeConnectionAsync(acmeConnection);

        var connectionFromDb = await repository.GetAcmeConnectionAsync(ClientId);
        acmeConnection = AcmeConnection.Load(
            acmeConnectionId,
            ClientId,
            AcmeCompany,
            connectionFromDb!.Pkce);
        acmeConnection.GeneratePkce();
        acmeConnection = AcmeConnection.Load(
            acmeConnectionId,
            ClientId,
            AcmeCompany,
            acmeConnection.Pkce,
            connectionFromDb.AcmeCredentials,
            connectionFromDb.OurCredentials);
        acmeConnection.UpdateAcmeCredentials(OtherAcmeCredentials);
        await acmeConnection.SetOurCredentialsAsync(_acmeConnectionServiceMock.Object);
        await repository.UpdateAcmeConnectionAsync(acmeConnection);
        var updatedConnectionFromDb = await repository.GetAcmeConnectionAsync(new ClientId(ClientId));
        acmeConnection = AcmeConnection.Load(
            acmeConnectionId,
            ClientId,
            AcmeCompany,
            Pkce.Load(acmeConnection.Pkce!.Id!,
                      acmeConnection.Pkce.CodeVerifier,
                      updatedConnectionFromDb.Pkce!.CreatedDate,
                      updatedConnectionFromDb.Pkce.UpdatedDate),
            AcmeCredentials.Load(acmeConnection.AcmeCredentials!.Id!,
                                acmeConnection.AcmeCredentials.RefreshToken,
                                acmeConnection.AcmeCredentials.AccessToken,
                                acmeConnection.AcmeCredentials.AccessTokenExpiration,
                                updatedConnectionFromDb.AcmeCredentials!.CreatedDate,
                                updatedConnectionFromDb.AcmeCredentials.UpdatedDate),
            OurCredentials.Load(acmeConnection.OurCredentials!.Id!,
                                acmeConnection.OurCredentials.Username,
                                acmeConnection.OurCredentials.Password,
                                updatedConnectionFromDb.OurCredentials!.CreatedDate,
                                updatedConnectionFromDb.OurCredentials.UpdatedDate));

        Assert.NotNull(connectionFromDb);
        Assert.NotNull(updatedConnectionFromDb);
        Assert.Equal(acmeConnectionId, connectionFromDb!.Id);
        Assert.Equal(acmeConnectionId, updatedConnectionFromDb!.Id);
        Assert.Equal(acmeConnection, updatedConnectionFromDb);
        Assert.NotEqual(acmeConnection, connectionFromDb);
    }
}
```

Yes, that's the real test. "Some names have been changed to protect the innocent." Can you take a look and identify what our test does?

To be fair, here's the `AcmeConnection` class with the signature of `Load()` and other methods,

```csharp
public record LightspeedConnection(PmsPropertyId PmsPropertyId)
{
    public static AcmeConnection Load(
        AcmeConnectionId dbId,
        ClientId clientId,
        AcmeCompany? acmeCompany = null,
        Pkce? pkce = null,
        AcmeCredentials? acmeCredentials = null,
        OurCredentials? ourCredentials = null)
    {
        // Create a new AcmeConnection from all the parameters
        // Beep, beep, boop...
    }

    // A bunch of methods to update the AcmeConnection state
    public void GeneratePkce() { /* ... */ }

    public void UpdateAcmeCompany(AcmeCompany company) { /* ... */ }

    public void UpdateAcmeCredentials(AcmeCredentials credentials) { /* ... */ }

    public void SetOurCredentialsAsync(IAcmeService service) { /* ... */ }
}
```

The `Pkce` object corresponds to two security codes we exchange in the OAuth flow. For more details, see [Dropbox guide on PKCE](https://dropbox.tech/developers/pkce--what-and-why-).

<figure>
<img src="https://images.unsplash.com/photo-1517373116369-9bdb8cdc9f62?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY3MDI1MzEyOQ&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="A electronic panel with lots of cables" />

<figcaption>Photo by <a href="https://unsplash.com/@barkiple?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">John Barkiple</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## What's wrong?

Did you spot what our test does? Don't worry. It took me some time to get what this test does, even though I was familiar with that codebase.

That test is full of noise and hard to follow. It abuses the `acmeConnection` variable. It keeps reading and assigning connections to it.

Behind all that noise, our test creates a new connection and stores it. Then, it retrieves, mutates, and updates the same connection. And in the last step, it recreates another one from all the input values to use it in the Assert part.

Let's see the test again, annotated this time,

```csharp
[Fact]
public async Task GetConnectionAsync_ConnectionUpdated_ReturnsUpdatedConnection()
{
    var repository = new AcmeConnectionRepository(AnySqlConnection);
    var acmeConnection = new AcmeConnection(ClientId);
    var acmeConnectionId = await repository.CreateAcmeConnectionAsync(acmeConnection);
    // 1. Create connection                 ^^^^^
    
    acmeConnection.GeneratePkce();
    acmeConnection = AcmeConnection.Load(
        acmeConnectionId,
        ClientId,
        pkce: acmeConnection.Pkce,
        acmeCredentials: AcmeCredentials,
        ourCredentials: OurCredentials.GenerateCredentials(ClientId));
    //  ^^^^^
    // 2. Change both credentials
    await repository.UpdateAcmeConnectionAsync(acmeConnection);

    var connectionFromDb = await repository.GetAcmeConnectionAsync(ClientId);
    //                                      ^^^^^
    // 3. Retrieve the newly created connection
    acmeConnection = AcmeConnection.Load(
        acmeConnectionId,
        ClientId,
        AcmeCompany,
        connectionFromDb!.Pkce);
    //  ^^^^^
    acmeConnection.GeneratePkce();
    //             ^^^^
    acmeConnection = AcmeConnection.Load(
        acmeConnectionId,
        ClientId,
        AcmeCompany,
        acmeConnection.Pkce,
        connectionFromDb.AcmeCredentials,
        connectionFromDb.OurCredentials);
    acmeConnection.UpdateAcmeCredentials(OtherAcmeCredentials);
    //             ^^^^^
    await acmeConnection.SetOurCredentialsAsync(_acmeConnectionServiceMock.Object);
    //                   ^^^^^
    // 4. Change Acme company and both credentials again
    await repository.UpdateAcmeConnectionAsync(acmeConnection);
    //               ^^^^^
    // 5. Update
    
    var updatedConnectionFromDb = await repository.GetAcmeConnectionAsync(new ClientId(ClientId));
    acmeConnection = AcmeConnection.Load(
    //                              ^^^^^
        acmeConnectionId,
        ClientId,
        AcmeCompany,
        Pkce.Load(acmeConnection.Pkce!.Id!,
                  acmeConnection.Pkce.CodeVerifier,
                  updatedConnectionFromDb.Pkce!.CreatedDate,
                  updatedConnectionFromDb.Pkce.UpdatedDate),
        AcmeCredentials.Load(acmeConnection.AcmeCredentials!.Id!,
                            acmeConnection.AcmeCredentials.RefreshToken,
                            acmeConnection.AcmeCredentials.AccessToken,
                            acmeConnection.AcmeCredentials.AccessTokenExpiration,
                            updatedConnectionFromDb.AcmeCredentials!.CreatedDate,
                            updatedConnectionFromDb.AcmeCredentials.UpdatedDate),
        OurCredentials.Load(acmeConnection.OurCredentials!.Id!,
                            acmeConnection.OurCredentials.Username,
                            acmeConnection.OurCredentials.Password,
                            updatedConnectionFromDb.OurCredentials!.CreatedDate,
                            updatedConnectionFromDb.OurCredentials.UpdatedDate));

    Assert.NotNull(connectionFromDb);
    Assert.NotNull(updatedConnectionFromDb);
    Assert.Equal(acmeConnectionId, connectionFromDb!.Id);
    Assert.Equal(acmeConnectionId, updatedConnectionFromDb!.Id);
    Assert.Equal(acmeConnection, updatedConnectionFromDb);
    Assert.NotEqual(acmeConnection, connectionFromDb);
}
```

Also, this test keeps using the `Load()` method, even though the `AcmeConnection` class has some methods to update its own state.

## Step 1. Use the same code as the Production code

**Write integration tests using the same code as the production code.**

Let's write our test in terms of our business methods instead of using the `Load()` everywhere.

```csharp
[Fact]
public async Task GetConnectionAsync_ConnectionUpdated_ReturnsUpdatedConnection()
{
    var repository = new AcmeConnectionRepository(AnySqlConnection);
    var acmeConnection = new AcmeConnection(ClientId);
    var acmeConnectionId = await repository.CreateAcmeConnectionAsync(acmeConnection);
    // 1. Create connection                 ^^^^^
    
    acmeConnection = await repository.GetAcmeConnectionAsync(ClientId);
    acmeConnection.GeneratePkce();
    //             ^^^^^
    await repository.UpdateAcmeConnectionAsync(acmeConnection);
    //               ^^^^^
    // 2. Update pkce

    acmeConnection = await repository.GetAcmeConnectionAsync(ClientId);
    acmeConnection.UpdateAcmeCompany(AcmeCompany);
    //             ^^^^^
    acmeConnection.UpdateAcmeCredentials(OtherAcmeCredentials);
    //             ^^^^^
    await acmeConnection.SetOurCredentialsAsync(_acmeConnectionServiceMock.Object);
    //                   ^^^^^
    await repository.UpdateAcmeConnectionAsync(acmeConnection);
    //               ^^^^^
    // 3. Update company and credentials
    
    var updatedConnectionFromDb = await repository.GetAcmeConnectionAsync(ClientId);

    Assert.NotNull(updatedConnectionFromDb);
    Assert.Equal(acmeConnectionId, updatedConnectionFromDb!.Id);
    Assert.Equal(acmeConnection.Pkce, updatedConnectionFromDb.Pkce);
    Assert.Equal(acmeConnection.AcmeCompany, updatedConnectionFromDb.AcmeCompany);
    Assert.NotNull(updatedConnectionFromDb.AcmeCredentials);
    Assert.NotNull(updatedConnectionFromDb.OurCredentials);
}
```

Notice, we stopped using the `Load()` method. We rewrote the test using the methods from the `AcmeConnection` class like `UpdateAcmeCredentials`, `SetOurCredentialsAsync`, and others.

Also, we separated the test into blocks. In each block, we retrieved the `acmeConnection`, mutated it with its own methods, and called `UpdateAcmeConnectionAsync()`. Cleaner!- I'd say.

We removed the last `Load()` call. We didn't need to assert if the last retrieved object was exactly the same as the recreated version. Instead, we checked that the updated connection had the same value objects.

## Step 2. Use descriptive variables

For the next step, let's stop abusing the same `acmeConnection` variable and create more descriptive variables for every step.

```csharp
[Fact]
public async Task GetConnectionAsync_ConnectionUpdated_ReturnsUpdatedConnection()
{
    var repository = new AcmeConnectionRepository(AnySqlConnection);
    var acmeConnection = new AcmeConnection(ClientId);
    var acmeConnectionId = await repository.CreateAcmeConnectionAsync(acmeConnection);
    
    var newlyCreated = await repository.GetAcmeConnectionAsync(ClientId);
    //  ^^^^^
    newlyCreated.GeneratePkce();
    await repository.UpdateAcmeConnectionAsync(newlyCreated);

    var pkceUpdated = await repository.GetAcmeConnectionAsync(ClientId);
    //  ^^^^^
    pkceUpdated.UpdateAcmeCompany(AcmeCompany);
    pkceUpdated.UpdateAcmeCredentials(OtherAcmeCredentials);
    await pkceUpdated.SetOurCredentialsAsync(_acmeConnectionServiceMock.Object);
    await repository.UpdateAcmeConnectionAsync(pkceUpdated);
    
    var updated = await repository.GetAcmeConnectionAsync(ClientId);
    //  ^^^^^

    Assert.NotNull(updated);
    Assert.Equal(acmeConnectionId, updated!.Id);
    Assert.Equal(pkceUpdated.Pkce, updated.Pkce);
    Assert.Equal(pkceUpdated.AcmeCompany, updated.AcmeCompany);
    Assert.NotNull(updated.AcmeCredentials);
    Assert.NotNull(updated.OurCredentials);
}
```

With these variables names is easier to follow what our test does.

## An alternative solution with Factory methods

We were lucky there were a lot of methods on the `AcmeConnection` class to mutate and update it in the tests. If we didn't have those methods, we could create one "clone" method for every property we needed to mutate.

For example,

```csharp
public static class AcmeConnectionExtensions
{
    public static AcmeConnection CredentialsFrom(
        this LightspeedConnection self,
        AcmeCredentials acmeCredentials,
        OurCredentials ourCredentials)
    {
        // Copy self and change AcmeCredentials and OurCredentials
    }

    public static AcmeConnection AcmeCompanyFrom(
        this LightspeedConnection self,
        AcmeCompany acmeCompany)

    {
        // Copy self and change the AcmeCompany
    }
}
```

We can create an initial `AcmeConnection` and clone it with our helper methods to reduce all boilerplate in our original test.

Voilà! That was a long refactoring session. There are two things we can take away from this refactoring. First, we should strive for readability in our tests. We should make our test even more readable than our production code. Can anyone spot what one of our tests does in 30 seconds? That's a readable test. Second, we should always write our tests using the same code as our production code. We shouldn't write production code to only use it inside our unit tests. That `Load()` method was a backdoor to build objects when we should have used class constructors and methods to mutate its state.

To read more content about unit testing, check [how to write tests for HttpClient]({% post_url 2022-12-01-TestingHttpClient %}), [how to test an ASP.NET filter]({% post_url 2022-12-03-TestingAspNetAuthorizationFilters %}), and [how to write tests for logging messages]({% post_url 2022-12-04-TestingLoggingAndLogMessages %}). Don't miss my [Unit Testing 101 series]({% post_url 2021-08-30-UnitTesting %}) where I cover from naming conventions to best practices.

_Happy testing!_