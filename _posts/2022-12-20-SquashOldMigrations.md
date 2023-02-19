---
layout: post
title: "Dump and Load to squash old migrations"
tags: csharp tutorial showdev
cover: Cover.png
cover-alt: "Squash racket and ball" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

Recently, I stumbled upon the article [Get Rid of Your Old Database Migrations](https://andrealeopardi.com/posts/get-rid-of-your-old-database-migrations/). The author shows how Clojure, Ruby, and Django use the "Dump and Load" approach to compact or squash old migrations. This is how I implemented the "Dump and Load" approach in one of my client's projects.

## 1. Export database objects and reference data with schemazen

In one of my client's projects, we had too many migration files that we started to group them inside folders named after the year and month. Squashing migrations sounds like a good idea here.

For example, for a three-month project, we wrote 27 migration files. This is the Migrator project,

{% include image.html name="TooManyMigrations.png" caption="27 migration files for a short-term project" alt="List of migration files in one of my projects" width="200px" %}

For those projects, we use [Simple.Migrations to apply migration files]({% post_url 2020-08-15-Simple.Migrations %}) and a bunch of custom C# extension methods to write the `Up()` and `Down()` steps. Since we don't use an all-batteries-included migration framework, I needed to generate the dump of all database objects.

I found [schemazen](https://github.com/sethreno/schemazen) in GitHub, a CLI tool to _"script and create SQL Server objects quickly."_

This is how to script all objects and export data from reference tables with schemazen,

```bash
dotnet schemazen script --server (localdb)\\MSSQLLocalDB
    --database <YourDatabaseName>
    --dataTablesPattern=\"(.*)(Status|Type)$\"
    --scriptDir C:/someDir
```

Notice I used `--dataTablesPattern` option with a regular expression to only export the data from the reference tables. In this project, we named our reference tables with the suffixes "Status" or "Type." For example, `PostStatus` or `ReceiptType`.

I could simply export the objects from SQL Server directly. But those script files contain a lot of noise in the form of default options. Schemazen does it cleanly.

Schemazen generates one folder per object type and one file per object. And it exports data in a TSV format. I didn't find an option to export the INSERT statements in its source code, though.

Schemazen generates a folder structure like this,

```bash
 |-data
 |-defaults
 |-foreign_keys
 |-tables
 props.sql
 schemas.sql
```

After this first step, I had the database objects. But I still needed to write the actual migration file.

<figure>
<img src="https://images.unsplash.com/photo-1592915883536-d44208ad2baf?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&h=400&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTY3MTUwMDEzOA&ixlib=rb-4.0.3&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=600" alt="Piles of used cars and trucks waiting to be recycled" />

<figcaption>Photo by <a href="https://unsplash.com/@randylaybourne?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Randy Laybourne</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
  </figcaption>
</figure>

## 2. Process schemazen exported files

To write the squash migration file, I wanted to have all scripts in a single file and turn the TSV files with the exported data into INSERT statements.

I could write a C# script file, but I wanted to stretch my Bash/Unix muscles. After some Googling, I came up with this,

```bash
# It grabs the output from schemazen and compacts all dump files into a single one
FILE=dump.sql

# Merge all files into a single one
for folder in 'tables/' 'defaults/' 'foreign_keys/'
do
    find $folder -type f \( -name '*.sql' ! -name 'VersionInfo.sql' \) | while read f ;
    do
        cat $f >> $FILE;
    done
done

# Remove GO keywords and blank lines
sed -i '/^GO/d' $FILE
sed -i '/^$/d' $FILE

# Turn tsv files into INSERT statements
for file in data/*tsv;
do
    echo "INSERT INTO $file(Id, Name) VALUES" | sed -e "s/data\///" -e "s/\.tsv//" >> $FILE
    cat $file | awk '{print "("$1",\047"$2"\047),"}' >> $FILE
    echo >> $FILE
    
    sed -i '/^$/d' $FILE
    sed -i '$ s/,$//g' $FILE
done
```

The first part merges all separate object files into a single one. I filtered the `VersionInfo` table. That's Simple.Migration's table to keep track of already applied migrations.

The second part removes the `GO` keywords and blank lines.

And the last part turns the TSV files into INSERT statements. It grabs table names from the file name and removes the base path and the TSV extension. It assumes reference tables only have an id and a name.

With this compact script file, I removed the old migration files except the last one. For the project in the screenshot above, I kept `Migration0027`. Then, I used all the SQL statements from the dump file in the `Up()` step of the migration. I had an squash migration after that.

Voilà! That's how I squashed old migrations in one of my client's projects using schemazen and a Bash script. The idea is to squash our migrations with after stable release of our projects. From the reference article, one commenter said he does this approach one or twice a year. Another one, after every breaking changes. 

By the way, recently, I got interested in the Unix tools again. Check [how to replace keywords in a file name and content with Bash]({% post_url 2022-12-10-ReplaceKeywordInFile %}) and [how to create ASP.NET Core Api project structure with dotnet cli]({% post_url 2022-12-15-CreateProjectStructureWithDotNetCli %}).

_Happy coding!_