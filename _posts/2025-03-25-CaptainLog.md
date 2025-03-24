---
layout: post
title: "A Simple Script to Keep a Log File with Bash and Vim"
tags: productivity
---

To keep track of my client work, I've been using a simple "did" file. You know, [I'm a plain-text fan]({% post_url 2020-08-29-HowITakeNotes %}).

At the end of every workday, I write down what I did for that client and what I need to do the next working day.

Here's the script I use—add it to any of your dotfiles: 

```bash
function did() {
	vim +'normal Go' +'r! date "+\%Y-\%m-\%d \%H:\%M:\%S"' +'normal o' ~/did.txt
}
```

From a terminal, simply type `did`, and it opens a "did.txt" file with [Vim]({% post_url 2020-09-14-LearnVimForFunAndProfit %}), appends the current date and time at the end, and you're ready to type. Simple as that.

For everything apart from client work, [I've ditched my to-do lists]({% post_url 2025-01-11-DitchingTodos %}).
