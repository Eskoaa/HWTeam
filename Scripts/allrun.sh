#!/bin/bash

# This script executes commands provided as arguments on all servers specified in the servers file.
# This script needs a servers file to run. By default it checks the home/user/servers file.
# Specify either ip addresses or names one per line in the file or use the -f option. 

# Default file for servers
FILE="/home/$(id -un)/servers"
# Specify ssh options
SSH_OPTIONS='-qo ConnectTimeout=2'

usage () {
    echo "Usage: "$0" [-sv] [-n USERNAME] [-f FILE] [COMMAND]..." >&2
    echo "Executes COMMAND on all servers listed in the specified file." >&2
    echo "      -f [FILE]     Override default file (${FILE})" >&2
    echo "      -n [USERNAME] Username to connect with." >&2
    echo "      -d            Dry run. Commands displayed but not executed." >&2
    echo "      -s            Run as sudo." >&2
    echo "      -v            Verbose mode." >&2
    exit 1
}

while getopts f:n:svd OPTION
do
    case $OPTION in
        v)
            VERBOSE=true
            ;;
        d)
            DRYRUN=true
            ;;
        s)
            SUDO=true
            ;;
        f)
            FILE=$OPTARG 
            ;;
        n) 
            USERNAME=$OPTARG
            ;;
        ?)
            usage
            ;;
    esac
done

# Make sure arguments are inserted after options
shift $(( OPTIND -1))

if [[ $# -lt 1 ]]
then
    usage
fi

# Check for root privileges.
if [ "$UID" -ne 0 ] && [ "$SUDO" == true ]
then
    echo "Cannot use -s option with non-root user." >&2
    exit 1
elif [ "$UID" -eq 0 ] && [ "$SUDO" != true ]
then
    echo "Use -s option to run with root." >&2
    exit 1
fi

# Check that the file exists.
if [[ ! -e $FILE ]]
then
    echo "The file "$FILE" does not exist." >&2
    exit 1
fi

# Check for dry run flag.
if [[ "$DRYRUN" == true ]]
then
    for COMMAND in "$@"
    do
        if [[ "$SUDO" == true ]]
        then
            for SERVER in $(cat $FILE)
            do
                echo "DRY RUN: ssh "$SSH_OPTIONS" "$USERNAME"@"$SERVER" "sudo" "$COMMAND
            done
        else
            for SERVER in $(cat $FILE)
            do
                echo "DRY RUN: ssh "$SSH_OPTIONS" "$USERNAME"@"$SERVER" "$COMMAND
            done
        fi
    done
    exit 0
fi

# Loop through the servers in the specified file and execute the specified commands.
for COMMAND in "$@"
do
    for SERVER in $(cat $FILE)
    do
# Check for the verbose flag.
        if [[ "$VERBOSE" == true ]]
        then
            echo "Executing command ${COMMAND} on ${SERVER}"
        fi

# Check that the user is able to connect to the server with public keys.
        if ssh -o ConnectTimeout=2 $USERNAME"@"$SERVER $COMMAND 2>&1 | grep 'publickey' &> /dev/null
        then
            echo "Incorrect username ${USERNAME} or public key on ${SERVER}. Use the -n option to specify username." >&2
        else
            ssh $SSH_OPTIONS $USERNAME"@"$SERVER $COMMAND 2> /dev/null
            EXITSTATUS=$?
        fi
        
# Check the exit status of the ssh command.
        if [[ $EXITSTATUS -eq 255 ]]
        then
            echo $SERVER" is offline, unreachable or incorrect server name specified." >&2
        elif [[ $EXITSTATUS -ne 0 ]]
        then
            echo "Unknown command ${COMMAND} on ${SERVER}." >&2
        fi
    done
done
exit 0
