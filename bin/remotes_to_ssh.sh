#!/usr/bin/env bash
# Switch https git remote urls to ssh
git remote -v | awk '
  /https:\/\// {
    split($0, a, " ")
    split(a[2], b, "/")

    url = "ssh://git@"b[3]":22"

    for (i = 4; i <= length(b); i++)
      url = url"/"b[i]

    if (url !~ /\.git$/)
      url = url".git"

    system(sprintf("git remote set-url %s %s", a[1], url))
    printf "%s `%s` -> `%s`\n", a[1], a[2], url
  }
'
