# Pass - The Unix password manager
Forget proprietary password managers that require a subscription, use `pass` to
generate, store, and retrieve all your passwords through your gpg key

```bash
pass init emiliko@mami2.moe
pass insert university/password
pass insert -e university/username
```

Passwords, or rather entire files can be retrieved to stdout, the clipboard, or
a qrcode. Stdout will show multiline files. `-c` will only copy the first line
to `wl-clipboard` for `PASSWORD_STORE_CLIP_TIME` or 45s

```bash
pass [show] university/password
pass [show] -c university/password
pass [show] -q university/password
```
