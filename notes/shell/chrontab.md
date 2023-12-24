# Crontab
Run programs at a given time. Useful for system cleanups and updates

```bash
crontab -e
```

Edit your crontab file

Syntax looks like (min, hour, day, month, year). Note these are absolute values,
so putting something like `* 1 * * *` will run the program at `1:00am` every
day. To understand these times use [this](https://crontab.guru/) Example crontab
file:

```bash
PATH=/usr/local/bin:/bin:/usr/bin
HOME=/home/emiliko

* * * * * ~/program_1.sh  # Every minute, on the minute
* * * * * (sleep 30; ~/program_1.sh)  # Every minute at 30s in
1 * * * * ~/program_2.sh   # Every hour at :01 minute
1 * 3 * * ~/program_3.sh   # Every day at 3:01am
```

Since crontab doesn't support resolutions greater than 1 minute, a workaround
with `sleep` can be used instead. `program_1.sh` above effectively runs every
30s
