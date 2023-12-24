#!/usr/bin/env -S awk -f
# Create a table of contents for a markdown file. Respects code blocks!
#
# ARGS (use these with -v[name]=[value] when calling):
#   int heading : Indenting level for the "highest" heading. DEFAULT = 1
#   int table_only : Only print the table of contents. DEFAULT = 0
#
# EXAMPLE RUN:
#  $ table_of_contents_markdown.awk -vtable_only=1 -vheading=2 <<HERE
#  # Main
#  ## Hello
#  ### Deep header
#  ##### 2 deeper
#  #### 1 deeper
#  # Section
#  #### No way
#  HERE
#
# EXAMPLE OUTPUT:
#   ## Table of Contents
#    1. [Main](#main)
#     - [Hello](#hello)
#      * [Deep header](#deep-header)
#        * [2 deeper](#2-deeper)
#       * [1 deeper](#1-deeper)
#    2. [Section](#section)
#       * [No way](#no-way)

# Converts a markdown heading to a pandoc style id
# Steps:
#  1. Convert to lowercase
#  2. Non-word? text is removed
#  3. Two or more hyphens in a row are converted to one
#  4. Spaces are converted to hyphens
#  5. If the same id has already been generated, a unique incrementing number
#     is appended, starting at 1
#
# *Gitlab seems to preprend for step 5 instead
# *Github seems to skip step 4
function heading_to_id(heading,    id) {
    id = tolower(heading);

    gsub(/[^-A-z0-9 ]/, "", id);
    gsub(/-+/, "-", id);
    gsub(/ +/, "-", id);

    if (existing_ids[id]++)
        id = sprintf("%d-%s", existing_ids[id]-1, id);

    return id
}

BEGIN { if (heading == 0) heading = 1;  }

/```/ { is_code_block = !is_code_block }

/^#+ [^ ].+$/ && !is_code_block {
    match($0, /#+/);
    heading_level = RLENGTH
    s = substr($0, RSTART+RLENGTH+1);

    s = sprintf("[%s](#%s)", s, heading_to_id(s))

    if (heading_level <= heading) {
        s = sprintf(" %d. %s", ++nb_heading, s);
    } else if (heading_level == heading + 1) {
        s = sprintf("  - %s", s);
    } else {
        s = " * "s
        for (i = 0; i < heading_level - heading; i++) s = " "s;
    }

    table_of_contents[toc++] = s
}

{ file[lines++] = $0 }

END {
    print "## Table of Contents"
    for (t in table_of_contents)
        print table_of_contents[t]

    if (!table_only) {
        print ""
        for (line in file)
            print file[line]
    }
}
