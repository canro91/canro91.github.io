---
layout: post
title: <em>#BugOfTheDay</em> Back to the future, date and time with Newtonsoft.Json
---

QA team reported a bug. The display time of a operation in a web page is a couple of hours, even a day, after the actual time. What's wrong?

You inspect all the code trying to find a line where the date isn't properly parsed. But, at first glance, all seems right. Then, you ask for the log files. And all your suspictions boil down to deserialize a json to xml using `DeserializeXmlNode` of Newtonsoft.Json. You isolate the lines of code and there you are! The actual time zone of your date is changed!

```csharp
var document = @"{ ""date"": ""2019-07-09T19:52:58-05:00"" }";
var xml = JsonConvert.DeserializeXmlNode(document);
using (var sw = new StringWriter())
{
	xml.Save(sw);
	Console.WriteLine(sw.ToString());
}

// <?xml version="1.0" encoding="utf-16"?>
// <date>2019-07-10T00:52:58+00:00</date>
```

## Solution

After looking in StackOverflow and Newtonsoft.Json documentation, you find there is a way to change the default handling of dates, the `DateParseHandling` setting. You can use `DateParseHandling.None` to treat formatted date strings as raw strings and prevent any parsing. By default, this value is `DateParseHandling.DateTime`, so all date strings are parsed to `DateTime`.

But, wait! There isn't any overloaded method to pass a `JsonSetting`. Head to Github. The [`DeserializeXmlNode`](https://github.com/JamesNK/Newtonsoft.Json/blob/b371ab1b0e8f52ee2af83169ccd2506517bf1fcf/Src/Newtonsoft.Json/JsonConvert.cs#L971) method relies on `DeserializeObject` using a custom converter. And, you can pass a setting to the `DeserializeObject` with the date handling and the custom converter. Voilà!

```csharp
var document = @"{ ""date"": ""2019-07-09T19:52:58-05:00"" }";
var settings = new JsonSerializerSettings
{
	Converters = new List<JsonConverter>()
	{
		new XmlNodeConverter()
	},
 	DateParseHandling = DateParseHandling.None
};
var xml = JsonConvert.DeserializeObject<XmlDocument>(document, settings);
using (var sw = new StringWriter())
{
	xml.Save(sw);
	Console.WriteLine(sw.ToString());
}

//<?xml version="1.0" encoding="utf-16"?>
// <date>2019-07-09T19:52:58-05:00</date>
```