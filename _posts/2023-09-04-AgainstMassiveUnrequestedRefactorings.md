---
layout: post
title: "A business case against massive unrequested refactorings"
tags: career
cover: Cover.png
cover-alt: "Stairs, paintings, and brushes" 
---

This isn't a tutorial or a refactoring session. Today, I'd like to share my thoughts about those massive unrequested refactorings we often think are worth the effort but end up with unwanted consequences.

## Two massive refactorings stories

### Changing entities and value objects

This first story happened to "a friend to a friend of mine." Wink, wink! As part of his task, some team-member decided to refactor the entire solution. The project was in its early stages. He changed every Domain Entity, [Value Object]({% post_url 2022-12-21-WhenToChooseValueObjects %}), and database table. Because what he found wasn't "scalable" in his experience. But the rest of the team was waiting for his task.

One week later, the team was still discussing names, [folder structure]({% post_url 2022-12-15-CreateProjectStructureWithDotNetCli %}), and the need for that refactoring in the first place. They all were blocked.

### Changing class and table names

And I haven't told you the story of "another friend of a friend of mine." His team's architect decided to work on a weekend. And the next thing he knew next Monday morning was that almost all class and table names were different. The team's architect decided to rename everything. He simply didn't like the initial naming conventions. Arrrggg!

These are two examples of massive unrequested refactorings. Nobody asked those guys to change anything in the first place. There was no need or business case for that in the first place.

<figure>
<img src="https://images.unsplash.com/photo-1634586648651-f1fb9ec10d90?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY4NDg3OTg0NA&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="A room with some tools in it" />

<figcaption>Another massive but unfinished refactoring...Photo by <a href="https://unsplash.com/@st_lehner?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Stefan Lehner</a> on <a href="https://unsplash.com/photos/biRt6RXejuk?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

## Need for refactoring

I'm not saying we shouldn't refactor things. I believe in the "leave the basecamp cleaner than the way you found it" mantra. But, before embarking on a massive refactoring, let's ask if it's really needed and if the team can afford it, not only in terms of money but time and dependencies.

Often we get too focused on [naming variables, functions, and classes]({% post_url 2022-12-07-BanningSomeNamingConventions %}) to see the bigger picture and the overall project in perspective. "Perfect is the enemy of good."

And if there isn't an alternative, let's split that massive refactoring into [separate, focused, and short PRs]({% post_url 2022-12-19-LessonsAsReviewer %}) that can be reviewed in a single review session without much back and forth.

**The best refactorings are the small ones that slowly and incrementally improve the health of the overall project. One step at a time. Not the massive unrequested ones.**

Voilà! That's my take on massive unrequested refactorings. Have you ever done one too? What impact did it had? Did it turn out well? I think all code we write should move the project closer to its finish line. Often, massive unrequested refactorings don't do that.

I can share another story of "another friend of mine." His team lead decided to remove exceptions and use Result classes instead because that wasn't "scalable." One week later, his team was still discussing things and commenting his PR. A few days after merging the refactoring PR, another team lead reverted everything back. Another massive unrequested refactoring.

Massive unrequested refactorings remind me of the analogy that [coding is like living in a house]({% post_url 2021-01-25-LivableCode %}). A massive unrequested refactoring would be like a full home renovation while staying there!

_Happy coding!_