---
layout: post
title: Parsinator, a tale of a pdf parser
tags: tutorial showdev csharp
cover: Parsinator.png
cover-alt: Parsinator, a tale of a pdf parser
---

Imagine one day, your boss asks you to read a pdf file to extract relevant information and build a request for your main API. That happened to me. My first thought was: "_how in the world am I going to read the text on the pdf file?"_ This is how I built Parsinator.

[Parsinator](https://github.com/canro91/parsinator) is a library to turn structured and unstructured text into a header-detail representation. With Parsinator, we can create an XML file from a text-based pdf file or a C# object from a printer spool file.

I wrote Parsinator to parse invoices into XML files and then to call a documents API on an invoicing system.

## Requirements

There I was, another day at the office with a new challenge. One of our clients couldn't connect to our invoicing software. The only input he could provide was a text-based pdf file. This was the challenge: **parse a text-based pdf file into an XML file**.

These were the requirements:

* I could receive pdf files with any structure. Two clients won't have the same file structure.
* I will receive not only pdf files but any plain-text file.
* I needed to build something easy to grasp for my coworkers or future self to maintain.
* I will have to ship it by the end of the week. Sounds familiar?

## Actual implementation

I couldn't use regular expressions on every line of the input text. That wasn't a good solution. Every new file would imply coding the whole thing again. Arrrggg!

One of my concerns was extracting the text from a pdf file. But, after Googling a bit, I found the [iTextSharp library](https://github.com/itext/itextsharp) and a StackOverflow answer to [read a text-based pdf file](https://stackoverflow.com/a/5003230). No big deal after all!

After using iTextSharp, a pdf file was a list of lists of strings, `List<List<string>>`. One list per page and one string per line. I abstracted this step to support any text, not only pdf files.

My next concern was how to do the actual parsing. I borrowed [Parser combinators](https://en.wikipedia.org/wiki/Parser_combinator) from [Haskell](https://www.haskell.org/) and other functional languages. I could create small composable functions to extract or discard text at the page or line level. 

### Skippers

First, I assumed that a file has some content that spawns from one page to another. Imagine an invoice with many purchased items that we need  a couple of pages to print it. Also, I assumed that a file has some content on a particular page and line. For example, the invoice number is at the top-right corner of the first page.

Second, there were some lines I could ignore. For example, the legal notice at the bottom of the last page of an invoice. I needed to _"skip"_ the first or last lines on a page, all blank lines, and everything between two line numbers or regular expressions. To ignore some text, I wrote **skippers**.

This is [SkipLineCountFromStart](https://github.com/canro91/Parsinator/blob/master/Parsinator/Skippers/SkipLineCountFromStart.cs), a skipper to ignore the first lines of every page:

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

After ignoring unnecessary text, I needed some functions to extract the text between two lines or regular expressions. I called these functions: **parsers**.

This is [ParseFromLineNumberWithRegex](https://github.com/canro91/Parsinator/blob/master/Parsinator/Parsers/ParseFromLineNumberWithRegex.cs), a parser to read a line at a given number if it matches a regular expression:

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
    public IDictionary<string, string> Parse(string line, int lineNumber)
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

But what about the text spawning many pages? I came up with **transformations**. Well I almost named them "Transformers," but I didn't want to confuse them with the giant robots from the movies... Transformations flatten all lines spawning many pages into a single stream of lines.

Imagine an invoice with a table of all purchased items spawning into two or more pages. The items table starts with a header and ends with a subtotal. I could use some skippers to extract these items. Then, I could apply parsers in every line to find the item name, quantity, and price.

This is [TransformFromMultipleSkips](https://github.com/canro91/Parsinator/blob/master/Parsinator/Transformations/TransformFromMultipleSkips.cs), a transformation that applies some skippers to generate a single stream of text:

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

This is how I could use the previous transformation to grab the purchased items of an invoice: 

```csharp
// Table starts with "Code Description Price Total"
// and ends with "S U B T O T A L"
new TransformFromMultipleSkips(
    new SkipBeforeRegexAndAfterRegex(
        before: new Regex(@"\|\s+Code\s+.+Total\s+\|"),
        after: new Regex(@"\|\s+\|\s+S U B T O T A L\s+\|")),
    new SkipBlankLines());
```

I used two skippers: one to ignore everything before and after two regular expressions and another to ignore blank lines. 

### All the pieces

Then, I created a method to put everything in place. It applied all **skippers** on every page to ignore the irrelevant text. After that, it runs all **parsers** in the appropriate pages and lines from the output of **skippers**.

This is the [Parse](https://github.com/canro91/Parsinator/blob/master/Parsinator/Parser.cs#L33) method:

```csharp
public Dictionary<string, Dictionary<string, string>> Parse(List<List<string>> lines)
{
    List<List<string>> pages = _headerSkipers.Chain(lines);

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

Voilà! That's how I came up with Parsinator. With this approach, I could parse new files without coding the whole thing every time I needed to support a new file structure. I only needed to reuse the right skippers and parsers.

I used Parsinator to connect 4 clients with legacy software to an invoicing software by parsing pdf and plain text files to input XML files.

In the [Sample project](https://github.com/canro91/Parsinator/tree/master/Parsinator.Sample), I wrote tests to parse a plain-text invoice and a GPS frame. Feel free to take a look at it.

All ideas and contributions are more than welcome!

[![canro91/parsinator - GitHub](https://gh-card.dev/repos/canro91/parsinator.svg)](https://github.com/canro91/parsinator)