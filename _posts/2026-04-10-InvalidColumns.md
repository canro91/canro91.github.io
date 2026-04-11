---
layout: post
title: "TIL: How to Read Invalid Fields as Null with CsvHelper"
tags: csharp todayilearned
---

_In another episode of [the Excel paradox of Coding]({% post_url 2026-03-28-ExcelParadox %})..._

**TL;DR**: To read an invalid field from a CSV file as `null` with CsvHelper, create a map class and use `Default()` with `useOnConversionFailure` set to `true` on the appropriate field.

## The cleanest approach

To honor [the 20-minute rule]({% post_url 2024-09-09-WritingIdeas %}) and [preserve my keystrokes]({% post_url 2024-11-09-LimitedKeystrokes %}), let's say we need to read a CSV file with CsvHelper. By default, it throws an exception when it fails to parse a column, for example when it finds text on a numeric column.

Here's how to read that invalid field as `null` instead of throwing an exception,

```csharp
using CsvHelper;
using CsvHelper.Configuration;
using System.Globalization;
using System.Text;

namespace TestProject1;

[TestClass]
public class CsvHelperTests
{
    private class MovieRating
    {
        public string Name { get; set; }
        public float? Rating { get; set; }
    }

    private sealed class MovieRatingMap : ClassMap<MovieRating>
    {
        public MovieRatingMap()
        {
            Map(m => m.Name);
            Map(m => m.Rating)
                .Default(defaultValue: default(float?),
                         useOnConversionFailure: true);
            //           ^^^^^
            // If the field is invalid, use the default value
        }
    }

    [TestMethod]
    public void NullWhenInvalidFloats()
    {
        var csv = new StringBuilder()
            .AppendLine("Name,Rating")
            .AppendLine("Inception,9.0")
            .AppendLine("Titanic,ThisIsNotAValidRating")  /* <-- */
            .ToString();

        using var reader = new StringReader(csv);
        using var csvReader = new CsvReader(reader, CultureInfo.InvariantCulture);
        csvReader.Context.RegisterClassMap<MovieRatingMap>();
        //                ^^^^^

        var records = csvReader.GetRecords<MovieRating>().ToList();

        Assert.AreEqual(2, records.Count);

        var last = records.Last();
        Assert.AreEqual("Titanic", last.Name);
        Assert.IsNull(last.Rating);
        //            ^^^^^
        // Look, ma! It's null
    }
}
```

The magic happens in `MovieRatingMap`. The `Rating` map uses `Default()` with `useOnConversionFailure` set to `true`.

## The manual approach

As an alternative, let's read the CSV file manually while processing the records as needed,

```csharp
[TestMethod]
public void ByHand()
{
	var csv = new StringBuilder()
		.AppendLine("Name,Rating")
		.AppendLine("Inception,9.0")
		.AppendLine("Titanic,ThisIsNotAValidRating")
		.ToString();

	using var reader = new StringReader(csv);
	using var csvReader = new CsvReader(reader, CultureInfo.InvariantCulture);
	csvReader.Context.RegisterClassMap<MovieRatingMap>();

	csvReader.Read();
	csvReader.ReadHeader();
	//        ^^^^^
	// Open the reader and read the header

	var records = new List<MovieRating>();
	while (csvReader.Read())
	//               ^^^^^
	// Read it by hand...
	{
		var name = csvReader.GetField<string>("Name");
		var rating = csvReader.GetField("Rating");
		//                     ^^^^^
		// Read the field as string...

		var parsedRating = !float.TryParse(rating, NumberStyles.Float, CultureInfo.InvariantCulture, out var parsed)
								? default(float?)
								: parsed;
		// Parse it as needed...

		records.Add(new MovieRating
		{
			Name = name,
			Rating = parsedRating
		});
	}

	Assert.AreEqual(2, records.Count);

	var last = records.Last();
	Assert.AreEqual("Titanic", last.Name);
	Assert.IsNull(last.Rating);
	//            ^^^^^
	// Look, ma! It's still null
}
```

A lot more work! We have full control, but it's less clean.

In case you're wondering, [I asked Copilot]({% post_url 2025-10-14-AIRule %}) about this but, with a straight face, it hallucinated suggesting a flag on `CsvConfiguration`, which didn't even exist.

For scenarios like this, you still need strong debugging and code reading skills. I cover those skills and more in _[Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding?utm_source=blog&utm_medium=post&utm_campaign=read-invalid-fields-null-csvhelper)_—A roadmap with 30 lessons to help you code like a pro.
