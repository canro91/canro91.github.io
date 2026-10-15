---
layout: post
title: "A Day In The Life of A Random Coder: A Save Button And a Forward Slash Almost Ruined It"
tags: coding
---

After 3 months of work, today was the day to test a brand-new invoicing module for a hardware shop.

We're building a Blazor app to charge companies based on active users and license fees.\
By "we" means a team of contractors I'm part of.\
At the beginning of every month, the CEO creates invoices and charges cards manually.\
Zero automation.\
One by one.\
It takes him two or three days of work.\
Yes, in the 21st century.

Today, the CEO decided to compare his manual process to the new module.\
On the first attempt to charge a card, we got a "Not Found" response code from the payment gateway API.

It turns out, on Octopus Deploy, our CI/CD tool, the API url and credentials were missing.\
Someone added it by clicking "Add to the List" under the Project Variables.\
But they forgot to hit "Save."\
Adding to the list isn't the same as saving.\
Who would have known it?\
Arrgggg!!!

Fifteen minutes later, after a deployment, we got the same "Not Found" on the logs.\
This time, we forgot to append a "/" at the end of the API url on Octopus Deploy.

From `https://acoolapi/something/rest` to `https://acoolapi/something/rest/`.\
Noticed the subtle difference?

Well, it seems .NET built-in HttpClient's `SendAsync()` does a simple string manipulation to build urls.\
I wanted to [find the source code]({% post_url 2025-03-26-ReadCode %}) to check my assumption, but it was too late and [I'm lazy]({% post_url 2025-07-13-TheProblemWithAI %})—And this post is getting long.

I guess today I learned to hit Save and append slashes on urls.

_Even with AI, troubleshooting matters more than ever. [Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=day-life-random-coder-save-button-forward-slash-almost-ruined) shows you a roadmap with 30 lessons—troubleshooting is one of them—to help you build future-proof skills._


