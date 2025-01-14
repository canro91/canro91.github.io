---
layout: post
title: "Monday Links: Notebooks, Learning, and KPIs"
tags: mondaylinks
cover: Cover.png
cover-alt: "A pile of folded newspapers on a desktop"
---

Five interesting reads from the past month.

## Lab Notebooks

I like the idea of keeping "lab" notebooks, especially to record the thought process for consulting clients. I'm a big fan of plain text. But the article recommends using pen and paper. 

[Read full article](https://sambleckley.com/writing/lab-notebooks.html)

## Git Things

Git and Version Control are one of the subjects we have to learn ourselves. I prefer [short Pull Requests]({% post_url 2022-12-19-LessonsAsReviewer %}) with only one or two commits. I name my commits with a long and descriptive title that becomes a good title on PR descriptions.

This article shows "tactics" to better use Git. I really like these two:

1. start by writing the commit message before the actual work and then amending it. Commit Message Driven Development I guess, to follow the XDD trend
2. splitting refactorings into two commits: changing the API and then changing the calling sites

[Read full article](https://matklad.github.io/2023/12/31/git-things.html#Git-Things)

<figure>
<img src="https://images.unsplash.com/photo-1581342997365-9e7cadb47edb?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTcwNDkwNzM5Ng&ixlib=rb-4.0.3&q=80&w=600" alt="Teacher and student sitting on a chair">

<figcaption>It's never too late to learn about learning...Photo by <a href="https://unsplash.com/@bostonpubliclibrary?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Boston Public Library</a> on <a href="https://unsplash.com/photos/man-and-woman-sitting-on-chair-pfyd9cSH5Ac?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a></figcaption>
</figure>

## 10 Things Software Developers Should Learn about Learning

This article contains ten findings, backed by research, about learning and software engineering. Totally worth reading if you're into learning about learning.

These are some of my favorite lessons:

* "Expert programmers may have low or high working memory capacity but it is the contents of their long-term memory that make them experts."
* "Expert developers can reason at a higher level by having memorized (usually implicitly, from experience) common patterns in program code, which frees up their cognition."
* "The brain needs rest to consolidate the new information that has been processed so that it can be applied to new problems."
* "There is a key distinction between a beginner who has never learned the details and thus lacks the memory connections, and an expert who has learned the deeper structure but searches for the forgotten fine details."
* "There is no reliable correspondence between problem-solving in the world of brain teasers and problem-solving in the world of programming. If you want to judge programming ability, assess programming ability."

If you don't want to read the whole article, jump to the Summary section at the end.

[Read full article](https://cacm.acm.org/magazines/2024/1/278891-10-things-software-developers-should-learn-about-learning/fulltext)

## Why Most Software Engineering KPIs are BS and What to Do About it in 2024

Does your team measure story points too? The truth is we don't know how to measure our work. I worked with a company that measured the percentage of completed tasks. It was a killing pressure. And once we have a metric, we start to game it. On the last day of the sprint, we saw people removing tasks so as not to mess with the final percentage.

From the article: _"Engineering leaders (and sometimes non-technical executives) have often made the poor choice to measure output rather than impact"_. The author recommends: _"separate engineering health metrics to KPIs."_ This is how the team feels vs the business impact of the work done.

[Read full article](https://jamesyorston.co.uk/articles/most_engineering_kpis_are_bs)

## 27 Years Ago, Steve Jobs Said the Best Employees Focus on Content, Not Process.

This article tells Steve Jobs's opinion on office politics and bureaucracy and how often we think "paperwork" is the real work. Process vs Output. Also, this article shares how to keep the best team members around, those who are good at identifying the output.

From the article: _"Success is rarely based solely on process. Success mostly comes down to what your business accomplishes."_

Voilà! What are the KPIs of your team? Do you measure story points or percentage of completed vs planned tasks? Until next Monday Links.

{%include monday_links.html %}

_Happy coding!_