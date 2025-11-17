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

In fact, for my book, _[Street-Smart Coding](https://imcsarag.gumroad.com/streetsmartcoding)_, I chose a ticket pricing example that was clear but messy enough to teach a lesson.

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

That code block makes you say "Whaaaat?!!?" in more than one place, but what would you refactor first? Can you spot the bug?

_Street-Smart Coding: 30 Ways to Get Better at Coding_ isn't exactly about clean code. It's a roadmap with 30 strategies to level up your coding skills. Writing code for humans is just one of them.

Because coding isn't simply typing symbols fast and mastering syntax. Real coding is also about clear communication, thoughtful problem-solving, and knowing when to say no—and 27 skills more that I cover in the book.

_[Get your copy of Street-Smart Coding here](https://imcsarag.gumroad.com/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=best-bad-example-teach-clean-code-principles)_


