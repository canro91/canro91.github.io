---
layout: post
title: TIL&colon; How to convert 2-digit year to 4-digit year in C#
tags: todayilearned csharp
---

Today I was working with credit cards and I needed to convert a 2-digit year in C#. The first thing that came to my mind was adding 2000 to it. But it didn't feel right. _It wouldn't be a problem in hundreds of years._

To convert 2-digit year into a 4-digit year, you can use the `ToFourDigitYear` method inside the `Calendar` class of the current culture.

```csharp
CultureInfo.CurrentCulture.Calendar.ToFourDigitYear(21)
// 2021
```

But, if you're working with a string containing a date, you can create a custom `CultureInfo` instance and set the maximum year to 2099. After that, you can parse the string holding the date with the custom culture. _Et voilà!_

```csharp
CultureInfo culture = new CultureInfo("en-US");
culture.Calendar.TwoDigitYearMax = 2099;

string dateString = "1 Jan 21";
DateTime.TryParse(dateString, culture, DateTimeStyles.None, out var result);
// true, 1/1/2021 12:00:00 AM
```

Sources: [Convert a two digit year](https://stackoverflow.com/questions/2024273/convert-a-two-digit-year-to-a-four-digit-year), [Parse string dates with two digit year](https://www.hanselman.com/blog/how-to-parse-string-dates-with-a-two-digit-year-and-split-on-the-right-century-in-c)
