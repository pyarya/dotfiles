# Qemu
Optimized options that seem to work on MacOS:

```bash
-m 4G -smp 6                # Resources: Use 4GB memory and 6 cpus
-machine type=q35,accel=hvf # Machine: Default is `pc`. `q35` should be better. Haven't noticed any perfomance gains
                            # Hypervisor: Uses HyperVisorFramework to speed up qemu a LOT, ~6x
-drive file=archlinux.qcow2,media=disk,if=virtio  # Boot: Points to the image
-nic user,hostfwd=tcp::10022-:22  # Network: Forward host port 10022 to guest 22, so `ssh -p10022 user@localhost` should work

# Display options on MacOS:
    # If you launch this script in the background, the same terminal can be
    # used to ssh into qemu. After exiting, tmux's scrollback breaks. Opening
    # and closing [n]vim fixes this...
-nographic
    # Doesn't do anything noticably different from just -nographic
-monitor none -curses -nographic
    # Support a 4k instance on MacOS. A spice server would be better. It's
    # really laggy with KDE, to the point of unusable
-vga virtio -full-screen -display cocoa
    # Only supports 1080p. MacOS must use a cocoa display. Compared to above
    # the display scales by 2x which makes text bigger tho more blurry
-vga std -display cocoa
```

# Qemu fully nongraphic

MacOS can't use `-display ncurses` properly with qemu. Ncurses requires a linux
kernel to work properly. Instead use `-nographic` and launch the process in the
background. Bash uses `&` for backgrounding. You can now SSH into the qemu
instance.

Bonus:
For shared file systems, there are two options on Macs:
 - MacFUSE - Manually setup and mount with sshfs. It's much easier to use
 - lima - Tries to do reverse sshfs for you and forwards ports too. This one is
   pretty new and questionably useful compared to manually using sshfs
