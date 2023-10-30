---
layout: post
title: "Working with ASP.NET Core IDistributedCache Provider for NCache"
tags: tutorial asp.net showdev
cover: Cover.png
cover-alt: "Storage unit" 
---

As we learned last time, when I covered [in-memory caching with ASP.NET Core]({% post_url 2020-06-29-HowToAddACacheLayer %}), a cache is a storage layer between an application and an external resource (a database, for example) used to speed up future requests to that resource. In this post, let's use ASP.NET Core `IDistributedCache` abstractions to write a data caching layer using NCache.

## 1. What's NCache?

From [NCache official page](https://www.alachisoft.com/ncache/), _"NCache is an Open Source in-memory distributed cache for .NET, Java, and Node.js applications."_

Among other things, we can use NCache as a database cache, NHibernate 2nd-level cache, Entity Framework cache, and web cache for sessions and responses.

NCache comes in three editions: Open Source, Professional, and Enterprise. The Open Source version supports up to two nodes and its cache server is only available for .NET Framework version 4.8. For a complete list of differences, check [NCache edition comparison](https://www.alachisoft.com/ncache/edition-comparison.html).

One of the NCache key features is performance. Based on [their own benchmarks](https://www.alachisoft.com/ncache/ncache-performance-benchmarks.html), "NCache can linearly scale to achieve 2 million operations per second with a 5-server cache cluster."

## 2. How to install NCache on a Windows machine?

Let's see how to install an NCache server on a Windows machine. For this, we need a Windows installer and have a [trial license key](https://www.alachisoft.com/trial-key.html). Let's install NCache Enterprise edition, version 5.2 SP1.

After running the installer, we need to select the installation type from three options: Cache server, remote client, and Developer/QA. Let's choose Cache Server.

{% include image.html name="1-InstallationType.png" alt="NCache Installation Types" caption="Cache Server Installation Type" width="375px" %}

Then, we need to enter a license key. Let's make sure to have a license key for the same version we're installing. Otherwise, we will get an "invalid license key" error. We receive the license key in a message sent to the email address we used during registration.

{% include image.html name="2-License.png" alt="NCache License Key" caption="Enter NCache license key"  width="375px" %}

Next, we need to enter the full name, email, and organization we used to register ourselves while requesting the trial license.

{% include image.html name="3-Data.png" alt="Enter User Information" caption="Enter User Information" width="375px" %}

Then, we need to select an IP address to bind our NCache server to. Let's stick to the defaults.

{% include image.html name="4-IP.png" alt="Configure IP Binding" caption="Configure IP Binding" width="375px" %}

Next, we need to choose an account to run NCache. Let's use the Local System Account.

{% include image.html name="5-User.png" alt="Account to run NCache" caption="Account to run NCache" width="375px" %}

Once the installation finishes, our default browser will open with the Web Manager. By default, NCache has a default cache named `demoCache`.

{% include image.html name="6-Manager.png" alt="NCache Web Manager" caption="NCache Web Manager"  width="600px" %}

Next time, we can fire the Web Manager by navigating to `http://localhost:8251`.

NCache's official site recommends a minimum of two servers for redundancy purposes. But, for our sample app, let's use a single-node server for testing purposes.

So far, we have covered the installation instructions for a Windows machine. But, we can also install NCache in Linux and Docker containers. And, we can use NCache as virtual machines in Azure and AWS.

<figure>
<img src="https://images.unsplash.com/photo-1501523460185-2aa5d2a0f981?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY0ODc3ODIwOA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Storage unit" />

<figcaption>A cache is a fast storage unit. Photo by <a href="https://unsplash.com/@jezar?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Jezael Melgoza</a> on <a href="https://unsplash.com/s/photos/warehouse?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## 3. How to add and retrieve data from an NCache cache?

Now, we're ready to start using our NCache server from a .NET app. In Visual Studio, let's create a solution with a .NET 6 "MSTest Test Project" and a class file to learn the basic caching operations with NCache.

### Connecting to an NCache cache

Before connecting to our NCache server, we need to first install the client NuGet package: `Alachisoft.NCache.SDK`. Let's use the version: `5.2.1`.

To start a connection, we need the `GetCache()` method with a cache name. For our sample app, let's use the default cache: `demoCache`.

Let's start writing a test to add and retrieve movies from a cache.

```csharp
using Alachisoft.NCache.Client;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace NCacheDemo.Tests;

[TestClass]
public class NCacheTests
{
    [TestMethod]
    public void AddItem()
    {
        var cacheName = "demoCache";
        ICache cache = CacheManager.GetCache(cacheName);

        // We will fill in the details later
    }
}
```

> If you're new to unit testing, start looking at [how to write your first unit test in C# with MSTest]({% post_url 2021-03-15-UnitTesting101 %}).

Notice we didn't have to use a connection string to connect to our cache. We only used a cache name. The same one as in the Web Manager: `demoCache`.

NCache uses a `client.ncconf` file instead of connection strings. We can define this file at the application or installation level. For our tests, we're relying on the configuration file at the installation level. That's why we only needed the cache name.

### Adding items

To add a new item to the cache, we need to use the `Add()` and `AddAsync()` methods with a `key` and a `CacheItem` to cache. The key is an identifier and the item is a wrapper for the object to cache.

Every item to cache needs an expiration. The `CacheItem` has an `Expiration` property for that.

There are two basic expiration types: `Absolute` and `Sliding`.

A cached item with `Absolute` expiration expires after a given time. Let's say, a few seconds. But, an item with `Sliding` expiration gets renewed every time it's accessed. If within the sliding time, we don't retrieve the item, it expires.

Let's update our test to add a movie to our cache.

```csharp
using Alachisoft.NCache.Client;
using Alachisoft.NCache.Runtime.Caching;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Threading.Tasks;

namespace NCacheDemo.Tests;

[TestClass]
public class NCacheTests
{
    private const string CacheName = "demoCache";

    [TestMethod]
    public async Task AddItem()
    {
        var movie = new Movie(1, "Titanic");
        var cacheKey = movie.ToCacheKey();
        var cacheItem = ToCacheItem(movie);

        ICache cache = CacheManager.GetCache(CacheName);
        // Let's add Titanic to the cache...
        await cache.AddAsync(cacheKey, cacheItem);

        // We will fill in the details later
    }

    private CacheItem ToCacheItem(Movie movie)
        => new CacheItem(movie)
        {
            Expiration = new Expiration(ExpirationType.Absolute, TimeSpan.FromSeconds(1))
        };
}

[Serializable]
public record Movie(int Id, string Name)
{
    public string ToCacheKey()
        => $"{nameof(Movie)}:{Id}";
}
```

Notice, we used two helper methods: `ToCacheKey()` to create the key from every movie and `ToCacheItem()` to create a cache item from a movie.

We used [records from C# 9.0]({% post_url 2021-09-13-TopNewCSharpFeatures %}) to create our `Movie` class. Also, we needed to annotate it with the `[Serializable]` attribute.

### Retrieving items

After adding items, let's retrieve them. For this, we need the `Get<T>()` method with a key.

Let's complete our first unit test to retrieve the object we added.

```csharp
using Alachisoft.NCache.Client;
using Alachisoft.NCache.Runtime.Caching;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Threading.Tasks;

namespace NCacheDemo.Tests;

[TestClass]
public class NCacheTests
{
    private const string CacheName = "demoCache";

    [TestMethod]
    public async Task AddItem()
    {
        var movie = new Movie(1, "Titanic");
        var cacheKey = movie.ToCacheKey();
        var cacheItem = ToCacheItem(movie);

        ICache cache = CacheManager.GetCache(CacheName);
        await cache.AddAsync(cacheKey, cacheItem);

        // Let's bring Titanic back...
        var cachedMovie = cache.Get<Movie>(cacheKey);
        Assert.AreEqual(movie, cachedMovie);
    }

    private CacheItem ToCacheItem(Movie movie)
        => new CacheItem(movie)
        {
            Expiration = new Expiration(ExpirationType.Absolute, TimeSpan.FromSeconds(1))
        };
}

[Serializable]
public record Movie(int Id, string Name)
{
    public string ToCacheKey()
        => $"{nameof(Movie)}:{Id}";
}
```

### Updating items

If we try to add an item with the same key using the `Add()` or `AddAsync()` methods, they will throw an `OperationFailedException`. Try to add a unit test to prove that.

To either add a new item or update an existing one, we should use the `Insert()` or `InserAsync()` methods instead. Let's use them in another test.

```csharp
using Alachisoft.NCache.Client;
using Alachisoft.NCache.Runtime.Caching;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Threading.Tasks;

namespace NCacheDemo.Tests;

[TestClass]
public class NCacheTests
{
    // Our previous test is the same
    
    [TestMethod]
    public async Task UpdateItem()
    {
        ICache cache = CacheManager.GetCache(CacheName);

        var movie = new Movie(2, "5th Element");
        var cacheKey = movie.ToCacheKey();
        var cacheItem = ToCacheItem(movie);
        // Let's add the 5th Element here...
        await cache.AddAsync(cacheKey, cacheItem);

        var updatedMovie = new Movie(2, "Fifth Element");
        var updatedCacheItem = ToCacheItem(updatedMovie);
        // There's already a cache item with the same key...
        await cache.InsertAsync(cacheKey, updatedCacheItem);

        var cachedMovie = cache.Get<Movie>(cacheKey);
        Assert.AreEqual(updatedMovie, cachedMovie);
    }

    // Rest of the file...
}
```

Notice we used the `InsertAsync()` method to add an item with the same key. When we retrieved it, it contained the updated version of the item.

There's another basic method: `Remove()` and `RemoveAsync()`. We can guess what they do. Again, try to write a test to prove that.

## 4. How to use ASP.NET Core IDistributedCache with NCache?

Up to this point, we have NCache installed and know how to add, retrieve, update, and remove items.

Let's revisit our sample application from our post about [using a Redis-powered cache layer]({% post_url 2020-06-29-HowToAddACacheLayer %}).

Let's remember the example from that last post. We had an endpoint that uses a service to access a database, but it takes a couple of seconds to complete. Let's think of retrieving complex object graphs or doing some computations with the data before returning it.

Something like this,

```csharp
using DistributedCacheWithNCache.Responses;

namespace DistributedCacheWithNCache.Services;

public class SlowService
{
    public async Task<Something> DoSomethingSlowlyAsync(int someId)
    {
        // Beep, boop...Aligning satellites...
        await Task.Delay(3 * 1000);

        return new Something
        {
            SomeId = someId,
            Value = "Anything"
        };
    }
}
```

Notice we emulated a database call with a 3-second delay.

Also, we wrote a set of extensions methods on top of the `IDistributedCache` to add and retrieve objects from a cache.

There were the extension methods we wrote last time,

```csharp
using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;

namespace DistributedCacheWithNCache.Services;

public static class DistributedCacheExtensions
{
    public static readonly DistributedCacheEntryOptions DefaultDistributedCacheEntryOptions
        = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(60),
            SlidingExpiration = TimeSpan.FromSeconds(10),
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

Notice we used Newtonsoft.Json to serialize and deserialize objects.

### NCache and the IDistributedCache interface

Now, let's use a .NET 6.0 "ASP.NET Core Web App," those extension methods on top of `IDistributedCache`, and NCache to speed up the `SlowService`.

First, we need to install the NuGet package `NCache.Microsoft.Extensions.Caching`. This package implements the `IDistributedCache` interface using NCache, of course.

After installing that NuGet package, we need to add the cache into the ASP.NET dependencies container in the `Program.cs` file. To achieve this, we need the `AddNCacheDistributedCache()` method.

```csharp
// Program.cs
using Alachisoft.NCache.Caching.Distributed;
using DistributedCacheWithNCache;
using DistributedCacheWithNCache.Services;

var (builder, services) = WebApplication.CreateBuilder(args);

services.AddControllers();
services.AddNCacheDistributedCache((options) =>
//      ^^^^^
// We add the NCache implementation here...
{
    options.CacheName = "demoCache";
    options.EnableLogs = true;
    options.ExceptionsEnabled = true;
});
services.AddTransient<SlowService>();

var app = builder.Build();
app.MapControllers();
app.Run();
```

Notice, we continued to use the same cache name: `demoCache`. And, also we relied on a `Deconstruct` method to have the `builder` and `services` variables deconstructed. I took this idea from Khalid Abuhakmeh's [Adding Clarity To .NET Minimal Hosting APIs](https://khalidabuhakmeh.com/adding-clarity-to-dotnet-minimal-hosting).

Back in the `SlowService`, we can use the `IDistributedCache` interface injected into the constructor and the extension methods in the `DistributedCacheExtensions` class. Like this,

```csharp
using DistributedCacheWithNCache.Responses;
using Microsoft.Extensions.Caching.Distributed;

namespace DistributedCacheWithNCache.Services;

public class SlowService
{
    private readonly IDistributedCache _cache;

    public SlowService(IDistributedCache cache)
    {
        _cache = cache;
    }

    public async Task<Something> DoSomethingSlowlyAsync(int someId)
    {
        var key = $"{nameof(someId)}:{someId}";
        // Here we wrap the DoSomethingAsync method around the cache logic
        return await _cache.GetOrSetValueAsync(key, async () => await DoSomethingAsync(someId));
    }

    private static async Task<Something> DoSomethingAsync(int someId)
    {
        // Beep, boop...Aligning satellites...
        await Task.Delay(3 * 1000);

        return new Something
        {
            SomeId = someId,
            Value = "Anything"
        };
    }
}
```

Notice, we wrapped the `DoSomethingAsync()` with actual retrieving logic around the caching logic in the `GetOrSetValueAsync()`. At some point, we will have the same data in our caching and storage layers.

With the caching in place, if we hit one endpoint that uses that service, we will see faster response times after the first call delayed by 3 seconds.

{% include image.html name="8-SecondTime.png" alt="Faster response times after using NCache" caption="A few miliseconds reading it from NCache" width="900px" %}

Also, if we go back to NCache Web Manager, we should see some activity in the server.

{% include image.html name="9-Dashboard.png" alt="NCache Dashboard" caption="NCache Dashboard showing our first request" width="900px" %}

In this scenario, all the logic to add and retrieve items is abstracted behind the `IDistributedCache` interface. That's why we didn't need to directly call the `Add()` or `Get<T>()` method. Although, if we take a look at the NCache source code, we will find those methods [here](https://github.com/Alachisoft/NCache/blob/b8bb6f06372c1f79397e95b3ca8612cff24eb911/SessionState/ASP.NET%20Core/NCacheSessionServices/NCacheDistributedCache/NCacheDistributedCache.cs#L132) and [here](https://github.com/Alachisoft/NCache/blob/b8bb6f06372c1f79397e95b3ca8612cff24eb911/SessionState/ASP.NET%20Core/NCacheSessionServices/NCacheDistributedCache/NCacheDistributedCache.cs#L111).

Voilà! That's NCache and how to use it with the `IDistributedCache` interface. With NCache, we have a distributed cache server with few configurations and a dashboard out-of-the-box. Also, we can add all the caching logic into [decorators]({% post_url 2021-02-10-DecoratorPattern %}) and have our services as clean as possible.

To follow along with the code we wrote in this post, check my [Ncache Demo](https://github.com/canro91/NCacheDemo) repository over on GitHub.

[![canro91/NCacheDemo - GitHub](https://gh-card.dev/repos/canro91/NCacheDemo.svg)](https://github.com/canro91/NCacheDemo)

To read more content, check my [Unit Testing 101]({% post_url 2021-08-30-UnitTesting %}) series to learn from how to write your first unit tests to mocks. Also, check [how to implement full-text searching with Lucene and NCache]({% post_url 2022-08-08-FullTextSearchWithNCache %})

_I wrote this post in collaboration with [Alachisoft](https://www.alachisoft.com/), NCache creators._

_Happy coding!_