# Systemd Timers
Gen Z's crontab

Generally there are 3 pieces to a timer
 - The script being run
 - The systemd service defining which script to run
 - The systemd timer triggering the service

## Tools
`systemd-analyze calendar` can be very handy at verifying timestamps

```bash
systemd-analyze calendar *-*-* *:10,20:10
```

To find suitable targets for things like `Wants` and `After`, see
`systemd.special(7)`. If you want to check the current status of your targets,
use:

```bash
systemctl list-units --type target --state active
systemctl status network-online.target
```

## Placing files

Scripts should be put in `/usr/local/bin` if they can be run by anyone or
`/usr/local/sbin` if they should only be run by root

Define a `xxx.service` file in `/etc/systemd/system`. Set the timer as one of
its `Wants`. `network.target` may be more appropriate in some cases.
`multi-user.target` is a good default for `WantedBy`

```systemd
[Unit]
Description = Sends current ip address to uni servers
Wants = broadcast_ip.timer
Wants = network.target
After = network.target

[Service]
Type = oneshot
ExecStart = /usr/local/bin/broadcast_ip.sh

[Install]
WantedBy = multi-user.target
```

Now you'll need a timer file. It's easiest to make it have the same name as the
service file and put it in the same `/etc/systemd/system`

```systemd
[Unit]
Description = Sends current ip address to uni servers
Requires = broadcast_ip.service

[Timer]
Unit = broadcast_ip.service
OnCalendar = *-*-* *:15,45:00

[Install]
WantedBy = timers.target
```
