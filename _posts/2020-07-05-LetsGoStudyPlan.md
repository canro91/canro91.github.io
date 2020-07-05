---
layout: post
title: Let's Go&colon; Learn Go in 30 days
---

You want to learn a new programming language? You aren't sure about what language to choose? Have you heard about Go? _Well, let's Go!_

> _"Go is an open source programming language that makes it easy to build simple, reliable, and efficient software"_. [golang.org](https://golang.org/)

Go is a popular language these days. According to Stack Overflow 2020 Developer Survey, Go is in the top 5 of most loved languages. It ranks in the top 3 most wanted languages. Docker, Kubernetes, and a growing [list of projects](https://github.com/golang/go/wiki/GoUsers) use Go.

## Motivation

**Go reduces the complexity of writing concurrent software**. Go uses the concept of **channels** and **goroutines**. These two constructs allow you to have a "queue" and "two threads" to write to and read from it, out of the box. Rob Pike, one of the creators of Go, explains these concepts in his talk [Concurrency is not parallelism](https://blog.golang.org/waza-talk). In other languages, you would need error-prone code to achieve similar results. _Threads, locks, semaphores, etc, ..._

## Method

**Learn something by doing**. This is one of the takeaways from the book [Pragmatic Thinking and Learning]({% post_url  2020-05-07-PragmaticThinkingAndLearning %}). Instead of watching videos or skimming books, recreate examples and build mini-projects. _"Instead of dissecting a frog, build one"_.

**No Copy/Paste**. Read the sample, "cover" it and reproduce it without looking at it. If you get stuck, search online instead of going back to the sample. For exercises, read the instructions and try to solve them by yourself. Then, check your solution. _Fire up your text editor!_

## Resources

Before starting, you can have a general overview of the language with Pluralsight course [Go Big Picture](https://app.pluralsight.com/library/courses/go-big-picture/table-of-contents). To grasp the main concepts, you can follow [Learn Go with tests](https://github.com/quii/learn-go-with-tests). It teaches Go using the concept of Test-Driven Development (TDD). _Red, green, refactor_. Other helpful resources to are [Go by Example](https://gobyexample.com/) and [Go documentation](https://golang.org/doc/).

> “To me, legacy code is simply code without tests.”
> 
> ― Michael C. Feathers, Working Effectively with Legacy Code

### Basic

* Guess the number, simple calculator
* [Build some CLI tools](https://github.com/danistefanovic/build-your-own-x#build-your-own-command-line-tool) like cowsay, lolcat and fortune
* [Build your own shell](https://github.com/danistefanovic/build-your-own-x#build-your-own-shell)
* [Caesar cipher](https://en.wikipedia.org/wiki/Caesar_cipher)

### Intermediate

* [Fun weekend projects](https://www.opsdash.com/blog/fun-weekend-projects-golang.html) like an [Slack bot](https://www.opsdash.com/blog/slack-bot-in-golang.html) (a [Twitter bot](https://tutorialedge.net/golang/writing-a-twitter-bot-golang/) if you prefer Twitter) or a [simple key-value store](https://www.opsdash.com/blog/persistent-key-value-store-golang.html). You can find another take of a Slack bot [here](https://chrisrng.svbtle.com/building-a-slack-bot-in-golang)
* Write a data structure like a linked list, a stack or a queue
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
* [Let's Create a Simple Load Balancer With Go](https://kasvith.github.io/posts/lets-create-a-simple-lb-go/)
* [Building a BitTorrent client from the ground up in Go](https://blog.jse.li/posts/torrent/)
* [Building a Web Server](https://www.gophersumit.com/series/web-1/)

### Fullstack

* Chat with [Angular](https://www.thepolyglotdeveloper.com/2016/12/create-real-time-chat-app-golang-angular-2-websockets/) or [React](https://tutorialedge.net/projects/chat-system-in-go-and-react/)
* Url shortener with [Redis](http://bindersfullofcode.com/2019/02/12/golang-url-shortener.html) or [CouchDB](https://www.thepolyglotdeveloper.com/2016/12/create-a-url-shortener-with-golang-and-couchbase-nosql/). Another take with [Redis and Iris](https://www.kieranajp.uk/articles/build-url-shortener-api-golang/) 
* [Todo with MongoDB and React](https://schadokar.dev/posts/build-a-todo-app-in-golang-mongodb-and-react/)
* [Blog App Tutorial](https://www.youtube.com/channel/UCL8dTpgXgQKtKGp45dke1fg)
* [Building a Microservice](https://www.youtube.com/playlist?list=PLmD8u-IFdreyh6EUfevBcbiuCKzFk0EW_)

You can find more project ideas here: [40 project ideas for software engineers](https://www.codementor.io/@npostolovski/40-side-project-ideas-for-software-engineers-g8xckyxef), [What to code](https://what-to-code.com/), [Build your onw x](https://github.com/danistefanovic/build-your-own-x) and [Project-based learning](https://github.com/tuvtran/project-based-learning#go).

### Conferences

* [Concurrency is not parallelism](https://blog.golang.org/waza-talk)
* [How do you structure your Go apps](https://www.youtube.com/watch?v=oL6JBUk6tj0)
* [Things in Go I Never Use](https://www.youtube.com/watch?v=5DVV36uqQ4E)
* [Best Practices for Industrial Programming](https://www.youtube.com/watch?v=PTE4VJIdHPg)
* [7 common mistakes in Go and when to avoid them](https://www.youtube.com/watch?v=29LLRKIL_TI)

## Conclusions

Go was design to reduce the clutter and complexity of other languages. Go syntax is like C. Go is like C on asteroids. _Goodbye, C pointers!_ Go doesn't include expected features like inheritance, exceptions or generics. _Yes, Go doesn't have exceptions_. But, Go is batteries-included. You have included, for free, a testing and benchmarking library, a formatter and a race-condition detector. Coming from C#, you can still miss assertions like the ones from NUnit or XUnit. _Aren't you curious about a language without exceptions? Happy Go time!_

> _You can find my own 30-day journey following the resources from this post in [LetsGo](https://github.com/canro91/LetsGo)_