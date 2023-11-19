---
layout: post
title: "TIL: How to declutter sites with uBlock Origin filters"
tags: todayilearned productivity
cover: Cover.png
cover-alt: "A tidy office desk" 
---

These days while procastinating on HackerNews, I found [this submission](https://news.ycombinator.com/item?id=37584134). It points to a [GitHub repo](https://github.com/mig4ng/ublock-origin-filters) with some uBlock Origin filters to clean up websites.

I learned that I not only can block elements in a page with uBlock Origin, but also restyle them. Ding, ding, ding! These are the uBlock Origin filters I'm using to declutter some site I visit often.

## 1. uBlock Origin filters to restyle elements

A uBlock Origin filter to restyle an element looks like this,

```
<domain>##<selector>:style(<new-css-here>)
```

Here are the filters I used to restyle HackYourNews and HackerNews,

```
hackyournews.com##body:style(width: 960px; margin: 0 auto;)
hackyournews.com##.title:style(font-size: 18pt !important;)
hackyournews.com##.ratings:style(font-size: 12pt !important;)
hackyournews.com##.subtext:style(font-size: 14pt !important;)

news.ycombinator.com###hnmain:style(background-color: #fdf6e3; width: 960px !important; margin: 0 auto !important;)
news.ycombinator.com##.rank:style(font-size: 14pt !important;)
news.ycombinator.com##.titleline:style(font-size: 16pt !important;)
news.ycombinator.com##.sitebit.comhead:style(font-size: 12pt !important;)
news.ycombinator.com##.subtext:style(font-size: 12pt !important;)
news.ycombinator.com##.spacer:style(height: 12px !important;)
news.ycombinator.com##.toptext:style(font-size: 12pt !important;)
news.ycombinator.com##.comment:style(font-size: 14pt !important;)
news.ycombinator.com##span.comhead:style(font-size: 12pt !important;)
news.ycombinator.com##.morelink:style(font-size: 14pt !important;)
```

## 2. How to install custom uBlock Origin filters in Brave

To install these filters in Brave, let's navigate to `brave://settings/shields/filters`, paste the filters, and hit "Save."

This is how HackerNews looked without my filters,

{% include image.html name="Before.png" alt="HackerNew front page" caption="HackerNews front page without any restyling" width="800px" %}

And this is how it looks after restyling it,

{% include image.html name="After.png" alt="HackerNew front page after restyling" caption="HackerNews front page with some uBlock Origin filters" width="800px" %}

I reduced the page width and increased font size for more readability.

For other sites, I install these extensions: [Modern Wiki](https://www.modernwiki.app/) to restyle Wikipedia, [StackOverflow Focus](https://github.com/elrumo/stackOverflow_focus), and [Distraction-Free YouTube](https://chromewebstore.google.com/detail/df-tube-distraction-free/mjdepdfccjgcndkmemponafgioodelna).

Voilà! That's how to use uBlock Origin filters to declutter websites. I like clean and minimalistic designs. Before learning about uBlock Origin filters, I started to dabble into browser extension development to restyle sites. With these filters, it's easier.

What site would you like to declutter with this trick?

For more productivity content, check [how to replace keywords in file with Bash]({% post_url 2022-12-10-ReplaceKeywordInFile %}), [how to rename C# project files with Git]({% post_url 2022-12-09-RenameProjectsVisualStudio %}), and [how to format SQL files with Git and Poor Man's T-SQL Formatter]({% post_url 2023-09-18-FormatSqlFilesOnCommit %}).

_Happy coding!_