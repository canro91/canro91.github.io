---
layout: post
title: "TIL: How to color a website based on its URL. A visual aid and time saver"
tags: todayilearned productivity
cover: Cover.png
cover-alt: "Color pencils" 
---

These days, I spent a while debugging an issue. After a couple of minutes of scratching my head, I realized I was looking at log entries in the wrong environment. I know! A facepalm moment. I decided to look for a way to change the colors of a browser tab or a website based on the URL I visited. This is what I found.

## Coloring a website per URL

After a quick search, I found the [URLColors extension](https://github.com/fej-snikduj/URLColors) in GitHub. It adds an opaque rectangle on top of a website. We only need to configure a keyword for the URL and a hex color. Optionally, it can make the rectangle blink.

For example, this is how I colored Hacker News,

```
// <site>, <color>, <flash|no>, <timerInSeconds>, <border-width>, <opacity>
news.ycombinator.com, #b58900, no, 0, 10px, 0.5
```

I used this extension to color the OpenSearch dashboard and other websites I work with. I use the [Solarized theme](https://ethanschoonover.com/solarized/) and different color temperatures and rectangle width per environment.

This is what an OpenSearch dashboard looks like,

{% include image.html name="OpenSearchDashboard.png" alt="An OpenSearch dashboard with a red rectangle around it" caption="An OpenSearch dashboard for a non-development environment" width="400px" %}

I go with a red and thick rectangle that blinks for Production-related environments.

## Coloring Management Studio bar per connection string

I use a similar trick with SQL Server Management Studio. When connecting to a new server, under the "Options" button, we can change the color of the status bar,

{% include image.html name="SqlServerManagementStudio.png" alt="SQL Server Management Studio 'Use custom color' option" caption="SQL Server Management Studio 'Use custom color' option" width="400px" %}

Voilà! No more changes in the Production environment by mistake. No more time wasted looking at the wrong website. Colors are helpful for that.

Even we can change Visual Studio title bar color with the [SolutionColor extension](https://marketplace.visualstudio.com/items?itemName=Wumpf.SolutionColor).

For more productivity tricks, check [How to declutter sites with uBlock Origin filters]({% post_url 2023-11-13-DeclutteringUBlockOrigin %}) and [how to automatically format SQL files with Git]({% post_url 2023-09-18-FormatSqlFilesOnCommit %}).

_Happy coding!_