---
layout: post
title: "How to Handle the Startup Class When Migrating ASP.NET Core Projects"
tags: asp.net
cover: Cover.png
cover-alt: "A power button" 
---

.NET 6.0 replaced the Startup class with a new hosting model and a simplified Program.cs file. 

The Startup class is still available in newer versions. If we're migrating a pre-.NET 6.0 project, the [.NET upgrade assistant tool](https://learn.microsoft.com/en-us/dotnet/core/porting/upgrade-assistant-overview) does the work while keeping the Startup class.

Here are 3 alternatives to handle with the Startup class when migrating to newer versions:

## 1. Official Docs approach

Newer versions of ASP.NET Core work perfectly fine with the old Program.cs file and Startup class, we can choose to do nothing and keep them.

Here are an old-style Program and Startup classes:

```csharp
using System;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;

namespace AnOldStyleAspNetCoreProject;

public class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    public static IHostBuilder CreateHostBuilder(string[] args) =>
         Host.CreateDefaultBuilder(args)
             .ConfigureWebHostDefaults(webBuilder =>
             {
                 webBuilder.UseStartup<Startup>();
             });
}
```

```csharp
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace AnOldStyleAspNetCoreProject;

public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllers();
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        app.UseRouting();
        app.UseAuthorization();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
        });
    }
}
```

Nothing fancy. A simple API project.

If we want to keep the Startup class, here's what [Microsoft official docs](https://learn.microsoft.com/en-us/aspnet/core/migration/50-to-60?view=aspnetcore-6.0&tabs=visual-studio#use-startup-with-the-new-minimal-hosting-model) show to make the Startup class work with the new hosting model and the simplified Program.cs:

```csharp
var builder = WebApplication.CreateBuilder(args);

// vvvvv
var startup = new Startup(builder.Configuration);
startup.ConfigureServices(builder.Services);
// ^^^^^

var app = builder.Build();

startup.Configure(app, app.Environment);
// ^^^^^

app.Run();
```

We created a new instance of Startup inside the new Program.cs file.

## 2. Hybrid approach

If we really want to ditch the Startup class, Andrew Lock recommends [a hybrid approach in his blog](https://andrewlock.net/exploring-dotnet-6-part-12-upgrading-a-dotnet-5-startup-based-app-to-dotnet-6/#option-3-local-methods-in-program-cs):

Turn the methods from the Startup class into private methods in the new Program.cs file.

```csharp
var builder = WebApplication.CreateBuilder(args);

ConfigureServices(builder.Services);
// ^^^^^

var app = builder.Build();

Configure(app, app.Environment);
// ^^^^^^

app.Run();

// This method used to be in Startup.cs
static void ConfigureServices(IServiceCollection services)
{
    services.AddControllers();
}

// This method used to be in Startup.cs too
static void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    app.UseRouting();
    app.UseAuthorization();

    app.UseEndpoints(endpoints =>
    {
        endpoints.MapControllers();
    });
}
```

## 3. Do-it-yourself approach

And if we want our Program.cs to look like the newer ones, there's no automatic tool for that (at least I couldn't find one in my Googling session). We have to copy the contents of the Startup class into the Program.cs file, by hand:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Put here what you had in ConfigureServices...
builder.Services.AddControllers();

var app = builder.Build();

// Put here what you had in Configure...
app.UseAuthorization();

// Before:
//
// app.UseRouting();
// ASP0014: Suggest using top level route registrations instead of UseEndpoints
//app.UseEndpoints(endpoints =>
//{
//    endpoints.MapControllers();
//});
//
// After:
app.MapControllers();

app.Run();
```

We cut and pasted the content of Startup inside the right sections of the new Program.cs. This time, we get some warnings about deprecated methods and their alternatives.

Voilà! If you're a lazy developer like me, do nothing or go with the approach from the official docs. Otherwise, go with any of the other two options.