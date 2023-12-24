# Networks
This file covers wifi and bluetooth connections on linux

Required packages for the guide:
 - systemd
 - NetworkManager
 - `bluetoothctl`

Optional GUI tools to make this easier:
 - `pacman -S nm-connection-editor`
 - `pacman -S blueberry`

# Basic networks
For Archlinux, choose between NetworkManager and netctl for your networking
needs. NetworkManager comes from the GNOME project and is fully feature packed
from the getgo. Netctl is a set of light shell scripts that rely on external
packages for networking, so a bit harder to install

Both can be checked with systemd
```bash
systemctl status netctl.service
systemctl status NetworkManager.service
```

**Make sure only one is running and enabled**. Using both at the same time will
result in system slowdowns, especially at boot times

## NetworkManager and netctl conflict
If your system is running some `/sys/.../subnet...` for 90s at startup, likely
netctl is trying to start up a device, though the device name has changed.
Places to check:

    /etc/NetworkManager/system-connections/
    cd /etc/systemd/system/multi-user.target.wants/ && rg enp0s3
    vi /etc/systemd/system/multi-user.target.wants/netctl@enp4s0.service
    vi netctl@enp4s0.service

If you are using both by accident, make sure to use the native disable in
addition to the systemd disable. For example, with netctl:

    systemctl disable netctl
    systemctl disable netctl@enp4s0.service
    netctl disable enp4s0

## Public networks
Public networks often use a captive portal to make users accept their terms and
conditions

 1. Connect to the network using `nmtui` or similar
 2. Use a GUI browser and navigate to any site
 3. If that doesn't work, try navigating to a non-https using page
 4. If that doesn't work, try navigating to a site you've never visited in incognito
 5. If that doesn't work, try navigating to the router at 192.168.[0-1].[0-1]

# Bluetooth
Before starting bluetooth, make sure bluetooth.service is running, otherwise
nothing will work

```bash
systemctl start bluetooth.service
```

You may optionally install the `blueberry` GUI package. It's quite light and
limited, though it's a good way to check if your devices are connected

## Keyboard
Start `bluetoothctl`. The command sequence to connect will look something like:

    $ bluetoothctl
    [bluetooth]# power on
    [bluetooth]# agent off
    [bluetooth]# agent KeyboardOnly
    [bluetooth]# scan on
    [bluetooth]# pair <MAC-ADDR>
    [bluetooth]# trust <MAC-ADDR>
    [bluetooth]# connect <MAC-ADDR>
    [bluetooth]# quit

When you turn `scan on`, the list may explode with various mac addresses. Try to
find your keyboard amongst those. During the `pair` section, `bluetoothctl` may
prompt you with 6 digits. Type those on the keyboard and possibly hit enter
after them

See the [Archwiki page](https://wiki.archlinux.org/title/bluetooth_keyboard) for
more info

## Bluetooth headphones
This section connected AirPods Pro. Setup may differ for other devices

Start by connecting your headphones with a very similar set of steps as the
keyboard guide above. Use `default-agent` instead of `agent KeyboardOnly`. For
example:

    $ bluetoothctl
    [bt]# power on
    [bt]# default-agent
    [bt]# scan on
      [NEW] Device 00:8A:76:4D:9B:BB Anna’s Airpods
    [bt]# trust 00:8A:76:4D:9B:BB
    [bt]# pair 00:8A:76:4D:9B:BB
    [bt]# connect 00:8A:76:4D:9B:BB

Once connected, blue headphones may cutout or just not play back anything. This
is a PulseAudio issue. The bluetooth sound latency may need to be adjusted

Start by finding your bluetooth card's name with

    $ pactl list | grep -Pzo '.*bluez_card(.*\n)*'

Next increase the audio latency. 50000ms seems to work well for AirPods Pro,
though this is likely [different for other
headphones](https://askubuntu.com/questions/475987/a2dp-on-pulseaudio-terrible-choppy-skipping-audio)

    $ pactl set-port-latency-offset bluez_card.00_8A_76_4D_9B_BB headphone-output 50000
    $ systemctl restart bluetooth.service

Repeat the steps above, adjusting the bluetooth sound latency, until it works.
Consider using the `blueberry` GUI to quickly reconnect the headphones on each
bluetooth.service restart. Don't forget to relaunch `blueberry` every time too

```bash
kill $(pgrep ^blueberry$) && systemctl restart bluetooth.service && blueberry &
```

# Enterprise networks
Large organizations, like universities, use enterprise security on their
networks. These require an account to login, not just a password

The guide below assumes the network's name is "UWS" and your login username is
"emiliko"

You can install the optional `nm-connection-editor` to make things easier

    $ nmcli device wifi list
This should show the network you're looking for

If your network is not using PAP authentication, it may be possible to just
connect with a simple password, try:

```bash
nmcli --ask device wifi connect UWS
```

Otherwise run this line, replacing the necessary information in the line above.
Particularly `UWS`, `emiliko` and `wlan0`. For `wlan0`, find your wifi device
with `ip link`. `enp...` is usually ethernet

```bash
nmcli connection add type wifi con-name "UWS" ifname wlan0 ssid "UWS" -- wifi-sec.key-mgmt wpa-eap 802-1x.eap ttls 802-1x.phase2-auth mschapv2 802-1x.identity "emiliko"
```

## Option 1: With nm-connection-editor
Open `nm-connection-editor`. Go into "Wifi-Security" and make it look like:

    WPA & WPA2 Enterprise
    Tunnled TLS
    CA Certificate: (None)
    Check No CA certificate required
    Inner authentication: PAP
Type in your login credentials at the bottom. Now run

## Option 2: Without nm-connection-editor
If you don't have the GUI tool `nm-connection-editor` and no way to install it,
you can try editing the network's profile directly. The relevant file is at
`/etc/NetworkManager/system-connections/UWS.nmconnection`

This file should look something like below, with relevant information replaced.
The file can only be accessed by root

```
[connection]
id=UWS
uuid=cb62f680-e1da-41c9-bfa0-35e7ef6f5137
type=wifi
interface-name=wlan0
timestamp=1657043376

[wifi]
mode=infrastructure
ssid=UWS

[wifi-security]
key-mgmt=wpa-eap

[802-1x]
eap=ttls;
identity=emiliko
password=PutYourPasswordInPlainTextHere_YesPlainText
phase2-auth=pap

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto

[proxy]
```

Alternatively, use the file above as a reference to edit it via

```bash
nmcli connection edit UWS
```

## After setting up above
```bash
nmcli device wifi connect UWS
```

NetworkManager takes a bit, about 30s, to finish authentication. This will also
happen during boot, so you can't use the network right away

If your network does not use PAP authetication, it might just work to type the
password in

```bash
nmcli --ask device wifi connect UWS
```
