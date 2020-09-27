---
layout: post
title: Git guide for TFS users
tags: tutorial git
---

Dear developer, you're working in a project that uses Team Foundation Server, TFS. You're used to check-out and check-in your files. You feel comfortable with it. But, now you have moved to a different project that uses Git or your company has decided to migrate to Git. _Where are my changesets now? How do I check-out my files? How these two things relate to each other?_–you ask. Keep reading!

## Centralized vs Distributed

Centralized version control systems need a server in place to operate. To check a file, view the history of a file or perform any other operation you need to communicate to a server.

But, distributed version control systems don't need a server. Each operation is performed in a local copy of the project. And you could choose to sync your local copy with a server later on. _Have you guest which one belongs to each category?_ TFS is a centralized version control system and Git a distributed one.<sup>[1]</sup>

This distinction brings some differences between TFS and Git. These are some of them.

### Exclusive checkout

_Have you ever needed to modify a file and you can't because a co-worker is working in that file too?_ Although, this is a feature that can be turned on or off in TFS, it isn't available in Git. Because, there is no lock on files to have only one user working in a file at a time. Each developer works in his own copy of the project.

### No mappings

Before starting to work with a project under TFS, you need some _"mappings"_, where the files in TFS server will be in your computer. But, with Git, you can clone and keep a project anywhere in your computer.

### Checking and Pushing

After modifying some files, you want to version control them. With TFS you "check-in" your files. This means, those files are kept in the history of the project and synced with the server. But, with Git, your committed files live only in your local copy of the project, until you sync or _push_ them to a server.

## Branching

With Git, branches have a new meaning. You could have lots of light-weight and short-lived branches to try things out, solve bugs or do your work. By convention, all Git repositories start with a branch called _master_.

> The master/slave methaphor is discouraged these days. Starting from [Git 2.28](https://github.blog/2020-07-27-highlights-from-git-2-28/#introducing-init-defaultbranch), Git will use the configuration value `init.defaultBranch` to name the default branch. Other alternatives for master are: main, primary or default.

#### Gitflow, a branching model

Maybe, you have worked with one branch per environment: Dev, QA, Beta and Production. You start every new task on the Dev branch.

But, there is another branch model. **Gitflow workflow** suggests that the _master_ branch mirrors the Production environment. The _develop_ branch is where everyday work happens. But, every new task starts in a separate branch taken from _develop_. Once you're done with your task, you merge this branch back to _develop_.

In case of bugs or issues in Production, you create a new branch from _master_. And you merge it back to _master_ and _develop_ once you're done fixing the issue.

Every release has a separate branch, too. This release branch is also merged to _master_ and _develop_. For more details, see [Introducing GitFlow](https://datasift.github.io/gitflow/IntroducingGitFlow.html).

#### Pull or Merge Requests

Some projects adopt another convention. _Nobody pushes or syncs directly to the master branch_.

Instead, every new task needs to go through a review phase using a pull or merge request. _"The author of the task asks to merge his changes into the current codebase"_, hence that name.

Most of the time, this review is done through a web tool or web interface. After the review, the same tool will allow the reviewer to merge the changes to the destination branch.

## Reference

This is a relationship between TFS and Git concepts.

* **Changesets = commits**: Be aware commits could live only in your computer, until you upload your changes to a server. If you want to collaborate with others or host your code somewhere else, just in case. _Have you ever heard about Github, Gitlab or Bitbucket?_
* **Check-in = Commit + Push**: `git commit -m 'A beatiful commit message'` + `git push origin my-branch`
* **Get latest version = Pull**: `git pull origin my-branch` By convention, the name associated to the sync server is _origin_
* **Branch = Branch + Checkout**: `git checkout -b a-new-branch`
* **Shelve = stash**: If you want to temporary suspend your work and resume it later, you use a shelve in TFS or an stash with Git. To create an stash `git stash -u` and `git stash apply` to bring back your changes.

## Integration

Please, do not be afraid of using the command line and memorizing lots of commands. There are  Git clients and out-of-the-box integrations (or plugins) for Git in most popular IDEs. For example, Visual Studio and Visual Studio Code support Git out-of-the-box, and [SourceTree](https://www.sourcetreeapp.com/) is a Git client you can dowload for free.

> For a more in-depth guide to version control with Git, read my guide on [How to version control your projects with Git]({% post_url 2020-05-29-HowToVersionControl %}).

_Happy Git time!_

[1]: https://docs.microsoft.com/en-us/azure/devops/repos/tfvc/index?view=azure-devops