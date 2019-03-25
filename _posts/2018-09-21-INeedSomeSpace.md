---
layout: post
title: I need some space, the database said
description: How to select and post-process database records with Insight.Database
---

Imagine one day you come to your workplace and you get this new task. You have to connect your code to a legacy database system to extract some data, do some processing and notify back. But, you realize all string fields are rigth-padded with whitespace. What can you do now?

First, the obvious solution. Manually trim all columns, but this could be boring if there are lots of fields to extract. And, this solution won't cover new fields. So, there must be a better solution.

One alternative is to do some post-processing with your ORM of choise after reading your records. Use [Insight.Database](https://github.com/jonwagner/Insight.Database). It provides a mechanism to do additional changes to each record after they are read. So, you can use a method to trim all string properties.

```csharp
using (var connection = new SqlConnection(_ConnectionString))
{
    var someRecords = connection.QuerySql(
                $@"SELECT * FROM SCHEMA.TABLE",
                Parameters.Empty,
                Query.Returns(TrimRecords));

    return someRecords;
}

private readonly PostProcessRecordReader<RawRecord> TrimRecords
	= new PostProcessRecordReader<RawRecord>((reader, record) =>
    {
        if (record != null)
        {
            record.TrimAllStrings();
        }

        return record;
    });
```

Now, you could use Reflection to trim all string properties of your dto's. Also, you can annotate your dto's to avoid trimming some properties.

```csharp
[AttributeUsage(AttributeTargets.Property)]
public sealed class DoNotTrimAttribute : Attribute
{
}

public static class ObjectExtensions
{
    public static void TrimAllStrings<TSelf>(this TSelf obj)
    {
        BindingFlags flags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.FlattenHierarchy;

        foreach (PropertyInfo p in obj.GetType().GetProperties(flags))
        {
            if (Attribute.IsDefined(p, typeof(DoNotTrimAttribute)))
                continue;

            Type currentNodeType = p.PropertyType;
            Object value = p.GetValue(obj, null);
            if (value == null)
                continue;

            if (value is String str)
            {
                p.SetValue(obj, str.Trim(), null);
            }
            else if (value is IEnumerable collection)
            {
                foreach (var e in collection)
                {
                    e.TrimAllStrings();
                }
            }
            else if (currentNodeType != typeof(object) && Type.GetTypeCode(currentNodeType) == TypeCode.Object)
            {
                value.TrimAllStrings();
            }
        }
    }
}
```

That's all, folks! Now, all your string properties are trimmed. Your code isn't full of `Trim` methods after every property, so you won't forget to trim new properties.