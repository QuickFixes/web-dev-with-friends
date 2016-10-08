#!/bin/bash
#
#  Bash programmable completion setup for local playbooks
#
#  Author: Kevin Ernst <ernstki -at- mail.uc.edu>
#
#  Usage:  $ source path/to/completions.sh
#          $ play <Tab>
#
MYDIR=$( cd "$(dirname "$BASH_SOURCE")" && pwd )
USAGE='
Usage:  $ source path/to/completions.sh
        $ play <Tab>
'

if [[ ! $0 =~ ^- ]]; then
    # if *run* as a script, instead of sourced:
    echo "$USAGE" 2>&1
    exit 1
fi

__invoke_tasks() {
    if ! test -d provisioning; then return; fi
    ( cd provisioning && ls *.yml )
}

play() {
    bin/play.sh "provisioning/$1"
}

complete -W "$( __invoke_tasks )" play
