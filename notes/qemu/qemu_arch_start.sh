#!/usr/bin/env bash
# Qemu booting on MacOS
qemu-system-x86_64 \
    -m 4G -smp 6 \
    -nographic \
    -accel hvf \
    -drive file=archlinux-2021.01.01.qcow2,media=disk,if=virtio \
    -nic user,hostfwd=tcp::10022-:22 &> /dev/null

exit 0
# Above invocation explained
-m 4G -smp 6                # Resources: Use 4GB memory and 6 cpus
-machine type=q35,accel=hvf # Machine: Default is `pc`. `q35` should be better, tho haven't noticed anything
                            # Hypervisor: Uses HyperVisorFramework to speed up qemu a LOT, ~6x
-drive file=archlinux.qcow2,media=disk,if=virtio  # Boot: Points to the image
-nic user,hostfwd=tcp::10022-:22  # Network: Forward host port 10022 to guest 22, so `ssh -p10022 user@localhost` should work


# Display options:
    # If you launch this script in the background, the same terminal can be
    # used to ssh into qemu. After exiting, tmux's scrollback breaks. Opening
    # and closing [n]vim fixes this...
-nographic \
    # Doesn't do anything noticably different from just -nographic
-monitor none -curses -nographic \
    # Support a 4k instance on MacOS. A spice server would be better. It's
    # really laggy with KDE, to the point of unusable
-vga virtio -full-screen -display cocoa \
    # Only supports 1080p. MacOS must use a cocoa display. Compared to above
    # the display scales by 2x which makes text bigger tho more blurry
-vga std -display cocoa \


# Previously used presets:
-monitor none \
-vga virtio -full-screen -display cocoa \  # 4k supported, though it's really slow at 4k
-vga std \ # Normal run, only supports up to 1080p
-accel hvf \
# possible
-vga virto \
-enable-kvm \
#
-net tap,script=/Users/emiliko/documents/safe/arch_vm/tap-up,downscript=/Users/emiliko/documents/safe/arch_vm/tap-down
    -nographic \
    -chardev stdio,id=char0 \
    -serial chardev:char0 \
    -monitor none \
    -net nic,model=virtio,macaddr=54:54:00:55:55:55 \


