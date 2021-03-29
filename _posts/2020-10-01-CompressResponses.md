---
layout: post
title: "TIL: How to add gzip compression to ASP.NET Core API responses"
tags: todayilearned asp.net
---

If you're using ASP.NET Core 2.x, you need to install the NuGet `Microsoft.AspNetCore.ResponseCompression`

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
}

public void Configure(IApplicationBuilder app, IHostingEnvironment env)
{
    app.UseResponseCompression();
}
```

_Source_: [Response compression in ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/performance/response-compression?view=aspnetcore-3.1#gzip-compression-provider)