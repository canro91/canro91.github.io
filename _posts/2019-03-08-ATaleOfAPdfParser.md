---
layout: post
title: Parsinator, a tale of a pdf parser
---

One day your boss asks you to read a pdf file to extract relevant information to later process it in your main software. What can you do now? How in the world are you going to read the pdf file?

## The Requirements

There you are, a normal day at your office with a new challenge. One of your clients can't connect to your main software, the only input he can provide is a text-based pdf file. This is the challenge: parse this pdf file into something that can be processed later on. But, these are the requirements:

* You can receive pdf files with any structure. Two clients won't have the same file structure.
* Eventually, you will receive not only pdf files, but any plain-text file
* You will have to build something easy to grap for your coworkers or your future self to maintain.
* You will have to ship it by the end of the week

## Actual implementation

Since you're asked to support files with any format, a `for` through the lines with lots of `if`s and regular expressions isn't the most adequate solution. A file with a different format will imply to code the whole thing again. There must be a better way!

On one hand, one of your concerns is how to given a pdf file turn it into actual text. But, a few lines with [itextsharp](https://github.com/itext/itextsharp) will do [the reading](https://stackoverflow.com/a/5003230). So, no big deal after all! Now, a pdf file is a list of lists of strings. One list per page and one string per line. You could abstract this step to support not only pdf files.

On the other hand, how can you do the actual parsing? Parser combinators to the rescue! You could borrow this idea from Haskell and other functional languages. You can create small composable pieces of code to extract or discard some text at the page or line level. 

First, you can assume that your file has some content that spawns from one page to another and some content that can be read from a given page. A header/detail representation.

Second, there are some lines you don't care about since they don't have any relevant information. So you can ignore them. For example, you can _"skip"_ the first or last lines in a page, all blank lines, everything between two line numbers or two regular expression. Then, you have the _skippers_.

```csharp
public class SkipLineCountFromStart : ISkip
{    
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

After ignoring all the unnecessary text, you can create separate little functions to extract text. For example, extract a line if it matches a regular expression, read all text between two consecutives line numbers or regexes, read a fixed string. Here, you have the _parsers_. Now, you can read text in a line of a page or use a default value if no text is found.

```csharp
public class ParseFromLineNumberWithRegex : IParse
{    
    // Parse if the given line matches a regex and
    // return the first matching group
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

But, what about the text spawning multiple lines? Now, you can introduce the _transformations_ to flatten all lines spawning multiple pages into a single stream of lines. So, you can use the same parsers in every single of these lines.

Finally, with this approach, you or any of your coworkers could reuse the same constructs to parse a new file or add new ones without coding the whole thing every time you are asked to support a new file.

PS: All these ideas and other suggestions from my coworkers gave birth to [Parsinator](https://github.com/canro91/Parsinator), a library to turn structured or unstructured text into a header-detail representation. Feel free to take a look at it. All ideas and contributions are more than welcome!

