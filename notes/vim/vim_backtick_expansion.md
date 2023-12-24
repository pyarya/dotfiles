# Vim backtick expansion

```
:h backtick-expansion
```

Essentially allows command substitution with shell or vim commands. Requires a
lot of escaping special symbols though

```bash
:e `mktemp`
:e `=tempname()`
```

Edit a new temporary file. Very useful in gui contexts when you just quickly
need to jot something down. The equal sign in the second line expands a vim
function instead of calling a shell
