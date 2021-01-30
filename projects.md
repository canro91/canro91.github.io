---
layout: page
title: Projects
---

This is some of the code I have written. Feel free to take a look, report any bug, ask for a new feature or send a pull-request.

### Parsinator

I wrote [Parsinator](https://github.com/canro91/Parsinator), a library to extract relevant data from text-based pdfs and plain text files. I used Parsinator to connect 4 legacy client softwares to a document API by parsing pdfs and plain text files into input XML files. You could read the motivation behind Parsinator on my post [Parsinator, a tale of a pdf parser]({% post_url 2019-03-08-ATaleOfAPdfParser %})

[![canro91/parsinator - GitHub](https://gh-card.dev/repos/canro91/parsinator.svg)](https://github.com/canro91/parsinator)

### BaseXml

I wrote [BaseXml](https://github.com/canro91/BaseXml) to manipulate and validate XML files. I used BaseXml to add, read, update and validate nodes and attributes from standard XML documents on an electronic invoicing system. I used BaseXml to avoid serializing complex XML files.

[![canro91/basexml - GitHub](https://gh-card.dev/repos/canro91/basexml.svg)](https://github.com/canro91/basexml)

### Kiukie

I wrote [Kiukie](https://github.com/canro91/Kiukie) to roll queues from database tables and ASP.NET Core Hosted Services. I used Kiukie to send hotel and property events to a third-party travel agency API on a reservation management system.

[![canro91/Kiukie - GitHub](https://gh-card.dev/repos/canro91/Kiukie.svg)](https://github.com/canro91/Kiukie)

### Slow Room Search

I improved the respose time of the room search functionality of a booking engine by a factor of ~1.5X. I removed N+1 problems and nested loops, and added a caching layer. From this task, I learned to always measure before rushing to optimize anything.

For all the findings and lessons I learned, you could read [The Slow Room Search]({% post_url 2020-09-23-TheSlowRoomSearch %}). Also, you can read my tutorial on [how to add a caching layer with ASP.NET Core 3]({% post_url 2020-06-29-HowToAddACacheLayer %}).

### Other projects

From time to time, I contribute to OSS by opening issues and sending pull requests to the libraries and projects I use. I have contributed to [DateTimeExtensions](https://github.com/joaomatossilva/DateTimeExtensions) adding holidays for my country, for example.

To see other projects, you can take a look at [my GitHub profile](https://github.com/canro91).
