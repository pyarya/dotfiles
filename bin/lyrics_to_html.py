#!/usr/bin/env python3
import argparse, os, subprocess, sys

def html_body(lyrics: list) -> str:
    html_body = str();

    is_in_stanza = False;
    lines_in_stanza = 0;

    for line in lyrics:
        if not is_in_stanza:  # Open new stanza
            html_body += f'{"":>6}<p class="stanza">\n';
            is_in_stanza = True
            lines_in_stanza = 0

        if line == '\n' and lines_in_stanza > 0:  # Close stanza
            html_body += f'{"":>6}</p>\n\n'
            is_in_stanza = False
        elif line != '\n':  # Add non-blank line to stanza
            html_body += f'{"":>10}<span class="line">{line.strip()}</span>\n'
            lines_in_stanza += 1

    html_body += f'{"":>6}</p>\n\n'
    return html_body


def html_from_template(title, icon, body, url) -> str:
    return html_template_top(title, icon) \
           + body \
           + html_template_bottom(title, url);


html_template_top = lambda title, icon : """\
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>""" + title + """</title>
    <link rel="shortcut icon" href=" """ + icon + """ ">
    <style>
        body {
            font-family: verdana;
            background-color: #222;
            color: #D4D4D4;
        }
        .stanza {
            margin-left: 300px;
        }
        .line {
            display: block;
            font-size: 25px;
        }
        #rikaichan-window {
            background-color: #222 !important;
            color: #D4D4D4 !important;
        }
        #rikaichan-window .w-kanji {
            font-size: 30px !important;
            color: #8EC07C !important;
        }
        #rikaichan-window .w-kana {
            font-size: 25px !important;
            color: #FABD2F !important;
        }
        #rikaichan-window .w-conj {
            color: #D3869B !important;
        }
        #rikaichan-window .w-def {
            font-size: 20px !important;
            color: #D4D4D4 !important;
        }
        body li.tod {
            font-size: 18px ;
        }
        body li.tod:first-child:nth-last-child(2) {
            font-size: 22px ;
        }
        body li.tod:nth-child(2) {
            font-size: 16px ;
        }
    </style>
  </head>

  <body>
"""

html_template_bottom = lambda title, url : f"""
      <p style="margin: 50px; padding-left: 250px">
          <a style="color: red; text-align: center"
             target="_blank"
             href="{url}"
             >Link to video: {str(title)}</a>
      </p>
  </body>
</html>
"""

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Quickly create an html file from lyrics');
    parser.add_argument('-t', '--title', metavar='<title>', type=ascii);
    parser.add_argument('-u', '--url', metavar='<url>', type=ascii);
    parser.add_argument('-i', '--icon', metavar='<path>', type=ascii);
    parser.add_argument('-d', '--download', metavar='<url>', type=ascii,
                        help='Download mp3 from url');
    parser.add_argument('file', type=ascii, nargs='?',
                        help='Read lyrics from file');
    args = parser.parse_args();

    if args.file is not None or not sys.stdin.isatty():
        title = args.title[1:-1] if args.title is not None else '';
        url =   args.url[1:-1]   if args.url   is not None else '';
        icon =  args.icon[1:-1]  if args.icon  is not None else '';

        # Read lyrics lines
        if args.file is not None:
            lyrics_file = open(args.file[1:-1], 'r');
            lyrics = lyrics_file.readlines();
        else:
            lyrics = sys.stdin.readlines();

        body = html_body(lyrics);
        html = html_from_template(title, icon, body, url);

        sys.stdout.write(html);
        sys.exit(0);
    else:
        parser.print_help();
        sys.exit(1);
