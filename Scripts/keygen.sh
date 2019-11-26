#!/bin/bash

# Check for root privileges.
if [[ $UID -ne 0 ]]
    then
    echo "Please run as sudo or as root" >&2
    exit 1
fi

# Add usernames to array and loop through them. Create .ssh directory if it doesn't exist and create public and private keyfiles if they don't exist. Use the same private keys for all user accounts. Change permissions accordingly.
USERNAMES=([REDACTED])

for i in "${USERNAMES[@]}"
do
    su $i -c "mkdir -p /home/${i}/.ssh"
    PRIV=/home/${i}/.ssh/id_ed25519 
    PUB=/home/${i}/.ssh/id_ed25519.pub

    if [[ ! -f $PRIV ]]
    then
        su $i -c "touch $PRIV"
    fi

    if [[ ! -f $PUB ]]
    then
        su $i -c "touch $PUB"
    fi

    su $i -c "echo '[REDACTED] ' > $PRIV"
 
    su $i -c "echo '[REDACTED]' > $PUB"
    su $i -c "chmod 700 /home/${i}/.ssh"
    su $i -c "chmod 600 $PRIV"
done
exit 0
