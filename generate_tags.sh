#!/bin/bash
# Read all files in _post/ to generate tag pages

# References
# https://stackoverflow.com/questions/29182502/how-to-find-unique-words-from-file-linux
# https://www.computerhope.com/unix/utr.htm

tag_dir=tags
mkdir -p $tag_dir

for tag in $(grep -E 'tags: ((\w+)\s)+' _posts/2* | cut -d ':' -f 3 | tr -s "[:space:]" "\n" | sort | uniq)
do
cat <<EOF > $tag_dir/$tag.html
---
layout: tag_page
title: "Tag: $tag"
tag: $tag
---
EOF
done
