---
layout: post
title: "BugOfTheDay: There are pending requests working on this transaction"
tags: bugoftheday csharp
cover: Cover.png
cover-alt: "There are pending requests working on this transaction"
--- 

These days I got this exception message: "The transaction operation cannot be performed because there are pending requests working on this transaction". This is how I fixed it after almost a whole day of Googling and debugging.

**To fix the pending requests exception, make sure to properly await all asynchronous methods wrapped inside any database transaction.**

## Pipeline pattern and reverting reservations

I was working with [the pipeline pattern]({% post_url 2020-02-14-PipelinePattern %}) to book online reservations.

The reservation process used two types of steps inside a pipeline: foreground and background steps.

The foreground steps ran to separate enough rooms for the reservation. And the background steps did everything else to fullfil the reservation, but in background jobs.

If anything wrong happened executing the foreground steps, the whole operation rollbacked. And there was no rooms set aside for the incoming reservation. To achieve this, every foreground step had a method to revert its own operation.

The code to revert the whole pipeline was wrapped inside a trasanction. It looked something like this,

```csharp
using (var transactionScope = _transactionManager.Create(IsolationLevel.Serializable))
{
    try
    {
        await pipeline.RevertAsync();

        transactionScope.Commit();
    }
    catch (Exception e)
    {
        transactionScope.Rollback();

        _logger.LogError(e, "Something horribly horribly wrong happened");

        throw;
    }
}
```

The `Commit()` method broke with the exception mention earlier. Arrrggg!

<figure>
<img src="https://images.unsplash.com/photo-1473158912295-779ef17fc94b?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxhbGx8fHx8fHx8fHwxNjI0MTY1NTUw&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Broken display glass" />

<figcaption>No displays or electronic devices were damaged while debugging this issue. Photo by <a href="https://unsplash.com/@shots_of_aspartame?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Julia Joppien</a> on <a href="https://unsplash.com/s/photos/broken-computer?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Always await async methods

After Googling for a while, I found a couple of [StackOverflow answers](https://stackoverflow.com/questions/36552285/the-transaction-operation-cannot-be-performed-because-there-are-pending-requests) that mention to await all asynchronous methods. But, I thought it was a silly mistake and I started to look for something else more complicated.

After checking for a while, trying to isolate the problem, following [one of my debugging tips]({% post_url 2020-09-19-ThreeDebuggingTips %}), something like this code got all my attention.

```csharp
public async Task RevertAsync(ReservationContext context)
{
    var reservation = context.Reservation;
    if (reservation == null)
    {
        return;
    }

    var updatedByUserId = GetSystemUserAsync(context).Id;
    await _roomService.UnassignRooms(reservation, updatedByUserId);
}

private async Task<User> GetSystemUserAsync()
{
    var systemUser = await _userRepository.GetSystemUserAsync();
    return systemUser;
}
```

Did you notice any asynchronous method not being awaited? No? I didn't for a while. Neither did my reviewers.

But, there it was. Unnoticed for the code analyzer too. And, for all the passing tests.

Oh, dear! `var updatedByUserId = GetSystemUserAsync(context).Id`. This line was the root of the issue. It was meant to log the user Id who performed an operation, not the Id of the `Task` not being awaited.

Voilà! In case you have to face this exception, take a deep breath and carefully look for any async methods not being awaited inside your transactions.

If you want to read more content, check [my debugging tips]({% post_url 2020-09-19-ThreeDebuggingTips %}). To learn to write unit tests, start reading [Unit Testing 101]({% post_url 2021-03-15-UnitTesting101 %}). A better failing test would've caught this issue.

To read about C# async/await keywords, check my [C# Definitive Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}). It contains good resources to be a fluent developer in C#.

_Happy bug fixing!_