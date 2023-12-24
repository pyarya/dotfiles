# Extract subtitles with ffmpeg

```
ffmpeg -i Movie.mkv -map 0:s:0 subs.srt
```

Extract subtitles from the mkv file. This one extracts the 0th subtitle track.
To extract the first, use `-map 0:s:1`

```
ffmpeg -ss 10 -t 10 Movie.mkv audio.mp3
```

Another curious thing is [ffmpeg's treatment of arguments](ffmpeg relative). All arguments that
come before a file are applied to that file only. The remainder of the command
is relative to those inital args. This means seeking forward 10s then cutting
10s will actually cut out the 10-20s interval

[ffmpeg relative]: https://stackoverflow.com/questions/46508055/using-ffmpeg-to-cut-audio-from-to-position
