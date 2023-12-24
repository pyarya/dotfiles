# SSH port forwarding
Local port forwarding allows ssh to connect one of your ports to the
destination's port. This is particularly useful for localhosted websites, which
you can run on the host and access on your machine

Some key terms:
```
<client-port> = Port on the machine you're using to ssh. Ex: laptop
<host-port>   = Port on the machine running sshd
<host-address> = URL of machine running the sshd, which you're logging onto
<url-from-host> = Name relative to the host machine who's port the host forwards
```

The opens an ssh tunnel without obstructing the current terminal:
```bash
    ssh -p10011 -NL 7000:localhost:8080 emiliko@localhost &
    ssh -NL <client-port>:<url-from-host>:<host-port> <user>@<host-address> &
```

# In config file
The syntax in the config is quite similar

```ssh
    LocalForward 8001 localhost:7000
    LocalForward <client-port> <host-address>:<host-port>
```
