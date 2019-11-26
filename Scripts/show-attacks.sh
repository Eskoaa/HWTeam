#!/bin/bash

# This script shows failed login attempts and locations of ip addresses with more than specified connection attempts

# Check for root privileges
if [[ $UID -ne 0 ]]
then
    echo "Please run as root." >&2
    exit 1
fi

ATTEMPTS=0

echo "Count,IP,Location"

# Sort the file
ADDRESSES=$(grep "invalid user" /var/log/messages | grep -v COMMAND | awk -F 'invalid ' '{print $2}' | awk -F 'port' '{print $1}' | grep -v sup | awk '{print $NF}' | sort | uniq -c | sort -nr | awk '{print $1","$2}')

# Check addresses that occur more than specified times and geolocate them.
for i in $ADDRESSES
do
    REPEATS=$(echo $i | cut -d "," -f 1)
    ADDRESS=$(echo $i | cut -d "," -f 2)
    
    if [[ $REPEATS -gt $ATTEMPTS ]]
    then
        LOCATION=$(curl -s https://ipvigilante.com/${ADDRESS})
        CONTINENT=$(echo $LOCATION | awk -F '"continent_name":"' '{print $2}' | awk -F '"' '{print $1}')
        COUNTRY=$(echo $LOCATION | awk -F '"country_name":"' '{print $2}' | awk -F '"' '{print $1}')
        SUB1=$(echo $LOCATION | awk -F '"subdivision_1_name":"' '{print $2}' | awk -F '"' '{print $1}')
        CITY=$(echo $LOCATION | awk -F '"city_name":"' '{print $2}' | awk -F '"' '{print $1}')
        echo $REPEATS" "$ADDRESS"  "$CONTINENT", "$COUNTRY", "$SUB1", "$CITY
    fi
done
exit 0
