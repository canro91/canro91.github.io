---
layout: post
title: Pipeline pattern&colon; Perform tasks with an assembly line of steps
---

> TL;DR Pipeline pattern is like the enrich pattern with factories. Pipeline = Command + Factory + Enricher

## Problem

You need to do a complex operation in your system. But, this complex operation consist of smaller tasks or steps. For example, make a reservation, generate an invoice or create an order. If a single task fails, you want to mark the whole operation as failed. 

Also, this set of tasks can vary depending of certain conditions. So, your complex operation won't have the same tasks every time. For example, it will vary per client, type of operation or any other parameter. _How would you do it?_

## Solution

The pipeline pattern to the rescue! A pipeline is like an assembly line in a factory. Each workstation in an assembly adds a part until the product is assembled. For example, in a car assembly line, there are separate stations to put the doors, the engine and the wheels of a car.

You can create a set of reusable _steps_ to perfom each action in your "assembly line". So you can apply these steps one after the other in a pipeline. For example, to sell an item online, you need to update the stock, charge a credit card, send a delivery order and send an email to the client. _To the code!_

First, create a command/context class for the inputs of the pipeline

```csharp
public class BuyItemCommand : ICommand
{
    // Item code, quantity, credit card information, etc
}
```

Then, create one class per each workstation of your assembly line. These are the _steps_. For example, `UpdateStockStep`, `ChargeCreditCardStep`, `SendDeliveryOrderStep` and `NotifyClientStep`.

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
    
Next, a builder for a pipeline with all its steps. Since the steps may vary depending on the type of operation, the client or any other condition, you can load your steps from a database or config files. For example, selling an eBook doesn't need to create a delivery order.

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

Now, create the pipeline to run all its steps. It's a loop through its steps.

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
    
Also, you can use decorators to perform orthogonal actions on the execution of the pipeline or every step. For example, run the pipeline inside a transaction, log every step or measure the execution time of the pipeline.

Now everything is in place, so you can run your pipeline

```csharp
var command = new BuyItemCommand();
var builder = new BuyItemPipelineBuilder(command);
var pipeline = builder.CreatePipeline();

await pipeline.ExecuteAsync();
```

But, some steps of the pipeline can be delayed for later processing. The user doesn't have to wait for these steps to finish its interaction in the system. You can run them in background jobs or schedule its execution for later processing. For example, you can use [Hangfire](https://github.com/HangfireIO/Hangfire) or roll your own queue mechanism ([Kiukie](https://github.com/canro91/Kiukie)...Ahem, ahem)

## Conclusion

This is a pattern you may find out there or may need to write. It's an assembly of steps to perform some actions based on a input object. You could extend this pattern to add custom action on the execution of the pipeline or each step. Also, depending on the expected load of your pipeline, you could use [Azure Functions](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) to run your steps.

PS: You can take a look at [Pipelinie](https://github.com/canro91/Pipelinie) to see more examples. Pipelinie offers abstractions and default implementations to roll your own pipelines and builders. All ideas and contributions are more than welcome!