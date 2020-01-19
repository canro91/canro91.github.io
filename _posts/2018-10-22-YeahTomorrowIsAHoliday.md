---
layout: post
title: Yeah, tomorrow is a holiday
description: Is it a holiday today? How do add only working days to a date? An alternative to handle holidays and working days in C# using DateTimeExtensions
---

Have you ever had to add only working days to a given date? Or do you have to do it now? For example, users might have to confirm an action after a given number of working days.

After searching the Internet, you could end up with a table in your database with all the holidays of a year and a query to find the number of holidays between two dates. But, someone (Hi, future you!), sooner or later, will have to populate that table again. If you forget to do so, user reports or unexpected behavior will be in your email next day. There must be a better way!

Since, holidays can be calculated for every year, you don't need that table in place. Most of the time, holidays are celebrated in a fixed date, the next Monday or some days after or before Easter. Good news! [DateTimeExtensions](https://github.com/joaomatossilva/DateTimeExtensions) has already taken care of all these issues. You can add or subtract working days based on your localization. There are some cultures available out-of-the-box. DateTimeExtensions can be installed as a Nuget package.

Here you have an example of how to add holidays to a given date.

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
        
        // Add two days without holiday. Oct 15 is holiday in Colombia, for example
        var tuesdayAfterHoliday = fridayBeforeHoliday.AddWorkingDays(2, new WorkingDayCultureInfo("es-CO"));
        Console.WriteLine(tuesdayAfterHoliday);
    }
}
```

Finally, you got rid of that table and now you can add working holidays with a predefined mechanism. Also, you have in your toolbox other extensions methods to the `DateTime` and `DateTimeOffset` class thanks to **DateTimeExtensions**.





