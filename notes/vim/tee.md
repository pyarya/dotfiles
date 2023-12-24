# Tee command
Duplicate piped output between a file and the stdout

```bash
sudo echo "something" > root_file
```

This won't work since output redirection is always done with user privileges.
Instead we use:

```bash
echo "something" | sudo tee root_file
echo "something" | sudo tee root_file &>/dev/null
```

Now the redirection will be executed with root privileges. Stdout can be
silenced to get the same effect as before. Tee can also copy output to multiple
files, or act like `>>` with `-a`

```bash
echo "something" | tee file1 | tee file2 > file3
```

It's very useful in vim, when you forget to use root privileges when editing a
root-only file:

```bash
:w ! sudo tee %
```

Note that neovim doesn't support interactive sessions through external commands
yet, so this only works in vim
