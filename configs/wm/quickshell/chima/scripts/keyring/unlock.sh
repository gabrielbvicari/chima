#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if "${SCRIPT_DIR}/is_unlocked.sh"; then
    exit 1
fi

if [[ -z "${UNLOCK_PASSWORD}" ]]; then
    echo -n 'Login password: ' >&2
    read -s UNLOCK_PASSWORD || return
fi

killall -q -u "$(whoami)" gnome-keyring-daemon
eval $(echo -n "${UNLOCK_PASSWORD}" \
           | gnome-keyring-daemon --daemonize --login \
           | sed -e 's/^/export /')
unset UNLOCK_PASSWORD
echo '' >&2
