---
layout: post
title: "NCache & Full-Text Search"
tags: tutorial asp.net showdev
cover: Cover.png
cover-alt: "Game cards with letters" 
---

I bet you have used the SQL LIKE operator to find a keyword in a text field. For large amounts of text, that would be slow. Let's learn how to implement a full-text search with Lucene and NCache.

## What is Full-Text Search?

Full-text search is a technique to search not only exact matches of a keyword in some text but for patterns of text, synonyms, or close words in large amounts of text.

To support large amounts of text, searching is divided into two phases: indexing and searching. In the indexing phase, an analyzer processes text to create indexes based on the rules of a spoken language like English to remove stop words and record synonyms and inflections of words. Then, the searching phase only uses the indexes instead of the original text source.

## Full-Text Search with Lucene and NCache

### 1. Why Lucene and NCache?

From [its official page](https://lucenenet.apache.org/index.html), "Apache Lucene.NET is a high performance search library for .NET." It's a C# port of Java-based Apache Lucene, an "extremely powerful" and fast search library optimized for full-text search.

NCache gives distributed capabilities to Lucene by implementing the Lucene API on top of its In-Memory Distributed cache. This way, NCache makes Lucene a linearly scalable full-text searching solution for .NET. For more features of Distributed Lucene, check [NCache Distributed Lucene page](https://www.alachisoft.com/ncache/distributed-lucene.html).

### 2. Create a Lucene Cache in NCache

We have already [installed and used NCache as a IDistributedCache provider]({% post_url 2022-04-11-DistributedCacheWithNCache %}). This time, let's use NCache version 5.3 to find movies by title or director name using Lucene's full-text search.

Lucene stores data in immutable "segments," which consist of multiple files. We can store these segments in our local file system or in RAM. But, since we're using Lucene with NCache, we're storing these segments in NCache.

Before indexing and searching anything, first, we need to create a Distributed Lucene Cache. Let's navigate to `http://localhost:8251` to fire NCache Web Manager and add a New Distributed Cache.

Let's select "Distributed Lucene" in the Store Type and give it a name. Then, let's add our own machine and a second node. For write operations, we need at least two nodes. We can stick to the defaults for the other options.

By default, NCache stores Lucene indexes in `C:\ProgramData\ncache\lucene-index`.

{% include image.html name="1-StoreType.png" alt="NCache Store Type as Distributed Lucene" caption="NCache Store Type as Distributed Lucene" %}

For more details about these installation options, check [NCache official docs](https://www.alachisoft.com/resources/docs/ncache/getting-started-guide-windows/create-lucene-cache.html).

<figure>
<img src="https://images.unsplash.com/photo-1485095329183-d0797cdc5676?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY1ODYxODA1MQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Movie theater" />

<figcaption>Let's index some movies, shall we? Photo by <a href="https://unsplash.com/@jakehills?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Jake Hills</a> on <a href="https://unsplash.com/s/photos/film?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a></figcaption>
</figure>

### 3. Index Some Movies

After creating the Distributed Lucene cache, let's populate our Lucene indexes with some movies from a Console app. Later, we will search them from another Console app.

First, let's create a Console app to load some movies to the Lucene Cache. Also, let's install the `Lucene.Net.NCache` NuGet package.

In the `Program.cs` file, we could load all movies we want to index from a database or another store. For example, let's use a list of movies from IMDb. Something like this,

```csharp
using SearchMovies.Shared;
using SearchMovies.Shared.Entities;
using SearchMovies.Shared.Services;

var searchService = new SearchService(Config.CacheName);
searchService.LoadMovies(SomeMoviesFromImdb());

Console.WriteLine("Press any key to continue...");
Console.ReadKey();

// This list of movies was taken from IMDb dump
// See: https://www.imdb.com/interfaces/
static IEnumerable<Movie> SomeMoviesFromImdb()
{
    return new List<Movie>
    {
        new Movie("Caged Fury", 1983, 3.8f, 89, new Director("Maurizio Angeloni", 1959), new []{ Genre.Crime,Genre.Drama  }),
        new Movie("Bad Posture", 2011, 6.5f, 93, new Director("Jack Smith", 1932), new []{ Genre.Drama,Genre.Romance  }),
        new Movie("My Flying Wife", 1991, 5.5f, 91, new Director("Franz Bi", 1899), new []{ Genre.Action,Genre.Comedy,Genre.Fantasy  }),
        new Movie("Modern Love", 1990, 5.2f, 105, new Director("Sophie Carlhian", 1962), new []{ Genre.Comedy  }),
        new Movie("Sins", 2012, 2.3f, 84, new Director("Pierre Huyghe", 1962), new []{ Genre.Action, Genre.Thriller  })
        // Some other movies here...
    };
}
```

Notice we used a `SearchService` to handle the index creation in a method called  `LoadMovies()`. Let's take a look at it.

```csharp
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Index;
using Lucene.Net.Store;
using Lucene.Net.Util;
using SearchMovies.Shared.Entities;
using SearchMovies.Shared.Extensions;

namespace SearchMovies.Shared.Services;

public class SearchService
{
    private const string IndexName = "movies";
    private const LuceneVersion luceneVersion = LuceneVersion.LUCENE_48;

    private readonly string _cacheName;

    public SearchService(string cacheName)
    {
        _cacheName = cacheName;
    }

    public void LoadMovies(IEnumerable<Movie> movies)
    {
        using var indexDirectory = NCacheDirectory.Open(_cacheName, IndexName);
        // 1. Opening directory    ^^^

        var standardAnalyzer = new StandardAnalyzer(luceneVersion);
        var indexConfig = new IndexWriterConfig(luceneVersion, standardAnalyzer)
        {
            OpenMode = OpenMode.CREATE
        };
        using var writer = new IndexWriter(indexDirectory, indexConfig);
        // 2. Creating a writer   ^^^

        foreach (var movie in movies)
        {
            var doc = movie.MapToLuceneDocument();
            writer.AddDocument(doc);
            // 3. Adding a document
        }

        writer.Commit();
        // 4. Writing documents
    }
}
```

A bit of background first, Lucene uses documents as the unit of search and index. Documents can have many fields, and we don't need a schema to store them.

We can search documents using any field. Lucene will only return those with that field and matching data. For more details on some Lucene internals, check its [Lucene Quick Start guide](https://lucenenet.apache.org/quick-start/introduction.html).

Notice we started our `LoadMovies` by opening an NCache directory. We needed the same cache name we configured before and an index name. Then we created an `IndexWriter` with our directory and some configurations, like a Lucene version, an analyzer, and an open mode.

Then, we looped through our movies and created a Lucene document for each one using the `MapToLuceneDocument()` extension method. Here it is,

```csharp
using Lucene.Net.Documents;
using SearchMovies.Shared.Entities;

namespace SearchMovies.Shared.Extensions;

public static class MoviesExtensions
{
    public static Document MapToLuceneDocument(this Movie self)
    {
        return new Document
        {
            new TextField("name", self.Name, Field.Store.YES),
            new TextField("directorName", self.Director.Name, Field.Store.YES)
        };
    }
}
```

To create Lucene documents, we used two fields of type `TextField`: movie name and director name. For each field, we need a name and a value to index. We will use the field names later to create a response object from search results.

There are two basic field types for Lucene documents: `TextField` and `StringField`. The first one has support for Full-Text search and the second one supports searching for exact matches.

Once we called the `Commit()` method, NCache stored our movies in a distributed index.

### 4. Full-Text Searching Movies

Now that we populated our index with some movies, to search them, let's create another Console app to read a Lucene query.

Again, let's use the same `SearchService`, this time with a `SearchByNames()` method passing a Lucene query.

```csharp
using Lucene.Net.Analysis.Standard;
using Lucene.Net.Index;
using Lucene.Net.QueryParsers.Classic;
using Lucene.Net.Search;
using Lucene.Net.Store;
using Lucene.Net.Util;
using SearchMovies.Shared.Entities;
using SearchMovies.Shared.Extensions;
using SearchMovies.Shared.Responses;

namespace SearchMovies.Shared.Services;

public class SearchService
{
    // Same SearchService as before...

    public IEnumerable<MovieResponse> SearchByNames(string searchQuery)
    {
        using var indexDirectory = NCacheDirectory.Open(_cacheName, IndexName);
        using var reader = DirectoryReader.Open(indexDirectory);
        //                 ^^^^^^^^^^^^^^^
        // 1. Creating a reader
        var searcher = new IndexSearcher(reader);

        var analyzer = new StandardAnalyzer(luceneVersion);
        var parser = new QueryParser(luceneVersion, "name", analyzer);
        var query = parser.Parse(searchQuery);
        //          ^^^^^^
        // 2. Parsing a Lucene query 

        var documents = searcher.Search(query, 10);
        // 3. Searching documents

        var result = new List<MovieResponse>();
        for (int i = 0; i < documents.TotalHits; i++)
        {
            var document = searcher.Doc(documents.ScoreDocs[i].Doc);
            result.Add(document.MapToMovieResponse());
            // 4. Populating a result object
        }

        return result;
    }
}
```

This time, instead of creating an `IndexWriter`, we used a `DirectoryReader` and a query parser with the same Lucene version and analyzer. Then, we used the `Search()` method with the parsed query and a result count. The next step was to loop through the results and create a response object.

To create a response object from a Lucene document, we used the `MapToMovieResponse()`. Here it is,

```csharp
public static MovieResponse MapToMovieResponse(this Document self)
{
    return new MovieResponse(self.Get("name"), self.Get("directorName"));
}
```

This time, we used the `Get()` method with the same field names as before to retrieve fields from documents.

For example, let's find all movies whose director's name contains "ca", with the query `directorName:ca*`,

{% include image.html name="2-DirectorsWithca.png" alt="Movies with director name contains 'ca'" caption="Movies with director name contains 'ca'" %}

Of course, there are more keywords in [Lucene Query Syntaxt](https://www.lucenetutorial.com/lucene-query-syntax.html).

Voilà! That's how to use Distributed Lucene with NCache. If we already have an implementation with Lucene.NET, we would need few code changes to migrate it to Lucene with NCache. Also, notice that [NCache doesn't implement all Lucene methods](https://www.alachisoft.com/resources/docs/ncache/prog-guide/lucene-ncache.html#not-supported-lucene-api).

To follow along with the code we wrote in this post, check my [Ncache Demo](https://github.com/canro91/NCacheDemo) repository over on GitHub.

[![canro91/NCacheDemo - GitHub](https://gh-card.dev/repos/canro91/NCacheDemo.svg)](https://github.com/canro91/NCacheDemo)

To read more content, check my post [Working with ASP.NET Core IDistributedCache Provider for NCache]({% post_url 2022-04-11-DistributedCacheWithNCache %}) to learn about caching with ASP.NET Core and NCache.

_I wrote this post in collaboration with [Alachisoft](https://www.alachisoft.com/), NCache creators._

_Happy coding!_