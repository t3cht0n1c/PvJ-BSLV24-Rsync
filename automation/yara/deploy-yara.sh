#!/bin/bash

# GPL-3.0-or-later (c) 2024 straysheep-dev

# Copy a static yara binary and a list of rules to a remote host for scanning.
# A good starting point for rules is the Neo23x0/signature-base set.
# https://github.com/Neo23x0/signature-base

# You just need an SSH connection (public key is recommended) to the remote host, and read access to the paths.
# If you're root you can read anything.
# This script creates a randomized 35 character folder to drop everything into, and removes all evidence of yara after scanning.

# Tested from an Ubuntu 24.04 node, deploying yara onto an Ubuntu 16.04 server for scanning.

if [[ "$1" == '' || "$2" == '' ]]; then
	echo "[*]Usage $0 <ssh-connecton> <remote-path>"
	echo "       $ $0 root@10.10.10.10 /dev/shm"
	exit 1
fi

SSH_CONNECTION="$1"
REMOTE_PATH_ARG="$2"

# Change this to point to your yara binary and rule files
FILE_LIST="
$HOME/src/yara/yara
$HOME/Downloads/gen_webshells.yar
$HOME/Downloads/thor-webshells.yar
"

# Add or remove paths as needed
PATH_LIST='
/etc
/home
/boot
/var/www
/var/tmp
/dev/shm
/tmp
/usr
/srv
/opt
'

# Drop files onto remote system
RANDOM_STRING="$(tr -dc 'A-Z1-9' < /dev/urandom | fold -w 35 | head -n1)"
REMOTE_PATH="$REMOTE_PATH_ARG"/"$RANDOM_STRING"
ssh "$SSH_CONNECTION" "mkdir -p $REMOTE_PATH"
echo "[*]Deploying yara..."
for file in $FILE_LIST; do
	file_name=$(basename "$file")
	echo "  $file_name >>> $REMOTE_PATH"
	scp "$file" "$SSH_CONNECTION":"$REMOTE_PATH" >/dev/null
done

# Execute scans
echo ""
echo "[*]Starting scans $(date +%F:%T)"
for rule in $FILE_LIST; do
	if [[ "$rule" =~ \.yar$ ]]; then
		rule_file=$(basename "$rule")
		# Uses grep -Pv $REMOTE_PATH_ARG to prevent scanning our own yara files
		# in case we deploy into a path in the PATH_LIST.
		ssh "$SSH_CONNECTION" "$REMOTE_PATH/yara $REMOTE_PATH/$rule_file -r --scan-list <( grep -Pv \"$REMOTE_PATH_ARG\" <(cat <<<\"$PATH_LIST\")) 2>/dev/null"
	fi
done
echo "[*]Ending scans $(date +%F:%T)"
echo ""

# Clean up files
for file in $FILE_LIST; do
	file_name=$(basename "$file")
	echo "[*]Removing $file_name..."
	ssh "$SSH_CONNECTION" "rm $REMOTE_PATH"/"$file_name" 2>/dev/null
	ssh "$SSH_CONNECTION" "rm -rf $REMOTE_PATH"
done
