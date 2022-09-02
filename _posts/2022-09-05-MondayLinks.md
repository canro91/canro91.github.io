---
layout: post
title: "Monday Links: Time zones and NDC Conference"
tags: mondaylinks
cover: Cover.png
cover-alt: "A pile of folded newspapers on a desktop"
---

Last month I followed the NDC Conference on YouTube. In this Monday Links episode, I share some of the conferences I watched and liked. I don't know why but I watched presentations about failures, aviation disasters, and software mistakes. Well, two of the 5 links aren't about that. Enjoy!

## Improve working across time zones

Prefer document-based over meeting-based documentation. Only schedule meetings for discussions and have a clear agenda for everyone to review before the meeting. After the meeting, share the conclusions with people in different time zones who couldn't join. [Read full article](https://askwhy.substack.com/p/improve-working-across-time-zones)

## Mayday! Software lessons from aviation disasters

This is a conference from NDC. It shows two case studies from aviation disasters and how they relate to software engineering. For the first case study, after an incident, a security expert asked his team these questions to identify the cause of the incident:

* How can I prove myself wrong?
* What details might I be ignoring because it doesn't fit my theory or solution?
* What else could cause this issue or situation?

Experts traced the root of the incident ten years before the crash: counterfeit parts. This makes us wonder about counterfeit code: code we copy from StackOverflow, blogs, and documentation. We're responsible for every line of code we write, even for the ones we copy and paste.

The second case study teaches us some good lessons about communication.

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/_oPzRQExVvM?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

## Failure is Always an Option

From space accidents to the British Post Office to a Kenya money transfer company, this talk shows how new businesses and branches of Science come out of failures and unanticipated usages of systems. Inspired by and contradicting one line in the Apollo 13 movie, "Failure is not an option."

This talk claims that the single point of failure of modern cloud-based solutions is the credit card paying the cloud provider. LOL!

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/Av3QP940L2c?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

## Hacking C#: Development for the Truly Lazy

This talk shows a bag of tricks to make code more readable. It shows how to use C# extension methods to remove duplication. Also, it presents the "Commandments of Extension Methods:"

* No business logic
* Keep them as small as possible
* Keep them generic, so you can use them with any object
* Keep them portable
* Use them where there is boring and repetitive code
* Make them useful

Ah! I learned we can make indexers receive multiple indexes. Like `something[1, 3, 5]`.

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/0ial6pfgV9g?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

## Programming's Greatest Mistakes

I had a coworker that always said: "Nobody is going to die," when somebody else was reluctant to change some code. It turned out we weren't working on a medical or aerospatial domain. But often, oops cause businesses to lose money. I bet you have taken down servers because of an unoptimized SQL query. That happened to a friend of a friend of mine. Wink, wink!

It starts by showing one stupid mistake the author made in his early days using a sarcastic name for one of his support tools. The support team ended up shipping it to their clients. Y2K, a missing `using` in a mission-critical software, null, and other mistakes.

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/qC_ioJQpv4E?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

Voilà! Do you also follow the NDC Conference? What are your own programming's greatest mistakes? Don't be ashamed. All of us have one. Until next Monday Links!

In the meantime, check my [Getting Started with LINQ course](https://www.educative.io/courses/getting-started-linq-c-sharp) where I cover from what LINQ is to its most recent methods and overloads introduced in .NET6. And don't miss the previous [Monday Links on Storytelling, Leet Code, and Boredom]({% post_url 2022-08-01-MondayLinks %}).

_Happy coding!_