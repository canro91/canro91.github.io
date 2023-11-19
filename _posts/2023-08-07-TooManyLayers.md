---
layout: post
title: "Too many layers: My take on Queries and Layers"
tags: csharp
cover: Cover.png
cover-alt: "Rock sediments and layers"
---

These days I reviewed a pull request in one of my client's projects and shared a thought about reading database entities and layering. I believe that project took layering to the extreme. These are my thoughts.

**For read-only database-access queries, reduce the number of layers in an application to avoid excessive mapping between layers and unneeded artifacts.**

## Too many layers, I guess

The [pull request I reviewed]({% post_url 2022-12-05-LeadingQuestionsOnCodeReviews %}) added a couple of API endpoints to power a report-like screen. These two endpoints only returned data given a combination of parameters. Think of showing all movies released on a date range with 4 or 5 stars. It wasn't exactly that, but let's use that example to prove a point.

That project had database entities, domain objects, results wrapping DTOs, and responses. To add a new read-only API endpoint, we would need a request object, query, query handler, and repository.

Inside the repository, we would need to map database entities to domain entities and [value objects]({% post_url 2022-12-21-WhenToChooseValueObjects %}). Inside the query handler, we would need to return a result object containing a collection of DTOs. Another mapping. Inside the API endpoint, we would need to return a response object. Yet another mapping. I guess you see where I'm going.

This is the call chain of methods I found in that project:

{% include image.html name="TooManyLayers.png" alt="Sequence diagram to read a list of movies" caption="Three layers and even more mappings" %}

And these are all the files we would need to add a new API endpoint and its dependencies:

```bash
|-Api/
|---src/
|-----Movies/
|-------MovieQueryApi.cs
|-------GetMoviesQueryResponse.cs
|-Application/
|---src/
|-----Movies/
|-------GetMoviesQuery.cs
|-------GetMoviesQueryHandler.cs
|-------GetMoviesQueryResult.cs
|-------MovieDto.cs
|-Domain/
|---src/
|-----Movies/
|-------Movie.cs
|-------Director.cs
|-------Genre.cs
|-Infrastructure.Contracts/
|---src/
|-----Movies/
|-------IMovieRepository.cs
|-Infrastructure.SqlServer/
|---src/
|-----Movies/
|-------MovieRepository.cs
```

Technically, the objects inside the Domain were already there. By the way, we can [create that folder structure with dotnet cli]({% post_url 2022-12-15-CreateProjectStructureWithDotNetCli %}).

That's layering to the extreme. All those artifacts and about three mapping methods between layers are waaay too much to only read unprocessed entities from a database. Arrrggg! Too much complexity. We're only reading data, not loading domain objects to call methods on them.

I believe **simple things should be simple to achieve**.

## Query Services: A simpler alternative

As an alternative to those artifacts and mappings, I like to follow the idea from the book [Hands-on Domain-Driven Design with .NET Core]({% post_url 2022-10-03-HandsOnDDDTakeaways %}).

For read-only queries, the HODDD book uses two models:

1. **Query Models** for the request parameters, and
2. **Read Models** for the request responses.

Then, it calls the underlying storage mechanism directly from the API layer. Well, that's too much for my own taste. But I like the simplicity of the idea.

I prefer to use **Query Services**. They are query handlers that live in the Infrastructure or Persistence layer, call the underlying storage mechanism, and return a read model we pass directly to the API layer. This way, we only have two layers and no mappings between them. We declutter our project from those extra artifacts!

I mean something like this,

{% include image.html name="FewerLayers.png" alt="Sequence diagram to read a list of movies" caption="Two layers and zero mappings" %}

And something like this,

```bash
|-Api/
|---src/
|-----Movies/
|-------MovieQueryApi.cs
|-Application/
|---src/
|-----Movies/
|-------GetMoviesQueryModel.cs
|-------MoviesReadModel.cs
|-Infrastructure.SqlServer/
|---src/
|-----Movies/
|-------GetMoviesQueryService.cs
```

We put the input and output models in the Application layer since we want the query service in the Infrastructure layer. Although, the HODDD book places the input and output models and data-access code directly in the API layer. Way simpler in any case!

Voilà! That's my take on read-only queries, layers, and Domain-Driven Design artifacts. I prefer to keep read-only database access simple and use query services to avoid queries, query handlers, repositories, and the mappings between them. What do you think? Do you also find all those layers and artifacts excessive?

If you want to read more content on Domain-Driven Design, check [a case of primitive obsession]({% post_url 2020-12-10-PrimitiveObsession %}) and [my takeaways from the book Domain Modeling Made Functional]({% post_url 2021-12-13-DomainModelingMadeFunctional %}).

_Happy coding!_
