---
layout: post
title: "Stop Optimizing for Scale—Most Apps Don't Need It"
tags: misc
---

In [my Friday Links email](https://fridaylinks.beehiiv.com/subscribe) yesterday, I shared one post called [Programming Myths We Desperately Need to Retire](https://amritpandey.io/programming-myths-we-desperately-need-to-retire/).

Myth #5, "Let's optimize for scale," resonated a lot with me:

> _Most products never reach the scale you're "preparing" for. And even if they do, you'll have time—and budget—to refactor later._

Oh boy! Been there and done that.

At a past job, while working on a hotel management solution, we had to connect the reservation module to a third-party restaurant solution. The goal was for guests to pay their restaurant bills along with their hotel bills.

We were about six software engineers plus the QA team. We worked to make that solution scale to thousands of guests and restaurant orders. We built an eventually consistent solution with [background processors using Hangfire]({% post_url 2022-12-06-BackgroundServicesAndLiteHangfire %}), [Domain-Driven Design]({% post_url 2025-03-16-DDDIsNotAboutEntities %}), and all the best practices you can imagine. 

There's nothing wrong with that. The problem? When we finished our module and handed it off to the Product people. Nobody bought it. Six months of work...wasted.

The Product team only had a few leads when they pitched the idea to the Engineering team. But those leads weren't going to wait six months for our integration. Or maybe the Product team wanted to list a new feature on the webpage so they could compare the product to the competitors. And after all that time optimizing for scale? Nobody bought it.
