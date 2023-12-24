# Airpods - bluetooth audio
Bluetooth headsets may be unusable with pulse audio by default. Particular
symptoms include cutting out and compressed playback. This is completely
independent of the speaker setup, so it won't mess up the config there

Start by finding your bluetooth card's name with

    $ pactl list | grep -Pzo '.*bluez_card(.*\n)*'

This also shows the latency in the output section. It should be 0. Now increase
the latency. 50000 is a good choice for airpods pro

    $ pactl set-port-latency-offset bluez_card.00_8A_76_4D_9B_BB headphone-output 50000
    $ systemctl restart bluetooth

That should fix the cutting out issues. Not connect the airpods

    $ bluetoothctl
    [bt]# power on
    [bt]# default-agent
    [bt]# scan on
      [NEW] Device 00:8A:76:4D:9B:BB Anna’s Airpods
    [bt]# trust 00:8A:76:4D:9B:BB
    [bt]# pair 00:8A:76:4D:9B:BB
    [bt]# connect 00:8A:76:4D:9B:BB

You may need to redirect pulse audio's output to the airpods. Referenced from
[here](https://askubuntu.com/questions/475987/a2dp-on-pulseaudio-terrible-choppy-skipping-audio)
