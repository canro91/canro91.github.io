---
layout: post
title: "TIL: AutoMapper Only Considers Simple Mappings When Validating Configurations"
tags: csharp todayilearned
---

Oh boy! AutoMapper once again.

Today I have `CreateMovieRequest` with a boolean property `ICanWatchItWithKids` that I want to map to a MPA rating. If I can watch it with kids, the property `MPARating` on the destination type should get a "General" rating. Anything else gets "Restricted."

To my surprise, this test fails:

```csharp
using AutoMapper;

namespace TestProject1;

[TestClass]
public class WhyAutoMapperWhy
{
    public class CreateMovieRequest
    {
        public string Name { get; set; }
        public bool ICanWatchItWithKids { get; set; }
    }

    public class Movie
    {
        public string Name { get; set;}
        public MPARating Rating { get; set;}
    }

    public enum MPARating
    {
        // Sure, there are more.
        // But these two are enough.
        General,
        Restricted
    }

    [TestMethod]
    public void AutoMapperConfig_IsValid()
    {
        var mapperConfig = new MapperConfiguration(options =>
        {
            options.CreateMap<CreateMovieRequest, Movie>(MemberList.Source)
                    .ForMember(
                        dest => dest.Rating,
                        opt => opt.MapFrom(src => src.ICanWatchItWithKids
                                                        ? MPARating.General
                                                        : MPARating.Restricted));
        });

        mapperConfig.AssertConfigurationIsValid();
        //           ^^^^^														
        // AutoMapper.AutoMapperConfigurationException:
        // CreateMovieRequest -> Movie (Source member list)
        // TestProject1.WhyAutoMapperWhy+CreateMovieRequest -> TestProject1.WhyAutoMapperWhy+Movie (Source member list)
        //
        // Unmapped properties:
        // ICanWatchItWithKids
    }
}
```

It turns out that starting from AutoMapper version 10.0, only source members expressions are considered when validating mappings. And it's buried in the [Upgrade Guide here](https://docs.automapper.org/en/latest/10.0-Upgrade-Guide.html#source-validation). Arrggg!

## Two solutions: One for the lazy and the right one

Since I'm validating mappings based on the source type, I can simply ignore it:

```csharp
options.CreateMap<CreateMovieRequest, Movie>(MemberList.Source)
	.ForMember(
		dest => dest.Rating,
		opt => opt.MapFrom(src => src.ICanWatchItWithKids ? MPARating.General : MPARating.Restricted))
	.ForSourceMember(src => src.ICanWatchItWithKids, opt => opt.DoNotValidate());
	// ^^^^^
	// Thanks AutoMapper, I'll take it from here.
```

It feels like cheating, but it works.

Or, I can use a converter:

```csharp
options.CreateMap<CreateMovieRequest, Movie>(MemberList.Source)
	.ForMember(
		dest => dest.Rating,
		opt => opt.ConvertUsing(
				// ^^^^^
				new FromBoolToMPARating(),
				src => src.ICanWatchItWithKids));

// And here's the converter:
public class FromBoolToMPARating : IValueConverter<bool, MPARating>
{
	public MPARating Convert(bool sourceMember, ResolutionContext context)
	{
		// Here's the actual mapping:		
		return sourceMember ? MPARating.General : MPARating.Restricted;
	}
}
```

Another day working with AutoMapper. It would have been way easier mapping that by hand.

For more adventures with AutoMapper, check [How to ignore unmapped fields in the destination type]({% post_url 2025-01-24-IgnoringPropertiesAutoMapper %}).
