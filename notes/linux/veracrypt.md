# Veracrypt
A cross-platform block device encryption program with support for passwords,
keys, hidden volumes, and manual PIM setting for security

Here we use `alias vera='veracrypt -t'` for the non-graphic interface

AES is the best all-round choice of cipher. Sha256 is the best choice of hash

Keyfiles must be prepared before locking a volume. `vera --create-keyfile` can
create one, or just use a few 100 bytes from /dev/urandom in a file.

Veracrypt devices must be mounted on a directory and require root access to use
`mount`

Dismount volumes with the `-d` option, providing a path to the mount point, the
name of the volume, or nothing to unmount all veracrypt volumes. Sometimes
veracrypt may fail to unmount. To check which process is using the container use

```bash
please fuser -vm <mount-point>
# For the really desperate
lsof
# Or if it must be closed no matter what process is using it
vera --force --dismount
umount -f <mount-point>
```

## Creating a new volume interactively
Start with `vera -c`. The most sensible default are:

```
Volume type: Normal
Volume path: /home/emiliko/file_name  # Use absolute path!
Volume size?
Encryption Algorithm: (1) AES
Hash algorithm: (1) SHA-512
Filesystem: (8) Btrfs
```

## iNode problems
If you're making a very small container, you may run into inode issues. Btrfs
doesn't use inodes, so it should be ideal. However, btrfs requires a file system
over 1M for sure

Ext4 uses inodes and by default won't have nearly enough on a small drive. For
example, the default is 96 inodes for a 1M drive
