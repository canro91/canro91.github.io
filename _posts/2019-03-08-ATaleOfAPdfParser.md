---
layout: post
title: Parsinator, a tale of a pdf parser
tags: tutorial showdev csharp
---

One day your boss asks you to read a pdf file to extract relevant information to later process it in your main software. That happened to me. My first thought was: "_how in the world am I going to read the text on the pdf file?"_ This is how I built Parsinator.

[Parsinator](https://github.com/canro91/Parsinator) is a library to turn structured and unstructured text into a header-detail representation. With Parsinator, you can create an xml file from a pdf file or an object from a printer spool file. I wrote Parsinator to parse invoices into xml files to feed a document API on an invoicing system.

## Requirements

There I was, a normal day at the office with a new challenge. One of our clients couldn't connect to our invoicing software. The only input he could provide was a text-based pdf file. This was the challenge: **parse a text-based pdf file into an xml**. These were the requirements:

* You can receive pdf files with any structure. Two clients won't have the same file structure.
* You will receive not only pdf files, but any plain-text file.
* You will have to build something easy to grasp for your coworkers or your future self to maintain.
* You will have to ship it by the end of the week. _Sounds familiar?_

## Actual implementation

To support files with any format, checking every line with regular expressions wasn't a good solution. A file with a different format would imply to code the whole thing again. _There must be a better way!_

One of my concerns was how to read the text from the  pdf file. But, after Googling a bit, I found the [iTextSharp pdf library](https://github.com/itext/itextsharp) and a StackOverflow answer to [read a text-based pdf file](https://stackoverflow.com/a/5003230). _No big deal after all!_

After using iTextSharp, a pdf file was a list of lists of strings, `List<List<string>>`. One list per page and one string per line. I abstracted this step to support any text, not only pdf files.

My next concern was how to do the actual parsing. I borrowed [Parser combinators](https://en.wikipedia.org/wiki/Parser_combinator) from [Haskell](https://www.haskell.org/) and other functional languages. With parsers combinators, I could create small composable functions to extract or discard text at the page or line level. 

### Skippers

First, I assumed that a file has some content that spawns from one page to another. Imagine an invoice with lots of purchased items that requires a couple of pages to print it. Also, I assumed that a file has some content at a given page and line. For example, the invoice number at the top-right corner of the first page.

Second, there were some lines I could ignore. For example, the legal notice at the bottom of the last page of an invoice. So, I needed to _"skip"_ the first or last lines in a page, all blank lines, everything between two line numbers or two regular expressions. To ignore text, I wrote **skippers**.

An skipper to ignore the first lines of every page looks like this:

```csharp
public class SkipLineCountFromStart : ISkip
{
    private readonly int LineCount;

    public SkipLineCountFromStart(int lineCount = 1)
    {
        this.LineCount = lineCount;
    }
            
    // The first LineCount lines are removed from the 
    // input text
    public List<List<string>> Skip(List<List<string>> lines)
    {
        var skipped = lines.Select(l => l.Skip(LineCount).ToList())
                           .ToList();
        return skipped;
    }
}
```

<figure>
<img src="https://images.unsplash.com/44/fN6hZMWqRHuFET5YoApH_StBalmainCoffee.jpg?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MXwxfDB8MXxhbGx8fHx8fHx8fA&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Parsinator, a tale of a pdf parser" />

<figcaption><span>Photo by <a href="https://unsplash.com/@carlijeen?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Carli Jeen</a> on <a href="https://unsplash.com/s/photos/receipt?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

### Parsers

After ignoring unnecessary text, I needed to create small functions to extract text. For example, a function to extract the lines between two  line numbers or regular expressions. I called these functions: **parsers**. With parsers, I could read text in a line of a page or use a default value.

A parser to read a line at a given number if it matches a regular expression looks like this:

```csharp
public class ParseFromLineNumberWithRegex : IParse
{
    private readonly string Key;
    private readonly int LineNumber;
    private readonly Regex Pattern;
        
    public ParseFromLineNumberWithRegex(string key, int lineNumber, Regex pattern)
    {
        this.Key = key;
        this.LineNumber = lineNumber;
        this.Pattern = pattern;
    }
        
    // Parse if the given line matches a regex and
    // returns the first matching group
    public IDictionary<String, String> Parse(String line, int lineNumber)
    {
        if (lineNumber == this.LineNumber)
        {
            var matches = this.Pattern.Match(line);
            if (matches.Success)
            {
                HasMatched = true;
                var value = matches.Groups[1].Value;
                return new Dictionary<string, string> { { Key, value.Trim() } };
            }
        }
        return new Dictionary<string, string>();
    }
}
```

### Transformations

But, what about the text spawning many pages? I came up with **transformations**. They flatten all lines spawning many pages into a single stream of lines.

In the invoice example, imagine it has a table with all purchased items spawning into two or more pages. The items table starts with a header and ends with a subtotal. You can use again some skippers to extract these items. And then, apply the same set of parsers in every line to find the item name, quantity and price.

The next snippet shows a transformation. It applies some skippers, one by one, to generate a single stream of text.

```csharp
public class TransformFromMultipleSkips : ITransform
{
    private readonly IList<ISkip> ToSkip;

    public TransformFromMultipleSkips(IList<ISkip> skippers)
    {
        ToSkip = skippers;
    }

    public List<string> Transform(List<List<string>> allPages)
    {
       // Chain applies the next skipper on the output of the previous one
        List<String> details = ToSkip.Chain(allPages)
                                     .SelectMany(t => t)
                                     .ToList();
        return details;
    }
}
```

Then, I could use the previous transformation to grab the purchased items of an invoice. 

```csharp
// Table starts with "Code Description Price Total"
// and ends with "S U B T O T A L"
new TransformFromMultipleSkips(
    new SkipBeforeRegexAndAfterRegex(
        before: new Regex(@"\|\s+Code\s+.+Total\s+\|"),
        after: new Regex(@"\|\s+\|\s+S U B T O T A L\s+\|")),
    new SkipBlankLines());
```

The previous snippet uses two skippers. One to ignore everything before and after two regular expressions. And another to ignore blank lines. 

### All the pieces

Then, I created a method put everything in place. It applied all **skippers** in every page to keep only the relevant information. After that, it run all **parsers** in the appropriate pages and lines from the output of **skippers**.

```csharp
public Dictionary<string, Dictionary<string, string>> Parse(List<List<String>> lines)
{
    List<List<String>> pages = _headerSkipers.Chain(lines);

    foreach (var page in pages.Select((Content, Number) => new { Number, Content }))
    {
        var parsers = FindPasersForPage(_headerParsers, page.Number, lines.Count);
        if (parsers.Any())
            ParseOnceInPage(parsers, page.Content);
    }

    if (_detailParsers != null && _detailParsers.Any())
    {
        List<String> details = (_transform != null)
                ? _transform.Transform(pages)
                : pages.SelectMany(t => t).ToList();

        ParseInEveryLine(_detailParsers, details);
    }

    return _output;
}
```

## Conclusion

Voilà! That's how I came up with Parsinator. With this approach, you can parse new files without coding the whole thing every time you need to support a new one. You need to reuse the right skippers and parsers based on the structure of the new file.

I used Parsinator to connect 4 legacy client softwares to a document API on an invoicing software by parsing pdfs and plain text files to input xml files. In the [Sample project](https://github.com/canro91/Parsinator/tree/master/Parsinator.Sample) you can see how to parse a plain-text invoice and a GPS frame. Feel free to take a look at it.

All ideas and contributions are more than welcome!

[![canro91/parsinator - GitHub](https://gh-card.dev/repos/canro91/parsinator.svg)](https://github.com/canro91/parsinator)
