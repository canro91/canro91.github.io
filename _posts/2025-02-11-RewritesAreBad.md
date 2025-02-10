---
layout: post
title: "Full Rewrites Are Bad But Be Ready For Them"
tags: misc
---

Rewriting legacy code that works isn't a good idea.

At some point in the rewrite, we have to maintain two systems. Fixing bugs in the legacy one while making sure they're fixed in the new one too.

These days, Antirez, Redis' creator, wrote in [We are destroying software](https://antirez.com/news/145):

> We are destroying software pushing for rewrites of things that work.

Rewrites are expensive and time-consuming. Every rewrite starts with good intentions, but they all end up being the next application to rewrite.

Interestingly enough, I've been involved in full rewrites at every job I've had.

At my first job, I had to rewrite a WebForms app into a WinForms app. That was the solution to a networking issue. By the time I left (actually, [I was fired]({% post_url 2025-01-14-BeingFired %})), there was an ongoing project to unify every separate department application into a single "unified" platform. Another rewrite.

At my second job, similar story. A WebForms app backed by 1,000-LOC stored procedures. We rewrote it using ASP.NET Web API with NHibernate. But, by the time the president (a coder in a past life) found out that NHibernate was slower, he ordered another rewrite. A rewrite in the middle of another rewrite. It took us around five years to finish the first prototype of a working app.

My next job rewrite was from Python jobs to background jobs with ASP.NET Core. The idea was to read a database table with price updates for rooms at a hotel and call the Expedia or Booking.com API. The challenge? We couldn't send two price updates for the same hotel at the same time. These days I'd [use Hangfire]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}) for that.

Next job? Rewriting a VisualBasic WebForm app into Blazor. Oh boy!

You see? Chances are you can't run away from rewrites and legacy code. And funny enough, "Working Effectively with Legacy Code" has been sitting in my to-read list all these years.
