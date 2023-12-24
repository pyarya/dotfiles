# Systemd-networkd
Systemd's networking is effectively composed of 3 parts. The interface configs
in `systemd-networkd`, the DNS resolver? in `systemd-resolved` and the wireless
interface, for our purposes `iwd`

`iwd` is only necessary for wifi

 - `/etc/iwd/main.conf`: Disabling passive scanning
 - `/var/lib/iwd/`: Per-network profiles, notably for WEP-Enterprise
 - `/etc/iwd/main.conf`: Daemon settings
 - `/etc/systemd/network`: For networkd stuff, so links and addresses
 - `/etc/systemd/system/systemd-networkd-wait-online.service.d`
 - `/etc/systemd/resolved.conf`: For resolved
 - `/etc/nsswitch.conf`: For nss-mdns
 - `/etc/mdns.allow`: Also for nss-mdns, only when not using mdns_minimal
