---
layout: post
title: "How to add an in-memory and a Redis-powered cache layer with ASP.NET Core"
tags: tutorial asp.net csharp
cover: Cover.png
cover-alt: Caching with ASP.NET Core
---

Let's say we have a `SlowService` that calls a microservice and we need to speed it up. Let's see how to add a caching layer to a service using ASP.NET Core 6.0.

**A cache is a storage layer used to speed up future requests. Reading from a cache is faster than computing data or retrieving it from an external source on every request. ASP.NET Core has built-in abstractions for a caching layer using memory and Redis.**
 
## 1. In-Memory cache

Let's start with an ASP.NET Core 6.0 API project with a controller that uses our `SlowService` class. 

First, let's install the `Microsoft.Extensions.Caching.Memory` NuGet package. Then, let's register the in-memory cache using the `AddMemoryCache()` method.

In our `Program.cs` file, let's do this,

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

builder.Services.AddTransient<ISlowService, SlowService>();

builder.Services.AddMemoryCache(options =>
//               ^^^^^
{
    options.SizeLimit = 1_024;
    //      ^^^^^
});

var app = builder.Build();
app.MapControllers();
app.Run();
```

Since memory isn't infinite, we need to limit the number of items stored in the cache. Let's use `SizeLimit`. It sets the number of "slots" or "places" the cache can hold. Also, we need to tell how many "places" a cache entry takes when stored. More on that later!

### Decorate a service to add caching

Next, let's use the [decorator pattern]({% post_url 2021-02-10-DecoratorPattern %}) to add caching to the existing `SlowService` without modifying it.

To do that, let's create a new `CachedSlowService`. It should inherit from the same interface as `SlowService`. That's the trick!

The `CachedSlowService` needs a constructor receiving `IMemoryCache` and `ISlowService`. This last parameter will hold a reference to the existing `SlowService`.

Then, inside the decorator, we will call the existing service if we don't have a cached value.

```csharp
public class CachedSlowService : ISlowService
{
    private readonly IMemoryCache _cache;
    private readonly ISlowService _slowService;

    public CachedSlowService(IMemoryCache cache, ISlowService SlowService)
    //     ^^^^^
    {
        _cache = cache;
        _slowService = slowService;
    }

    public async Task<Something> DoSomethingSlowlyAsync(int someId)
    {
        var key = $"{nameof(someId)}:{someId}";
        return await _cache.GetOrSetValueAsync(
        //                  ^^^^^
            key,
            () => _slowService.DoSomethingSlowlyAsync(someId));
    }
}
```

### Set Size, Limits, and Expiration Time

**Let's always use expiration times when caching items**.

Let's choose between sliding and absolute expiration times:

* `SlidingExpiration` resets the expiration time every time an entry is used before it expires.
* `AbsoluteExpirationRelativeToNow` expires an entry after a fixed time, no matter how many times it's been used.
* If we use both, the entry expires when the first of the two times expire

<figure>
<img src="https://images.unsplash.com/photo-1591976711776-4a91184e0bf7?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop" alt="A child playing colorful videogames" />

<figcaption>If parents used SlidingExpiration, kids would never stop watching Netflix or using smartphones! <span>Photo by <a href="https://unsplash.com/@sigmund?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Sigmund</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

**Let's always add a size to each cache entry.** This `Size` tells how many "places" from `SizeLimit` an entry takes. 

When the `SizeLimit` value is reached, the cache won't store new entries until some expire.

Now that we know about expiring entries, let's create the `GetOrSetValueAsync()` extension method. It checks first if a key is in the cache. Otherwise, it uses a factory method to compute and store a value into the cache. This method receives a custom `MemoryCacheEntryOptions` to overwrite the default values.

```csharp
public static class MemoryCacheExtensions
{
    // Make sure to adjust these values to suit your own defaults...
    public static readonly MemoryCacheEntryOptions DefaultMemoryCacheEntryOptions
        = new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(60),
            // ^^^^^
            SlidingExpiration = TimeSpan.FromSeconds(10),
            // ^^^^^
            Size = 1
            // ^^^^^
        };

    public static async Task<TObject> GetOrSetValueAsync<TObject>(
        this IMemoryCache cache,
        string key,
        Func<Task<TObject>> factory,
        MemoryCacheEntryOptions options = null)
            where TObject : class
    {
        if (cache.TryGetValue(key, out object value))
        {
            return value as TObject;
        }

        var result = await factory();

        options ??= DefaultMemoryCacheEntryOptions;
        cache.Set(key, result, options);

        return result;
    }
}
```

### Register a decorated service

To start using the new `CachedSlowService`, let's register it into the dependency container.

Let's register the existing `SlowService` and the new decorated service,

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

// Before:
//builder.Services.AddTransient<ISlowService, SlowService>();

// After:
builder.Services.AddTransient<SlowService>();
//               ^^^^^
builder.Services.AddTransient<ISlowService>(provider =>
//               ^^^^^
{
    var cache = provider.GetRequiredService<IMemoryCache>();
    var slowService = provider.GetRequiredService<SlowService>();
    return new CachedSlowService(cache, SlowService);
    //         ^^^^^
});

builder.Services.AddMemoryCache(options =>
{
    options.SizeLimit = 1_024;
});

var app = builder.Build();
app.MapControllers();
app.Run();
```

As an alternative, we can use [Scrutor](https://github.com/khellang/Scrutor), an "assembly scanning and decoration" library, to register our decorators.

Let's use the `Remove()` method to delete cached entries if needed. We don't want to use outdated or deleted values read from our cache by mistake.

> _There are only two hard things in Computer Science: cache invalidation and naming things._
>
> -- Phil Karlton
>
> From [TwoHardThings](https://www.martinfowler.com/bliki/TwoHardThings.html)

### Unit Test a decorated service

Let's see how to test our decorator.

We need a fake for our decorator and assert it's called only once after two consecutive calls. Let's use [Moq to create fakes]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}).

```csharp
[TestClass]
public class CachedSlowServiceTests
{
    [TestMethod]
    public async Task DoSomethingSlowlyAsync_ByDefault_UsesCachedValues()
    {
        var cacheOptions = Options.Create(new MemoryCacheOptions());
        var memoryCache = new MemoryCache(cacheOptions);
        //                ^^^^^
        var fakeSlowService = new Mock<ISlowService>();
        fakeSlowService
            .Setup(t => t.DoSomethingSlowlyAsync(It.IsAny<int>()))
            .ReturnsAsync(new Something());
        var service = new CachedSlowService(memoryCache, fakeSlowService.Object);
        //            ^^^^^

        var someId = 1;
        await service.DoSomethingSlowlyAsync(someId);
        await service.DoSomethingSlowlyAsync(someId);
        //            ^^^^^
        // Yeap! Twice!
        
        fakeSlowService.Verify(t => t.DoSomethingSlowlyAsync(someId), Times.Once);
        // Yeap! Times.Once!
    }
}
```

Now, let's move to the distribute cache.

## 2. Distributed cache with Redis

A distributed cache layer lives in a separate server. We aren't limited to the memory of our application server.

A distributed cache is helpful when we share our cache server among many applications or our application runs behind a load balancer.

### Redis and ASP.NET Core

[Redis](https://redis.io/) is "an open source (BSD licensed), in-memory data structure store, used as a database, cache, and message broker." ASP.NET Core supports distributed caching with Redis. 
	
Using a distributed cache with Redis is like using the in-memory implementation. We need the `Microsoft.Extensions.Caching.StackExchangeRedis` NuGet package and the `AddStackExchangeRedisCache()` method.

Now our `CachedSlowService` should depend on `IDistributedCache` instead of `IMemoryCache`.

Also we need a Redis connection string and an optional `InstanceName`. With an `InstanceName`, we group cache entries with a prefix.

Let's register a distributed cache with Redis like this,

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

builder.Services.AddTransient<SlowService>();
builder.Services.AddTransient<ISlowService>(provider =>
{
    var cache = provider.GetRequiredService<IDistributedCache>();
    //                                      ^^^^^
    var slowService = provider.GetRequiredService<SlowService>();
    return new CachedSlowService(cache, SlowService);
    //         ^^^^^
});

builder.Services.AddStackExchangeRedisCache(options =>
//               ^^^^^
{ 
    options.Configuration = "localhost";
    //      ^^^^^
    // I know, I know! We should put it in an appsettings.json
    // file instead.
    
    var assemblyName = Assembly.GetExecutingAssembly().GetName();
    options.InstanceName = assemblyName.Name;
    //      ^^^^^
});

var app = builder.Build();
app.MapControllers();
app.Run();
```

It's a good idea to read our Redis connection string from a [configuration file]({% post_url 2020-08-21-HowToConfigureValues %}) instead of hardcoding one.

In previous versions of ASP.NET Core, we also had the `Microsoft.Extensions.Caching.Redis` NuGet package. It's deprecated. It uses an older version of the [StackExchange.Redis](https://github.com/StackExchange/StackExchange.Redis) client.

### Redecorate a service

Let's change our `CachedSlowService` to use `IDistributedCache` instead of `IMemoryCache`,

```csharp
public class CachedSlowService : ISlowService
{
    private readonly IDistributedCache _cache;
    private readonly ISlowService _slowService;

    public CachedSlowService(IDistributedCache cache, ISlowService slowService)
    //                       ^^^^^
    {
        _cache = cache;
        _slowService = slowService;
    }

    public async Task<Something> DoSomethingSlowlyAsync(int someId)
    {
        var key = $"{nameof(someId)}:{someId}";
        return await _cache.GetOrSetValueAsync(
            key,
            () => _slowService.DoSomethingSlowlyAsync(someId));
    }
}
```

Now let's create a new `GetOrSetValueAsync()` extension method to use `IDistributedCache ` instead.

This time, we need the `GetStringAsync()` and `SetStringAsync()` methods. Also, we need a serializer to cache objects. Let's use [Newtonsoft.Json](https://github.com/JamesNK/Newtonsoft.Json).

```csharp
public static class DistributedCacheExtensions
{
    public static readonly DistributedCacheEntryOptions DefaultDistributedCacheEntryOptions
        = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(60),
            // ^^^^^
            SlidingExpiration = TimeSpan.FromSeconds(10),
            // ^^^^^
            
            // We don't need Size here anymore...
        };

    public static async Task<TObject> GetOrSetValueAsync<TObject>(
        this IDistributedCache cache,
        string key,
        Func<Task<TObject>> factory,
        DistributedCacheEntryOptions options = null)
            where TObject : class
    {
        var result = await cache.GetValueAsync<TObject>(key);
        if (result != null)
        {
            return result;
        }

        result = await factory();
        await cache.SetValueAsync(key, result, options);

        return result;
    }

    private static async Task<TObject> GetValueAsync<TObject>(
        this IDistributedCache cache,
        string key)
            where TObject : class
    {
        var data = await cache.GetStringAsync(key);
        if (data == null)
        {
            return default;
        }

        return JsonConvert.DeserializeObject<TObject>(data);
    }

    private static async Task SetValueAsync<TObject>(
        this IDistributedCache cache,
        string key,
        TObject value,
        DistributedCacheEntryOptions options = null)
            where TObject : class
    {
        var data = JsonConvert.SerializeObject(value);

        await cache.SetStringAsync(key, data, options ?? DefaultDistributedCacheEntryOptions);
    }
}
```

With `IDistributedCache`, we don't need sizes in the `DistributedCacheEntryOptions` when caching entries.

### Unit Test a decorated service

For unit testing, let's use `MemoryDistributedCache`, an in-memory implementation of `IDistributedCache`. This way, we don't need a Redis server in our unit tests.

Let's replace the `MemoryCache` dependency with the `MemoryDistributedCache` like this,

```csharp
var cacheOptions = Options.Create(new MemoryDistributedCacheOptions());
var memoryCache = new MemoryDistributedCache(cacheOptions);         
```

With this change, our unit test now looks like this,

```csharp
[TestClass]
public class CachedSlowServiceTests
{
    [TestMethod]
    public async Task DoSomethingSlowlyAsync_ByDefault_UsesCachedValues()
    {
        var cacheOptions = Options.Create(new MemoryDistributedCacheOptions());
        var memoryCache = new MemoryDistributedCache(cacheOptions);
        //                ^^^^^
        // This time, we're using an in-memory implementation
        // of IDistributedCache
        var fakeSlowService = new Mock<ISlowService>();
        fakeSlowService
            .Setup(t => t.DoSomethingSlowlyAsync(It.IsAny<int>()))
            .ReturnsAsync(new Something());
        var service = new CachedSlowService(memoryCache, fakeSlowService.Object);
        //            ^^^^^

        var someId = 1;
        await service.DoSomethingSlowlyAsync(someId);
        await service.DoSomethingSlowlyAsync(someId);
        // Yeap! Twice again!

        fakeSlowService.Verify(t => t.DoSomethingSlowlyAsync(someId), Times.Once);
    }
}
```

We don't need that many changes to migrate from the in-memory to the Redis implementation.

## Conclusion

Voilà! That's how we cache the results of a slow service using an in-memory and a distributed cache with ASP.NET Core 6.0. Additionally, we can turn on or off the caching layer with a toggle in our `appsettings.json` file to create a decorated or raw service.

For more ASP.NET Core content, read [how to compress responses]({% post_url 2020-10-01-CompressResponses %}) and [how to serialize dictionary keys]({% post_url 2021-10-25-LowerCaseDictionaryKeysOnSerialization %}). To read more about unit testing, check my [Unit Testing 101 guide]({% post_url 2021-08-30-UnitTesting %}) where I share what I've learned about unit testing all these years.

_Happy caching time!_
