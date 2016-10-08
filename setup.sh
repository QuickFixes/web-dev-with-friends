#!/bin/bash
#
#  Just download the base box and do the 'vagrant up' for the user already.
#
#  Author:  Kevin Ernst <ernstki@mail.uc.edu>
#  Date:    27 Sep 2016
#
#set -x
ME=$( basename "$BASH_SOURCE" )
MYDIR=$( cd "$(dirname "$BASH_SOURCE")" && pwd )
BOX_NAME=webdev-jessie
VAGRANT_BOX=${VAGRANT_BOX:-http://homepages.uc.edu/~ernstki/${BOX_NAME}.box}

quietly() {
    $* &>/dev/null
}
carp() {
    echo "$*" >&2
}
croak() {
    carp
    carp "ACK! $*"
    carp "     Bailing out..."
    carp
    exit 1
}

# Change into the directory where this script lives, in case it was run from
# a relative pathname (or a pathname starting from '/'):
trap 'quietly popd' 0 1 2 15
quietly pushd "$MYDIR/vm"

clear
echo "VM IMAGE PREPARATION"
echo "--------------------"
echo
echo "  This script will download and install the '$BOX_NAME' Vagrant base box"
echo "  and run 'vagrant up' for you. It honestly doesn't save you a whole lot"
echo "  of typing, but at least you don't have to look up the URL for the base"
echo "  box."
echo
read -p "Press ENTER now to continue or CTRL+C to abort... "
echo

if ! quietly which vagrant; then
    croak "Unable to find 'vagrant' in your \$PATH"
fi

# Download the base box and unpack it (to ~/.vagrant.d/boxes, probably)
if vagrant box list 2>&1 | grep -q "^$BOX_NAME"; then
    carp "Vagrant box '$BOX_NAME' seems to be present already. Skipping download."
else
    vagrant box add $BOX_NAME $VAGRANT_BOX || \
        croak "There was a problem downloading / unpacking the Vagrant box"
fi

vagrant up || \
    croak "There was a problem running / provisioning the Vagrant box"

echo
echo "Looks like everything was successful, at least as far as this part of"
echo "the setup goes. If Vagrant bailed out during the provisioning step,"
echo "you can safely run 'cd vm; vagrant provision' here to retry."
echo
echo "Otherwise, you may now use SSH to connect to the running VM on port"
echo "9922 (simply type 'cd vm; vagrant ssh' if you're on Linux or Mac OS X)"
echo "or try http://localhost:9980 to access the VM's web server."
echo

# vim: ts=4 sw=4 tw=78 colorcolumn=78
