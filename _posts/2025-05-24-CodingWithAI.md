---
layout: post
title: "5 Ways Copilot Helped Me Code Smarter This Week"
tags: misc
---

Rejecting AI is like rejecting calculators or computers.

It's here to stay and [we have to adapt]({% post_url 2025-01-21-AIAdaptation %}). That's why I always keeping an AI chat open, looking for ways to automate my work. Or maybe I'm just getting lazier as I get older.

This week, I tried Copilot (on the browser) to help me with some coding tasks. Here they are:

**#1. Translate a Visual Basic code block into C#.** I'm working with an old legacy WebForms app in Visual Basic these days. And being honest, I'm not in the mood for learning Visual Basic, so why not just translate it using AI? And as a form of exploratory refactoring, I gave it a large convoluted block of code and asked it to explain what it does and refactor it into smaller functions. And once I understood what it did, I threw away the refactored version. Sorry, Copilot!

**#2. Create a C# extension method from a code block.** Sometimes I'm just lazy as an excuse to test Copilot's capabilities.

**#3.** Naming is one of the most difficult tasks. **So why not ask Copilot for help to come up with descriptive names?** I gave Copilot a class definition, explained its purpose, and asked for a list of better names. I ended up choosing one of its options and got my PR approved.

**#4. Generate Builders for test data.** I gave it a sample [Builder class]({% post_url 2021-04-26-CreateTestValuesWithBuilders %}) and asked it to follow the same pattern but for some methods of a different class. Copilot nailed it.

**#5. Replicate tests from a sample test class.** While refactoring away from logic-heavy controllers to handlers, I gave it an existing handler and its tests. Then, after giving it the signature of my new handler, I asked Copilot to rewrite my controller tests as handler tests, following the pattern from the other handler tests and keeping my original assertions. Again, Copilot nailed this one.

And just for the record, I'm not using any fancy prompt, but this one,

> _"Act as a senior software engineer, with expert knowledge of the .NET stack, its libraries and ecosystem, and clean code. \<Explain task here>"_

I've found better results when I gave Copilot a sample class or code block to replicate. Think of AI as a fast junior engineer that needs clear and precise instructions. Otherwise, it takes a wild guess instead of asking for clarification.

Also as an experiment, I used [Copilot to launch a coding course]({% post_url 2024-03-18-AIToLaunchMyCourses %}). And once [I learned enough copywriting]({% post_url 2024-12-20-CopywritingStudyPlan %}), I revisited some of the marketing materials I generated with Copilot. And recently, I've been [using a prompt to replace Grammarly]({% post_url 2025-03-01-ReplacingGrammarly %}).
