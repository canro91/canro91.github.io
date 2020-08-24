---
layout: post
title: A Conversation on Microservices and Design
tags: tutorial
---

> _What is all the fuzz with this microservices thing?_

Microservices promise you can isolate components of your application to develop and scale them separately. You could choose different tech stacks for your microservices. Even, you could delegate microservices to different teams.

Martin Fowler defines [microservices](https://martinfowler.com/articles/microservices.html) as an architectural style to develop an application as a suite of small services running in their own processes and communicating with lightweight mechanisms.

If you have an e-commerce app, you can have a microservice for your invoicing component. Even with a separate database. Then, you can expose a REST API  to use anything related to the invoicing component. 

Althought, I read [an article](https://riak.com/posts/technical/microservices-please-dont/) that suggests you can achieve the same benefits with a monolith application.

> _How DDD and CQRS relate to microservices?_

They aren't mutually exclusive. You could have a monolith or a microservice that uses CQRS or DDD. They different, but related, design principles.

On one hand, [CQRS](https://en.wikipedia.org/wiki/Command%E2%80%93query_separation) separates command from queries. Commands mutate the state of your application. Queries answer any questions about your application. For example, creating a new user would be a command. But, finding all invocies of a client on the last month would be a query.

But, [DDD](https://en.wikipedia.org/wiki/Domain-driven_design) strives for a core layer independent of libraries and tools by implementating obiquitous language and bounded contexts. Code should express the business domain. The codebase and all participants of the project should speak the same language.

> _And what about TDD? You have to write lots of code!_

Yes. Again [TDD](https://en.wikipedia.org/wiki/Test-driven_development) is another design principle. With TDD, before writing any production code, you write a test that verifies the expected results of your code given a particular scenario.

If you're writing a calculator, you would expect an error if you divide any number by zero. Then, you would write a test to prove that.

> _So the database is just a repository?_

Yes. For [Ports and Adapters](https://alistair.cockburn.us/hexagonal-architecture/) and [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html), databases are implementations details. It means you could change your database technology without rewriting your entire application.

I knew a project that used a NoSQL document store. But, when the operation costs overpassed the budget, the project moved towards a relational database. Business logic was written in some sort of scripts in the engine itself. They had to rewrite most of the application to use a relational database. And to make things worse, instead of creating a business core independent of any database, they moved that logic to store procedures.

_Happy coding!_
