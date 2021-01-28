---
layout: post
title: How to add an in-memory and a Redis-powered cache layer with ASP.NET Core 3
tags: tutorial asp.net csharp
---

Imagine you have a service `SettingsService` that makes a REST request with a `HttpClient`. This service calls a microservice for the configurations of a property. But, it takes a couple of seconds to respond and it is accessed frequently. It would be a great to have this value stored somewhere else for faster respond times. Let's see how to add a caching layer to the `SettingsService` using ASP.NET Core!

**A cache is an storage layer used to speed up future requests.** Reading from cache is faster than computing data or retrieving it from an external source every time it is requested. ASP.NET Core has built-in abstractions to implement a caching layer using memory and Redis. You can use the Decorator pattern to separate the caching layer from your business logic.
 
## In-Memory approach

Let's start with an ASP.NET Core 3.1 API project with a controller that uses your `SettingsService` class. First, install the `Microsoft.Extensions.Caching.Memory` NuGet package. Then, register the in-memory cache in the `ConfigureServices` method of the `Startup` class. You need to use the `AddMemoryCache` method.

```csharp
// Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    services.AddMemoryCache(options =>
    {
        options.SizeLimit = 1024;
    });
    
    // ...
}
```

Since memory isn't infinite, you want to limit the number of items stored in the cache. Make use of `SizeLimit`. It is the maximum number of "slots" or "places" the cache can hold. Also, you need to tell how many "places" a cache entry takes when stored. _More on that later!_

### Decorator pattern

Next, let's use the [decorator pattern](https://refactoring.guru/design-patterns/decorator) to add caching to the existing `SettingsService` without modifying it. To do that, create a new `CachedSettingsService`. It should inherit from the same interface as `SettingsService`. _That's the trick!_

Also, you need a constructor receiving `IMemoryCache` and `ISettingsService`. This last parameter will hold a reference to the existing `SettingService`. Then, in the `GetSettingsAsync` method, you will call the existing service if the value isn't cached.

```csharp
public class CachedSettingsService : ISettingsService
{
    private readonly IMemoryCache _cache;
    private readonly ISettingsService _settingsService;

    public CachedSettingsService(IMemoryCache cache, ISettingsService settingsService)
    {
        _cache = cache;
        _settingsService = settingsService;
    }

    public async Task<Settings> GetSettingsAsync(int propertyId)
    {
        var key = $"{nameof(propertyId)}:{propertyId}";
        return await _cache.GetOrSetValueAsync(key, async () => await _settingsService.GetSettingsAsync(propertyId));
    }
}
```

### Size, Limits and Expiration Time

Now, let's create the `GetOrSetValueAsync` extension method. It will check first if a key is in the cache. Otherwise, it will use a factory method to compute the value and store it on the cache. This method receives a custom `MemoryCacheEntryOptions` to overwrite the default values.

Make sure to use expiration times when storing items. You can choose between sliding and absolute expiration times:

* `SlidingExpiration` will reset the expiration time every time an entry is used before it expires
* `AbsoluteExpirationRelativeToNow` will expire the entry after the given time, no matter how many times it's been used
* If you use both, the entry will expire when the first of the two times expire

<figure>
<img src="https://images.unsplash.com/photo-1591976711776-4a91184e0bf7?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop" alt="A child playing colorful videogames" />

<figcaption>If parents used SlidingExpiration, kids would never stop watching TV or using smartphones! <span>Photo by <a href="https://unsplash.com/@sigmund?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Sigmund</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

Don't forget to include a size for each cache entry, if you use `SizeLimit` when registering the in-memory cache into the dependency container. This `Size` tells how many "places" from `SizeLimit` an entry takes. When this limit is reached, the cache won't store any more entries until some of them expire. For more details, see [Use SetSize, Size, and SizeLimit to limit cache size](https://docs.microsoft.com/en-us/aspnet/core/performance/caching/memory?view=aspnetcore-3.1#use-setsize-size-and-sizelimit-to-limit-cache-size).

```csharp
public static class MemoryCacheExtensions
{
    // Make sure to adjust these values to suit your own defaults...
    public static readonly MemoryCacheEntryOptions DefaultMemoryCacheEntryOptions
        = new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(60),
            SlidingExpiration = TimeSpan.FromSeconds(10),
            Size = 1
        };

    public static async Task<TObject> GetOrSetValueAsync<TObject>(this IMemoryCache cache, string key, Func<Task<TObject>> factory, MemoryCacheEntryOptions options = null)
        where TObject : class
    {
        if (cache.TryGetValue(key, out object value))
        {
            return value as TObject;
        }

        result = await factory();

        options ??= DefaultMemoryCacheEntryOptions;
        cache.Set(key, value, options);

        return result;
    }
}
```

### Registration

To start using the new `CachedSettingsService`, you need to register it into the dependency container. _Back to the `Startup` class!_ Register the existing `SettingsService` and the new decorated service. You can use [Scrutor](https://github.com/khellang/Scrutor) to [register your decorators](https://andrewlock.net/adding-decorated-classes-to-the-asp.net-core-di-container-using-scrutor/).

```csharp
// Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    services.AddTransient<SettingsService>();
    services.AddTransient<ISettingsService>(provider =>
    {
        var cache = provider.GetRequiredService<IMemoryCache>();
        var settingsService = provider.GetRequiredService<SettingsService>();
        return new CachedSettingsService(cache, settingsService);
    });

    // The same as before...
    services.AddMemoryCache(options =>
    {
        options.SizeLimit = 1024
    });
    
    // ...
}
```

Be aware of removing cached entries if you need to update or delete entities in you own code. You don't want to use an old value or, even worse, a deleted value read from your cache. In this case, you would need to use the `Remove` method.

> _There are only two hard things in Computer Science: cache invalidation and naming things._
>
> -- Phil Karlton
>
> From [TwoHardThings](https://www.martinfowler.com/bliki/TwoHardThings.html)

### Unit Tests

Let's see how you can create a test for this decorator. You will need to create a fake for the decorated service. Then, assert it's called only once after two consecutive calls to the cached method. Let's use [Moq]({% post_url 2020-08-11-HowToCreateFakesWithMoq %}) to create fakes.

```csharp
[TestClass]
public class CachedPropertyServiceTests
{
    [TestMethod]
    public async Task GetSettingsAsync_ByDefault_UsesCachedValues()
    {
        var memoryCache = new MemoryCache(Options.Create(new MemoryCacheOptions()));
        var fakeSettingsService = new Mock<ISettingsService>();
        fakeSettingsService.Setup(t => t.GetSettingsAsync(It.IsAny<int>()))
                           .ReturnsAsync(new Settings());
        var service = new CachedSettingsService(memoryCache, fakeSettingsService.Object);

        var propertyId = 1;
        var settings = await service.GetSettingsAsync(propertyId);

        fakeSettingsService.Verify(t => t.GetSettingsAsync(propertyId), Times.Once);

        settings = await service.GetSettingsAsync(propertyId);
        decoratedService.Verify(t => t.GetSettingsAsync(propertyId), Times.Once);
    }
}
```

## Distributed approach

_Now, let's move to the distribute cache_. A distributed cache layer lives in a separate server. You aren't limited to the memory of the server running your API site.

A distributed cache make sense when you want to share your cache server among multiple applications. Or, when your site is running behind a load-balancer along many instances of the same server. For more advantages of distributed cache, see [Distributed caching in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/performance/caching/distributed?view=aspnetcore-3.1)

There is an implementation of the distributed cache using Redis for ASP.NET Core. [Redis](https://redis.io/) is _"an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker"_.
	
Using a distributed cache is similar to the in-memory approach. This time you need to install `Microsoft.Extensions.Caching.StackExchangeRedis` NuGet package and use the `AddStackExchangeRedisCache` method in your `ConfigureServices` method. Also, you need a Redis connection string and an optional `InstanceName`. The `InstaceName` groups entries with a prefix. It's helpful when using a single Redis server with different sites.

> Notice, there are two similar NuGet packages to use Redis with ASP.NET Core: [Microsoft.Extensions.Caching.Redis and Microsoft.Extensions.Caching.StackExchangeRedis](https://stackoverflow.com/questions/59847571/differences-between-microsoft-extensions-cashing-redis-and-microsoft-extensions). They use different versions of the [StackExchange.Redis](https://github.com/StackExchange/StackExchange.Redis) client.

```csharp
// Startup.cs
public void ConfigureServices(IServiceCollection services)
{
    services.AddTransient<SettingsService>();
    services.AddTransient<ISettingsService>(provider =>
    {
        var cache = provider.GetRequiredService<IDistributedCache>();
        var settingsService = provider.GetRequiredService<SettingsService>();
        return new CachedSettingsService(cache, settingsService);
    });

    services.AddStackExchangeRedisCache(options =>
    {
        var redisConnectionString = Configuration.GetConnectionString("Redis");
        options.Configuration = redisConnectionString;

        var assemblyName = Assembly.GetExecutingAssembly().GetName();
        options.InstanceName = assemblyName.Name;
    });   
}
```

### Redecorate

Make sure to change the cache interface from `IMemoryCache` to `IDistributedCache`. Go to your `CachedSettingsService` class and the `ConfigureService` method.

```csharp
public class CachedSettingsService : ISettingsService
{
    private readonly IDistributedCache _cache;
    private readonly ISettingsService _settingsService;

    public CachedSettingsService(IDistributedCache cache, ISettingsService settingsService)
    {
        _cache = cache;
        _settingsService = settingsService;
    }

    public async Task<Settings> GetSettingsAsync(int propertyId)
    {
        var key = $"{nameof(propertyId)}:{propertyId}";
        return await _cache.GetOrSetValueAsync(key, async () => await _settingsService.GetSettingsAsync(propertyId));
    }
}
```

Now, let's create a new `GetOrSetValueAsync` extension method to use the distributed cache. This time, you need to use asynchronous methods to retrieve and store items. These methods are `GetStringAsync` and `SetStringAsync`. Also, you need a serializer to cache objects. We are using [Newtonsoft.Json](https://github.com/JamesNK/Newtonsoft.Json).

Notice, this time you don't need sizes for cache entries.

```csharp
public static class DistributedCacheExtensions
{
    public static readonly DistributedCacheEntryOptions DefaultDistributedCacheEntryOptions
        = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(60),
            SlidingExpiration = TimeSpan.FromSeconds(10),
        };

    public static async Task<TObject> GetOrSetValueAsync<TObject>(this IDistributedCache cache, string key, Func<Task<TObject>> factory, DistributedCacheEntryOptions options = null)
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

    private static async Task<TObject> GetValueAsync<TObject>(this IDistributedCache cache, string key)
        where TObject : class
    {
        var data = await cache.GetStringAsync(key);
        if (data == null)
        {
            return default;
        }

        return JsonConvert.DeserializeObject<TObject>(data);
    }

    private static async Task SetValueAsync<TObject>(this IDistributedCache cache, string key, TObject value, DistributedCacheEntryOptions options = null)
        where TObject : class
    {
        var data = JsonConvert.SerializeObject(value);

        await cache.SetStringAsync(key, data, options ?? DefaultDistributedCacheEntryOptions, token);
    }
}
```

### Unit Tests

For unit testing, you can use `MemoryDistributedCache`, an in-memory implementation of `IDistributedCache`. So you don't need to roll a Redis server to test your code. From the previous unit test, you need to replace the `IMemoryCache` dependency with `var memoryCache = new MemoryDistributedCache(Options.Create(new MemoryDistributedCacheOptions()));`.

```csharp
[TestClass]
public class CachedPropertyServiceTests
{
    [TestMethod]
    public async Task GetSettingsAsync_ByDefault_UsesCachedValues()
    {
        // This time, CachedSettingsService uses an in-memory implementation of IDistributedCache
        var memoryCache = new MemoryDistributedCache(Options.Create(new MemoryDistributedCacheOptions()));
        var fakeSettingsService = new Mock<ISettingsService>();
        fakeSettingsService.Setup(t => t.GetSettingsAsync(It.IsAny<int>()))
                           .ReturnsAsync(new Settings());
        var service = new CachedSettingsService(memoryCache, fakeSettingsService.Object);

        var propertyId = 1;
        var settings = await service.GetSettingsAsync(propertyId);

        fakeSettingsService.Verify(t => t.GetSettingsAsync(propertyId), Times.Once);

        settings = await service.GetSettingsAsync(propertyId);
        decoratedService.Verify(t => t.GetSettingsAsync(propertyId), Times.Once);
    }
}
```

## Conclusion

Voilà! Now you know how to cache the results of a slow service using an in-memory and a distributed approach implementing the Decorator pattern on your ASP.NET Core API sites. Additionally, you can turn on or off the cache layer using a toggle in your `appsettings` file to either create a decorated o a plain service. If you need to cache outside of an ASP.NET Core site, you can use libraries like [CacheManager](https://github.com/MichaCo/CacheManager), [Foundatio](https://github.com/FoundatioFx/Foundatio#caching) and [Cashew](https://github.com/joakimskoog/Cashew).

To learn more about configuration in ASP.NET Core, read my post on [how to read configuration values in ASP.NET Core](https://canro91.github.io/2020/08/21/HowToConfigureValues/). Also, check my post on [how to write good unit test]({% post_url 2020-11-02-UnitTestingTips %}).

_Happy caching time!_
