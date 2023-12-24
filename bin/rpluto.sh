#!/usr/bin/env bash

print_long_help() {
    cat <<EOF
Start a Pluto Notebook server through an ssh connection

USAGE:
    rpluto [--help] [-p <host-port>] <local-port> <ssh-addr>

FLAGS:
    -h, --help      show this help message and exit

OPTIONS:
    -p <host-port>  Port use for on host for the Pluto Server

ARGS:
    <local-port>    Port on client to connect Pluto Server
    <ssh-addr>      Either an ~/.ssh/config alias or the host address
EOF
}

print_short_help() {
    cat <<EOF
USAGE:
    rpluto [--help] [-p <host-port>] <local-port> <ssh-addr>

For more information try --help
EOF
}

print_start_msg() {
    cat <<EOF
Starting remote Pluto Notebook. This may take a few seconds...
Wait for a popup or connect here using a browser:

    http://localhost:$1

When you're finished type ^C in this terminal
EOF
}

# 1: Client port
# 2: SSH alias or address
# [3]: Host port
ssh_pluto_tunnel() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        sleep 4 && open -n -a "Google Chrome" --args --incognito "http://localhost:$1" &
    elif [[ "$(uname -s)" == "Linux" ]]; then
        sleep 4 && chromium --incognito "http://localhost:$1" &>/dev/null
    fi

    ssh -L "$1":localhost:"${3:-7000}" "$2"\
        "julia -e\
            \"import Pluto;
            Pluto.run(
                port=${3:-7000},
                require_secret_for_open_links=false,
                require_secret_for_access=false
            )\""
}

exit_msg(){
    printf "\nNotebook has been shutdown\n"
    exit 0
}


# Print help and exit ====
if [[ $1 == '--help' ]]; then
    print_long_help
    exit 0
elif [[ "$1" =~ '-h' ]]; then
    print_short_help
    exit 0
fi


# Parse arguments ====
positional_args=()

while [[ "$#" -gt 0 ]]; do
    arg="$1"

    case $arg in
        -p)
            host_port="$2"
            shift
            shift
            ;;
        *)
            positional_args+=("$1")
            shift
            ;;
    esac
done

set -- "${positional_args[@]}"

# Set graceful exit
if [[ "$#" -eq 2 ]]; then
    trap exit_msg SIGINT

    print_start_msg "$1"

    ssh_pluto_tunnel $1 $2 $host_port
else
    print_short_help
    exit 2
fi
