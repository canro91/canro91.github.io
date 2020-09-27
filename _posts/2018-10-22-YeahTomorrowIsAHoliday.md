---
layout: post
title: Yeah, tomorrow is a holiday. Handle holidays in C# with DateTimeExtensions
description: Is it a holiday today? Do you need to add only working days to a date in C#? Learn how to handle holidays in C# with DateTimeExtensions
tags: tutorial showdev csharp
---

Do you need to add only working days to a date in C#? Do you need to check if a date is a holiday? Keep reading to learn how to handle holidays in C#.

You could have a database table with all the holidays in a year and a SQL query to find the holidays between two dates. But, someone (_Hi, future you!_), sooner or later, will have to populate that table again. If you forget to do so, your email will be full of bug reports the next day. _There must be a better way!_

Holidays can be calculated. You don't need a table in your database with every holiday. Most of the time, holidays are celebrated on a fixed date, the next Monday after the actual date or some days after or before Easter. [DateTimeExtensions](https://github.com/joaomatossilva/DateTimeExtensions) has already taken care of all these issues. _Good news!_

DateTimeExtensions helps you to

* check if a date is a holiday
* add working days to a date
* calculate working days between two dates excluding weekends and holidays

By default, DateTimeExtensions only ignores weekends. To knows about holidays, DateTimeExtensions uses cultures. There are some cultures available out-of-the-box. You can contribute adding your own culture if you can't find yours in the [list of available cultures](https://github.com/joaomatossilva/DateTimeExtensions#working-days-calculations).

First, you need to install DateTimeExtensions NuGet package. You can use the methods `AddWorkingDays`, `GetWorkingDays` and `IsHoliday` to work with holidays.

Here you have an example of how to add working days to a date in C#. This example uses the Colombian culture, `es-CO`, to ignore holidays.

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
        Console.WriteLine(withoutHoliday);
        
        // Add two days without weekends and holiday
        // For example, Oct 15th is holiday in Colombia
        var tuesdayAfterHoliday = fridayBeforeHoliday.AddWorkingDays(2, new WorkingDayCultureInfo("es-CO"));
        Console.WriteLine(tuesdayAfterHoliday);

        // Check if Oct 15 is holiday
        var holiday = new DateTime(2018, 10, 15);
        var isHoliday = holiday.IsHoliday(new WorkingDayCultureInfo("es-CO"));
        Console.WriteLine(isHoliday);
    }
}
```

Voila! That's how you can handle holidays in C# and avoid adding a table in your database with all holidays. DateTimeExtensions has also other useful extensions methods to the `DateTime` and `DateTimeOffset` classes.

> PS: I contributed to DateTimeExtensions adding support for holidays in Colombia. Do you want to contribute to an open source project? Add holidays for your country.

_Happy coding!_