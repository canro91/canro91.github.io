---
layout: post
title: A beginner's Guide to Git. A guide to time travel
tags: tutorial git
---

Have you ever tried to version control your projects by appending dates on folder names? Are you doing it now? I did it back in school with my class projects. If you're doing it this way, there's a better way. Let's use Git and GitHub to version control our projects. Read on!

```bash
$ ls
Project-2020-04-01/
Project-Final/
Project-Final-Final/
Project-ThisIsNOTTheFinal/
Project-ThisIsTheTrueFinal/
```

> _You can find the presentation version of this post [here]({% post_url 2020-04-09-FromZeroToPRWithGit %})._

## What is a Version Control System?

First, what is a version control system? A [version control system](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control), VCS, is a piece of code that keep track of changes of a file or set of files. So you can later access an specific change.

A version control system, among other things, allows to

* Revert a file or the entire project to a previous state
* Follow all changes of a file through its lifetime
* See who has modified a file

To better understand this concept, let’s use an analogy.

**A version control system is a time machine**. With it you can go backwards in time, create timelines and merge two separate timelines. You don’t travel to historical events in time, but to checkpoints in your project.

<figure>
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/TeamTimeCar.com-BTTF_DeLorean_Time_Machine-OtoGodfrey.com-JMortonPhoto.com-04.jpg/640px-TeamTimeCar.com-BTTF_DeLorean_Time_Machine-OtoGodfrey.com-JMortonPhoto.com-04.jpg" alt="DeLorean time machine" width="800" />

<figcaption>DeLorean from Back to the Future. Photo by <a href="https://commons.wikimedia.org/wiki/File:TeamTimeCar.com-BTTF_DeLorean_Time_Machine-OtoGodfrey.com-JMortonPhoto.com-04.jpg" title="via Wikimedia Commons">JMortonPhoto.com &amp; OtoGodfrey.com</a> / <a href="https://creativecommons.org/licenses/by-sa/4.0">CC BY-SA</a></figcaption>
</figure>

## Centralized vs Distributed

There is a distinction between version control systems. It makes them different. Centralized vs distributed.

**A centralized VCS requires a server to perform any operation on your project**. You need to connect to this server to download all your files to start to work. If this serves goes down, users can’t work. _Bye, bye, productivity!_ Team Foundation Server (TFS) from Microsoft is a centralized VCS.

But, **a distributed VCS doesn’t need a centralized server in the same sense**. Each user has a complete copy of the entire project. Most of operations are performed against this local copy. So you can work offline. _A two-hour flight without internet, no problem_. For example, Git is a distributed VCS.

If you’re coming from TFS, I’ve written a [Git Guide for TFS Users]({% post_url 2019-11-11-GitGuideForTfsUsers %}).

## What's Git anyways?

Up to this point, Git doesn’t need any further introduction. From its [official page](https://git-scm.com/), "_Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency._"

### Install and Setup Git

You can install Git from it’s official page. There you can find instructions to install it using package managers for all major OS's. 

Before starting to work, you need some one-time setups. You need to configure a name and an email. This name and email will appear in the file history of any file you create or modify.

Let's go to the command line. From the next two commands, replace "John Doe" and "johndoe@example.com" with your own name and email.

```bash
$ git config --global user.name "John Doe"
$ git config --global user.email johndoe@example.com
```

You can change this name and email between projects. If you want to use different names and emails for work, you’re covered. [You can manage different accounts](https://dev.to/balaaagi/managing-multiple-git-account-1ddd) between folders.

### Create a Git repository

There are two ways to start working with Git. From scratch or from an existing project.

If you are starting from scratch, inside the folder you want to version control, use `init`. Like this,

```bash
$ git init
```

After running `git init`, Git creates a hidden folder called `.git` inside your project folder. Git keeps everything under the hood on this folder. 

If you have an existing project, use `clone`, instead.

```bash
# Replace <url> with the actual url of the project
# For example, https://github.com/canro91/Parsinator
$ git clone <url>
```

Did you notice it? The command name is `clone`. Since you are getting a copy of everything a server has about a project.

### Add new files

Let’s start working! Create new files or change existing ones in your project. Next, you want Git to keep track of these files. You need three commands: `status`, `add` and `commit`.

First, `status` shows the pending changes in your files. `add` includes some files into the staging area. And, `commit` creates an event in the history of your project.

```bash
# git status will show pending changes in files
$ git status
# Create a README file using your favorite text editor.
# Add some content
# See what has changed now
$ git status
$ git add README
$ git commit -m 'Add README file'
```

Now Git knows about a file called `README`. You have a commit (a checkpoint) in your project you can go back to. Git has stored your changes. This commit has an unique code (a SHA-1) and an author.

You can use `log` to see all commits created so far.

```bash
# You will see your previous commit here
$ git log
```

### What's the Staging area?

The staging area or index is a concept that makes Git different.

**The staging area is an intermediate area where you can review your files before committing them**.

It’s like making your files wait in a line before keeping track of them. This allows you to commit only a group of files or portions of a single file.

If you’re coming from TFS, notice you need two steps to store your changes. These are: `add` to include files into the staging area and `commit` to create a checkpoint from them. With TFS, you only "check-in" your files.

### Ignoring files

Sometimes you don’t need to version control certain files or folders. For example, log files, third-party libraries, files and folders generated by compilation or by your IDE.

If you’re starting from scratch, you need to do this only once. But if you’re starting from an existing project, chances are somebody already did it.

You need to create a `.gitignore` file with the patterns of files and folders you want to ignore. You can use this file globally or per project. There is [a collection of gitignore templates on GitHub](https://github.com/github/gitignore) for your language and your IDE.

For example, to ignore the `node_modules` folder, the `.gitignore` file will contain  

```bash
node_modules/
```

Git won’t notice any files from the patterns included in the `.gitignore` file. Run `git status` to notice it.

### Commit messages

A [good commit message](https://thoughtbot.com/blog/5-useful-tips-for-a-better-commit-message) should tell why the change is needed, what problem it fixes and any side effect it might have.

Please, please don’t use “uploading changes” or any variations on your commit messages.

Depending on your workplace or project, you have to follow a naming convention for your commit messages. For example, you have to include the type of change (feature, test, bug or refactor) followed by a task number from your bug tracking software. If you need to follow a convention like this one, [Git can format the commit messages]({% post_url 2020-09-02-TwoRecurringReviewComments %}) for you.

Keep your commits small and focused. Work with incremental commits. And, don't commit changes that break your project.

## Branching and merging

### Branching

Using the time machine analogy, **a branch is a separate timeline**. Changes in a timeline don’t interfere with changes in other timelines. By convention, the main timeline is called **master**.

About the master convention, starting from [Git 2.28](https://github.blog/2020-07-27-highlights-from-git-2-28/#introducing-init-defaultbranch), when you run `git init`, Git will look for the configuration value `init.defaultBranch` to replace the hard-coded "master" name. Other alternatives for master are: main, primary or default. For existing repositories, you can follow [this Scott Hanselman post](https://www.hanselman.com/blog/EasilyRenameYourGitDefaultBranchFromMasterToMain.aspx) to rename your master branch.

Branching is one the most awesome Git features. Git branches are lightweight and fast when compared to other VCS.

Let's create a new branch called "testing". For this, we will need the command `branch` follow by the branch name.

```bash
# Create a new branch called testing
$ git branch testing
# List all branches you have
$ git branch
# Move to the new testing branch
$ git checkout testing
# Modify the README file
# For example, add a new line
# "For example, how to create branches"
$ git status
$ git add README
$ git commit -m 'Add example to README'
```

Now, let's switch back to the master branch and see what happened to our files there. To switch between branches, use `checkout`.

```bash
# Now move back to the master brach
$ git checkout master
# See how README hasn't changed
# Modify the README file again
# For example, add "Git is so awesome, isn't it?"
$ git status
$ git add README
$ git commit -m 'Add Git awesomeness'
# See how these changes live in different timelines
$ git log --oneline --graph --all
```

We have created two branches, let's see how we can combine what we have in the two branches.

<figure>
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Grays_Sports_Almanac_Back_to_the_Future.jpg/800px-Grays_Sports_Almanac_Back_to_the_Future.jpg" alt="Grays Sports Almanac" width="800" height="400" />

<figcaption>Grays Sports Almanac. Photo by <a href="https://commons.wikimedia.org/wiki/File:Grays_Sports_Almanac_Back_to_the_Future.jpg">Mike Mozart</a>, <a href="https://creativecommons.org/licenses/by/2.0">CC BY 2.0</a>, via Wikimedia Commons</figcaption>
</figure>

### Merging

Merging two branches is combining two separate timelines. 

Continuing with the time travel analogy, merging is like when Marty goes to the past to get back the almanac and he is about to run into himself. Or when captain America goes back to New York in 2012 and he ends up fighting the other captain America. You got the idea!

Let's create a new branch and merge it to `master`. We need the command `merge`.

```bash
# Move to master
$ git checkout master
# Create a new branch called hotfix and move there
$ git checkout -b hotfix
# Modify README file
# For example, add a new line
# "Create branches with Git is soooo fast!"
$ git status
$ git add README
$ git commit -m 'Add another example to README'
# Move back to master. Here master is the destination of all changes on hotfix
$ git checkout master
$ git merge hotfix
# See how changes from hotfix are now in master
# Since hotfix is merged, get rid of if
$ git branch -d hotfix
```

Here we have created a branch called `hotfix` and merged it to `master`. But we still have some chances on your branch `testing`. Let’s merge this branch to see what will happen.

```bash
$ git checkout master
$ git merge testing
# BOOM. You have a conflict
# Notice you have pending changes in README
$ git status
# Open README, notice you will find some weird characters.
#
# For example,
# <<<<<<< HEAD
# Content in master branch
# =======
# Content in testing branch
# >>>>>>> testing
#
# You have to remove these weird things
# Modify the file to include only the desired changes
$ git status
$ git add README
# Commit to signal conflicts were solved
$ git commit
# Remove testing after merge
$ git branch -d testing
```

If you're coming from TFS, you noticed you need to move first to the branch you want to merge into. You merge from the destination branch, not from the source branch.

Recently, I learned how to [move to the previous visited branch]({% post_url 2020-11-26-PreviousBranchGit %}). Use `$ git checkout -`.

### Branching model

Git encourages working with branches. Git branches are cheap and light-weight. You can start to create branches per task or features.

There is a convention for branch creation, [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/). It suggests feature, release and hotfix branches.

With Gitflow, you should have a _develop_ branch where everyday work happens. Every new task starts in a separate feature branch taken from _develop_. Once you're done with your task, you merge your feature branch back to _develop_.

## GitHub: Getting our code to the cloud

Up until now, all your work lives in your own computer. But, what if you want your project to live outside? You need a hosting solution. Among the most popular hosting solutions for Git, you can find [GitHub](https://github.com/), [GitLab](https://gitlab.com/) and [Bitbucket](https://bitbucket.org/).

It's important to distinguish between Git and Github. `Git != GitHub`. Git is the version control system and GitHub is the hosting solution for Git projects.

No matter what hosting you choose, your code isn't sync automatically with your server. You have to do it yourself. Let's see how.

You can [create a repo](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-new-repository) from your GitHub account. Go to `Your Repositories`. You need to use a name and a description. The wizard will give you some instructions to start from scratch or from an existing project.

Then, associate the GitHub endpoint to your local project. Endpoints are called remotes. Now you can upload or push your local changes to the cloud.

```bash
# Replace this url with you own
$ git remote add origin https://github.com/canro91/GitDemo.git
# push uploads the local master to a branch called master in the remote too
$ git push -u origin master
# Head to your GitHub account and refresh
```

## Cheatsheet

Here you have all the command we have used so far.

| Command | Function |
|---|---|
| `git init` | Create a repo in the current folder |
| `git clone <url>` | Clone an existing repo from _url_ |
| - | - |
| `git status` | List pending changes |
| `git add <file>` | Add _file_ to the staging area |
| `git commit -m '<message>'` | Create a commit with _message_ |
| `git log` | List committed files in current branch |
| `git log --oneline --graph --all` | List committed files in all branches |
| - | - |
| `git branch <branch-name>` | Create a new branch |
| `git checkout <branch-name>` | Change current branch to _branch-name_ |
| `git checkout -b <branch-name>` | Create a new branch and move to it |
| `git merge <branch-name>` | Merge _branch-name_ into current branch |
| - | - |
| `git remote add <remote-name> <url>` | Add a new remote pointing to _url_ |
| `git push -u <remote-name> <branch-name>` | Push _branch-name_ to _remote-name_ |

## Conclusion

Voilà! You have learned the most frequent commands for everyday use. You know how to use Git from the command line. But, most IDE's offer Git integration through plugins or extensions. Now try to use Git from your favorite IDE.

If you want to continue to practice these concepts, follow [First Contributions](https://github.com/firstcontributions/first-contributions) to open your first Pull Request. You can use my [Git Demo repository](https://github.com/canro91/GitDemo) too.

_Your mission, Jim, should you decide to accept it, is to get the latest changes from your repository. After pushing, clone your project in another folder, change any file and push this change. Next, go back to your first folder, modify another file and try to push. This post will self-destruct in five seconds. Good luck, Jim._

_Happy Git time!_