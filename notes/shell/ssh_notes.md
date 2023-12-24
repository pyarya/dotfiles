# SSH
OpenSSH (ssh) is a secure protocol for connecting to computers/servers remotely.
Its uses are infinite, from connecting to clouds to making your laptop a desktop

### Basics
    $ ssh -p 10022 emiliko@192.168.0.12
    $ ssh -p 10022 emiliko@localhost
Connects to user `emiliko` on host address `localhost` via port `10022`. Port
`22` is the default for ssh

    $ ssh emiliko@68.185.68.169
To connect over WAN, there're some additional setup on the server-side:
 1. Set your IPv4 address manually. This usually requires setting manual DNS
   servers. `1.1.1.1` and `1.0.0.1` are a good choice
 2. Set up port forwarding for port 22 on the router to your manual local IPv4
 3. Find your router's public IP address and use that as the host address

    $ dig +short myip.opendns.com @resolver1.opendns.com
    $ host myip.opendns.com resolver1.opendns.com
    $ curl --silent https://ifconfig.me/ip
Finds your network's public IP address. This'll the server's be the host address

### Setting up ssh and ssh keys
    # pacman -S openssh
Update or install ssh. It's often packaged as `openssh` and installs `ssh`

    # systemctl enable sshd
Starts up the ssh daemon. The system should now be able to accept ssh
connections. On macOS, use Preferences -> Sharing -> Remote Login

    $ ssh-keygen -t ed25519
    $ ssh-keygen -t ed25519 -f ~/.ssh/arch_qemu_ed25519 -C "For arch qemu"
Generate a `ed25519` key pair. Interactively or through flags, this will add a
comment at the end of the public key and save it in the designated file

    $ ssh-copy-id -i ~/.ssh/key_file.pub emiliko@localhost
    $ cat ~/.ssh/key_file.pub | ssh emiliko@localhost "mkdir -p ~/.ssh && cat >>
    ~/.ssh/authorized_keys"
Copy an ssh key to the host. Either one will give you the power of ssh keys

    $ ssh-keygen -pf ~/.ssh/key_file
Change the passphrase on the key

### Using ssh keys
    $ ssh -i ~/.ssh/identify_file emiliko@localhost
Login to user using the identity file. This points to your private key. If the
file is secured by a passphrase, you'll need to retype it every time

    $ eval $(ssh-agent) && ssh-add ~/.ssh/key_file.pub
Start the ssh agent and add a key file to it. This uses the path of the public
key file. The agent prevents the need to retype the passphrase on this terminal

    $ ssh -A emiliko@localhost
Forwards the ssh agent to the destination system. Only useful if you plan to ssh
from that system

    $ scp -P 10022 ~/file emiliko@localhost:~/dir/
Copies file between systems. `cp` except across systems. This uses the same
login methods, key or password, as `ssh`. Port option must be capitalized

    $ scp ~/file alias:~/dir/
Copies file between systems, using `alias` from `~/.ssh/config` as the
destination system. This will automatically specify a user, identity key, etc...

    $ ssh -L 2222:localhost:3333 emiliko@192.168.0.12
Creates an ssh tunnel connecting localhost:3333 on the host server to port 2222
on the client. Useful for webpages and IDE notebooks

### SSH keys with git
After setting up ssh keys in both GitHub and your computer, you'll need to
change repositories to use ssh instead of the http protocol

    $ git remote -v
Echos a list of remote sources for the current repository. If the URLs start
with `http`, ssh protocol is not being used to connect to the remote sources

    $ git remote add origin git@github.com:Aizuko/configs.git
    $ git remote set-url origin ssh://git@github.com:22/Aizuko/configs.git
Use ssh protocol when connecting to remote origin. `add` is for new projects
which don't have an origin yet. `set-url` is for existing projects using http

### Mounting remote filesystems with SSHFS
SSH can mount a remote file system as if it's a laggy disk connected to your
system. This can be a nice way to locally view and edit remote files

Disclaimer: These commands have only been tested on MacOS using macFUSE

    $ mount
Lists all the current mount points

    $ mkdir ~/mnt
    $ sshfs emiliko@192.168.0.12:/Users/emiliko ~/mnt
    $ sshfs emi:/Users/emiliko ~/mnt
Mounts the Emiliko's home directory to `~/mnt`. Do not try `emi:~/` as bash
tilde will expand relative to the host. Specify the remote path from the root

    $ umount emiliko@192.168.0.12:/Users/emiliko
    $ umount !sshfs:1
Unmount the remote filesystem. Remember to type out the full remote path

    $ sshfs -o cache=no emi:/home/emiliko ~/mnt
    $ umount !sshfs:3
Disable caching to reconnect on every command. Prevents false directory listings

    $ pgrep -lf sshfs
    $ ps aux | grep -i sshfs
    $ kill -9 10364
    # umount -f ~/mnt
Forcefully unmount the filesystem

#### SSH Forwarding
    $ ssh -p10011 -NL 7000:localhost:8080 emiliko@localhost &
    $ ssh -NL 7000:localhost:8080 emi &
Opens an ssh tunnel between `7000` on the client and `localhost:8080` on the
server. Best used with `&`, as in line 2, to avoid obstructing the current pane

#### SSH config
    ~/.ssh/config
    Host paraarch
        User emiliko
        Hostname 192.168.0.12
        Port 22
        IdentityFile ~/.ssh/parallels_arch_ed25519
        IdentitiesOnly=yes
Adds a new host `paraarch` to the ssh config. `paraarch` can be used instead of
the host name and it will automatically specify these flags. `IdentitiesOnly`
resolves some issues relating to multiple failed connection attempts

    ~/.ssh/config
    Host github.com
        Hostname github.com
        IdentityFile ~/.ssh/github_key_ed25519
When pulling from remote origin `git@github.com`, this key will be used
[//]: # ex: set ft=markdown:tw=80:
