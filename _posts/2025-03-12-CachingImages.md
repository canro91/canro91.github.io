---
layout: post
title: "TIL: Caching Trolls You When Serving Images With Unchanged URLs"
tags: todayilearned bugoftheday
---

Oh, boy! It took me like 3 hours to figure this out.

Here's the thing: I had a CRUD app with Blazor. In the Update page, I could change images—let's say, a hinge and other parts used to build a closet. Nothing fancy.

## The problem?

After updating the image and redirecting back to the List page, it still showed the previous image. Whaaat?! The API endpoint did update the image.

Since I can't show you the real code, for obvious reasons, here's a little corner of the app, 

{% include image.html name="CachingImages.gif" caption="After updating my image, it still showed the old one. Arrggg!" alt="Caching images" width="900px" %}

It only worked after pressing F5, to reload the entire page.

I tried to solve it by forcing a reload when redirecting from the Update page back to the List page. Like this,

```csharp
private async Task OnSaveClicked(IBrowserFile? image)
{
    var response = await MyHttpService.HttpPut<SomePutResponse>("api/my-cool-endpoint", _someUpdateRequest);

    if (response != null && image != null)
    {
        await MyHttpService.HttpPostFile<SomeImageResponse>("api/another-cool-endpoint", image);
    }

    NavManager.NavigateTo(Index.Route, forceLoad: true);
    //                                 ^^^^^
}
```

But sometimes it still showed the old image. Arrggg!

After googling for a while, [this SO answer](https://stackoverflow.com/questions/4495316/how-do-i-clear-the-image-cache-after-editing-an-image-on-my-site) saved my day. It was the browser trolling me all that time.

OK, the API endpoint powering the List page returned a public URL of every image, served from the same server. Every image file was named after the related object ID, something like `/public-files/acme-corp/my-cool-object/123.png`

Even though the backend changed the images, their URLs were the same. And the browser didn't notice anything new, so it kept showing the same image, without requesting it from the server.

## The solution?

Append a timestamp to every URL. [Audit fields are helpful here]({% post_url 2022-12-11-AuditFieldsWithOrmLite %})...I ended up appending the modification date of every image. Like this,

```csharp
public string GetPublicUrl(string path)
{
    var publicUrl = $"/files/{_companyName}/{path}";
    var modificationAt = GetLastModificationDate(Path.Combine(_someBasePath, path));

    return $"{publicUrl}?ts={modificationAt:HHmmssfff}";
}

private static DateTime GetLastModificationDate(string absolutePath)
{
    try
    {
        var file = new FileInfo(absolutePath);
        return file.LastWriteTimeUtc;
    }
    catch
    {
        return DateTime.UtcNow;
    }
}
```

Kudos to StackOverflow. Caching trolled me. Again. Total facepalm!
