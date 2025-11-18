---
layout: post
title: "BugOfTheDay: Blazor Input Control Won't Turn Red"
tags: csharp bugoftheday
---

In another episode of Adventures with Blazor, I ran into a sneaky bug with custom input validation.

This time I had an input control to enter sizes and lengths in either inches or millimeters based on a flag per client. When the bound value was missing, the border didn't turn red.

Here's a form using a custom `MeasurementInput`,

```html
@* MyCoolForm.razor *@
<EditForm Model="MyCoolRequest" OnValidSubmit="OnValidSubmit">
	<DataAnnotationsValidator />
	<ValidationSummary />

	<div class="row">
		<div class="col-sm-3">
			<label for="length" class="form-label">Length</label>
			<MeasurementInput id="length" @bind-Value="MyCoolRequest.Length" class="form-control" />
			@* ^^^^^ *@
			@* A custom input. Notice the class attribute *@
			<ValidationMessage For="() => MyCoolRequest.Length" class="invalid-feedback" />
		</div>
	</div>

	<button type="submit" class="btn btn-primary">@SubmitButtonText</button>
</EditForm>
```

And here's the actual `MeasurementInput`,

```html
@* MeasurementInput.razor *@
@inherits InputBase<Measurement>

<input class="@CssClass" @attributes="AdditionalAttributes" @bind="CurrentValueAsString" type="text" />
@*     ^^^^^ *@
@* Notice the class attribute here *@

@code
{
    [Parameter]
    public bool? ShouldUseInches { get; set; } = true;

    protected override string? FormatValueAsString(Measurement? value)
    {
        // Format as inches or millimeters
    }

    protected override bool TryParseValueFromString(string? value, out Measurement? result, [NotNullWhen(false)] out string? validationErrorMessage)
    {
        // Validate and parse from inches or millimeters
    }
}
```

After hours of debugging, I found the input style never applied the `is-invalid` class.

The fix? Two lines of code changed,

```diff
-<input class="@CssClass" @attributes="AdditionalAttributes" @bind="CurrentValueAsString" type="text" />
+<input class="form-control @CssClass" @attributes="AdditionalAttributes" @bind="CurrentValueAsString" type="text" />
```

```diff
-<MeasurementInput id="length" @bind-Value="MyCoolRequest.Length" class="form-control" />
+<MeasurementInput id="length" @bind-Value="MyCoolRequest.Length" />
```

Two class attributes: one in the input, one in the form. Arrggg! A full day lost to two lines of code. [Source](https://chrissainty.com/building-custom-input-components-for-blazor-using-inputbase/).

This tiny bug reminded me that coding isn't just about syntax. It's about searching, finding answers, and asking for help.

Even with AI, those skills remain essential for new coders. That's why I start my book, _Street-Smart Coding: 30 Ways to Get Better at Coding,_ with them. It's the practical guide I wish I had on my journey from junior to senior.

[Get your copy of Street-Smart Coding here](https://imcsarag.gumroad.com/l/streetsmartcoding/?utm_source=blog&utm_medium=post&utm_campaign=blazor-input-control-wont-turn-red)
