#!/bin/bash
#
#  Update a few things on the VM (guest system) to reflect the
#  actual user's name and email; create a new SSH public/private key pair
#
#  Author:  Kevin Ernst <ernstki@mail.uc.edu>
#  Date:    27 Sep 2016
#
#set -x
ME=$( basename "$BASH_SOURCE" )
MYDIR=$( cd "$(dirname "$BASH_SOURCE")" && pwd )

# Bail out if this script isn't run on a host matching this name
VM_HOSTNAME=bioreactor-jessie
REPO_NAME=bioreactor-vm
ORIGIN=git@github.uc.edu:Bioreactor
HUBORLAB=Hub
DEPLOY_KEY=id_rsa-bioreactor-vm-deploy
KEY_SETTINGS_URL=https://github.uc.edu/settings/keys

quietly() {
    $* &>/dev/null
}
# ≈ «kritteln» auf Deutsch (glaube ich)
carp() {
    echo "$*" >&2
}
# «sterben» auf Deutsch
croak() {
    carp
    carp "ACK! $*"
    carp "     Bailing out..."
    carp
    exit 1
}

# This cn be run on a properly-configured Ubuntu machine, e.g., by the
# 'bin/no-vm-setup.sh' script, so don't check the hostname anymore.
#if [ $(hostname) != "$VM_HOSTNAME" -a -z "$SKIP_HOSTNAME_CHECK" ]; then
#    croak "This script should only be run on the '$VM_HOSTNAME' VM"
#fi

# If run with the '--undo', copy the MUTI deploy keys back into ~/.ssh
if [[ $1 =~ ^--(undo|(install-)?deploy-key) ]]; then
    clear
    echo "REPLACE ~/.ssh/id_rsa WITH DEFAULT DEPLOY-ONLY KEYPAIR"
    echo "------------------------------------------------------"
    echo
    echo "  This operation will replace your SSH public/private keypair with"
    echo "  the (read-only) Git$HUBLAB 'deploy key' that was put in place during"
    echo "  the initial provisioning of the Vagrant virtual machine."
    echo 
    echo "  If you can't clone the '${REPO_NAME}' repository anymore, maybe"
    echo "  it's just because you forgot to paste your public key into the"
    echo "  'SSH Keys' section of your Git$HUBORLAB profile. You can do that now"
    echo "  by pressing <Strg>+<C> and then typing 'cat ~/.ssh/id_rsa.pub'"
    echo "  at the terminal prompt. Copy and paste the ENTIRE line into the"
    echo "  textarea at ${KEY_SETTINGS_URL}."
    echo
    read -p "Press ENTER now to continue or CTRL+C to abort... "
    echo

    quietly pushd "$MYDIR/../provisioning/files" || \
        croak "Unable to switch to the 'provisioning/files' subdirectory"
    # Check to see if the deploy key even exists:
    test -f $DEPLOY_KEY -a -f $DEPLOY_KEY.pub || \
        croak "Unable to locate Git$HUBORLAB deploy-only keypair"

    set -x
    cp -i $DEPLOY_KEY ~/.ssh/id_rsa || \
        croak "Problem copying deploy-only private key to ~/.ssh/id_rsa"
    cp -i $DEPLOY_KEY.pub ~/.ssh/id_rsa.pub || \
        croak "Problem copying deploy-only public key to ~/.ssh/id_rsa.pub"
    # Just to be sure that the key agent won't complain about permissions
    chmod 600 ~/.ssh/id_rsa
    ssh-add
    set +x

    echo
    echo "All done. Try typing 'git pull' inside ~/devel/$REPO_NAME to see if"
    echo "everything worked out."
    echo
    exit
fi

# Otherwise, run the script as normal
clear
echo "VM IMAGE PERSONALIZATION"
echo "------------------------"
echo
echo "  This script will update your ~/.gitconfig with your name and email, so"
echo "  that you get proper credit (or blame) in Git$HUBORLAB project commit logs."
echo
echo "  You will also be prompted for a password to secure your SSH private key."
echo "  Please don't just press ENTER; choose a good password."
#echo "  The same password will be used as the login password for the 'vagrant'"
#echo "  user on your VM image. Please don't just press ENTER; choose a good"
#echo "  password."
echo
echo "  After this script finishes, the public key will be printed to the"
echo "  terminal. You should then select and copy the ENTIRE LINE (with"
echo "  the right-click menu or <Shift> + <Strg> + <C>) and then paste this"
echo "  key into your Git$HUBORLAB profile. This enables you to clone / push to"
echo "  repositories to which you have permission to do so without having to"
echo "  supply a password each time."
echo
read -p "Press ENTER now to continue, 's' to skip this step, or CTRL+C to abort... "
echo

if [[ $REPLY =~ ^[Ss] ]]; then exit; fi

cd "$MYDIR/../provisioning" || croak "Could not find 'provisioning' directory"

ansible-playbook -c local -i'127.0.0.1,' personalization.yml || \
    croak "Ansible provisioning failed."

# Otherwise, copy the contents of the ~/.id_rsa.pub to the X clipboard
#if ! quietly which xclip; then
#    croak "Couldn't find 'xclip'; run 'sudo apt-get install xclip' and try again"
#fi

# This doesn't work (or at least not reliably), because 'xclip' stays in a
# loop waiting for another client to request the contents of the clipboard.
# See: http://stackoverflow.com/a/32584438 for details
#output=$( xclip -i -selection clipboard < ~/.ssh/id_rsa.pub 2>&1 )

#if [[ $output =~ "Can't open display" ]]; then
#    carp
#    carp "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#    carp " This script tried to copy your SSH public key to the X clipboard,"
#    carp " but it looks like you're not running it inside the graphical XFCE"
#    carp " environment."
#    carp
#    carp " IMPORTANT: You'll need to manually copy the contents of your public"
#    carp " key from the terminal after running this command (in a new Terminal"
#    carp " window):"
#    carp
#    carp "   cat ~/.ssh/id_rsa.pub"
#    carp
#    carp " Note: you have to make sure the key forms a single line of text"
#    carp " (i.e., no carriage returns) when you paste it into the \"SSH Keys\""
#    carp " section of your Git$HUBORLAB profile."
#    carp "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
#    carp
#else
#    echo
#    echo "Your ~/.ssh/id_rsa.pub (SSH public key) has been copied to the clipboard."
#fi

echo
echo "Here's your new SSH public key (output of 'cat ~/.ssh/id_rsa.pub')"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
cat ~/.ssh/id_rsa.pub
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo
echo 'Go ahead and copy this entire line (beginning with "ssh-rsa" and'
echo "ending with \"${USER}@$(hostname -s)\") from the terminal and add it to"
echo "your Git$HUBORLAB profile now:"
echo
echo "  $KEY_SETTINGS_URL"
echo
echo "Really, please do it now. You won't be able to clone any projects from"
echo "Git$HUBORLAB if you don't. Seriously."
echo
read -p "Press ENTER after you've added your key to Git$HUBORLAB, or CTRL+C to abort... "
echo

clear
echo
echo "Let's add the new private key \"identity\" to the running SSH agent, so"
echo "you can start using it right away."
echo
echo "As a final test, try a 'git pull' within the '$REPO_NAME' directory to"
echo "make sure that it works. If you originally cloned the '$REPO_NAME'"
echo "repository with an HTTP(S) URL, you can switch it to use the 'git://'"
echo "(SSH) protocol like so:"
echo
echo "  git remote set-url origin $ORIGIN/${REPO_NAME}.git"
echo
echo "If you're running this script in a GUI environment, you should receive"
echo "a dialog box prompting you to unlock the private key. Please check the"
echo "\"Automatically unlock this key\" box so you won't be prompted again."
echo
echo "This will add the private key password to your \"login keyring,\" which"
echo "is essentially a password database that gets unlocked automatically each"
echo "time you log in. For best security, you should also change the 'vagrant'"
echo "user's password at this time, since that's essentially the \"master"
echo "password\" for the database."
echo
echo "In any case, after supplying your private key password here, the key"
echo "will remain unlocked for the duration of your login session."
echo

# Add the new identity (and forget the old one)
ssh-add
