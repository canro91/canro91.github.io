---
layout: post
title: "TIL: Go to the previous branch in Git"
tags: todayilearned git
---

In the same spirit of `cd -`, starting from [Git v 1.6.2](https://github.com/git/git/blob/master/Documentation/RelNotes/1.6.2.txt), you can go to the previous visited branch using `git checkout -`.

This last command is an alias for `git checkout @{-1}`. And, `@{-1}` refers to the last branch you were on. 

```bash
# Starting from master
$ git checkout -b a-new-branch
# Do some work in a-new-branch
$ git checkout master
# Do some work in master
$ git checkout -
# Back to a-new-branch
```

_Source_: [Is there any way to git checkout previous branch?](https://stackoverflow.com/questions/7206801/is-there-any-way-to-git-checkout-previous-branch)