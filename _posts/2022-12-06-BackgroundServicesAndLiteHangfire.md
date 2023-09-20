---
layout: post
title: "How to replace BackgroundServices with a lite Hangfire"
tags: tutorial csharp asp.net
cover: Cover.png
cover-alt: "Industrial robots in a car assembly line"
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

I like ASP.NET Core BackgroundServices. I've used them in one of my client's projects to run recurring operations outside the main ASP.NET Core API site. Even for small one-time operations, I've run them in the same API site.

There's one catch. We have to write our own retrying, multi-threading, and reporting mechanism. BackgroundServices are a lightweight alternative to run background tasks.

## Lite Hangfire

These days, a coworker came up with the idea to use a "lite" Hangfire to replace ASP.NET Core BackgroundServices. By "lite," he meant an in-memory, single-thread Hangfire configuration.

Let's create an ASP.NET Core API site and install these NuGet packages:

* Hangfire,
* Hangfire.AspNetCore,
* [Hangfire.InMemory](https://github.com/HangfireIO/Hangfire.InMemory),
* [Hangfire.Console](https://github.com/pieceofsummer/Hangfire.Console) to bring color to our lives

### 1. Register Hangfire

In the Program.cs file, let's register the Hangfire server, dashboard, and recurring jobs. Like this,

```csharp
using Hangfire;
using LiteHangfire.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.ConfigureHangfire();
//               ^^^^^

var app = builder.Build();

app.UseAuthorization();
app.MapControllers();

app.UseHangfireDashboard();
app.MapHangfireDashboard();
//  ^^^^^
app.ConfigureRecurringJobs();
//  ^^^^^

app.Run();
```

To make things cleaner, let's use extension methods to keep all Hangfire configurations in a single place. Like this,

```csharp
using Hangfire;
using Hangfire.Console;
using Hangfire.InMemory;
using RecreatingFilterScenario.Jobs;

namespace LiteHangfire.Extensions;

public static class ServiceCollectionExtensions
{
    public static void ConfigureHangfire(this IServiceCollection services)
    {
        services.AddHangfire(configuration =>
        {
            configuration.UseInMemoryStorage();
            //            ^^^^^
            // Since we have good memory
            configuration.UseConsole();
            //            ^^^^^

        });
        services.AddHangfireServer(options =>
        {
            options.SchedulePollingInterval = TimeSpan.FromSeconds(5);
            //      ^^^^^
            // For RecurringJobs: Delay between retries.
            // By default: 15sec
            options.WorkerCount = 1;
            //      ^^^^^
            // Number of worker threads.
            // By default: min(processor count * 5, 20)
        });

        GlobalJobFilters.Filters.Add(new AutomaticRetryAttribute
        {
            Attempts = 1
            // ^^^^^
            // Retry count.
            // By default: 10
        });
    }

    public static void ConfigureRecurringJobs(this WebApplication app)
    {
        //var config = app.Services.GetRequiredService<IOptions<MyRecurringJobOptions>>().Value;
        // ^^^^^^^^^
        // To read the cron expression from a config file

        RecurringJob.AddOrUpdate<ProducerRecurringJob>(
            ProducerRecurringJob.JobId,
            x => x.DoSomethingAsync(),
            "0/1 * * * *");
            // ^^^^^^^^^
            // Every minute. Change it to suit your own needs

        RecurringJob.Trigger(ProducerRecurringJob.JobId);
    }
}
```

Notice that we used the `UseInMemoryStorage()` method to store jobs in memory instead of a database and the `UseConsole()` to bring color to our logging messages in the Dashboard.

<figure>
<img src="https://images.unsplash.com/photo-1589320011103-48e428abcbae?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY3MDAxODI0Mw&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Car factory" />

<figcaption>Photo by <a href="https://unsplash.com/@carlosaranda?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">carlos aranda</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

### 2. Change some Hangfire parameters

In the previous step, when we registered the Hangfire server, we used these parameters:

* `SchedulePollingInterval` is the time to wait between retries for recurring jobs. By default, it's 15 seconds. [Source](https://github.com/HangfireIO/Hangfire/blob/5b696d4174e13c3dd9489cc6a863d3417c632e31/src/Hangfire.Core/Server/RecurringJobScheduler.cs#L329)
* `WorkerCount` is the number of processing threads. By default, it's the minimum between five times the processor count and 20. [Source](https://github.com/HangfireIO/Hangfire/blob/5b696d4174e13c3dd9489cc6a863d3417c632e31/src/Hangfire.Core/BackgroundJobServer.cs#L171)

As an aside, I also discovered these settings:

* `ServerCheckInterval` is how often Hangfire checks for "timed out" servers. By default, it's 5 minutes. [Source](https://github.com/HangfireIO/Hangfire/blob/5b696d4174e13c3dd9489cc6a863d3417c632e31/src/Hangfire.Core/Server/ServerWatchdog.cs#L40)
* `ServerTimeout` is the time to consider that a server timed out from the last heartbeat. By default, it's 5 minutes.

Then, we registered the number of retry attempts. By default, Hangfire retries jobs 10 times. [Source](https://github.com/HangfireIO/Hangfire/blob/5b696d4174e13c3dd9489cc6a863d3417c632e31/src/Hangfire.Core/AutomaticRetryAttribute.cs#L83)

### 3. Write "Producer" and "Consumer" jobs

The next step is to register a recurring job as a "producer." It looks like this,

```csharp
using Hangfire;
using Hangfire.Console;
using Hangfire.Server;

namespace LiteHangfire.Jobs;

public class ProducerRecurringJob
{
    public const string JobId = nameof(ProducerRecurringJob);

    private readonly IBackgroundJobClient _backgroundJobClient;
    private readonly ILogger<ProducerRecurringJob> _logger;

    public ProducerRecurringJob(IBackgroundJobClient backgroundJobClient,
                                ILogger<ProducerRecurringJob> logger)
    {
        _backgroundJobClient = backgroundJobClient;
        _logger = logger;
    }

    public async Task DoSomethingAsync()
    {
        _logger.LogInformation("Running recurring job at {now}", DateTime.UtcNow);

        // Beep, beep, boop...
        await Task.Delay(1_000);

        // We could read pending jobs from a database, for example
        foreach (var item in Enumerable.Range(0, 5))
        {
            _backgroundJobClient.Enqueue<WorkerJob>(x => x.DoSomeWorkAsync(null));
            // ^^^^^
        }
    }
}
```

Inside this recurring job, we can read pending jobs from a database and enqueue a new worker job for every pending job available.

And a sample worker job that uses Hangfire.Console looks like this,

```csharp
public class WorkerJob
{
    public async Task DoSomeWorkAsync(PerformContext context)
    {
        context.SetTextColor(ConsoleTextColor.Blue);
        context.WriteLine("Doing some work at {0}", DateTime.UtcNow);

        // Beep, beep, boop...
        await Task.Delay(3_000);
    }
}
```

Notice that we expect a `PerformContext` as a parameter to change the color of the logging message. When we enqueued the worker jobs, we passed `null` as context, then Hangfire uses the right instance when running our jobs. [Source](https://stackoverflow.com/questions/38368153/how-do-i-get-the-current-attempt-number-on-a-background-job-in-hangfire/38387512).

Voilà! That's how to use a lite Hangfire to replace BackgroundServices without adding too much overhead or a new database to store jobs. With the advantage that Hangfire has recurring jobs, retries, and a Dashboard out of the box.

After solving a couple of issues, I learned some [lessons when working with Hangfire]({% post_url 2022-12-13-LessonsOnHangfireAndOrmLite %}).

To read more content about ASP.NET Core, check [how to write tests for HttpClient]({% post_url 2022-12-01-TestingHttpClient %}) and [how to test an ASP.NET filter]({% post_url 2022-12-03-TestingAspNetAuthorizationFilters %}).

_Happy coding!_
