---
layout: post
title: "TIL: How To Ignore Unmapped Fields in the Destination Type With AutoMapper"
tags: csharp todayilearned
---

Another day working with AutoMapper, another day with an edge case.

Let's say we have class `CreateMovieRequest` with three properties: name, release year, and another property I don't want to map, for some reason. And a destination class, `Movie`, with more properties apart from those three and names using a prefix.

Simply trying to use `CreateMap<CreateMovieRequest, Movie>()` won't work. AutoMapper will warn you about unmapped properties in the destination type. "Unmapped members were found. Review the types and members below."

Here's how to map two classes ignoring the unmapped properties in the destination type and with prefixes:

```csharp
using AutoMapper;

namespace TestProject1;

[TestClass]
public class IHateYouWilWheaton
{
    public record CreateMovieRequest(
        string Name,
        int ReleaseYear,
        string IDontWantThisOneMapped);

    public record Movie(
        // These two aren't mapped from the source
        int Id,
        int DurationInMinutes,
        // These two have the 'Movie' prefix
        string MovieName,
        int MovieReleaseYear);

    [TestMethod]
    public void IgnoringNotMappedProps()
    {
        var config = new MapperConfiguration(cfg =>
        {
            // Let's keep it here, shall we?
            cfg.RecognizeDestinationPrefixes("Movie");
            //  ^^^^^
            // To avoid explicitly mapping the fields because of the prefix

            // Before:
            // cfg.CreateMap<CreateMovieRequest, Movie>();
            //     ^^^^^
            // AutoMapper.AutoMapperConfigurationException: 
            // Unmapped members were found. Review the types and members below.
            // ...
            // Unmapped properties:
            // Id
            // MovieName
            // DurationInMinutes
            //
            //
            // After:
            cfg.CreateMap<CreateMovieRequest, Movie>(MemberList.Source)
                //                                   ^^^^^
                // To validate unmapped properties on the source type
                // Possible options: Source, Destination, and None			
                .ForSourceMember(src => src.IDontWantThisOneMapped, opt => opt.DoNotValidate());
                // ^^^^^
                // Since I don't want this one mapped for some reason
        });
        config.AssertConfigurationIsValid();

        var source = new CreateMovieRequest
        {
            Name = "Space Odyssey",
            ReleaseYear = 1968,
            IDontWantThisOneMapped = "Ok, if you say so"
        };

        var mapper = config.CreateMapper();
        var destination = mapper.Map<Movie>(source);

        Assert.AreEqual(destination.MovieName, source.Name);
        Assert.AreEqual(destination.MovieReleaseYear, source.ReleaseYear);
    }
}
```

The trick for prefixes is `RecognizeDestinationPrefixes()` and the one for warnings is passing any of `Source`, `Destination`, or `None` as a parameter to `Map()`.

And to ignore an "incoming" property, `ForSourceMember()`, with `DoNotValidate()`.

Et voilà!
