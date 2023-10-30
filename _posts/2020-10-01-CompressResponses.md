---
layout: post
title: "TIL: How to add gzip compression to ASP.NET Core API responses"
tags: todayilearned asp.net
---

Today, I got the report that one API endpoint took minutes to respond. It turned out that it returned hundreds of large complex objects. Those objects contained branding colors, copy text, and hotel configurations in a reservation system. This is how to add response compression in ASP.NET Core 6.0.

**To compress responses with ASP.NET Core, register the default compression providers into the dependencies container with the UseResponseCompression() method.**

Something like this,

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();
builder.Services.AddResponseCompression();
//               ^^^^^

var app = builder.Build();
app.UseResponseCompression();
//  ^^^^^
app.MapControllers();
app.Run();
```

If we don't specify any compression provider, ASP.NET Core uses a default one.

If we want gzip compression, then let's register the `GzipCompressionProvider` inside `AddResponseCompression()` and set its compression level by configuring the `GzipCompressionProviderOptions`,

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

builder.Services.AddResponseCompression(options =>
{
    options.Providers.Add<GzipCompressionProvider>();
    //                ^^^^^
});

builder.services.Configure<GzipCompressionProviderOptions>(options => 
{
    options.Level = CompressionLevel.Fastest;
    //      ^^^^^
});

var app = builder.Build();
app.UseResponseCompression();
// ^^^^^
app.MapControllers();
app.Run();
```

For my slow endpoint, the easiest solution to speed it up was mapping my huge complex object to a new view model that only contained the properties the client side needed. I rolled a simple extension method `MapToMyNewSimplifiedViewModel()` for that.

Voilà! That's how to add gzip compression to responses with ASP.NET Core 6.0. That's what I learned today.

_**UPDATE (Oct 2023)**: In previous versions of ASP.NET Core, we needed the `Microsoft.AspNetCore.ResponseCompression` NuGet package. It's deprecated. ASP.NET Core has response compression built in now. We don't need NuGet packages for this._

For more ASP.NET Core content, check [how to read configuration values]({% post_url 2020-08-21-HowToConfigureValues %}), [how to create a caching layer]({% post_url 2020-06-29-HowToAddACacheLayer %}), and [how to use background services with Hangfire]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}).

_Source_: [Response compression in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/performance/response-compression?view=aspnetcore-6.0#gzip-compression-provider)