---
layout: post
title: How to handle holidays in C# with DateTimeExtensions
description: Is it a holiday today? Do you need to add only working days to a date in C#? Learn how to handle holidays in C# with DateTimeExtensions
tags: tutorial showdev csharp
---

Do you need to add only working days to a date in C#? Do you need to check if a date is a holiday? This is how to handle holidays in C# with DateTimeExtensions.

## Don't store holidays on the database

We could have a table in our database with all the holidays in a year and a SQL query to find the holidays between two dates. But, sooner or later we will have to populate that table again. Anyone can forget to do so! Or we will only will do it when it's too late. There must be a better way!

We can calculate holidays. We don't need a table in our database with every holiday. Most of the time, we celebrate holidays on a fixed date, the next Monday after the actual date or some days after or before Easter.

<figure>
<img src="https://images.unsplash.com/photo-1488345979593-09db0f85545f?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYzMTMzMjU5OQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Endless water" />

<figcaption>Cabo San Lucas, Mexico. Photo by <a href="https://unsplash.com/@alexbertha?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Alex Bertha</a> on <a href="https://unsplash.com/s/photos/holiday?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## DateTimeExtensions

[DateTimeExtensions](https://github.com/joaomatossilva/DateTimeExtensions) has already taken care of handling holidays for us. Good news!

DateTimeExtensions helps us to

* check if a date is a holiday
* add working days to a date
* calculate working days between two dates excluding weekends and holidays

By default, DateTimeExtensions only ignores weekends. To know about holidays, DateTimeExtensions uses cultures. DateTimeExtensions has a [list of available cultures](https://github.com/joaomatossilva/DateTimeExtensions#working-days-calculations).

### How to add working days to a date in C# 

First, let's install the `DateTimeExtensions` NuGet package. We can use the methods `AddWorkingDays()`, `GetWorkingDays()` and `IsHoliday()` to work with holidays.

This is how to add working days to a date in C#.

```csharp
using System;
using DateTimeExtensions;
using DateTimeExtensions.WorkingDays;
                    
public class Program
{
    public static void Main()
    {
        var fridayBeforeHoliday = new DateTime(2018, 10, 12);
        
        // Add two days including Saturday and Sunday
        var plusTwoDays = fridayBeforeHoliday.AddDays(2);
        Console.WriteLine(plusTwoDays);
        
        // Add two days without Saturdays and Sundays
        var withoutHoliday = fridayBeforeHoliday.AddWorkingDays(2);
        //                                       ^^^^^
        Console.WriteLine(withoutHoliday);
        
        // Add two days without weekends and holidays
        // For example, Oct 15th is holiday in Colombia
        var tuesdayAfterHoliday = fridayBeforeHoliday.AddWorkingDays(2, new WorkingDayCultureInfo("es-CO"));
        //                                            ^^^^^
        Console.WriteLine(tuesdayAfterHoliday);

        // Check if Oct 15 is holiday
        var holiday = new DateTime(2018, 10, 15);
        var isHoliday = holiday.IsHoliday(new WorkingDayCultureInfo("es-CO"));
        //                      ^^^^^
        Console.WriteLine(isHoliday);
    }
}
```

Notice, `AddDays()` doesn't take into account weekends or holidays. And, by default, DateTimeExtensions `AddWorkingDays()` only ignores weekends.

To ignore holidays, we need to pass a culture to `AddWorkingDays()`. In our previous example, we used the Colombian culture, `es-CO`, to ignore holidays.

Voilà! That's how you can handle holidays in C# and avoid adding a table in your database with all holidays. DateTimeExtensions has also other useful extensions methods to the `DateTime` and `DateTimeOffset` classes.

I contributed to DateTimeExtensions adding support for holidays in Colombia. Do you want to contribute to an open source project? Add holidays for your own country!

If you want to read more content, check [my C# Definitive Guide]({% post_url 2018-11-17-TheC#DefinitiveGuide %}) with the subjects every intermediate C# developer should know and [my quick guide to LINQ]({% post_url 2021-01-18-LinqGuide %}) with all you need to know about LINQ in 15 minutes or less.

_Happy coding!_