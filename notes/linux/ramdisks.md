# Ramdisks
Ram is fast and files sometimes need to be quick. Disks via ramfs and tmpfs
allow us to mount a file system entirely in the ram, and it's supported by the
linux kernel out of the box

Tmpfs is the newer version of ramfs, with the only difference being that tmpfs
has a maximum size that it won't exceed. Ramfs doesn't actually bound its own
size, so the system can run out of memory

    # mount -t tmpfs -o uid=1000,size=1g tmpfs /home/emiliko/mnt

Mounts a temporary file system with a maximum size of 1GB at ~/mnt. Ramdisks
only use the size they need, so mounting this blank file system won't take up
any ram at first

Unmounting a ramdisk will clear everything off, which happens every time the
system is powered off

Linux systems come with a `/dev/shm` directory by default, which is a ramdisk
accessible by all users. To find the size of a ramdisk use `df -h /dev/shm`. To
check which ramdisks are mounted, use `findmnt` or `mount`

For more information:
 - `man 8 mount`
 - `man 5 tmpfs`
 - [ArchWiki](https://wiki.archlinux.org/title/tmpfs)
