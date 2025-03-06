---
layout: post
title: "How to Better Organize Your Program.cs File in ASP.NET Core Apps"
tags: csharp asp.net
---

If you're not careful, your Program.cs file can become a mess.

It can turn into a long class full of methods and conditionals for every dependency to configure. We focus on the rest of our code, but often forget about the Program.cs file.

We could try extension methods to keep our configurations clean and organized.

But, these days, while working with a client, I learned an alternative to extension methods for keeping our Program.cs file tidy. A coworker showed me this approach. He learned it from a past job.

Here's how to do it:

## 1. Let's create an ASP.NET Core project adding Hangfire

Let's create a dummy ASP.NET Core app. And to make it a bit more "complicated," let's add [a lite Hangfire]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}) with one recurring job.

Here's our unorganized Program.cs file,

```csharp
using Hangfire;
using Hangfire.Console;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

builder.Services.AddHangfire(configuration =>
{
    configuration.UseInMemoryStorage();
    configuration.UseConsole();
});
builder.Services.AddHangfireServer(options =>
{
    options.SchedulePollingInterval = TimeSpan.FromSeconds(5);
    options.WorkerCount = 1;
});
GlobalJobFilters.Filters.Add(new AutomaticRetryAttribute
{
    Attempts = 1
});

var app = builder.Build();
app.MapControllers();

app.UseHangfireDashboard();
app.MapHangfireDashboard();

RecurringJob.AddOrUpdate<ProducerRecurringJob>(
    ProducerRecurringJob.JobId,
    x => x.DoSomethingAsync(),
    "0/1 * * * *");

RecurringJob.TriggerJob(ProducerRecurringJob.JobId);

app.Run();
```

Nothing fancy. A bunch of `AddSomething()` and `UseSomething()` methods.

It's already kind of a mess, right? Looks familiar?

## 2. Let's register each dependency using a separate class

To make our app work, we must register controllers and Hangfire. Let's do it in a new class called `MyCoolAppUsingHangfire`,

```csharp
using Hangfire;
using Hangfire.Console;

namespace OrganizingProgramDotCs;

public class MyCoolAppUsingHangfire : BaseWebApp
//                                    ^^^^^
{
    protected override void RegisterConfiguration(IWebHostEnvironment env, IConfiguration configuration)
    //                      ^^^^^^
    {
        Register(new ControllersConfig()); // <--
        Register(new HangfireConfig()); // <--
    }
}

// One class to register controllers
class ControllersConfig : IConfigureServices, IConfigureApp
{
    public void ConfigureApp(WebApplication app)
    {
        app.MapControllers();
    }

    public void ConfigureServices(IConfiguration configuration, IServiceCollection services)
    {
        services.AddControllers();
    }
}

// Another class to register Hangfire
class HangfireConfig : IConfigureServices, IConfigureApp
{
    public void ConfigureApp(WebApplication app)
    {
        app.UseHangfireDashboard();
        app.MapHangfireDashboard();

        RecurringJob.AddOrUpdate<ProducerRecurringJob>(
            ProducerRecurringJob.JobId,
            x => x.DoSomethingAsync(),
            "0/1 * * * *");

        RecurringJob.TriggerJob(ProducerRecurringJob.JobId);
    }

    public void ConfigureServices(IConfiguration configuration, IServiceCollection services)
    {
        services.AddHangfire(configuration =>
        {
            configuration.UseInMemoryStorage();
            configuration.UseConsole();
        });
        services.AddHangfireServer(options =>
        {
            options.SchedulePollingInterval = TimeSpan.FromSeconds(5);
            options.WorkerCount = 1;
        });
        GlobalJobFilters.Filters.Add(new AutomaticRetryAttribute
        {
            Attempts = 1
        });
    }
}
```

`MyCoolAppUsingHangfire` has only one method: `RegisterConfiguration()`.

Inside it, we register two classes: `ControllersConfig` and `HangfireConfig`. One "config" class per "artifact" to register.

Each config class implements `IConfigureServices` and `IConfigureApp`.

Inside each config class, we put what was scattered all over the Program.cs file.

## 3. Let's look at BaseWebApp

Inside `BaseWebApp`, the real magic happens,

```csharp
namespace OrganizingProgramDotCs;

public abstract class BaseWebApp
{
    private readonly List<IConfigure> _configurations = [];

    protected abstract void RegisterConfiguration(IWebHostEnvironment env, IConfiguration configuration);
    //                      ^^^^^

    protected void Register(IConfigure configure)
    {
        _configurations.Add(configure);
    }

    public async Task RunAppAsync(params string[] args)
    //                ^^^^^
    {
        var builder = WebApplication.CreateBuilder(args);
        RegisterConfiguration(builder.Environment, builder.Configuration);

        foreach (var configuration in _configurations.OfType<IConfigureServices>())
        {
            configuration.ConfigureServices(builder.Configuration, builder.Services);
        }

        var app = builder.Build();

        foreach (var configuration in _configurations.OfType<IConfigureApp>())
        {
            configuration.ConfigureApp(app);
        }

        await app.RunAsync();
    }
}

public interface IConfigure;
public interface IConfigureApp : IConfigure
{
    void ConfigureApp(WebApplication webApplication);
}
public interface IConfigureServices : IConfigure
{
    void ConfigureServices(IConfiguration configuration, IServiceCollection services);
}
```

`RunAppAsync()` looks almost like the content of a normal Program.cs.

But, it reads the services and configurations to register from a list, `_configurations`. We populate that list inside `MyCoolAppUsingHangfire` using the method `Register()`.

## After that change, our Program.cs file has only a few lines of code

And lo and behold,

```csharp
using OrganizingProgramDotCs;

var myCoolApp = new MyCoolAppUsingHangfire();
await myCoolApp.RunAppAsync(args);
```

With this approach, we move every configuration artifact to separate classes, keeping the Program.cs clean and compact. Ours now has only three lines of code.

We could also use this approach [to handle the Startup class when migrating old ASP.NET Core projects]({% post_url 2024-09-25-MigratingStartupClass %}).

Et voilà!
