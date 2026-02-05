---
layout: post
title: "TIL: Blazor Breaks When Others Touch the DOM"
tags: bugoftheday todayilearned csharp
---

In another episode of _Adventures with Blazor_...

Once more, I ran into the mysterious _"TypeError: Cannot read properties of null (reading 'removeChild')"_. But unlike [the last time]({% post_url 2025-12-09-Debugging %}), it wasn't a problem in a third-party component that we had to replace. It was my fault.

Wouldn't it be great if the error message mentioned which property was null: an id, xpath, or CSS class?

This time, a modal created a record and showed a success alert. But after dismissing it and closing the modal, the page broke with the same error.

Here's a Blazor page that recreates the scenario. A simple modal with a form that shows an alert bound to a `_directorSavedSuccessfully`. Notice the `<div>` wrapped around the `@if` inside the `<BodyContent>`.

```xml
@page "/directors"

<button class="btn btn-primary" @onclick="AddDirectorClicked">Add Director</button>

<ModalDialog Title="Add Director" @ref="_editDialog">
    <BodyContent>
		@if (_directorSavedSuccessfully)
		{
			<div class="alert alert-success alert-dismissible fade show" role="alert">
				Director saved successfully.
				<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
				@*                                      ^^^^^ *@
			</div>
		}

		<EditForm Model="_editDirector" OnValidSubmit="SaveDirectorClicked" id="directorForm">
			<InputText @bind-Value="_editDirector.Name" class="form-control" />
		</EditForm>
    </BodyContent>
    <FooterContent>
        <button type="button" class="btn btn-secondary" @onclick="CloseClicked">Close</button>
        <button type="submit" form="directorForm" class="btn btn-primary">Save</button>
    </FooterContent>
</ModalDialog>

@code {
    private ModalDialog? _editDialog;
    private bool _directorSavedSuccessfully;
    private Director _director;

    private void AddDirectorClicked()
    {
        _directorSavedSuccessfully = false;
        _editDialog?.Open();
    }

    private Task SaveDirectorClicked()
    {
        // Imagine we're calling an API here to save...
        _directorSavedSuccessfully = true;

        return Task.CompletedTask;
    }

    private void CloseClicked()
    {
        _directorSavedSuccessfully = false;
        _editDialog?.Close();
    }
}
```

Bootstrap removed the alert node directly, via the `data-bs-dismiss="alert"`. But Blazor was still "tracking" it. So when the modal was closed, Blazor didn't find the alert. Somebody else ate its cheese. And boom!

The solution? Don't let anything else touch the DOM, but Blazor. Wire that alert to a variable controlled by Blazor.

```diff
-<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
+<button type="button" class="btn-close" @onclick="_ => _directorSavedSuccessfully = false" aria-label="Close"></button>
```

Et voilà! Let Blazor own the DOM.

For debugging and problem-solving tips, read [Street-Smart Coding](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=blazor-breaks-others-touch-dom). And it's even more relevant now in the era of AI-assisted coding.
