---
layout: post
title: <em>#BugOfTheDay</em> Deserializing a json string, an horror debugging session
---

## Problem 

A typical day in the office: coping and pasting code from StackOverflow, waiting for the Continuous Integration pipeline to finish... All of a sudden, a json refuses to be deserialized into a class. A normal class annotated with `JsonProperty` attributes. Are you kidding me? The code looked like this:

```csharp
XmlDocument xmlDocument = new XmlDocument();
xmlDocument.LoadXml(document);

string jsonDocument = JsonConvert.SerializeXmlNode(xmlDocument, formatting: Formatting.Indented, omitRootObject: true);
var jsonDocumentContent = JsonConvert.DeserializeObject<ADocument>(jsonDocument);

public class ADocument
{
    public SubDocument SubDocument { get; set; }
}

public class SubDocument
{
    [JsonProperty("@Id")]
    public string Id { get; set; }
}
```

Nothing fancy. You fire the debugger to amuse yourself even more. The result: your instance is full of `null`'s and default values. Then, you take some of the lines to an online C# compiler. And, everything is working fine! Arrrgg!

## Solution

After almost one-hour debugging session, hypothesis come and go, you asked a coworker for help. Maybe, a couple of eyes more could catch the bug. He goes through the same steps. Simplify the input, create an isolated unit test and step into every method. No clue. Still `null`'s and defaults.

He is about to quit, looking down. In a final move, he asks you to go to the definition of the deserialize method. Then, you realize. You go back to your file. There it is, hidden among a bunch of `using`'s statements. 

```
using Exceptionless.Json;
```

Somebody resolved the missing `using` by hitting `Ctrl + .` and `Enter`. _Exceptionless instead of Newtonsoft.Json_. [Exceptionless client](https://github.com/exceptionless/Exceptionless.Net) uses its own version of Newtonsoft.Json

_The End_