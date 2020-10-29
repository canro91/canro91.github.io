---
layout: post
title: Parsinator, a tale of a pdf parser
tags: tutorial showdev csharp
---

One day your boss asks you to read a pdf file to extract relevant information to later process it in your main software. What are you going to do now? How in the world are you going to read the pdf file?

## Requirements

There you are, a normal day at your office with a new challenge. One of your clients can't connect to your main software. The only input he can provide is a text-based pdf file. This is the challenge: parse this pdf file into something that can be processed later on. But, these are the requirements:

* You can receive pdf files with any structure. Two clients won't have the same file structure.
* Eventually, you will receive not only pdf files, but any plain-text file.
* You will have to build something easy to grasp for your coworkers or your future self to maintain.
* You will have to ship it by the end of the week.

## Actual implementation

Since you're asked to support files with any format, a `for` through the lines with lots of `if`s and regular expressions isn't the most adequate solution. A file with a different format will imply to code the whole thing again. _There must be a better way!_

On one hand, one of your concerns is how to given a pdf file turn it into actual text. But, a few lines using [itextsharp pdf library](https://github.com/itext/itextsharp) will do [the reading](https://stackoverflow.com/a/5003230). So, no big deal after all! Now, a pdf file is a list of lists of strings, `List<List<string>>`. One list per page and one string per line. You could abstract this step to support not only pdf files.

On the other hand, how can you do the actual parsing? [Parser combinators](https://en.wikipedia.org/wiki/Parser_combinator) to the rescue! You could borrow this idea from [Haskell](https://www.haskell.org/) and other functional languages. You can create small composable pieces of code to extract or discard some text at the page or line level. 

### Skippers

First, you can assume that your file has some content that spawns from one page to another. Also, there is some content that can be read from a given page and line. A header/detail representation. Imagine an invoice with lots of purchased items that requires a couple of pages.

Second, there are some lines you don't care about. Since they don't have any relevant information to extract. So you can ignore them. For example, you can _"skip"_ the first or last lines in a page, all blank lines, everything between two line numbers or two regular expressions. Then, you have the **skippers**.

An skipper to ignore the first lines of every page will look like this:

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

### Parsers

After ignoring all the unnecessary text, you can create separate small functions to extract text. For example, extract a line if it matches a regular expression, read all text between two consecutive line numbers or regular expressions. Here, you have the **parsers**. Now, you can read text in a line of a page or use a default value if there isn't any.

A parser to read a line at a given number if it matches a regular expression will look like this:

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

But, what about the text spawning many pages? Now, you can introduce the **transformations**. They flatten all lines spawning many pages into a single stream of lines. So, you can use the same parsers in every one of these lines.

For example, imagine an invoice with all purchased items organize in a table. This table can spawn into two or more pages. The items table starts with a header and ends with the subtotal of all purchased items. You can use again some skippers to extract these items between the header and the subtotal.

The next snippet shows a transformation that composes some skippers and applies them one by one to generate a single stream of text.

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

Then, you can use the previous transformation to grab the purchased items of an invoice. The next snippet uses two skippers. One to ignore everything before and after two regular expressions. And another to ignore blank lines.

```csharp
// Table starts with "Code Description Price Total"
// and ends with "S U B T O T A L"
new TransformFromMultipleSkips(
    new SkipBeforeRegexAndAfterRegex(
        before: new Regex(@"\|\s+Code\s+.+Total\s+\|"),
        after: new Regex(@"\|\s+\|\s+S U B T O T A L\s+\|")),
    new SkipBlankLines());
```

### All the pieces

Then, you can create a method put everything in place. You apply all **skippers** in every page to keep relevant only the information. After that, you run all **parsers** in the appropriate pages and lines from the output of **skippers**.

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

Finally, with this approach, you or any of your coworkers could reuse the same constructs to parse a new file. You can add new files without coding the whole thing every time you are asked to support a new file. You need to come up with the right skippers and parsers based on the structure of the new file.

> PS: All these ideas and other suggestions from my coworkers gave birth to [Parsinator](https://github.com/canro91/Parsinator), a library to turn structured or unstructured text into a header-detail representation.
>
> I used Parsinator to connect 4 legacy client softwares to a document API by parsing pdfs and plain text files to input xml files. In the [Sample project](https://github.com/canro91/Parsinator/tree/master/Parsinator.Sample) you can see how to parse a plain-text invoice and a GPS frame. Feel free to take a look at it.
>
> All ideas and contributions are more than welcome!

[![canro91/parsinator - GitHub](https://gh-card.dev/repos/canro91/parsinator.svg)](https://github.com/canro91/parsinator)