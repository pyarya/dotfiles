#!/usr/bin/env -S awk -f
# Translate the unix-timestamps in bash history to dates. Requires gnu `date`
{
    if ($0 ~ /^#[0-9]+$/)
        system("date -d @" substr($0, 2));
    else
        print "    "$0
}

