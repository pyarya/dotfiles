# SSH port forwarding
    ssh -p10011 -NL 7000:localhost:8080 emiliko@localhost &
Opens an ssh tunnel without obstructing the current terminal. Syntax for the
tunnel looks like:
    <client_port>:<url_from_host:host_port>
