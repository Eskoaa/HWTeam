#!/bin/bash

# This script loop through usernames and creates .ssh and authorized_keys files to them if nececcary. After this pedefined public key is inserted in  the authorized_keys file.

# Check for root privileges.
if [[ $UID -ne 0 ]]
    then
    echo "Please run as sudo or as root"
    exit 1
fi

USERNAMES=([REDACTED])

for i in "${USERNAMES[@]}"
do
    su $i -c "mkdir -p /home/${i}/.ssh"
    AUTH=/home/${i}/.ssh/authorized_keys

    if [[ ! -f $AUTH ]]
    then
        su $i -c "touch $AUTH"
    fi

    su $i -c "echo '[REDACTED]' >> $AUTH"
    su $i -c "chmod 600 $AUTH"
    su $i -c "chmod 700 /home/${i}/.ssh"
done
