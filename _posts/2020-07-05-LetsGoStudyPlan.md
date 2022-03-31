---
layout: post
title: "Let's Go: Learn Go in 30 days"
tags: letsX go
cover: LetsGo.png
---

Do you want to learn a new programming language but don't know what language to choose? Have you heard about Go? Well, let's learn Go in 30 days!

From its [official page](https://golang.org/), Go is _"an open source programming language that makes it easy to build simple, reliable, and efficient software"_. 

Go is a popular language. According to Stack Overflow 2020 Developer Survey, Go is in the top 5 of most loved languages. It ranks in the top 3 most wanted languages. Docker, Kubernetes, and a growing [list of projects](https://github.com/golang/go/wiki/GoUsers) use Go.

## Why to choose Go?

**Go reduces the complexity of writing concurrent software**. Go uses the concept of **channels** and **goroutines**. These two constructs allow us to have a "queue" and "two threads" to write to and read from it, out-of-the-box.

In other languages, we would need error-prone code to achieve similar results. Threads, locks, semaphores, etc, ...

Rob Pike, one of the creators of Go, explains channels and goroutines in his talk [Concurrency is not parallelism](https://blog.golang.org/waza-talk).

<div class="video-container">
<iframe src="https://www.youtube-nocookie.com/embed/oV9rvDllKEg?rel=0&fs=0" width="640" height="360" frameborder="0"></iframe>
</div>

## How to learn Go? Methodology

To learn a new programming language, library or framework, stop passively reading tutorials and copy-pasting code you find online. Follow these two principles:

**Learn something by doing**. This is one of the takeaways from the book [Pragmatic Thinking and Learning]({% post_url 2020-05-07-PragmaticThinkingAndLearning %}). Instead of watching videos or skimming books, recreate examples and build mini-projects.

**Don't Copy and Paste**. Instead of copy-pasting, read the sample code, "cover" it and reproduce it without looking at it. If you get stuck, search online instead of going back to the sample. For exercises, read the instructions and try to solve them by yourself. Then, check your solution.

> _"Instead of dissecting a frog, build one"_.
> 
>  ― Andy Hunt, Pragmatic Thinking and Learning

## Resources

Before starting to build something with Go, we can have a general overview of the language with the Pluralsight course [Go Big Picture](https://app.pluralsight.com/library/courses/go-big-picture/table-of-contents).

To grasp the main concepts, we can follow [Learn Go with tests](https://github.com/quii/learn-go-with-tests). It teaches Go using the concept of Test-Driven Development (TDD). Red, green, and refactor.

Other helpful resources to are [Go by Example](https://gobyexample.com/) and [Go documentation](https://golang.org/doc/).

> “To me, legacy code is simply code without tests.”
> 
> ― Michael C. Feathers, Working Effectively with Legacy Code

### Basic

* Guess the number, simple calculator
* [Build some CLI tools](https://github.com/danistefanovic/build-your-own-x#build-your-own-command-line-tool) like cowsay, lolcat, and fortune
* [Build your own shell](https://github.com/danistefanovic/build-your-own-x#build-your-own-shell)
* [Caesar cipher](https://en.wikipedia.org/wiki/Caesar_cipher)

### Intermediate

* [Fun weekend projects](https://www.opsdash.com/blog/fun-weekend-projects-golang.html) like an [Slack bot](https://www.opsdash.com/blog/slack-bot-in-golang.html) (a [Twitter bot](https://tutorialedge.net/golang/writing-a-twitter-bot-golang/) if you prefer Twitter) or a [simple key-value store](https://www.opsdash.com/blog/persistent-key-value-store-golang.html). You can find another take of a Slack bot [here](https://chrisrng.svbtle.com/building-a-slack-bot-in-golang)
* Write a data structure like a linked list, a stack, or a queue
* [Build a CLI wrapper for XKCD](https://eryb.space/2020/05/27/diving-into-go-by-building-a-cli-application.html)
* [Build and test a REST API with PostgreSQL](https://semaphoreci.com/community/tutorials/building-and-testing-a-rest-api-in-go-with-gorilla-mux-and-postgresql) or [Build a REST API with Fiber and SQLite](https://tutorialedge.net/golang/basic-rest-api-go-fiber/)
* [Build an API client](https://blog.gopheracademy.com/advent-2019/api-clients-humans/)
* [The Super Tiny Compiler](https://github.com/hazbo/the-super-tiny-compiler)
* If you're coming from Node.js [API for Node.js developers](https://www.youtube.com/playlist?list=PLzQWIQOqeUSPFPVfticl-CsmUv82Gb5W-) 

### Advanced

* [Write cleaner web servers](https://dev.to/chidiwilliams/writing-cleaner-go-web-servers-3oe4)
* Create an FTP Client. You need to understand sockets
    * [Ping-pong](https://gist.github.com/kenshinx/5796276)
    * [Chat with Sockets](https://www.thepolyglotdeveloper.com/2017/05/network-sockets-with-the-go-programming-language/)
* [Write a SQL database](http://notes.eatonphil.com/database-basics.html)
* [Writing a document database from scratch in Go](https://notes.eatonphil.com/documentdb.html)
* [Let's Create a Simple Load Balancer With Go](https://kasvith.github.io/posts/lets-create-a-simple-lb-go/)
* [Building a BitTorrent client from the ground up in Go](https://blog.jse.li/posts/torrent/)

### Fullstack

* Chat with [Angular](https://www.thepolyglotdeveloper.com/2016/12/create-real-time-chat-app-golang-angular-2-websockets/) or [React](https://tutorialedge.net/projects/chat-system-in-go-and-react/)
* Url shortener with [Redis](http://bindersfullofcode.com/2019/02/12/golang-url-shortener.html) or [CouchDB](https://www.thepolyglotdeveloper.com/2016/12/create-a-url-shortener-with-golang-and-couchbase-nosql/). Another take with [Redis and Iris](https://www.kieranajp.uk/articles/build-url-shortener-api-golang/)
* [Blog App Tutorial](https://www.youtube.com/channel/UCL8dTpgXgQKtKGp45dke1fg)
* [Building a Microservice](https://www.youtube.com/playlist?list=PLmD8u-IFdreyh6EUfevBcbiuCKzFk0EW_)

You can find more project ideas here: [40 project ideas for software engineers](https://www.codementor.io/@npostolovski/40-side-project-ideas-for-software-engineers-g8xckyxef), [What to code](https://what-to-code.com/), [Build your own x](https://github.com/danistefanovic/build-your-own-x) and [Project-based learning](https://github.com/tuvtran/project-based-learning#go).

### Conferences

* [Concurrency is not parallelism](https://blog.golang.org/waza-talk)
* [How do you structure your Go apps](https://www.youtube.com/watch?v=oL6JBUk6tj0)
* [Things in Go I Never Use](https://www.youtube.com/watch?v=5DVV36uqQ4E)
* [Best Practices for Industrial Programming](https://www.youtube.com/watch?v=PTE4VJIdHPg)
* [7 common mistakes in Go and when to avoid them](https://www.youtube.com/watch?v=29LLRKIL_TI)

## Conclusion

Go was designed to reduce the clutter and complexity of other languages. Go syntax is like C. Go is like C on asteroids. _Goodbye, C pointers!_ Go doesn't include common features in other languages like inheritance or exceptions. Yes, Go doesn't have exceptions.

However, Go is batteries-included. You have a testing and benchmarking library, a formatter, and a race-condition detector. Coming from C#, you can still miss assertions like the ones from NUnit or XUnit.

Aren't you curious about a language without exceptions? _Happy Go time!_

> _You can find my own 30-day journey following the resources from this post in [LetsGo](https://github.com/canro91/LetsGo)_

[![canro91/LetsGo - GitHub](https://gh-card.dev/repos/canro91/LetsGo.svg)](https://github.com/canro91/LetsGo)

<img src="https://go.dev/images/gophers/pilot-bust.svg" width="80" height="50" />
