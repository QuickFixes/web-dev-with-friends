#!/bin/bash
#
#  Run a local Ansible playbook.
#  Because that's a lot to type.
#

ME=$( basename "$BASH_SOURCE" )
MYDIR=$( cd "$(dirname "$BASH_SOURCE")" && pwd )
ANSIBLE_CONFIG=$MYDIR/../ansible.cfg
export ANSIBLE_CONFIG

ADD_ARGS=
PLAYBOOK=

carp() {
    echo "$@" >&2
}
bail() {
    carp
    carp "ACK! $*"
    carp "     Bailing out."
    carp
    exit 1
}

usage() {
    echo "
  usage:
    $ME [-s] [-p] <playbook.yml>

  where:
    -s              become the superuser (root)
    -p              prompt for password for sudo
    <playbook.yml>  path to playbook to run
"
}

if [ $# -lt 1 ]; then
    usage
    exit
fi

#while [ $# -gt 0 ]; do
while (( $# )); do
    if [ "${1:0:2}" = "-h" -o "${1:0:3}" = "--h" ]; then
        usage
        exit
    elif [ "$1" = '-s' -o "$1" = '-u' ]; then
        ADD_ARGS="$ADD_ARGS -s -u root"
        shift
    elif [ "$1" = '-p' -o "$1" = '-K' ]; then
        ADD_ARGS="$ADD_ARGS -K"
        shift
    elif [ -f "$1" -a "${1: -4}" = '.yml' ]; then
        PLAYBOOK="$1"
        shift
    else
        usage
        bail "Unrecognized argument '$1'."
    fi
done

if [ -z "$PLAYBOOK" ]; then
    usage
    bail "Playbook not specified or unreadable."
fi

ansible-playbook ${ADD_ARGS:-} -c local -i '127.0.0.1,' "$PLAYBOOK"

# vim: tw=78 sw=4 ts=4 expandtab
