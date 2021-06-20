---
layout: post
title: How to read configuration values in ASP.NET Core
tags: tutorial asp.net csharp
---

ASP.NET Core has brought a lot of new features [compared to ASP.NET Framework](https://canro91.github.io/2020/03/23/GuideToNetCore/), the previous version. It has new project files, a dependency container, [a caching layer](https://canro91.github.io/2020/06/29/HowToAddACacheLayer/), among other features. Configuration has changed too. Let's see how to read and overwrite configuration values with ASP.NET Core.

**To read configuration values in ASP.NET Core, you need to implement the Options pattern.** There is no `ConfigurationManager` class to read configuration values from a `web.config` file. ASP.NET Core has introduced json files. To implement the Options pattern, you define a configuration class matching the values you want to read from the `appsetttings.json` file and use the default dependency container to receive the read values in your code.

<figure>
<img src="https://images.unsplash.com/photo-1589210212007-20415bd621b1?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop" alt="Macaroons in the showcase of a pastry shop" />

<figcaption>Those are Macaroons options. Not the Options pattern. <span>Photo by <a href="https://unsplash.com/@veredcc?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Vered Caspi</a> on <a href="https://unsplash.com/s/photos/choices?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

### Options pattern

Let's see how to implement the Options pattern to read configuration values.

First, add in the `appsettings.json` files, the values you want to configure. Unlike, the previous version of ASP.NET you can use sections and subsections to group your values. And, you can use booleans, integers and arrays, instead of only strings.

```json
{
  "MySettings": {
    "ASetting": "Hello, world!",
    "ABooleanSetting": true,
    "AnIntegerSetting": 1,
    "AnArraySetting": ["hello", ",", "world", "!"]
  }
}
```

Then, create a class `MySettings`. This class name matches your section name in the `appsettings.json` file. Also, property names should match the key names inside your sections in the `appsettings.json` file.

```csharp
public class MySettings
{
    public string ASetting { get; set; }
    public bool ABooleanSetting { get; set; }
    public int AnIntegerSetting { get; set; }
    public string[] AnArraySetting { get; set; }
}
```

Next, bind the custom section in the settings file and the `MySettings` configuration class. In the `ConfigureServices` method of the `Startup` class, use the `Configure` method. Like this, 

```csharp
services.Configure<MySettings>(_configuration.GetSection("MySettings"));
```

Notice how the `_configuration` field is injected into the `Startup` class.

```csharp
public class Startup
{
    private IConfiguration _configuration;

    public Startup(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public void ConfigureServices(IServiceCollection services)
    {
        services.Configure<MySettings>(_configuration.GetSection("MySettings"));

        services.AddControllers();
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        // etc...
    }
}
```

If you use subsections in your settings file, separate them using `:` in the `Configure` method. For example, if  `MySettings` were inside a section `AllMyCoolSettings`, then you would use `MySettings:AllMyCoolSettings` as the section name to bind. Like this,

```csharp
services.Configure<MySettings>(_configuration.GetSection("AllMyCoolSettings:MySettings"));
```

By default, ASP.NET Core reads configuration values from environment variables too. An environment variable `MySettings__ASetting` will change the value of `ASetting`. This time, the separator is a double undescore, `__`.

To use these configuration values, add an `IOptions<MySettings>` parameter in the constructor of your service or controller.

```csharp
[Route("api/[controller]")]
public class ValuesController : Controller
{
    private readonly MySettings _mySettings;

    public ValuesController(IOptions<MySettings> mySettingsOptions)
    {
        _mySettings = mySettingsOptions.Value;
    }

    [HttpGet]
    public string Get(int id)
    {
        return _mySettings.ASetting;
    }
}
```

That's it! That's the Options pattern in action.

In your tests, you can use the method `Options.Create` with an instance of the `MySettings` class to fake configuration values. You don't need any mock for that.

### Use multiple configuration files per environment

**You can separate your configuration values per environment in different configuration files.**

You could have settings files for Development, QA or any other environment. If a value isn't found in an environment-specific file, ASP.NET Core uses the default `appsettings.json` file.

You can change the current environment with the `ASPNETCORE_ENVIRONMENT` environment variable. On a develop machine, you can use [the launchSettings.json file](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/environments?view=aspnetcore-3.1#development-and-launchsettingsjson) to set environment variables.

```json
{
  // ...
  "profiles": {
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    "<YourSolutionName>": {
      "commandName": "Project",
      "launchBrowser": true,
      "applicationUrl": "http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "MySettings__ASetting": "A settting changed from an environment var"
      }
    }
  }
}
```

### PostConfigure

Imagine one day, you start to work on a legacy project. But, you can't find some configuration values in any settings file. After asking a co-worker, those configuration values are read from environment variables. When you get the values for these environment variables to test, they are outdated. _Arggg!_

You can add those environment variables in the `launchSettings.json` file. New developers won't have to struggle to find those values again.

But, you can refactor the code to use the Options pattern instead of environment variables. To make things obvious, you can add the right values in the `appsettings.json` file.

_What about the existing environment variables?_ If you can't rename the existing environment variables to follow your settings file, use [the PostConfigure method](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/options?view=aspnetcore-3.1#options-post-configuration). You can overwrite the values read from the settings file using the existing environment variables.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.Configure<MySettings>(_configuration.GetSection("MySettings"));

    // Other configurations and services...

    services.PostConfigure<MySettings>((options) =>
    {
        var aSettingEnvVar = Environment.GetEnvironmentVariable("A_Setting");
        if (!string.IsNullOrEmpty(aSettingEnvVar))
        {
            options.ASetting = aSettingEnvVar;
        }
    });

    services.AddControllers();
}
```

### Conclusion

Voilà! Now you know how to read configuration values with ASP.NET Core. Be aware, there are other [options interfaces](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/options?view=aspnetcore-3.1#options-interfaces): `IOptionSnapshot` and `IOptionsMonitor`. Also, you can use other configuration providers to read your values from an ini file, an xml file or Azure Key Vault.

If you're interested in more ASP.NET Core content, check my posts on [how to create a caching layer](https://canro91.github.io/2020/06/29/HowToAddACacheLayer/) and [how to create a CRUD API with Insight.Database](https://canro91.github.io/2020/05/01/InsightDatabase/).

_Happy coding!_
