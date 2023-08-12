---
layout: post
title: "TIL: Five or more lessons I learned after working with Hangfire and OrmLite"
tags: todayilearned csharp showdev
cover: Cover.png
cover-alt: "Disarmed laptop in pieces" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

These days I finished another internal project while working with one of my clients. I worked to connect a Property Management System with a third-party Point of Sales. I had to work with Hangfire and OrmLite. I used [Hangfire to replace ASP.NET BackgroundServices]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}). Today I want to share some of the technical things I learned along the way.

## 1. Hangfire lazy-loads configurations

Hangfire lazy loads configurations. We have to retrieve services from the ASP.NET Core dependencies container instead of using static alternatives.

I faced this issue after trying to run Hangfire in non-development environments without registering the Hangfire dashboard. This was the exception message I got: _"JobStorage.Current property value has not been initialized."_ When registering the Dashboard, Hangfire loads some of those configurations. That's why "it worked on my machine."

These two issues in Hangfire GitHub repo helped me to find this out: [issue #1991](https://github.com/HangfireIO/Hangfire/issues/1991) and [issue #1967](https://github.com/HangfireIO/Hangfire/issues/1967).

This was the fix I found in those two issues:

```csharp
using Hangfire;
using MyCoolProjectWithHangfire.Jobs;
using Microsoft.Extensions.Options;

namespace MyCoolProjectWithHangfire;

public static class WebApplicationExtensions
{
    public static void ConfigureRecurringJobs(this WebApplication app)
    {
        // Before, using the static version
        //
        // RecurringJob.AddOrUpdate<MyCoolJob>(
        //    MyCoolJob.JobId,
        //    x => x.DoSomethingAsync());
        // RecurringJob.Trigger(MyCoolJob.JobId);
				
        // After
        //
        var recurringJobManager = app.Services.GetRequiredService<IRecurringJobManager>();
        // ^^^^^
        recurringJobManager.AddOrUpdate<MyCoolJob>(
            MyCoolJob.JobId,
            x => x.DoSomethingAsync());
			
        recurringJobManager.Trigger(MyCoolJob.JobId);
    }
}
```

## 2. Hangfire Dashboard in non-Local environments

By default, Hangfire only shows the Dashboard for local requests. A coworker pointed that out. It's in plain sight in [the Hangfire Dashboard documentation](https://docs.hangfire.io/en/latest/configuration/using-dashboard.html). Arrrggg!

To make it work in other non-local environments, we need an authorization filter. Like this,

```csharp
public class AllowAnyoneAuthorizationFilter : IDashboardAuthorizationFilter
{
    public bool Authorize(DashboardContext context)
    {
        // Everyone is more than welcome...
        return true;
    }
}
```

And we add it when registering the Dashboard into the dependencies container. Like this,

```csharp
app.UseHangfireDashboard("/hangfire", new DashboardOptions
{
    Authorization = new [] { new AllowAnyoneAuthorizationFilter() }
});
```

## 3. InMemory-Hangfire SucceededJobs method

For the In-Memory Hangfire implementation, the `SucceededJobs()` method from the monitoring API returns jobs from most recent to oldest. There's no need for pagination. Look at the `Reverse()` method in the [SucceededJobs() source code](https://github.com/HangfireIO/Hangfire.InMemory/blob/master/src/Hangfire.InMemory/InMemoryMonitoringApi.cs#L308).

I had to find out why an ASP.NET health check was only working for the first time. It turned out that the code was paginating the successful jobs, always looking for the oldest successful jobs. Like this,

```csharp
public class HangfireSucceededJobsHealthCheck : IHealthCheck
{
    private const int CheckLastJobsCount = 10;

    private readonly TimeSpan _period;

    public HangfireSucceededJobsHealthCheck(TimeSpan period)
    {
        _period = period;
    }

    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        var isHealthy = true;

        var monitoringApi = JobStorage.Current.GetMonitoringApi();

        // Before
        //
        // It used pagination to bring the oldest 10 jobs
        //
        // var succeededCount = (int)monitoringApi.SucceededListCount();
        // var succeededJobs = monitoringApi.SucceededJobs(succeededCount - CheckLastJobsCount, CheckLastJobsCount);
        //                                                 ^^^^^

        // After
        //
        // SucceededJobs returns jobs from newest to oldest 
        var succeededJobs = monitoringApi.SucceededJobs(0, CheckLastJobsCount);
        //                                            ^^^^^  

        var successJobsCount = succeededJobs.Count(x => x.Value.SucceededAt.HasValue
                                  && x.Value.SucceededAt > DateTime.UtcNow - period);

        var result = successJobsCount > 0
            ? HealthCheckResult.Healthy("Yay! We have succeeded jobs.")
            : new HealthCheckResult(
                context.Registration.FailureStatus, "Nein! We don't have succeeded jobs.");
        
        return Task.FromResult(result);
    }
}
```

This is so confusing that there's an [issue on the Hangfire repo](https://github.com/HangfireIO/Hangfire/issues/2160) asking for clarification. Not all storage  implementations return successful jobs in reverse order. Arrrggg!

## 4. Prevent Concurrent execution of Hangfire jobs

Hangfire has an attribute to prevent the concurrent execution of the same job: `DisableConcurrentExecutionAttribute`. [Source](https://github.com/HangfireIO/Hangfire/blob/master/src/Hangfire.Core/DisableConcurrentExecutionAttribute.cs). Even we can change the resource being locked to avoid executing jobs with the same parameters. For example, we can run only one job per client id simultaneously.

```csharp
[DisableConcurrentExecutionAttribute(timeoutInSeconds: 60)]
// ^^^^^
public class MyCoolJob
{
    public async Task DoSomethingAsync()
    {
        // Beep, beep, boop...
    }
}
```

## 5. OrmLite IgnoreOnUpdate, SqlScalar, and CreateIndex

OrmLite has a `[IgnoreOnUpdate]` attribute. I found this attribute when reading OrmLite source code. When using `SaveAsync()`, OrmLite omits properties marked with this attribute when generating the SQL statement. [Source](https://github.com/ServiceStack/ServiceStack.OrmLite/blob/master/src/ServiceStack.OrmLite/OrmLiteDialectProviderBase.cs#L810).

OrmLite `QueryFirst()` method requires an explicit transaction as a parameter. Unlike `SqlScalar()` which uses the same transaction from the input database connection. [Source](https://github.com/ServiceStack/ServiceStack.OrmLite/blob/master/src/ServiceStack.OrmLite/OrmLiteReadApi.cs#L524). I learned this because I had a `DoesIndexExists()` method inside a database migration and it failed with the message _"ExecuteReader requires the command to have a transaction..."_ This is what I had to change,

```csharp
private static bool DoesIndexExist<T>(IDbConnection connection, string tableName, string indexName)
{
    var doesIndexExistSql = @$"
      SELECT CASE WHEN EXISTS (
        SELECT * FROM sys.indexes
        WHERE name = '{indexName}'
        AND object_id = OBJECT_ID('{tableName}')
      ) THEN 1 ELSE 0 END";
    
    // Before
    //
    // return connection.QueryFirst<bool>(isIndexExistsSql);
    //                   ^^^^^
    // Exception: ExecuteReader requires the command to have a transaction...

    // After
    var result = connection.SqlScalar<int>(doesIndexExistSql);
    //                      ^^^^^
    return result > 0;
}
```

Again, by looking at OrmLite source code, the `CreateIndex()` method, by default, creates indexes with names like: `idx_TableName_FieldName`. Then we can omit the index name parameter when working with this method. [Source](https://github.com/ServiceStack/ServiceStack.OrmLite/blob/master/src/ServiceStack.OrmLite/OrmLiteDialectProviderBase.cs#L1494)

Voilà! That's what I learned from this project. This gave me the idea to stop to reflect on what I learned from every project I work on. I really enjoyed figuring out the issue with the health check. It made me read the source code of the In-memory storage for Hangfire.

For more content, check how I use the `IgnoreOnUpdate` attribute to [automatically insert and update audit fields with OrmLite]({% post_url 2022-12-11-AuditFieldsWithOrmLite %}), [how to pass a DataTable as a parameter with OrmLite]({% post_url 2023-06-26-PassDataTableOrmLite %}) and [how to replace BackgroundServices with a lite Hangfire]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}).

_Happy coding!_