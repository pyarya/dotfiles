# Mounting disks
On MacOS, there's `diskutil` which handles everything to do with disks and
partitioning all in one. It also has a graphical frontend. Macs by default
automatically mount readable external media into `/Volumes` and nothing explicit
needs to be done, although `diskutil` can trigger this as well

In Linux, the functionality of this tool is broken up into `fdisk`, `lsblk`,
`df`, `parted`, and `mount`. For querying information, these overlap heavily and
can often be used interchangeably. `lsblk` is often sufficient to query external
drives, with the following options:

```bash
lsblkf -o name,label,fstype,mountpoint,size,state
```

However, `mount` is a particularly bad substitute for `diskutil`. For one it
needs root privileges for something as simple as mounting a usb stick. It also
doesn't create mount pointer for us in `/Volumes`, we have do to that manually

Instead, it's a good idea to install `udisks2`. "Easier" distros typically come
with this or something similar preinstalled. `udisksctl` is much more similar to
`diskutil`. It'll mount drives without requiring root into
`/run/media/<username>/`, using the EFI label for that partition

```bash
udisksctl help
udisksctl mount -b /dev/sda2
udisksctl mount -b /dev/sda3
```

You can mount multiple partitions from the same block device at the same time

Do not try to mix `mount` and `udisksctl`! This can lead to some severe
nonsense, like ghost disks. Before using `udisksctl` consider checking the
output of `mount`. Note that `lsblk` may know less than `mount` and `df`

There are no guarantees that an external drive will have any particular name.
This is problematic in scripts and requires an `lsblk` every time before
mounting external media. Instead you can use the automatically created symlink
in `/dev/disk/by-*`. For example, a partition with label `hey_hey` can always be
mounted with

```bash
udisksctl mount -b /dev/disk/by-label/hey_hey
```

There can presumably be problems with conflicting partition labels, though it's
better not to use `udisksctl` in that case either. `/dev/disk/by-id/*` uses WWID
for identification, which is stored on the hardware for the drive and guaranteed
to be universally unique. That's a better idea for the fstab file
