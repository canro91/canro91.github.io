---
layout: post
title: "Pipeline pattern: An assembly line of steps"
tags: tutorial csharp
---

You need to do a complex operation made of smaller consecutives tasks. This is how you can use the Pipeline pattern to achieve that. _Let's get started!_

**With the Pipeline pattern, a complex task is divided into separated steps.** Each step is responsible for a piece of logic of that complex task. Like an assembly line, steps in a pipeline are executed one after the other, depending on the output of previous steps.

> TL;DR Pipeline pattern is like the enrich pattern with factories. Pipeline = Command + Factory + Enricher

## Problem

You need to do a complex operation in your system. But, this complex operation consist of smaller tasks or steps. For example, make a reservation, generate an invoice or create an order. If a single task fails, you want to mark the whole operation as failed. 

Also, the steps in your operation won't be the same every time. For example, they will vary per client, type of operation or any other input parameter. _Let's use the Pipeline pattern._

## Solution

**A pipeline is like an assembly line in a factory.** Each workstation in an assembly adds a part until the product is assembled. For example, in a car factory, there are separate stations to put the doors, the engine and the wheels.

You can create reusable **steps** to perfom each action in your "assembly line". Then, you run these steps one after the other in a pipeline.

For example, in an e-commerce system to sell an item, you need to update the stock, charge a credit card, send a delivery order and send an email to the client.

<figure>
<img src="https://images.unsplash.com/photo-1567789884554-0b844b597180?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Pipeline pattern in C#" />

<figcaption><span>Photo by <a href="https://unsplash.com/@lennykuhne?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Lenny Kuhne</a> on <a href="https://unsplash.com/photos/QMjCzOGeglA?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

### Let's implement our own pipeline

First, create a command/context class for the inputs of the pipeline.

```csharp
public class BuyItemCommand : ICommand
{
    // Item code, quantity, credit card information, etc
}
```

Then, create one class per each workstation of your assembly line. These are the **steps**.

In our e-commerce example, steps will be `UpdateStockStep`, `ChargeCreditCardStep`, `SendDeliveryOrderStep` and `NotifyClientStep`.

```csharp
public class UpdateStockStep : IStep<BuyItemCommand>
{
    public Task ExecuteAsync(BuyItemCommand command)
    {
        // Put your own logic here
        return Task.CompletedTask;
    }
}
```
    
Next, we need a builder to create our pipeline with its steps. Since the steps may vary depending on the type of operation or the client, you can load your steps from a database or configuration files. For example, to sell an eBook, we don't need to create a delivery order.

```csharp
public class BuyItemPipelineBuilder : IPipelineBuilder
{
    private readonly IStep<BuyItemCommand>[] Steps;

    public BuyItemPipelineBuilder(IStep<BuyItemCommand>[] steps)
    {
        Steps = steps;
    }

    public IPipeline CreatePipeline(BuyItemCommand command)
    {
      // Create your pipeline here...
      var updateStockStep = new UpdateStockStep();
      var chargeCreditCardStep = new ChargeCreditCard();
      var steps = new[] { updateStockStep, chargeCreditCardStep };
      return new BuyItemPipeline(command, steps);
    }
}
```

Now, create the pipeline to run all its steps. It will have a loop to execute each step.

```csharp
public class BuyItemPipeline : IPipeline
{
    private readonly BuyItemCommand Command;
    private readonly IStep<BuyItemCommand>[] Steps;

    public BuyItemPipeline(BuyItemCommand command, IStep<BuyItemCommand>[] steps)
    {
        Command = command;
        Steps = steps;
    }

    public async Task ExecuteAsync()
    {
        foreach (var step in Steps)
        {
            await step.ExecuteAsync(Command);
        }
    }
}
```
    
Also, you can use the [Decorator pattern]({% post_url 2021-02-10-DecoratorPattern %}) to perform orthogonal actions on the execution of the pipeline or every step. You can run the pipeline inside a database transaction, log every step or measure the execution time of the pipeline.

Now everything is in place, let's run our pipeline.

```csharp
var command = new BuyItemCommand();
var builder = new BuyItemPipelineBuilder(command);
var pipeline = builder.CreatePipeline();

await pipeline.ExecuteAsync();
```

Some steps of the pipeline can be delayed for later processing. The user doesn't have to wait for these steps to finish his interaction in the system. You can run them in background jobs or schedule its execution for later processing. For example, you can use [Hangfire](https://github.com/HangfireIO/Hangfire) or roll your own queue mechanism ([Kiukie](https://github.com/canro91/Kiukie)...Ahem, ahem)

## Conclusion

Voilà! This is the Pipeline pattern. You can find it out there or implement it on your own. Depending on the expected load of your pipeline, you could use [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) or any other queue mechanism to run your steps.

I have used and implemented this pattern before. I used it in an invoicing platform to generate documents. Each document and client type had a different pipeline.

Also, I have used it in a reservation management system. I had separate pipelines to create, modify and cancel reservations.

> PS: You can take a look at [Pipelinie](https://github.com/canro91/Pipelinie) to see more examples. Pipelinie offers abstractions and default implementations to roll your own pipelines and builders.
>
> All ideas and contributions are more than welcome!

[![canro91/Pipelinie - GitHub](https://gh-card.dev/repos/canro91/Pipelinie.svg)](https://github.com/canro91/Pipelinie)