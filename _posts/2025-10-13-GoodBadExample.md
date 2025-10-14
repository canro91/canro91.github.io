---
layout: post
title: "The Best Bad Example I'm Using to Teach Clean Code Principles in My Book"
tags: coding writing
---

Finding good bad examples is hard.

I've worked with ugly codebases that I don't want to revisit. But copying and pasting from them isn't a good idea. Apart from privacy issues, complex business rules and  convoluted code blocks make them unusable for tutorials or lessons.

A good bad example needs to be messy enough to teach from, but not so broken it confuses readers.

## Movies and TV are great teaching domains

Since we have all seen a good movie or gone to the cinema, I've shifted to movies and TV shows. They're familiar enough to use as examples.

In fact, for my book, [Street-Smart Coding]({% post_url 2025-09-21-30Ways %}), I chose a ticket pricing example that was clear but messy enough to teach a lesson.

Here it is:

```csharp
// Simple ticket price logic
float CalculatePrice(MovieTicketRequest request)
{
    var ticketBasePrice = 40f;

    if (request.Date.DayOfWeek == DayOfWeek.Saturday
        || request.Date.DayOfWeek == DayOfWeek.Sunday)
    {
        ticketBasePrice = 50f;
    }

    int reduction = 0;
    if (request.Date.DayOfWeek == DayOfWeek.Tuesday
        || request.Date.DayOfWeek == DayOfWeek.Wednesday)
    {
        reduction = 25;
    }

    if (request.Age < 10)
    {
        if (request.Date.DayOfWeek == DayOfWeek.Saturday
            || request.Date.DayOfWeek == DayOfWeek.Sunday)
        {
            ticketBasePrice /= 2;
        }

        var finalPriceChildren = ticketBasePrice * (1 - reduction / 100.0);
        return (float)Math.Ceiling(ticketBasePrice);
    }

    var finalPrice = ticketBasePrice * (1 - reduction / 100.0);
    return (float)Math.Ceiling(finalPrice);
}
```

A method that prices movie tickets by day and age. Simple enough to highlight common issues, like duplication and branching logic, but not so complex that I need to explain its business rules.

What would you refactor first? Can you spot the bug?
