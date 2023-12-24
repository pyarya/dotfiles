# Emailing with Curl

`curl` is an amazing networking tool. It can even automate sending emails!
You'll need a app password or real password to login to your email account

## Email just a file

For the most basic email, we can stuff the headers into the email file itself.
Here's a basic example

```bash
cat <<EMAIL email.txt
From: Emiliko Mirror <emiliko@gmail.com>
To: Emiliko Mirror <emiliko@cs.ox.ac.uk>
Subject: Sleep triggered on $(hostname)
Date: $(date)

Dear me,

The system went to sleep! I thought I should notify my gmail account, so here
I am.

cheers,
Emiliko
EMAIL

curl --silent --ssl-reqd \
  --url 'smtps://smtp.gmail.com:465' \
  --user 'emiliko@cs.ox.ac.uk:<my-password-here>' \
  --mail-from 'emiliko@cs.ox.ac.uk' \
  --mail-rcpt 'emiliko@gmail.com' \
  --upload-file email.txt
```

The `From:` - `Date:` headers at the top are very important. Gmail seems to
insert them automatically if they're missing, though other mail providers
require them

If you use 2fa, you'll need to [obtain an app
password](https://support.google.com/accounts/answer/185833?hl=en) instead

## Email with attachments

We can also `CC`, `BCC` and attach files with our curl emails

Attachments need a MIME type for the file, which is easiest obtained with the
`file` command. In this example, we also remove the headers from the email file,
opting to use the more explicit `-H` curl option

```bash
declare -r attach_file=mirrors_house.png
declare -r mime_type="$(file --mime-type "$attach_file" | sed 's/.*: //')"

cat <<EMAIL >email.txt
Dear classmates,

I just bought a new house! Check out the picture I attached below

OMGOMGOMG, I'm so excited!

cheers,
Kate Mirror
EMAIL

curl --silent --ssl-reqd \
  --url 'smtps://smtp.fastmail.com:465' \
  --user 'kate%40mirror.house:<my-password>' \
  --mail-from "kate@mirror.house" \
  --mail-rcpt 'emiliko@cs.ox.ac.uk' \
  --mail-rcpt 'lou@lou.me' \
  --mail-rcpt 'louis@louis.me' \
  -F '=(;type=multipart/mixed' \
  -F "=$(cat email.txt);type=text/plain" \
  -F "file=@${attach_file};filename=home.png;type=${mime_type};encoder=base64" \
  -F '=)' \
  -H "From: Kate Mirror <kate@mirror.house>" \
  -H "Subject: Check out my new place!" \
  -H "To: Emiliko Mirror <emiliko@cs.ox.ac.uk>" \
  -H "CC: Lou Mirror <lou@lou.me>" \
  -H "Date: $(date)"
```

Notice that for `BCC` the user isn't mentioned in `-H` at all, though still gets
a `--mail-rcpt`

Oddly, some mail servers seem sensitive to the filename field. My university
server would consistently bounce emails when I tried to have a filename field.
Consider removing it to use the file's actual name

## Further reading

 - [A basic official guide](https://everything.curl.dev/usingcurl/smtp)
 - [Sending a simple email with
   curl](https://stackoverflow.com/questions/14722556/using-curl-to-send-email)
 - [An example on using the -F option with
   curl](https://blog.ambor.com/2021/08/using-curl-to-send-e-mail-with.html)
 - [Backup of the above on
   github](https://github.com/ambanmba/send-ses/blob/main/send-ses.sh)
 - [A hit at using the filename field in
   forums](https://stackoverflow.com/questions/15127732/change-name-of-upload-file-in-curl)
