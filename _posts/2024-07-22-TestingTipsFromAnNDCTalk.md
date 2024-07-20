---
layout: post
title: "5 Unit Testing Best Practices I Learned from This NDC Conference Talk"
tags: tutorial csharp
cover: Cover.png
cover-alt: "crowded audience" 
---

Recently, I found a NDC talk titled ".NET Testing Best Practices" by Rob Richardson.

Today I want to share five unit testing best practices I learned from that talk, along with my comments on other parts of it.

Here's the YouTube video of the talk, in case you want to watch it, and [the speaker's website](https://robrich.org/),

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/_USCe5PolOA?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

During the presentation, the speaker coded some unit tests for the `LightActuator` class. This class powers an IoT device that turns a light switch on or off based on a motion sensor input.

The `LightActuator` turns on lights if any motion is detected in the evening or at night. And, it turns off lights in the morning or if no motion has been detected in the last minute.

Here's the `LightActuator` class, [Source](https://github.com/robrich/net-testing-xunit-moq/blob/main/start/LightController/ApplicationCode.cs#L42)

```csharp
public class LightActuator : ILightActuator
{
    private DateTime LastMotionTime { get; set; }

    public void ActuateLights(bool motionDetected)
    {
        DateTime time = DateTime.Now;

        // Update the time of last motion.
        if (motionDetected)
        {
            LastMotionTime = time;
        }

        // If motion was detected in the evening or at night, turn the light on.
        string timePeriod = GetTimePeriod(time);
        if (motionDetected && (timePeriod == "Evening" || timePeriod == "Night"))
        {
            LightSwitcher.Instance.TurnOn();
        }
        // If no motion is detected for one minute, or if it is morning or day, turn the light off.
        else if (time.Subtract(LastMotionTime) > TimeSpan.FromMinutes(1)
                    || (timePeriod == "Morning" || timePeriod == "Noon"))
        {
            LightSwitcher.Instance.TurnOff();
        }
    }

    private string GetTimePeriod(DateTime dateTime)
    {
        if (dateTime.Hour >= 0 && dateTime.Hour < 6)
        {
            return "Night";
        }
        if (dateTime.Hour >= 6 && dateTime.Hour < 12)
        {
            return "Morning";
        }
        if (dateTime.Hour >= 12 && dateTime.Hour < 18)
        {
            return "Afternoon";
        }
        return "Evening";
    }
}
```

And here's the first unit test the presenter live-coded,

```csharp
public class LightActuator_ActuateLights_Tests
{
    [Fact]
    public void MotionDetected_LastMotionTimeChanged()
    {
        // Arrange
        bool motionDetected = true;
        DateTime startTime = new DateTime(2000, 1, 1); // random value

        // Act
        LightActuator actuator = new LightActuator();
        actuator.LastMotionTime = startTime;
        actuator.ActuateLights(motionDetected);
        DateTime actualTime = actuator.LastMotionTime;

        // Assert
        Assert.NotEqual(actualTime, startTime);
    }
}
```

Of course, the presenter refactored this test and introduced more examples throughout the rest of the talk. But this initial test is enough to prove our points.

## Five Unit Testing Best Practices from This Talk

### 1. Adopt a new naming convention

In this talk, I found a new [naming convention for our unit tests]({% post_url 2021-04-12-UnitTestNamingConventions %}).

To name test classes, we use `<ClassName>_<MethodName>_Tests`.

For test methods, we use `<Scenario>_<ExpectedResult>`.

Here are the test class and method names for our sample test,

```csharp
public class LightActuator_ActuateLights_Tests
//           ^^^^^
{
    [Fact]
    public void MotionDetected_LastMotionTimeChanged()
    //          ^^^^^
    {
        // Beep, beep, boop...
        // Magic goes here
    }
}
```

### 2. Label your test parameters

Instead of simply calling the method under test with a list of parameters, let's label them for more clarity.

For example, instead of simply calling `ActuateLights()` with `true`, let's create a documenting variable,

```csharp
[Fact]
public void MotionDetected_LastMotionTimeChanged()
{
    bool motionDetected = true;
    DateTime startTime = new DateTime(2000, 1, 1);

    LightActuator actuator = new LightActuator();
    actuator.LastMotionTime = startTime;
    // Before
    //actuator.ActuateLights(true);
    //                       ^^^^^
    // After
    actuator.ActuateLights(motionDetected);
    //                     ^^^^^
    DateTime actualTime = actuator.LastMotionTime;

    // Beep, beep, boop...
}
```

### 3. Use human-friendly assertions

Looking closely at the sample test, we notice the Assert part has a bug.

The actual and expected values inside `NotEqual()` are in the wrong order. The expected value should go first. Arrrggg!

```csharp
[Fact]
public void MotionDetected_LastMotionTimeChanged()
{
    bool motionDetected = true;
    DateTime startTime = new DateTime(2000, 1, 1);

    LightActuator actuator = new LightActuator();
    actuator.LastMotionTime = startTime;
    actuator.ActuateLights(motionDetected);
    DateTime actualTime = actuator.LastMotionTime;

    Assert.NotEqual(actualTime, startTime);
    //              ^^^^^
    // They're in the wrong order. Arrrggg!
}
```

To avoid flipping them again, it's a good idea to use more human-friendly assertions using libraries like [FluentAssertions](https://github.com/fluentassertions/fluentassertions) or [Shouldly](https://github.com/shouldly/shouldly).

Here's our tests using FluentAssertions,

```csharp
[Fact]
public void MotionDetected_LastMotionTimeChanged()
{
    bool motionDetected = true;
    DateTime startTime = new DateTime(2000, 1, 1);

    LightActuator actuator = new LightActuator();
    actuator.LastMotionTime = startTime;
    actuator.ActuateLights(motionDetected);
    DateTime actualTime = actuator.LastMotionTime;

    // Before
    //Assert.NotEqual(actualTime, startTime);
    //                ^^^^^
    // They're in the wrong order. Arrrggg!
    //
    // After, with FluentAssertions
    actualTime.Should().NotBe(startTime);
    //         ^^^^^
}
```

### 4. Don't be too DRY

Our sample test only covers the scenario when any motion is detected. If we write another test for the scenario with no motion detected, our tests look like this,

```csharp
public class LightActuator_ActuateLights_Tests
{
    [Fact]
    public void MotionDetected_LastMotionTimeChanged()
    {
        bool motionDetected = true;
        //                    ^^^^
        DateTime startTime = new DateTime(2000, 1, 1);

        LightActuator actuator = new LightActuator();
        actuator.LastMotionTime = startTime;
        actuator.ActuateLights(motionDetected);
        DateTime actualTime = actuator.LastMotionTime;

        Assert.NotEqual(startTime, actualTime);
        //     ^^^^^
    }

    [Fact]
    public void NoMotionDetected_LastMotionTimeIsNotChanged()
    {
        bool motionDetected = false;
        //                    ^^^^^
        DateTime startTime = new DateTime(2000, 1, 1);

        LightActuator actuator = new LightActuator();
        actuator.LastMotionTime = startTime;
        actuator.ActuateLights(motionDetected);
        DateTime actualTime = actuator.LastMotionTime;

        Assert.Equal(startTime, actualTime);
        //     ^^^^^
    }
}
```

The only difference between the two is the value of `motionDetected` and the assertion method at the end.

We might be tempted to remove that duplication, using [parameterized tests]({% post_url 2021-03-29-UnitTestingCommonMistakes %}).

But, **inside unit tests, being explicit is better than being DRY.**

Turning our two tests into a parameterized test would make us write a weird Assert part to switch between `Equal()` and `NotEqual()` based on the value of `motionDetected`.

Let's prefer clarity over dryness. Tests serve as a living documentation of system behavior.

### 5. Replace dependency creation with auto-mocking

`ActuateLights()` uses a static class to turn on/off lights,

```csharp
public void ActuateLights(bool motionDetected)
{
    DateTime time = DateTime.Now;

    if (motionDetected)
    {
        LastMotionTime = time;
    }

    string timePeriod = GetTimePeriod(time);
    if (motionDetected && (timePeriod == "Evening" || timePeriod == "Night"))
    {
        LightSwitcher.Instance.TurnOn();
        // ^^^^^
    }
    else if (time.Subtract(LastMotionTime) > TimeSpan.FromMinutes(1)
                || (timePeriod == "Morning" || timePeriod == "Noon"))
    {
        LightSwitcher.Instance.TurnOff();
        // ^^^^^
    }
}
```

It'd be hard to assert if the lights were turned on or off with a static method.

A better approach is to replace `LightSwitcher.Instance` with an interface.

But adding a new dependency to the `LightActuator` would break our tests.

Instead of manually passing the new `LightSwitch` abstraction to the `LightActuator` constructor inside our tests, we could rely on auto-mocking tools like [Moq.AutoMocker](https://github.com/moq/Moq.AutoMocker).

Here's our test using AutoMocker,

```csharp
[Fact]
public void MotionDetected_LastMotionTimeChanged()
{
    bool motionDetected = true;
    DateTime startTime = new DateTime(2000, 1, 1);

    var ioc = new AutoMocker();
    //            ^^^^^
    var actuator = ioc.CreateInstance<LightActuator>();
    //                 ^^^^^

    actuator.LastMotionTime = startTime;
    actuator.ActuateLights(motionDetected);
    DateTime actual = actuator.LastMotionTime;

    actual.Should().NotBe(startTime);
}
```

I've already used a similar approach with [TypeBuilder and AutoFixture]({% post_url 2021-06-21-WriteSimplerTestsTypeBuilderAndAutoFixture %}).

## My Reaction: What I'd do differently

After writing and getting my tests reviewed, I've developed my own "taste" for unit testing. 

Don't take me wrong. This is a good talk and I've stolen some ideas for my own presentations.

But, this is what I'd do differently:

### 1. Avoid comments for AAA sections

Let's avoid adding `// Arrange`, `// Act`, and `// Assert` comments inside our tests.

We don't add `// class`, `// fields`, and `// methods` in other parts of our code, so it shouldn't be necessary in our tests either.

Instead, I prefer using blank lines to visually separate the three sections of the [Arrange/Act/Assert pattern]({% post_url 2021-07-19-WriteBetterAssertions %}).

In the examples I've shown you, I completely removed those comments.

### 2. Name test values instead of using comments

It's a good idea to document our test values. But, let's avoid using comments when we can use a descriptive name.

I'd rename `startTime` with a comment at the end to `anyStartTime` or `randomStartTime`,

```csharp
[Fact]
public void MotionDetected_LastMotionTimeChanged()
{
    bool motionDetected = true;
    // Before:
    //DateTime startTime = new DateTime(2000, 1, 1); // random value
    //                                               ^^^^^
    var anyStartTime = new DateTime(2000, 1, 1);
    //  ^^^^^
    // or
    //var randomStartTime = new DateTime(2000, 1, 1);
    //    ^^^^

    LightActuator actuator = new LightActuator();
    actuator.LastMotionTime = anyStartTime;
    actuator.ActuateLights(motionDetected);
    DateTime actualTime = actuator.LastMotionTime;

    Assert.NotEqual(anyStartTime, actualTime);
}
```

### 3. Don't expose private parts

In the talk, as part of the refactoring session, the presenter tested some internals. Specifically, he made the `LastMotionTime` property inside the `LightActuator` class public to use it inside the tests.

Even somebody in the audience raised this question too.

I understand the presenter had less than an hour to show a complete example and he chose a simple approach.

But, let's avoid exposing internals to our tests. [That's the most common mistake on unit testing]({% post_url 2021-10-11-DontRepeatLogicInAssertions %}).

## Parting thoughts

Voilà! Those are the five lessons I learned from this talk.

My favorite quote from the talk:

> "What's cool about unit testing is we can debug our code by writing code"
>
> — Rob Richardson

As an exercise left to the reader, the presenter didn't cover testing time. But we already covered [how to write tests that use DateTime.Now]({% post_url 2021-05-10-WriteTestsThatUseDateTimeNow %}) using a custom abstraction.

And if we're using .NET 8.0, we can rely on [.NET 8.0 TimeProvider and its abstractions]({% post_url 2024-06-10-TestingTimeWithTimeProvider %}) to abstract and test time.

Another thing I didn't like is that at some point in the testing session, a `TimePeriodHelper` was added. And that's one of the [method and class names I'd like to ban]({% post_url 2022-12-07-BanningSomeNamingConventions %}).

{%include ut201_course.html %}