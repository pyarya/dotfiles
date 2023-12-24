# Aerc - Allegedly "the world's best email client"
A terminal email client that's pretty decent out-of-the-box. Configuration is
divided between 3 files, the most important one is accounts.conf described here

```bash
please pacman -S aerc w3m dante
```

You'll need an app password to login. This can be put directly after the email.
Gmail has one [here for
example](https://support.google.com/accounts/answer/185833?hl=en)

```
source   = `imaps://emiliko%40gmail.com:passwordhere123@imap.gmail.com:993`
```

Or alternatively use the `source-cred-cmd` to retrieve a password through a
program like `pass`, as shown below

```
[Gmail]
source   = `imaps://emiliko%40gmail.com@imap.gmail.com:993`
source-cred-cmd = `pass show gmail/primary/app_password`
outgoing = `smtps+plain://emiliko%40gmail.com@smtp.gmail.com:465`
outgoing-cred-cmd = `pass show gmail/primary/app_password`
default  = INBOX
from     = Emiliko Mirror <emiliko@gmail.com>
copy-to  = Sent
check-mail = 1m
```

For other email providers, look up their server names and port, for example
Fastmail has them [listed
here](https://www.fastmail.help/hc/en-us/articles/1500000278342)
