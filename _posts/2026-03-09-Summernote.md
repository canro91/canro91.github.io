---
layout: post
title: "Building a Reusable Blazor Component for Summernote"
tags: csharp todayilearned
---

_In another adventure with Blazor..._

While migrating a legacy app, I had to "componentize" an HTML editor. It used [Summernote](https://summernote.org/getting-started/), _"a super simple WYSIWYG editor on Bootstrap"_.

The fun part was learning JavaScript interop: [calling JavaScript from .NET](https://learn.microsoft.com/en-us/aspnet/core/blazor/javascript-interoperability/call-javascript-from-dotnet?view=aspnetcore-10.0#invoke-js-functions) and [viceversa](https://learn.microsoft.com/en-us/aspnet/core/blazor/javascript-interoperability/call-dotnet-from-javascript?view=aspnetcore-10.0#pass-a-dotnetobjectreference-to-an-individual-javascript-function).

After some Googling and sneaking into abandoned GitHub repos, here's what I came up with:

## The component

In Summernote.razor:

```csharp
@using Microsoft.AspNetCore.Components.Sections

<HeadContent>
    <link rel="stylesheet" href="css/summernote.css" />
</HeadContent>

<div id="@_id">@((MarkupString)Value)</div>

<SectionContent SectionName="scripts">
    <script src="js/summernote.js" type="text/javascript"></script>
</SectionContent>
```

In Summernote.razor.cs:

```csharp
using Microsoft.AspNetCore.Components;
using Microsoft.JSInterop;

namespace MyCoolComponents.HtmlEditor;

public partial class Summernote : IAsyncDisposable
{
    private readonly string _id = $"summernote_{Guid.NewGuid()}";

    private IJSObjectReference? _module;
    private DotNetObjectReference<Summernote>? _dotnetRef;
    private bool _editorInitialized = false;

    [Parameter]
    public string Value { get; set; }

    [Parameter]
    public EventCallback<string> ValueChanged { get; set; }

    [Inject]
    public IJSRuntime JsRuntime { get; set; } = default!;

    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        if (!_editorInitialized)
        {
            _dotnetRef = DotNetObjectReference.Create(this);

            _module = await JsRuntime.InvokeAsync<IJSObjectReference>("import", "./PutYourPathHere/Summernote.razor.js");
            await _module.InvokeVoidAsync("edit", _id, _dotnetRef, nameof(OnTextChange));

            _editorInitialized = true;
        }
    }

    [JSInvokable]
    public async Task OnTextChange(string editorText)
    {
        Value = editorText;
        await ValueChanged.InvokeAsync(editorText);
    }

    public async ValueTask DisposeAsync()
    {
        if (_module is not null)
        {
            await _module.DisposeAsync();
        }

        _dotnetRef?.Dispose();
    }
}
```

Here's where the magic happens.

After rendering the component, it calls a JavaScript function that initializes the Summernote editor. Then, it registers a callback that calls a .NET function every time the editor changes to update the component state.

Notice it stores content in a `MarkupString` but it binds as a string.

In Summernote.razor.js:

```javascript
export function edit(id, dotnetRef, callback) {
    let snid = '#' + id;
    $(snid).summernote({
        callbacks: {
            onChange: function (contents, $editable) {
                dotnetRef.invokeMethodAsync(callback, contents);
            }
        }
    });
}
```

## How to use it

And here's a sample form using the editor:

```csharp
@using MyCoolComponents.HtmlEditor

<EditForm Model="MyCoolRequest" OnValidSubmit="OnValidSubmit">
    <DataAnnotationsValidator />
    <ValidationSummary />

    <div class="row">
        <div class="form-group col-sm-9">
            <label for="content" class="form-label">Content</label>
            <Summernote @bind-Value="Annotation.Content" />
            @* ^^^^^ *@
            @* Look, Ma! It works! *@
            <ValidationMessage For="() => Annotation.Content" class="invalid-feedback" />
        </div>
    </div>

    <button type="submit" class="btn btn-primary">Submit</button>
</EditForm>
```

This piece of code is _provided "as is", without warranty of any kind_...Blah, blah, blah. Use under your own risk. Steal it.

If this helped you, you'll love [Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding?utm_source=blog&utm_medium=post&utm_campaign=blazor-component-summernote)—30 proven lessons to help you level up your coding journey.
