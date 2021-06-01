---
layout: post
title: Git guide for TFS users
tags: tutorial git
---

Dear developer, you're working in a project that uses Team Foundation Server, TFS. You're used to check-out and check-in your files. Now you have to use Git. Do you know how the two relate to each other? This is what makes TFS and Git different.

**Team Foundation Server (TFS) and Git belong to two different types of Version Control Systems. TFS is centralized and Git is distributed. This distinction makes collaborating with others, syncing changes and branching to work different.**

## Centralized vs Distributed

Centralized version control systems need a server in place to operate. To version control a file, view the history of a file or perform any other operation you need to communicate to a server.

But, distributed version control systems don't need a server. Each operation is performed in a local copy of the project. You could choose to sync your local copy with a server later on.

TFS is a centralized version control system and Git a distributed one.

## TFS vs Git

This distinction between Centralized and Distributed Version Control Systems brings some differences between TFS and Git. These are some of them.

### Exclusive checkout

Have you ever needed to modify a file and you couldn't because a co-worker was working on that file too? That's Exclusive Checkout.

Exclusive Checkout is a feature you can turn on or off in TFS. But, it isn't available in Git. Because, there is no lock on files to have only one user working in a file at a time.

With Git, each developer works in his own copy of the project.

### No mappings

Before starting to work with a project under TFS, you need some _"mappings"_. A place where the files in TFS server will be in your computer. 

With Git, you can clone and keep a project anywhere in your computer. There's no such a thing as mappings.

### Checking and Pushing

After modifying some files, you want to version control them. With TFS you "check-in" your files. This means, those files are kept in the history of the project and synced with the server.

With Git, you don't "check-in" your files, you "commit" them. And, your committed files live only in your local copy of the project, until you sync or _push_ them to a server.

## Branching

With Git, branches have a new meaning. You could have lots of light-weight and short-lived branches to try things out, solve bugs or do your everyday work. By convention, all Git repositories start with a branch called _master_.

Starting from [Git 2.28](https://github.blog/2020-07-27-highlights-from-git-2-28/#introducing-init-defaultbranch), Git will use the configuration value `init.defaultBranch` to name the default branch. Other alternatives for master are: main, primary or default.

### Gitflow, a branching model

Maybe, you have worked with one branch per environment: Dev, QA, Beta and Production. You start every new task directly on the Dev branch.

There is another branch model: Gitflow.

Gitflow suggests that the _master_ branch mirrors the Production environment. The _develop_ branch is where everyday work happens. But, every new task starts in a new branch taken from _develop_. Once you're done with your task, you merge this branch back to _develop_.

In case of bugs or issues in Production, you create a new branch from _master_. And you merge it back to _master_ and _develop_ once you're done fixing the issue.

Every release has a separate branch, too. This release branch is also merged to _master_ and _develop_. For more details, see [Introducing GitFlow](https://datasift.github.io/gitflow/IntroducingGitFlow.html).

### Pull or Merge Requests

Some projects adopt another convention. Nobody pushes or syncs directly to the master or develop branch.

Instead, every new task goes through a code review phase using a pull or merge request. During code review, your code is examined to find bugs and to stick to coding conventions.

A pull or merge request means that "the author of the task asks to merge his changes from a branch into the current codebase".

Most of the time, this code review is done through a web tool or web interface. After one or two team members review your changes, the same tool will allow the reviewer to merge the changes to the destination branch.

<div class="message">If you're interested in the code review process, check my post on <a href="/2019/12/17/BetterCodeReviews">Tips and Tricks for Better Code Reviews</a>. It contains tips for everyone involved in the code review process.</div>

## Reference

This is how TFS and Git actions relate to each other.

### Changesets = Commits

In TFS, a changeset is a set of changes that have been version-controled and synced to the server.

With Git, you have commits. Your commits can live only on your local copy, until you upload them to a server.

If you want to collaborate with others or host your code somewhere else, you can use a server as a single point of authority.

Have you ever heard about GitHub, GitLab or Bitbucket? These are third-party hosting solutions for Git.

### Check-in = Commit + Push

With TFS, you "check-in" your files. But, with Git, from the command line, you need three commands: `add`, `commit` and `push`.

```bash
$ git add .
$ git commit -m 'A beatiful commit message'
$ git push origin my-branch
```

### Get latest version = Pull

To get the most recent changes from a server, with TFS, you "get latest version".

With Git, you need to "pull" from a remote branch on a server. Use `git pull origin my-branch`.

By convention, the name associated to the sync server is _origin_. You can add other remotes if needed.

### Branch = Branch + Checkout

With TFS, you create a new branch from the source branch using the "Branch" option. If you have a large project, this could take a while.

With Git, you need to create a branch and switch to it. Use the commands: `branch` and `checkout`, respectively. But, you can combine these two actions into a single one with `checkout` and the `-b` flag.

```bash
$ git checkout -b a-new-branch
```

### Shelve = stash

If you want to temporary suspend your work and resume it later, you use a shelve in TFS or an stash with Git.

With Git, to create an stash, use `git stash -u`. And, `git stash apply` to bring back your changes.

## Integration

Please, do not be afraid of using the command line and memorizing lots of commands. There are  Git clients and out-of-the-box integrations (or plugins) for Git in most popular IDE's. For example, Visual Studio and Visual Studio Code support Git out-of-the-box, and [SourceTree](https://www.sourcetreeapp.com/) is a Git client you can download for free.

Voilà! That's what makes Git and TFS different. Now you know where your changesets are, how to check-out to files and why you don't need any mappings with Git.

For a more in-depth guide to Git, read [my beginner's guide to Git and GitHub]({% post_url 2020-05-29-HowToVersionControl %}). If you're interested in code reviews, check my post on [Better Code Reviews]({% post_url 2019-12-17-BetterCodeReviews %}).

_Happy Git time!_