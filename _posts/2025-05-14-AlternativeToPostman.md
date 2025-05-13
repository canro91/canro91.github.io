---
layout: post
title: "A Simpler and Faster Alternative to Postman"
tags: productivity showdev
---

Postman still isn't opening.

Five minutes after clicking the icon... Nothing. Maybe it's calling home, checking in with the International Space Station, or just ghosting me. Who knows?

Today I found out about [Bruno](https://www.usebruno.com/), a "Git-integrated, fully offline, and open source API client". A simpler alternative to Postman. I had come across Bruno before but had forgotten about it.

## But, there's an even simpler alternative to Postman and Bruno.

When I want to test a single endpoint, I just:
1. Go to the Network tab on Chrome,
2. Right-click on the request I want to test,
3. Then click on "Copy as cURL (bash)",
4. Then paste it into a Terminal, and
5. Press enter.

[cURL](https://curl.se/) is a "command line tool and library for transferring data with URLs". It comes preinstalled with Git Bash for Windows. And I'm a "terminal Git user," so I keep a terminal open all the time. Way faster than opening an Electron app.

Here are some cURL examples to send data:

```shell
$ curl --json '{"name":"some json here"}' https://example.com`
$ curl -s --json @body.json https://example.com
$ curl -s -i --json @body.json -H "header-name:header-value" https://example.com`
$ curl -d "data to PUT" -X PUT http://example.com/
```

Here's the meaning of those options:

* `--json`: To POST a json request either as a json string or from a file.
* `-s`: Silent mode
* `-i`: To include response headers
* `-k`: To avoid validating SSL certificates. Handy when an ASP.NET Core project has HTTPS redirection.

Et voilà! No waiting, no upgrades, no paywalled features. cURL is faster and simpler than Postman, which still doesn't open on my computer. I guess it's time to upgrade it or simply use a better alternative.

PS: Turns out Postman finally opened... after an upgrade. Unnecessary drama. Arrggg!
