---
layout: post
title: How to read configuration values in ASP.NET Core
tags: tutorial asp.net csharp
---

Let's see how to read and overwrite configuration values with ASP.NET Core 6.0 using the Options pattern.

**To read configuration values following the Options pattern, add a new section in the appsetttings.json file, create a matching class, and register it into the dependencies container using the Configure() method.**

<figure>
<img src="https://images.unsplash.com/photo-1589210212007-20415bd621b1?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=800&h=400&fit=crop" alt="Macaroons in the showcase of a pastry shop" />

<figcaption>Those are Macaroon options. Not the Options pattern. <span>Photo by <a href="https://unsplash.com/@veredcc?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Vered Caspi</a> on <a href="https://unsplash.com/s/photos/choices?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

Let's see how to use, step by step, the Options pattern to read configuration values.

## 1. Change the appsettings.json file

After creating a new ASP.NET Core API project with Visual Studio or [the dotnet tool from a terminal]({% post_url 2022-12-15-CreateProjectStructureWithDotNetCli %}), let's add in the `appsettings.json` file the values we want to configure on a new JSON object.

Let's add a couple of configuration values inside a new `MySettings` object in our `appsettings.json` file like this,

```json
{
  "MySettings": {
    "AString": "Hello, there!",
    "ABoolean": true,
    "AnInteger": 1,
    "AnArray": ["hello", ",", "there", "!"]
  }
}
```

Inside the `appsettings.json` file, we can use booleans, integers, and arrays, not only strings.

## 2. Create and bind a configuration class

Then, let's create a matching configuration class for our configuration section in the `appsettings.json` file.

We should name our configuration class after our section name and its properties after the keys inside our section.

This is the configuration class for our `MySettings` section,

```csharp
public class MySettings
{
    public string AString { get; set; }
    public bool ABoolean { get; set; }
    public int AnInteger { get; set; }
    public string[] AnArray { get; set; }
}
```

Next, let's bind our configuration class to our custom section and register it into the built-in dependencies container. In our `Program.cs` class, let's use the `Configure()` method for that,

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

var mySettingsSection = builder.Configuration.GetSection("MySettings");
builder.Services.Configure<MySettings>(mySettingsSection);
//               ^^^^^

var app = builder.Build();
app.MapControllers();
app.Run();
```

As an alternative, we can use `GetRequiredSection()` instead. It throws an `InvalidOperationException` if we forget to add the configuration section in our `appsettings.json` file.

## 3. Use sections and subsections

Let's use sections and subsections to group our configuration values on `appsettings.json` files.

Now let's say `MySettings` is inside another section: `AllMyCoolSettings`. We need a new `AllMyCoolSettings` class containing a `MySettings` property like this,

```csharp
public class AllMyCoolSettings
{
    public MySettings MySettings { get; set; }
    //     ^^^^^
}
```

Then, in the `Configure()` method, we separate the section and subsection names using a colon, `:`, like this,

```csharp
var mySettings = builder.Configuration.GetSection("AllMyCoolSettings:MySettings");
//                                                 ^^^^^
builder.services.Configure<MySettings>(mySettings);
```

## 4. Inject an IOptions interface

To use these configuration values, let's add an `IOptions<T>` parameter in the constructor of our service or controller.

Let's create a simple controller that prints one of our configured values, 

```csharp
[Route("api/[controller]")]
public class ValuesController : Controller
{
    private readonly MySettings _mySettings;

    public ValuesController(
        IOptions<MySettings> mySettingsOptions)
        // ^^^^^
    {
        _mySettings = mySettingsOptions.Value;
        //                              ^^^^^
    }

    [HttpGet]
    public string Get()
    {
        return _mySettings.ASetting;
        //     ^^^^^   
    }
}
```

The `IOptions<T>` interface has a property `Value`. It holds an instance of our configuration class with the parsed values from the `appsettings.json` file.

In our controller we use the injected `MySettings` like any other object instance. 

**By default, if we forget to add a configuration value in the `appsettings.json` file, ASP.NET Core doesn't throw any exception.** Instead, ASP.NET Core initializes the configuration class to its default values.

That's why it's a good idea to always [validate for missing configuration values inside constructors]({% post_url 2022-12-02-ValidateInputParameters %}).

For unit testing, let's use the method `Options.Create()` with an instance of the `MySettings` class we want to use. We don't need a [stub or mock]({% post_url 2021-05-24-WhatAreFakesInTesting %}) for that!

## 5. Use separate configuration files per environment

Let's separate our configuration values into different configuration files per environment.

By default, ASP.NET Core creates two JSON files: `appsettings.json` and `appsettings.Development.json`. But we could have other configuration files, too.

If ASP.NET Core doesn't find a value in an environment-specific file, it reads the default `appsettings.json` file instead.

ASP.NET Core reads the current environment from the `ASPNETCORE_ENVIRONMENT` environment variable.

On a development machine, we can use the `launchSettings.json` file to set environment variables.

For example, let's override one configuration value using an environment variable in our `launchSettings.json` file,

```json
{
    "<YourSolutionName>": {
      "commandName": "Project",
      "applicationUrl": "http://localhost:5000",
      
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        // ^^^^^
        "MySettings__AString": "This value comes from an environment variable"
        // ^^^^^
      }
    }
  }
}
```

By default, ASP.NET Core reads configuration values from environment variables, too.

Environment variables have a higher precedence than JSON files.

For example, if we set an environment variable `MySettings__AString`, ASP.NET Core will use that value instead of the one on the `appsettings.json` file.

Notice that the separator for sections and subsections inside environment variables is a double undescore, `__`.

## 6. Embrace PostConfigure

After registering our configuration classes, we can override their values using the `PostConfigure()` method.

I used `PostConfigure()` when refactoring a legacy application. I grouped related values in the `appsetting.json` file into sections. But I couldn't rename the existing environment variables to match the new names. I did something like this instead,

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

var mySettingsSection = builder.Configuration.GetSection("MySettings");
builder.Services.Configure<MySettings>();

builder.Services.PostConfigure<MySettings>(options =>
//               ^^^^^
{
    var anOldSetting = Environment.GetEnvironmentVariable("AnOldSettingName");
    //  ^^^^^
    if (!string.IsNullOrEmpty(anOldSetting))
    {
        options.AString = anOldSetting;
        //      ^^^^^
    }
});

var app = builder.Build();
app.MapControllers();
app.Run();
```

### Conclusion

Voilà! That's how to read configuration values with ASP.NET Core 6.0. Apart from the `IOptions` interface we used here, ASP.NET Core has `IOptionSnapshot` and `IOptionsMonitor`. Also, we can read values from INI files, XML files, or Azure Key Vault.

In the days of the [old ASP.NET framework]({% post_url 2020-03-23-GuideToNetCore %}), we had a `ConfigurationManager` class and a `web.config` file to read configuration values. Those days are gone! We have JSON files now.

For more ASP.NET Core content, check [how to create a caching layer]({% post_url 2020-06-29-HowToAddACacheLayer %}), [how to create a CRUD API with Insight.Database]({% post_url 2020-05-01-InsightDatabase %}), and [how to use background services with Hangfire]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}).

_Happy coding!_
