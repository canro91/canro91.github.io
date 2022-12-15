---
layout: post
title: "How to create ASP.NET Core Api project structure with dotnet cli"
tags: tutorial csharp
cover: Cover.png
cover-alt: "Architect workbench" 
---

_This post is part of [my Advent of Code 2022]({% post_url 2022-12-01-AdventOfCode2022 %})._

While looking at [C# Advent 2022](https://csadvent.christmas/), I found the Humble Toolsmith page and its post [Create Test Solutions by Scripting the Dotnet CLI](https://humbletoolsmith.com/2022/08/18/quickly-create-test-solutions-by-scripting-the-dotnet-cli/).

That post reminded me I have my own script to create the folder structure for ASP.NET Core API projects. Currently, I work with a client where I have to engage in short (3-5 month) projects. Every now and then, I create new projects. And these are the types of tasks we don't do often and always forget how to do it. Why not scripting it!

## How to create project structure with dotnet cli

This is the script I use to create the source and test projects with the references between them for an ASP.NET Core API project:

```bash
# Change to suit your own needs
Prefix=Acme.CoolProject
#      ^^^^^
# Change it to use your project name prefix

# 1. Create solution
dotnet new sln --name $Prefix.Api

# 2. Create src projects
# Create class libraries
for name in 'Data' 'Domain' 'Infrastructure' 'Messages'
do
# Optionally:
# dotnet new classlib -o $Prefix.$name/src -n $name
dotnet new classlib -o src/$Prefix.$name
dotnet sln add src/$Prefix.$name/$Prefix.$name.csproj --in-root
done

# Create Console projects
dotnet new console -o src/$Prefix.Data.Migrator
dotnet sln add src/$Prefix.Data.Migrator/$Prefix.Data.Migrator.csproj --in-root

# Create Api projects
dotnet new webapi -o src/$Prefix.Api
dotnet sln add src/$Prefix.Api/$Prefix.Api.csproj --in-root

# Api depends on Data, Infrastructure, and Messages
for dependsOn in 'Data' 'Infrastructure' 'Messages'
do
dotnet add src/$Prefix.Api/$Prefix.Api.csproj reference src/$Prefix.$dependsOn/$Prefix.$dependsOn.csproj
done

# Data depends on Domain and Infrastructure
for dependsOn in 'Domain' 'Infrastructure'
do
dotnet add src/$Prefix.Data/$Prefix.Data.csproj reference src/$Prefix.$dependsOn/$Prefix.$dependsOn.csproj
done

# Data.Migrator depends on Data
dotnet add src/$Prefix.Data.Migrator/$Prefix.Data.Migrator.csproj reference src/$Prefix.Data/$Prefix.Data.csproj

# Infrastructure depends on Domain and Messages
for dependsOn in 'Domain' 'Messages'
do
dotnet add src/$Prefix.Infrastructure/$Prefix.Infrastructure.csproj reference src/$Prefix.$dependsOn/$Prefix.$dependsOn.csproj
done

# 3. Create test projects
for name in 'Api' 'Data' 'Domain' 'Infrastructure'
do
dotnet new mstest -o tests/$Prefix.$name.Tests
dotnet sln add tests/$Prefix.$name.Tests/$Prefix.$name.Tests.csproj -s Tests
dotnet add tests/$Prefix.$name.Tests/$Prefix.$name.Tests.csproj reference src/$Prefix.$name/$Prefix.$name.csproj
done

# 4. Copy template files
# .gitignore, .editorconfig, .dockerignore
# Copy dotfiles
for file in $(ls -I "*.cs" ~/Documents/_Projects/_FolderStructure/Templates/)
do
cp ~/Documents/_Projects/_FolderStructure/Templates/$file .
done

# 5. Cleanup
find . -name "WeatherForecastController.cs" -type f -delete
find . -name "WeatherForecast.cs" -type f -delete

find . -name "Class1.cs" -type f -delete
find . -name "UnitTest1.cs" -type f -delete
```

When I need to create a new project, I only change the `Prefix` at the top of the file.

Notice this script copies some template files (.gitignore, .editorconfig, .dockerignore) from a shared location.

This script creates a project structure like this:

{% include image.html name="ProjectListInVS.png" alt="Project list in Visual Studio" caption="ASP.NET Core Api project structure inside Visual Studio" %}

And a folder structure like this:

```bash
│   Acme.CoolProject.Api.sln
├───src
│   ├───Acme.CoolProject.Api
│   ├───Acme.CoolProject.Data
│   ├───Acme.CoolProject.Data.Migrator
│   ├───Acme.CoolProject.Domain
│   ├───Acme.CoolProject.Infrastructure
│   └───Acme.CoolProject.Messages
└───tests
    ├───Acme.CoolProject.Api.Tests
    ├───Acme.CoolProject.Data.Tests
    ├───Acme.CoolProject.Domain.Tests
    └───Acme.CoolProject.Infrastructure.Tests
```

In the Messages project, I put input and output view models. And, when doing CQRS, I put commands and queries. In the Migrator project, I put the [Simple.Migrations runner and migrations to update the database schema]({% post_url 2020-08-15-Simple.Migrations %}).

With small tweaks, we can change the folder structure to have the component folders on top and the /src and /test folders inside them. Like,

```bash
│   Acme.CoolProject.Api.sln
├───Api
    ├───src
    └───tests
```

Even we can create folders and csproj files with shorter names by passing the `-n` flag and a name in the `dotnet new` command.

## How to update the csproj files with Powershell

Then to update csproj files, like making nullable warning errors or adding a root namespace, instead of doing it by hand, I tweak this PowerShell file:

```powershell
$projects = Get-ChildItem -Filter *.csproj -Recurse -Exclude *Tests*.csproj
    
$projects | foreach { 
    try
    {
        $path = $_.FullName;

        $proj = [xml](Get-Content $path);
        
        $propertyGroup = $proj.Project.PropertyGroup  | where { -not [String]::IsNullOrWhiteSpace($_.TargetFramework) };

        $shouldSave = $false
        if($propertyGroup.RootNamespace -eq $null)
        {
            $RootNamespace = $propertyGroup.ParentNode.ParentNode.CreateElement('RootNamespace');
      $propertyGroup.AppendChild($RootNamespace) | out-null;
            $propertyGroup.RootNamespace = "Acme.CoolProject";
            $shouldSave = $true
        }
        
        if($shouldSave)
        {
            $proj.Save($path);
            Write-Host "RootNamespace added to $path"
        }
    }
    catch
    {
        Write-Host $path ([System.Environment]::NewLine)
        $_
    }
}
```

Voilà! That's how I create the folder and project structure for one of my clients. This is another script that saved my day! Kudos to Humble Toolsmith for inspiring me to write this one.

To read more content, check [How to quickly rename projects inside a Visual Studio solution]({% post_url 2022-12-09-RenameProjectsVisualStudio %}) and [How to rename a keyword in file contents and names]({% post_url 2022-12-10-ReplaceKeywordInFile %}).

_Happy coding!_