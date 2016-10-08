#!/bin/bash
#
# Build the base box using 'veewee' (https://github.com/jedi4ever/veewee)
# Please refer to README.md for complete instructions
#

if [ "$FORCE" = "1" -o "${1:0:2}" = "-f" -o "${1:0:3}" = "--f" ]; then
    EXTRA_ARGS="--force"
fi

veewee vbox build $EXTRA_ARGS bioreactor-jessie
veewee vbox export bioreactor-jessie
