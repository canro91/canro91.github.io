---
layout: post
title: "BugOfTheDay: The slow room search"
tags: bugoftheday csharp
---

Another day at work! This time, the room search was running slow. For one of the big hotels, searching all available rooms in a week took about 15 seconds. This is how I optimized the room search functionality.

This room search was a public page to book a room into a hotel without using any external booking system. This page was like a custom Booking.com page. This page used an ASP.NET Core API project to combine data from different internal microservices to display the calendar, room images, and prices of a hotel.

## 1. Room type details

At first glance, I found an N+1 query problem. This is a common anti-pattern. The code called the database per each element from an input set to find more details about each item.

This N+1 problem was in the code to find the details of each room type. The code looked something like this:

```csharp
public async Task<IEnumerable<RoomTypeViewModel>> GetRoomTypesAsync(int hotelId, IEnumerable<int> roomTypeIds)
{
    var tasks = roomTypeIds.Select(roomTypeId => GetRoomTypeAsync(hotelId, roomTypeId));
    //                      ^^^^^
    var results = await Task.WhenAll(tasks);
    return results;
}

public async Task<RoomTypeViewModel> GetRoomTypeAsync(int hotelId, int roomTypeId)
{
    var endpoint = BuildEndpoint(hotelId, roomTypeId);
    var roomClass = await _apiClient.GetJsonAsync<RoomTypeViewModel>(endpoint);
    //                               ^^^^^
    return roomClass;
}
```

These two methods made a request per each room type found, instead of searching more than one room type in a single call. I decided to create a new method to receive a list of room types.

I cloned the existing method in the appropriate microservice and renamed it. The new method received an array of room types. Also, I removed all unneeded queries from the store procedure it used. The store procedure returned three results sets. But, the room search only cared about one.

Before any change, it took ~4 seconds to find a single room type. But, with the new method, it took ~600ms to find more than one room type in a single request. The hotel facing the problem had about 30 different room types. Hurray!

After this first change, the room search made a single request to find all room types.

```csharp
public async Task<IEnumerable<RoomTypeViewModel>> GetRoomTypesAsync(int hotelId, IEnumerable<int> roomTypeIds)
{
    var endpoint = BuildEndpoint(hotelId);
    var roomTypes = await _apiClient.PostJsonAsync<object, IEnumerable<RoomTypeViewModel>>(endpoint,  roomTypeIds);
    return roomTypes;
}
```

But, when calling the room search from Postman, the execution time didn't seem to improve at all. These were some of the times for the room search for one week. What went wrong?

| Room Type | Time in seconds |
|---|---|
| Before | 16.95 18.39 17.13 |
| After  | 19.48 17.61 18.65 |

<figure>
<img src="https://images.unsplash.com/photo-1445019980597-93fa8acb246c?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixlib=rb-4.0.3&q=80&w=600&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA" width="600">

<figcaption>Encuentro Guadalupe, El Porvenir, Mexico. <span>Photo by <a href="https://unsplash.com/@manuelmx?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Manuel Moreno</a> on <a href="https://unsplash.com/s/photos/hotel?utm_source=unsplash&amp;utm_medium=referral&amp;utm_content=creditCopyText">Unsplash</a></span></figcaption>
</figure>

## 2. Premature optimization

To check what happened, I stepped back and went to the room search method again. The room search method looked for all available rooms, the best rates and any restrictions to book a room. This method was something like this: 

```csharp
[Authorize]
[HttpGet]
public async Task<IActionResult> RoomSearchAsync([FromQuery] RoomSearchRequest request)
{   
    var hotelTimeZone = await GetHotelTimeZoneAsync(/* some parameters */);

    var roomListTask = GetRoomListAsync(/* some parameters */);
    var ratesTask = GetRatesAsync(/* some parameters */);
    var rulesTask = GetRulesAsync(/* some parameters */);

    await Task.WhenAll(roomListTask, ratesTask, propertyRulesTask);

    var roomList = await roomListTask;
    var rates = await ratesTask;
    var rules = await rulesTask;

    var roomSearchResults = await PrepareRoomSearchResultsAsync(rates, /* some parameters */);

    var result = new RoomSearchResponse
    {
        Rooms = roomSearchResults,
        Rules = rules
    };

    return Ok(result);
}
```

To find any bottlenecks, I wrapped some parts of the code using the `Stopwatch` class and log the elapsed time of them.

These are the log messages with the execution times before any change looked like this:

```
GetHotelTimeZoneAsync: 486ms
Task.WhenAll: 9641ms
    GetRatesAsync: 9588ms
    GetRoomListAsync: 7008ms
        FindAvailableRoomsAsync: 2792ms
        GetRoomTypesAsync:       4204ms
                                 ^^^^^
    GetRulesAsync: 3030ms
GetRoomTypeGaleriesAsync: 8228ms
```

But, the log after using the new method for room type details showed why it didn't seem to improve. The log looked like this:

```
GetHotelTimeZoneAsync: 616ms
Task.WhenAll: 8726ms
    GetRatesAsync: 8667ms
    GetRoomListAsync: 4171ms
        FindAvailableRoomsAsync: 3602ms
        GetRoomTypesAsync:        559ms
                                  ^^^^^
    GetRulesAsync: 4223ms
GetRoomTypeGaleriesAsync: 11486ms
```

The `GetRoomTypesAsync` method run concurrently next to the `GetRatesAsync` method. This last one was the slowest of the three methods inside the `Task.WhenAll`. That's why there was no noticeable improvement even though the time of the room type call dropped from 4204ms to 559ms. 

> _"Premature optimization is the root of all evil"_
> 
> -Donald Knuth

I was looking at the wrong place! I rushed to optimize without measuring anything. Lesson learned! I needed to start working either on `GetHotelTimeZoneAsync` or `GetRoomTypeGaleriesAsync`. 

## 3. Room gallery

This time to gain noticeable improvement, I moved to the `GetRoomTypeGaleriesAsync` method. Again, this method called another microservice. The code looked like this:

```csharp
public async Task<IEnumerable<RoomGallery>> GetRoomGalleriesAsync(IEnumerable<int> roomTypeIds)
{
    var roomGalleries = await _roomRepository.GetRoomImagesAsync(roomTypeIds);
    if (!roomGalleries.Any())
    {
        return Enumerable.Empty<RoomGallery>();
    }

    var hotelId = roomGalleries.First().HotelId;
    var roomGalleriesTasks = roomGalleries
        .Select(rg => Task.Run(()
        // ^^^^^
            => MapToRoomGallery(rg.RoomTypeId, hotelId, roomGalleries)));

    return (await Task.WhenAll(roomGalleriesTasks)).AsEnumerable();
}

private RoomGallery MapToRoomGallery(int roomTypeId, int hotelId, IEnumerable<RoomImageInfo> roomGalleries)
{
    return new RoomGallery
    {
        RoomTypeId = roomTypeId,
        HotelId = hotelId,
        Images = roomGalleries.Where(p => p.RoomTypeId == roomTypeId)
        //                     ^^^^^
            .OrderBy(x => x.SortOrder)
            .Select(r => new Image
            {
                // Some mapping code here...
            })
    };
}
```

The `MapToRoomGallery` method was the problem. It filtered the collection of result images, `roomGalleries` with every element. Basically, it was a nested loop over the same collection, an `O(nm)` operation. Also, since all the code was synchronous, there was no need for `Task.Run` and `Task.WhenAll`.

To fix this problem, I grouped the images by room type first. And then, I passed a filtered collection to the mapping method, `MapToRoomGallery`.

```csharp
public async Task<IEnumerable<RoomGallery>> GetRoomGalleriesAsync(IEnumerable<int> roomTypeIds)
{
    var images = await _roomRepository.GetRoomImagesAsync(roomTypeIds);
    if (!images.Any())
    {
        return Enumerable.Empty<RoomGallery>();
    }

    var hotelId = images.First().HotelId;
    var imagesByRoomTypeId = images.GroupBy(t => t.RoomTypeId, (key, result) => new { RoomTypeId = key, Images = result });
    //                              ^^^^^
    var roomGalleries = imagesByRoomTypeId.Select(rg =>
    {
        return MapToRoomGallery(rg.RoomTypeId, hotelId, rg.Images);
    });
    return roomGalleries;
}

private RoomGallery MapToRoomGallery(int roomTypeId, int hotelId, IEnumerable<RoomImageInfo> roomGalleries)
{
    return new RoomGallery
    {
        RoomTypeId = roomTypeId,
        HotelId = hotelId,
        Images = roomGalleries.OrderBy(x => x.SortOrder)
        //                     ^^^^^
            .Select(r => new Image
            {
                // Some mapping code here
            })
    };
}
```

After changing those three lines of code, the image gallery times went from ~4sec to ~900ms. And, the initial room search improved in ~2-3sec. The hotel with the slowness issue had about 70 images. It was a step in the right direction.

These are the times of three requests to the initial room search using Postman:

| Room Gallery | Time in seconds |
|---|---|
| Before | 13.96 13.49 17.64 |
| After  | 11.74 11.19 11.23 |

When checking the log, the room search had a noticeable improvement for the `GetRoomClassGaleriesAsync` method. From ~8-11s to ~3-4s. Only by changing three lines of code.

```
GetHotelTimeZoneAsync: 182ms
Task.WhenAll: 8349ms
    GetRatesAsync: 8342ms
    GetRoomListAsync: 2886ms
        FindAvailableRoomsAsync: 2618ms
        GetRoomTypesAsync:        263ms
    GetRulesAsync: 2376ms
GetRoomClassGaleriesAsync: 3586ms
                           ^^^^^ It was ~11sec
                           
```

## 4. Room rates

To make things faster, I needed to tackle the slowest of the methods inside the `Task.WhenAll`, the `GetRatesAsync` method. It looked like this:

```csharp
protected async Task<IEnumerable<BestRateViewModel>> GetRatesAsync(int hotelId, /* some other parameters */)
{
    var bestRatesRequest = new BestRatesRequest
    {
        // Some mapping code here
    };
    var bestRates = await _rateService.GetBestRatesAsync(bestRatesRequest);
    if (!bestRates.Any())
    {
        return Enumerable.Empty<BestRateViewModel>();
    }

    await UpdateRateDetailsAsync(bestRates, rateIds);
    await UpdatePackagesAsync(bestRates, hotelId);

    return bestRates;
}
```

Also, I logged the execution time of three more methods inside the `GetRatesAsync`. The log showed these entries:

```
GetHotelTimeZoneAsync: 530ms
Task.WhenAll: 12075ms
    GetRatesAsync: 12060ms
        GetBestRates: 5075ms
        UpdateRateDetailsAsync: 5741ms
                                ^^^^^
        UpdatePackagesAsync: 1222ms
    GetRoomListAsync: 3774ms
        FindAvailableRoomsAsync: 2555ms
        GetRoomTypesAsync:       1209ms
    GetRulesAsync: 2772ms
GetRoomClassGaleriesAsync: 4851ms
```

Among the inner methods was the `UpdateRateDetailsAsync` method. This method called an endpoint in another microservice for rates details. The method was something like this:

```csharp
[HttpPost]
public async Task<IEnumerable<RateDetailViewModel>> GetRateDetailsAsync([FromBody] int[] rateIds)
{    
    var results = new List<RateDetailViewModel>();
    foreach (var rateId in rateIds)
    // ^^^^^
    {
        if (rateId <= 0)
        {
            results.Add(new RateDetailViewModel
            {
                RateId = rateId,
                Error = $"Invalid Rate Id: {rateId}"
            });
            continue;
        }
        
        try
        {
            var result = await _rateService.GetRateDetailAsync(rateId);
            //                              ^^^^^
            results.Add(new RateDetailViewModel
            {
                RateId = rateId,
                Data = result
            });
        }
        catch (Exception e)
        {
            results.Add(new RateDetailViewModel
            {
                RateId = rateId,
                Error = e.Message
            });
        }
    }

    return results;
}
```

Again, the N+1 query anti-pattern. Arrgggg! The hotel with the slowness issue had ~10 rates, it means 10 separate database calls. To fix this issue, I changed  the code to validate all input ids and return early if there wasn't any valid id to call the database. Then, I made a single request to the database. Either it succeeded or failed for all the valid input ids.


```csharp
[HttpPost]
public async Task<IEnumerable<RateDetailViewModel>> GetRateDetailsAsync([FromBody] int[] rateIds)
{
    var results = rateIds.Where(rateId => rateId <= 0)
                        .Select(rateId => new RateDetailResultViewModel
                        {
                            RateId = rateId,
                            Error = $"Invalid Rate Id: {rateId}"
                        });
    if (results.Count() == rateIds.Length)
    // ^^^^^
    {
        return results;
    }

    var validRateIds = rateIds.Where(rateId => rateId > 0);

    try
    {
        var details = await m_rateService.GetRateDetailsAsync(validRateIds);
        //                                ^^^^^
        results = results.Concat(BuildRateDetailViewModels(validRateIds, details));
    }
    catch (Exception e)
    {
        var resultViewModels = validRateIds.Select(rateId => new RateDetailViewModel
        {
            RateId = rateId,
            Error = e.Message
        });
        results = results.Concat(resultViewModels);
    }

    return results;
}
```

After removing this N+1 problem, the execution time of getting details for ~10 rates went from ~1.6s to ~200-300ms. For three consecutive calls, these were the times of calling the modified rate method from Postman:

| Room Rates | Time in milliseconds |
|---|---|
| Before | 1402 1868 1201 |
| After  |  198  272  208 |

Also, the room search improved in ~2-3sec for 1-week range. The log showed these improvements too.

```
GetHotelTimeZoneAsync: 194ms
Task.WhenAll: 8349ms
    GetRatesAsync: 10838ms
        GetBestRates: 8072ms
        UpdateRateDetailsAsync: 2198ms
                                ^^^^^ It was ~5sec
        UpdatePackagesAsync: 557ms
    GetRoomListAsync: 3207ms
        FindAvailableRoomsAsync: 2982ms
        GetRoomTypesAsync:        218ms
    GetRulesAsync: 3084ms
GetRoomClassGaleriesAsync: 6370ms
```

It was the last low-hanging fruit issue I addressed. After the above three changes, the initial room search went from ~15-18sec to ~10-14sec. It was ~5 seconds faster.

These were the times of three requests to the room search after all these changes: 

| All changes | Time in seconds |
|---|---|
| Before | 16.95 18.39 17.13 15.36 |
| After | 11.36 10.46 14.62 10.38 |

## Conclusion

Voilà! That's how I optimized the room search functionality. Five seconds faster don't seem too much. But, that's the difference between someone booking a room in a hotel and someone leaving the page to find another hotel.

From this task, I learned two things. First, don't assume a bottleneck is here or there until you measure it. And, avoid the N+1 query anti-pattern and nested loops on large collections.

I didn't mess with any store procedure or SQL query trying to optimize it. But, I had some metrics in place and identified which was the store procedures to tune.

To find the bottlenecks, I took the simplest route wrapping methods with a `Stopwatch`, the next time I will use another alternative like [MiniProfiler](https://github.com/MiniProfiler/dotnet). 

The next step I tried was to cache the hotel timezone and other details. Until a hotel changes its address, its timezone won't change. You can take a look at my post on [how to add a caching layer with Redis and ASP.NET Core](https://canro91.github.io/2020/06/29/HowToAddACacheLayer/) for more details.

_Happy coding!_
