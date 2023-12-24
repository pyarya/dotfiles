# Remote desktop

SSH is great for using another computer remotely, though it falls short when you
want to use a graphical application like Chromium. Forwarding graphics requires
a very fast and stable connection

## Wayland

Most of these come from the [sway migration
guide](https://github.com/swaywm/sway/wiki/i3-Migration-Guide)

### VNC

VNC forwards the entire desktop, which is much heavier, though lets you use apps
already running

`wlroots` compositors can do vnc using `wayvnc` [available
here](https://github.com/any1/wayvnc). That's the server. The client can be any
x11 VNC client, though if you don't want xwayland scaling problems, use `wlvncc`
[found here](https://github.com/any1/wlvncc)

A simple script (from the client) to enable this:

```bash
ssh -L 9000:localhost:9000 emiliko@waybook wayvnc localhost 9000 &
wlvncc localhost 9000
```

### Waypipe

`waypipe` is x11 forwarding for wayland. It will only run apps explicitly
started while using the ssh connection, which is much lighter than VNC

Install [waypipe from here](https://gitlab.freedesktop.org/mstoeckl/waypipe).
`waypipe` **must be installed as `/usr/bin/waypipe` on both the client and
server**. The path is hard coded in `waypipe`

```bash
# On the client:
waypipe ssh emiliko@waybook firefox
```
