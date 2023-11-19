---
layout: post
title: "How to automatically format SQL files with Git and Poor Man's T-SQL Formatter"
tags: sql git productivity showdev
cover: Cover.png
cover-alt: "Rules on a workbench" 
---

I believe we shouldn't discuss formatting and linting during code reviews. That should be automated. With that in mind, these days, I learned how to automatically format SQL files with Git and Poor Man's T-SQL Formatter for one of my client's projects.

I already shared about [two free tools to format SQL files]({% post_url 2020-09-30-FormatSQL %}). Poor Man's T-SQL Formatter is one of the two. It's free and open source.

## 1. Format SQL files on commits

I wanted to format my SQL files as part of my development workflow. I thought about a pre-commit Git hook for that. I was already familiar with Git hooks since I use one to [put task numbers from branch names into commit messages]({% post_url 2020-09-02-TwoRecurringReviewComments %}).

After searching online, I found a Bash script to list all created, modified, and renamed files before committing them. I used [Phind](https://www.phind.com/), "the AI search engine for developers." These are the query I used:

* "How to create a git commit hook that lists all files with .sql extension?" and as a follow-up,
* "What are all possible options for the parameter --diff-filter on the git diff command?"

Also, I found out that Poor Man's T-SQL Formatter is available as a [Node.js command utility](https://github.com/TaoK/poor-mans-t-sql-formatter-npm-cli).

Using these two pieces, this is the pre-commit file I came up with,

```bash
#!/bin/sh

files=$(git diff --cached --name-only --diff-filter=ACMR)
[ -z "$files" ] && exit 0

for file in "${files[@]}"
do
    if [[ $file == *.sql ]]
    then
        echo "Formatting: $file"

        # 1. Prettify it
        sqlformat -f "$file" -g "$file" --breakJoinOnSections --no-trailingCommas --spaceAfterExpandedComma

        # 2. Add it back to the staging area
        git add $file
    fi
done

exit 0
```

I used these three options: `--breakJoinOnSections`, `--no-trailingCommas`, and `--spaceAfterExpandedComma` to place ONs after JOINs and commas on a new line.

## 2. Test the pre-commit hook

To test this Git hook, I created an empty repository, saved the above Bash script into a `pre-commit` file inside the `.git/hooks` folder, and installed the `poor-mans-t-sql-formatter-cli` package version 1.6.10.

For the actual SQL file, I used the query to find StackOverflow posts with many "thank you" answers, [Source](https://data.stackexchange.com/stackoverflow/query/886/posts-with-many-thank-you-answers),

```sql
select ParentId as [Post Link], count(id)
from posts
where posttypeid = 2 and len(body) <= 200
  and (body like '%hank%')
group by parentid
having count(id) > 1
order by count(id) desc;
```

This is where all the magic happened when committing the previous SQL file,

{% include image.html name="Console.png" alt="Sequence of Git commands to commit a file" caption="Committing a ThankYou.sql file and seeing the magic happening" width="800px" %}

By the way, I use [some Git alias]({% post_url 2020-04-13-ProgramThatSave100Hours %}) as part of my development workflow.

And this is the formatted SQL file,

```sql
SELECT ParentId AS [Post Link]
	, count(id)
FROM posts
WHERE posttypeid = 2
	AND len(body) <= 200
	AND (body LIKE '%hank%')
GROUP BY parentid
HAVING count(id) > 1
ORDER BY count(id) DESC;
```

Voilà! That's how to format SQL files automatically with Git. The command line version of Poor Man's T-SQL Formatter is not that fast. But it's still faster than copying a SQL file, firing a browser with an online linter, formatting it, and pasting it back.

Poor Man's T-SQL Formatter might not be perfect, but with a simple change in our script, we can bring any other SQL formatter we can call from the command line.

After this trick, I don't want to leave or read another comment like "please format this file" during code review.

For more content, check [my guide to Code Reviews]({% post_url 2019-12-17-BetterCodeReviews %}), [my Visual Studio setup for C#]({% post_url 2019-06-28-MyVSSetupSharpeningTheAxe %}), and the [lessons I've learned as a code reviewer]({% post_url 2022-12-19-LessonsAsReviewer %}).

_Happy coding!_