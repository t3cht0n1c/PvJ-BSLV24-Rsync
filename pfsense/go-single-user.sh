#!/bin/sh

# Check if the script is run with superuser privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with superuser privileges."
    exit 1
fi

# Create the nologin file to deny new logins
touch /etc/nologin

# Get a list of running services and stop each one
service -e | awk -F'/' '{print $NF}' | while read -r service_name; do
    if [ "$service_name" != "servicename" ]; then
        service "$service_name" onestop
    fi
done

# Close all user sessions except the current (root) user
current_user=$(whoami)
for user in $(users | tr ' ' '\n' | grep -v "$current_user"); do
    pkill -9 -u "$user"
done

echo "The system is now in single-user mode. Only the root user is allowed."

