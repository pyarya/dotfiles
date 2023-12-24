# Using fzf correctly

```
^r  Pull command out of bash history
^t  Complete file names relative to cwd
```

Standard shortcuts

```bash
mv **<TAB>
mv ./**<TAB>
```

When tabbing after `**`, fzf will complete the path. This works with other
destinations like `~/Downloads/**<TAB>`

Fzf also automatically completes most common commands, like `ssh`, `kill`, and
`unset`. Note that most of these still require `**`, they just complete what's
expected instead of file paths

You can set up additional completions in a bash config file

```bash
_fzf_setup_completion path mpv
```
