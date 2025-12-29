---
layout: post
title: "Senior C# Dev Reacts to Reddit's /csharp (Hot Takes Only)"
tags: csharp coding
---

I didn't have writer's block today. Naaah! I was just scrolling down the /csharp subreddit for inspiration.

Scrolling through, I realized I had answers and reactions. And to follow the popular YouTube format, here I go reacting/roasting/responding to the front page of /csharp:

{% include image.html name="ReactingToCSharp.gif" width="800px" alt="Reddit r/csharp front page" caption="Reddit r/csharp front page" %}

**#1. I wrote a cross-platform TUI podcast player in .NET 9 (mpv / VLC / native engine fallback)** [Source](https://www.reddit.com/r/csharp/comments/1oocaue/i_wrote_a_crossplatform_tui_podcast_player_in_net/)

Great! Put it on your portfolio.

**#2. Best approach for background or async tasks** [Source](https://www.reddit.com/r/csharp/comments/1oof2ol/best_approach_for_background_or_async_tasks/)

Mmm. Probably that's Hangfire.

> _Hi._
> _In my last project, I had:_
> _1 Api for backoffice_
> _1 Api for app mobile_
> _1 Worker Service for all the background tasks_
> _..._
> _So now I'm in new project, but I'm not sure if is necessary use Masstransit with RabbitMQ? Maybe channels? I mean, I want to keep it simple, but I don't like put consumers or jobs in the same API, I always prefer to have a worker service dedicated to all asynchronous tasks._

Hangfire?! [That's definitely Hangfire]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}). I don't need to read more. And you don't need to look for anything else.

**#3. Is conciseness always preferred? (Linq vs Loops)** [Source](https://www.reddit.com/r/csharp/comments/1oojxzu/is_conciseness_always_preferred_linq_vs_loops/)

Not that [I have a course about it](https://www.udemy.com/course/getting-started-with-linq-in-csharp/?referralCode=1B94DF2F5439E06B6397), but LINQ is the best of all C# features. Yes, write a LINQ query first. Then, if you're working on a high-performance scenario, go with loops.

**#4. Can you explain result of this code?** [Source](https://www.reddit.com/r/csharp/comments/1omgwoq/can_you_explain_result_of_this_code/)

Nah! I have a post to write. Ask ChatGPT or Copilot. It's free.

But seriously, it's a good exercise. Try debugging it yourself before asking.

**#5. Let's Talk About the Helper Classes: Smell or Solution?** [Source](https://www.reddit.com/r/csharp/comments/1onm2to/lets_talk_about_the_helper_classes_smell_or/)

Definitely a smell. Helper classes attract plenty of methods. "Where do I put this new method? Oh there's a Helper class over there! I'm putting it there..."

If you're tempted to [write a Helper class]({% post_url 2025-05-15-Helpers %}), hold your horses.

**#6. In general is it normal to have more than 2k lines in a file?** [Source](https://www.reddit.com/r/csharp/comments/1o87dfk/in_general_is_it_normal_to_have_more_than_2k/)

You shouldn't have one. But yes, it's normal.

***

_Scroll...scroll..._

_Nah! Boring! Scroll...scroll..._

***

**#7. After seeing that LOC post, can anyone beat this?** [Source](https://www.reddit.com/r/csharp/comments/1o88of3/after_seeing_that_loc_post_can_anyone_beat_this/)

Really?! Like, c'mon. We're seeing who has a larger file?!

The other day, I shared that you know you're in trouble when you try to open a file on GitHub and it says _"(Sorry about that, but we can’t show files that are this big right now.)"_ Spoiler alert: The file has 69,923 and it's called `GlobalFunctions.vb`.

You see? Helpers!

**#8. Is C# good for beginners?** [Source](https://www.reddit.com/r/csharp/comments/1ol9bm6/is_c_good_for_beginners/)

Hell, yes!

**#9. Why is this issue only popping up at the 30 line?** [Source](https://www.reddit.com/r/csharp/comments/1olsn8k/why_is_this_issue_only_popping_up_at_the_30_line/)

Dunno! See #4.

**#10. Career Guidance: .NET Backend Developer Role and Future Tech Stack Transition** [Source](https://www.reddit.com/r/csharp/comments/1on4i25/career_guidance_net_backend_developer_role_and/)

> _"Blah...blah...blah... I've accepted the offer, but I sometimes question whether choosing the .NET path was the right decision. I'd like to understand the current job market for .NET developers."_

Hey, buddy! We're in a bubble that is popping (or about to pop) now. In 2020-2021, "Software Engineer" on LinkedIn meant a line of recruiters with "life-changing opportunities."

These days? Just look at the headlines. Amazon just "let go" thousands of employees in the past weeks. And that was right after an outage that took down pretty much every client. That's for every stack, unless you have "AI" anywhere in your title.

OK, let's call it a day! That's enough roasting for today. I should be writing a YouTube script, but I don't have a channel. Just a blog...and a book. Speaking of which...

_This post is brought to you by..._ Check out my latest book, _Street-Smart Coding: 30 Ways to Get Better at Coding_. It's not a C# textbook. It's the roadmap I wish I had on my journey from junior/mid-level to senior. Some lessons are conventional. Others not so much. From Googling to debugging to clear communication.

_[Get your copy of Street-Smart Coding here](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=senior-c-dev-reacts-reddits-csharp)_

***

PS: In case you didn't notice, this was half-joking. And yes, I'm promoting my book.
