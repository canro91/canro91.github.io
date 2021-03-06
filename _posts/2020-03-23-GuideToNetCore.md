---
layout: post
title: ASP.NET Core Guide for ASP.NET Framework Developers
description: ASP.NET Core is here to stay. Let's see what has changed from the ASP.NET you've known for years
tags: tutorial asp.net
cover: Cover.png
cover-alt: ASP.NET Core Guide for ASP.NET Framework Developers
---

If you are a C# developer, chances are you have heard about this new .NET Core thing and the new version of the ASP.NET framework. You can continue to work with ASP.NET Web API or any other framework from the old ASP.NET you've known for years. But, ASP.NET Core is here to stay.

In case you missed it, "[ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/?view=aspnetcore-3.1) is a cross-platform, high-performance, open-source framework for building modern, cloud-based, Internet-connected applications". "ASP.NET Core is a redesign of ASP.NET 4.x, with architectural changes that result in a leaner, more modular framework".

ASP.NET Core has brought a lot of new features. For example, cross-platform development and deployment, built-in dependency injection, middlewares, health checks, out-of-the-box logging providers, hosted services, API versioning and much more.

Don't worry if you haven't started to worked with ASP.NET Core yet. This is a new framework with lots of new features, but it has brought many other features from the previous version. So, you will feel like home. 

> TL;DR
> 
> 1. You can create projects from the command line.
> 2. NuGet packages are listed on the `csproj` files.
> 3. `csproj` files don't list `.cs` files anymore.
> 4. There's no `Web.config`, you have a json file instead.
> 5. There's no `Global.asax`, you have `Startup.cs` instead.
> 6. You have a brand new dependency container.

## Every journey begins with the first step

<figure>
<img src="https://source.unsplash.com/bJhT_8nbUA0/800x400" alt="toddler's standing in front of beige concrete stair" />

<figcaption>Photo by <a href="https://unsplash.com/@tateisimikito?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Jukan Tateisi</a> on <a href="https://unsplash.com/?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

If you are adventurous, download and install the ASP.NET Core [developer (SDK)](https://dotnet.microsoft.com/download) and create a new empty web project from Visual Studio. These are the files that you get from it.

```
|____appsettings.Development.json
|____appsettings.json
|____Program.cs
|____Properties
| |____launchSettings.json
|____<YourProjectName>.csproj
|____Startup.cs
```

ASP.NET Core has been created with other operating systems and IDEs in mind. Now, you can create a project, compile it, and run the tests from the command line. For example, to create a new empty Web project, you can use `$ dotnet new web`

## Where is the packages.config file?

If you installed a NuGet package into your brand new ASP.NET Core project, one thing you could notice is the missing `packages.config` file. If you remember, it is an xml file that holds the packages installed. But, where in the world are those packages referenced now? In the csproj file of your project. 

Now, a csproj file looks like this:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>netcoreapp3.1</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Newtonsoft.Json" Version="12.0.3" />
  </ItemGroup>

</Project>
```

NuGet packages are referenced under `ItemGroup` in a `PackageReference` node. There you are [Newtonsoft.Json](https://www.newtonsoft.com/json)! _Goodbye, `packages.config`!_

## Wait! What happened to the csproj file?

Csproj files have been simplified. Before a csproj file listed every single file in the project. All your files with `.cs` extension were in it. Now, every `.cs` file within the folder structure of the project is part of it. 

Before, things started to get complicated as time went by and the number of files increased. Sometimes, merge conflicts were a nightmare. There were files under version control not included in the csproj file. Were they meant to be excluded because they didn't apply anymore? Or somebody tried to solve a merge conflict and forgot to include them? _This problem is no more!_

## Where is the Web.config file?

Another missing file is the `Web.config` file. Instead you have a Json file: the `appsettings.json` file. You can use strings, integers and booleans in your config file. There is even support for sections and subsections. Before, if you wanted to achieve that, you had to come up with a naming convention for your keys. For example, prepending the section and subsection name in every key name. 

Probably, you have used `ConfigurationManager` all over the place in your code to read configuration values. Now, you can have a class with properties mapped  to a section or subsection of your config file. And you can inject it into your services.

```json
// appsettings.json
{
    "MySettings": {
        "ASetting": "ASP.NET Core rocks",
        "AnotherSetting": true
    }
}
```

```csharp
public class MySettings
{
    public string ASetting { get; set; }
    public bool AnotherSetting { get; set; }
}

public class YourService
{
    public YourService(IOptions<MySettings> settings)
    {
        // etc
    }
}
```

> _You still need to register that configuration into the dependency container! More on that later._

Additionally, you can override keys per environment. You can use the name of your environment in the file name. For example, `appsettings.Development.json` or `appsettings.QA.json`. You can specify the current environment with an environment variable or in the `launchSettings.json` file.
	
There's even support for sensitive settings that you don't want to version control: `secrets.json` file. You can manage this file from the command line too.

## Where is the Global.asax?

Yet another missing file: [`Global.asax`](https://stackoverflow.com/questions/2340572/what-is-the-purpose-of-global-asax-in-asp-net). You used it to perform actions on application or session events. For example, when application started or ended. It was the place to do one-time setups, register filters or define routes.

But now we use the `Startup.cs` file. It contains the initialization and all the settings needed to run the application. An `Startup.cs` file looks like this:

```csharp
public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public IConfiguration Configuration { get; }
        
    public void ConfigureServices(IServiceCollection services)
    {
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
    }
}
```

It has [two methods](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/startup?view=aspnetcore-3.1#the-startup-class): `ConfigureServices` and `Configure`. The `Configure` method replaces the `Global.asax` file. It creates the app's request processing pipeline. This is the place to register a filter or a default route for your controllers. And the `ConfigureServices` is to configure the services to be injected into the dependency container..._Wait, what?_

## A brand new dependency container

Prior to ASP.NET Core, if you wanted to apply dependency injection, you had to bring a container and roll the discovery of services for your controllers. For example, you had an xml file to map your interfaces to your classes or did some assembly scanning to do it automatically. 

Now, a brand new dependency container is included out-of-the-box. You can inject dependencies into your services, filters, middlewares and controllers. It lacks some of the features from your favorite dependency container, but it is meant to suit "90% of the scenarios".

If you are familiar with the vocabulary from another containers, `AddTransient`, `AddScoped` and `AddSingleton` ring a bell. These are [the lifetimes](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection?view=aspnetcore-3.1#service-lifetimes) of the injected services, ranging from the shortest to the largest.

More specifically, a transient service is created every time a new instance is requested. An scoped service is created once per request. Plus, a singleton service is created only once per the application lifetime.

To register your services, you have to do it inside of the `ConfigureServices` method of the `Startup` class. Also, you bind your classes to a section or subsection of the config file here.

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddTransient<IMyService, MyService>();
    
    var section = Configuration.GetSection("MySettings");
    services.Configure<MySettings>(section);
}
```

## Conclusion

You have only scratched the surface of ASP.NET Core. You have learned about some of the changes ASP.NET Core has brought. But, if you haven't started with ASP.NET Core, go and try it. You may be surprise by how things are done now.

> _This post was originally published on [exceptionnotfound.net](https://exceptionnotfound.net/asp-net-core-guide-for-asp-net-framework-developers/) as part of Guest Writer Program. I'd like to thank Matthew for the editing of this post._ 