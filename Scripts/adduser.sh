#!/bin/bash

# Check for root privileges.
if [[ $UID -ne 0 ]]
    then
    echo "Failed. Please run with root privileges." >&2
    exit 1
fi

# Check that at least 1 argument has been entered.
if [[ $# -lt 1 ]]
    then
    echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
    exit 1
fi

# Use the first argument as the user name and the rest as comments.
USERNAME=$1
shift
COMMENTS=$@

# Generate a password automatically for the user. For demonstration purposes only. Not used in production.
PASSWORD=$(date +%s%H | sha256sum | head -c20)

# Generate the account
useradd -c "$COMMENTS" -m $USERNAME &> /dev/null

# Check if the account creation succeeded.
if [[ $? -ne 0 ]]
    then
    echo "Unable to create account. Please provide a valid username." >&2
    exit 1
fi

# Add the password to the account
echo $PASSWORD | passwd --stdin $USERNAME > /dev/null

# Check if the password creation succeeded.
if [[ $? -ne 0 ]]
    then
    echo "The password creation failed." >&2
    exit 1
fi

# Reset the password.
passwd -e $USERNAME > /dev/null

# Display information on the created account.
echo "Username: "$USERNAME
echo "Comments: "$COMMENTS
echo "Password: "$PASSWORD
echo "Hostname: "$HOSTNAME
exit 0
