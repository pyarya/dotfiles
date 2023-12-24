# Internet Forwarding

This note explains how to use the internet connection on computer A, which is
also connected to internet-less computer B, on computer B. This requires some
background

## IPv4 basics

IPv4 is made of 32 bits, written in 4x8-bit numbers like `192.168.0.1`. A
network mask specified at the end here determines which bits belong to this
network. Often it's 24, written like `192.168.0.1/24`, which means the first 3
8-bit numbers here are the local network

Usually `x.x.x.1` is the router or whatever resolves the WAN

Most ipv4 addresses are global on the WAN, though 3 are reserved for private
networks

 - `192.168.x.x`, most commonly seen on consumer networks
 - `10.x.x.x`, used for large local networks with 2^24 addresses
 - `172.[16 to 32].x.x`. The second number must be in the range 16-32

To simplify things, make sure your internal LAN is using a different one from
the WAN interface's LAN. `172.16.x.x` is often a good choice

## Forwarding internet

We have 3 interfaces involved:

 - `wan0`: the interface connected to the wider internet, possibly through a
   second LAN network that has a router
 - `eth0`: the interface on the same computer that has `wan0`, though connected
   to the internal LAN instead. This interface itself doesn't have internet
 - `eth1`: an interface on the internal network on another computer

We want to set up a network between `eth0` and `eth1`. Then we'll want a NAt
between `eth0` and `wan0` to route all the ipv4 packets incoming from `eth0` to
`wan0`

### Wan0

`wan0`'s configuration file is the easiest. It can use DHCP or a static IP, just
make sure it has internet with `ping archlinux.org`

Example:

```systemd
[Network]
Address=192.168.0.98/24
Gateway=192.168.0.1  # This is my router's IP
DNS=1.1.1.1
# The following is possibly useful, not sure
IPForward=ipv4
IPMasquerade=yes
```

Test your connection with the following:

```bash
sudo networkctl reload
ping 192.168.0.1  # Fails? You messed up your config
ping 1.1  # Fails? Your router doesn't have internet || your gateway is wrong
ping archlinux.org  # Fails? Your DNS isn't working. Try setting it to 1.1.1.1
```

### Eth0

This is the second interface on the computer with internet. This interface
itself doesn't have internet though. See the tests below to check

```systemd
[Network]
Address=172.16.0.1/24
Gateway=172.16.0.1  # Gateway is self!
DNS=1.1.1.1  # Again, optional, might not even do anything here
```

Testing if this interface has internet access:

```bash
networkctl list  # Read out the interface name here or in `ip a`. Assume eth0
ping -I eth0 1.1
ping 1.1  # If this fails too, then the computer just doesn't have internet
```

If the above ping succeeds, this interface also has internet. Otherwise, test
your connection to `eth1`:

```bash
ping -I eth0 172.16.0.22  # Fails? eth0 or eth1 isn't connected
ping 172.16.0.22  # Fails? Routing tables aren't using eth0 for 172.16.x.x
```

It should now be ready to forward internet. Run the following script as root:

```bash
declare -r WAN=wan0
declare -r LAN=eth0

# Reset iptables
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

# Forward internet
sysctl net.ipv4.ip_forward=1

iptables -t nat -A POSTROUTING -o "$WAN" -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$LAN" -o "$WAN" -j ACCEPT
```

### Eth1

This is the interface on the computer that wouldn't have internet otherwise. We
need to point it at `eth0`'s IP, so that `eth0` forwards all its networking

```systemd
[Network]
Address=172.16.0.22/24  # Choose anything >= 2 and <=254 for the last 8bits
Gateway=172.16.0.1  # This part is important
DNS=1.1.1.1  # Doesn't do anything, probably
IPForward=ipv4  # Might be useless
```

Test with:

```bash
ping -I eth1 172.16.0.1  # Fails? Something is wrong with eth1 or eth0's connection
ping 172.16.0.1  # Fails? Routing tables aren't using eth1 for 172.16.x.x
ping 192.168.0.1  # Fails? IPv4 forwarding isn't working
ping 1.1  # Fails? Might be a router issue
ping archlinux.org  # Fails? Likely a DNS issue
```

## Debugging

After setting this up, `ping 1.1` from my `eth1` computer would keep saying
`Packet filtered`. Running `systemctl stop firewalld.service` on the `eth0`
computer solved this. This is not a proper solution

You can also check if the ports are being filtered with the following. If
they're `unfiltered`, that's good. If they're being `filtered`, then `firewalld`
is the problem

```bash
nmap -sA 172.16.0.1
```

## Further reading
 - [Internet forwarding article on the
   archwiki](https://wiki.archlinux.org/title/Internet_sharing)
 - [systemd-networkd on the
   archwiki](https://wiki.archlinux.org/title/systemd-networkd)
 - [IP forwarding](https://bbs.archlinux.org/viewtopic.php?id=245264). Their
   solution was not using the Gateway with DHCP. Gateway is required for static
   IP setups though
 - [Good IP routing tables
   article](https://www.baeldung.com/linux/destination-source-routing)
 - [Nmap filtering
   check](https://www.redhat.com/sysadmin/troubleshoot-packet-filters-network)
 - ChatGPT can help a bit, though it's rarely right enough to actually get the
   whole network running
