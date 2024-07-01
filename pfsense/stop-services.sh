#!/bin/sh
#
# stop-services.sh
# Find running services and stop them. Intended for prepping machine
#  for major OS and version upgrades.

# Check if the script is run with superuser privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with superuser privileges."
    exit 1
fi

# Get the list of running services from /var/run/ and loop through them
ls /var/run/ | grep -E '.*\.pid$' | sed 's/\.pid$//' | while read -r service_name; do
    # Check if the service script exists in /usr/local/etc/rc.d
    if [ -f "/usr/local/etc/rc.d/${service_name}" ]; then
        echo "Stopping service ${service_name}..."
        service "${service_name}" stop
    elif [ -f "/etc/rc.d/${service_name}" ]; then
        echo "Stopping service ${service_name}..."
        service "${service_name}" stop
    else
        echo "Service ${service_name} not found as a script in /usr/local/etc/rc.d or /etc/rc.d."
    fi
done

# now kill the ones that aren't in rc.d for some reason
pkill -9 unbound
pkill -9 dhcpd
pkill -9 nginx
pkill -9 ping

#!/bin/sh

# Check if the script is run with superuser privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with superuser privileges."
    exit 1
fi

set -x

# Create the nologin file to deny new logins
touch /etc/nologin

# Get a list of running services and stop each one
for service_name in $(ps ax | grep "[ /]\(\./\)\?service\>" | awk '{print $NF}' | sort -u); do
    service "$service_name" stop
done

# Close all user sessions except the current (root) user
current_user=$(whoami)
for user in $(users | tr ' ' '\n' | grep -v "$current_user"); do
    pkill -9 -u "$user"
done

echo "The system is now in single-user mode. Only the root user is allowed."

echo "All relevant services have been stopped."

