#!/bin/bash
#
#  Provision a Vagrant virtual machine from *inside* the machine itself,
#  (hopefully) precluding the need to install Ansible on the host OS.
#
#  Adapted from https://bitbucket.org/weirauchlab/tf-tools-jumpstarter
#
#  Author:  Kevin Ernst <kevin.ernst@informatik.uni-halle.de>
#  Date:    26. April 2016
#
ME=$( basename "$BASH_SOURCE" )
MYDIR=$( cd "$(dirname "$BASH_SOURCE")" && pwd )
# Man, what a pain I had when '127.0.0.1,' was single-quoted
# possibly refer to: https://stackoverflow.com/a/1250279
RUNPLAY="ansible-playbook -c local -i127.0.0.1,"

# Bail out if this script isn't run on a host matching this name
VM_HOSTNAME=webdev-jessie
PROJECT_NAME=QuickFixes
VM_REPO_NAME=web-dev-with-friends

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

if [ $(hostname) != "$VM_HOSTNAME" ]; then
    croak "This script should only be run on the '$VM_HOSTNAME' VM"
fi

echo ' '
echo "This script will perform the 'provisioning' of the $PROJECT_NAME"
echo 'Vagrant VM from *within* the machine itself.'
echo ' '
echo "It's set up this way so that you don't have to install Ansible (the"
echo "provisioning system I chose) on your personal computer."
echo ' '
#echo "Press ENTER now to continue or CTRL+C to abort..."
#read JUNK

cd "$MYDIR/../provisioning" || croak "Could not find 'provisioning' directory"

# Install necessary support packages and install / configure the Apache server
# appropriately for the web application. Several of these playbooks are
# configured to run with 'sudo' (at least for certain steps), so we're sort of
# assuming that this script is run by the 'vagrant' user, who can 'sudo' w/out
# a password.
$RUNPLAY packages_and_sundry.yml || exit $?
$RUNPLAY apache_setup.yml        || exit $?

# Just in case the base box doesn't include the Vagrant user and configs
$RUNPLAY set_up_vagrant_user.yml    || exit $?
$RUNPLAY set_up_vim_and_plugins.yml || exit $?

# This was probably already done by the Vagrant shell provisioner:
#$RUNPLAY provisioning/clone_vm_repo.yml || exit $?

# This one clones the Git repos and needs to run as the 'vagrant' user
# so that the SSH agent running in the host operating system (e.g.,
# Pageant in Windows) can forward the key you set up with GitLab.
$RUNPLAY create_project_dirs.yml || exit $?
$RUNPLAY clone_projects.yml      || exit $?

echo ' '
echo "Okay, looks like we made it. Whew."
echo ' '
echo "On Linux, OS X, or Windows with a good working Bash shell (e.g.,"
echo "Git-Bash) you should be able to type"
echo ' '
echo "    vagrant ssh"
echo ' '
echo "to connect to the running VM right now."
echo ' '
echo "In order to be able to push new commits to the 'origin' repositories"
echo "for the $PROJECT_NAME project(s), and to identify yourself to Git (for"
echo "tracking your contributions in the commit history), you'll want to run"
echo ' '
echo "    /vagrant/bin/personalize.sh"
echo ' '
echo "right after logging in as the 'vagrant' user."
echo ' '
echo "~~~ Happy hacking! ~~~"
