# Apple corner
MacOS is a BSD derivative that constantly does things differently under the
hood. While most things are Unix compatible, some things are just different

### Basic setup
MacOS requires a few manual interventions to get the system working

    # spctl --master-disable
Reveals the option in "Security & Privacy" to run apps from any developer

    ~/Library/Sounds/madoka_error.aiff
Sound files stored in this directory are available under Sound -> Sound Effects

    ~/Library/KeyBindings/DefaultKeyBinding.dict
Allows basic remapping for system-wide key binds. Use `skhd` for complex hotkeys

### Basic commands

    $ echo 'hello' | pbcopy
    $ pbpaste > note.txt
Interact with the system clipboard through terminal. This does not work for
images. Install `pngpaste` for that functionality

    $ say 'something'
Says string with system voice. Useful as a notification for when a task is done

    $ afplay
Plays the audio of an audio file, such as an `mp3` or `wav`

### Disk Utility

    $ diskutil list
Lists all the volumes the system currently sees. This works for unmounted and
encrypted partitions as well

    $ diskutil mount disk1s1
Mounts `disk1s1`. Most useful to mount USB drives without physically reseeding

    $ diskutil apfs unlockVolume disk1s1
Unlocks and mounts an apple file system volume

### Launch daemon
Systemd for MacOS. It will automatically load scripts in designated directories
on login. It can also be controlled manually through `launchctl`

    $ launchctl load -w ~/Library/LaunchAgents/com.skhd.plist
    $ launchctl unload -w ~/Library/LaunchAgents/com.skhd.plist
Loads and starts the skhd daemon. `<key>Label</key>` must be the same to unload

    # launchctl list | grep skhd
Check the status of a running process. First number is the PID, second number is
the exit code. If the second number isn't 0 or there's no PID something broke

    /Users/emiliko/Library/LaunchAgents/com.launcher.plist
This file will be started automatically on emiliko's login. All paths provided
in must be absolute paths from root. Use `/Users/emiliko/` not `~/`

    /Users/emiliko/Library/LaunchAgents/com.launcher.plist
    <key>StandardOutPath</key>
    <string>/tmp/skhd.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/skhd.err</string>
Redirects stdout and stderr. Watch these files with `tail -f /tmp/skhd.err | nl`

### Installing SSHFS on Mac
To set up ssh filesystem (sshfs) on a mac, follow these steps on the client:

    $ brew install --cask osxfuse
Installs `osxfuse`. This is an open source tool to extend your mac's fs support

    https://osxfuse.github.io/
    $ curl https://github.com/osxfuse/sshfs/releases/download/osxfuse-sshfs-2.5.0/sshfs-2.5.0.pkg
Recently brew removed sshfs from its supported casks, since it relies on closed
source code. Instead, you'll need to install it directly from the download link

See ssh_notes for using SSHFS

### OSA script
MacOS's GUI can often be controlled through the use of Apple's `osascript`.
Notably, this can allow shell programs to give GUI notifications

    osascript -e 'display notification "'"${message}"'
Sends the system notification with the contents of `$message`

    osascript -e 'display notification "'"${msg}"'" with title "Skhd"'
Adds a "Skhd" as a title to the notification

    osascript -e 'display notification "'"${msg}"'" with title "Skhd" subtitle
    "Could not save image"'
Further adds a subtitle for the notification

    afplay $(defaults read .GlobalPreferences.plist \
        | awk '/sound.beep.sound"/ { gsub(/(.*= ")|(";)/, "", $0); print }')
Plays the default system error sound through the current audio output device


## FreeBSD corner
Keep in mind that MacOS is based on a really old FreeBSD and NetBSD kernel, so
many sections here will somewhat apply to Macs as well

#### Users and groups
Various commands for managing system permissions. Many can be, at least
somewhat, run the user themselves with their password

    # adduser
    # rmuser
    $ chpass  # edit user account settings, like login name and expiry
    $ passwd  # change a user's password
    $ pw      # a cli frontend for the settings files above. More advanced
https://docs.freebsd.org/en/books/handbook/basics/#users-modifying

    /etc/group
    $ id emiliko
Shows groups a user belongs to. User seems to implicitly belong to their group

    rwxr-x---x  .
    rwxr-x-r--  secret_file
    rwxr-x-rw-  no_touching
Oddly, the `x` on the directory here means means all other users:
 - Can `cd` into the directory
 - Cannot `ls` in this directory
 - Can read the file `secret_file` using something like `vim secret_file`
 - Can write to `no_touching`. Vim can only do this with `:x!` not `:w!`

    # service sshd restart
Reboots the ssh daemon. Users connected through ssh won't lose connection, if
the reboot is successful
[//]: # ex: set ft=markdown:tw=80:
