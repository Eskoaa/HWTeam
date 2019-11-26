#!/bin/bash

# This script disables, deletes and/or archives users on the local system.

# Check for root privileges.
if [[ $UID -ne 0 ]]
then
    echo "Please run as root or sudo." >&2
    exit 1
fi

# Provide a usage statement.
usage() {
    echo "Usage: ${0} [-dra] [USERNAME]..." >&2
    echo "Disable account." >&2
    echo "  -d      Delete account(s)." >&2
    echo "  -r      Remove home directory of account(s)." >&2
    echo "  -a      Create archive of the home directory of the account(s)." >&2
    exit 1
}

while getopts dra OPTION
do
    case $OPTION in
        a) ARCHIVE="true" ;;
        r) REMOVE="true" ;;
        d) DELETE="true" ;;
        ?) usage
    esac
done

shift $((OPTIND -1))
if [[ $# -lt 1 ]]
then
    usage
fi
DELETED="false"

if [[ $ARCHIVE = "true" ]]
then
    mkdir -p /archive

    for i in $@
    do
        id -u $i &> /dev/null

        if [[ $? -ne 0 ]]
        then
            echo "Username "$i" does not exist."
            exit 1
        fi

        date=$(date +%Y%m%d_%H%M%S)
        tar czf /archive/${i}".tar.gz."$date /home/${i}/ &> /dev/null
    done
    
    if [[ $? -ne 0 ]]
    then
        echo "Incorrect username." >&2
        exit 1
    fi

fi

if [[ $DELETE = "true" ]]
then
    if [[ $REMOVE = "true" ]]
    then
        for i in $@
        do
            userdel -r $i
        done
    else
        for i in $@
        do
            userdel $i
        done
    fi

    if [[ $? -ne 0 ]]
    then
        echo "Incorrect username." >&2
        exit 1
    fi
    DELETED="true"
fi

if [[ $DELETED = "false" ]]
then
    for i in $@
    do
        chage -E0 $i
    done
fi

exit 0
