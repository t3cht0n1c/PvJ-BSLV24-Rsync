#!/bin/bash
# build a hash file from a pfSense .iso file
#
# Usage:  build_hash_data 2.4.3
#         (run from the directory with the .iso file)
# /scripts directory with the generate_md5_list.sh present is expected

if [ -z "$1" ]
  then
    echo "You must specify the version of pfSense to hash, e.g. 2.4.3"
    exit 1
fi

myiso="pfSense-CE-$1-RELEASE-amd64.iso"
echo "processing " . $myiso

HASH_LIST="file_hashes_v$1"

set -x
SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo "Script path: $SCRIPT_PATH"
OUTPUT_FILE="$SCRIPT_PATH/../$HASH_LIST"

sudo mount -o loop $myiso /media/cdrom
# Check the exit status of the 'sudo mount' command
if [ $? -eq 0 ]; then
    echo "Mount successful."
else
    echo "Mount of /media/cdrom failed. Exiting."
    exit 1
fi

cd /media/cdrom

# echo "running $SCRIPT_PATH/generate_md5_list.sh $OUTPUT_FILE"

set +x 

# run the hash generator from here
sudo $SCRIPT_PATH/generate_md5_list.sh $OUTPUT_FILE

cd $SCRIPT_PATH
sudo umount /media/cdrom

echo "-----------------------------------------"
