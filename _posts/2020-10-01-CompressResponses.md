---
layout: post
title: "TIL: How to add gzip compression to ASP.NET Core API responses"
tags: todayilearned asp.net
---

Today, I got the report that one API endpoint took minutes to respond. When I checked it, it returned hundreds of huge complex configuration objects. Imagine an object to customize booking pages in a reservation system. From branding colors to copy text to hotel configurations. This is how to add gzip compression to ASP.NET Core API responses.

**To compress ASP.NET Core API responses, install the NuGet package "Microsoft.AspNetCore.ResponseCompression" and add UseResponseCompression() in the Configure() method of the Startup class.**

```csharp
public void Configure(IApplicationBuilder app, IHostingEnvironment env)
{
    app.UseResponseCompression();
    
    // Rest of method...
}
```

Then, configure the compression level with the `GzipCompressionProviderOptions` inside the `ConfigureServices()` method. And register the `GzipCompressionProvider` in the options of the `AddResponseCompression()` method.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.Configure<GzipCompressionProviderOptions>(options => 
    {
        options.Level = CompressionLevel.Fastest;
    });
    services.AddResponseCompression(options =>
    {
        options.Providers.Add<GzipCompressionProvider>();
    });
    
    // Rest of method...
}
```

The lowest hanging fruit to speed up this endpoint was to create a separate view model holding the few properties the consuming side needed. And a simple extension method `MapToMyNewViewModel()` did the trick.

Voilà! That's how to add gzip compression to ASP.NET Core responses. That's what I learned today.

_Source_: [Response compression in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/performance/response-compression?view=aspnetcore-3.1#gzip-compression-provider)