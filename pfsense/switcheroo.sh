#!/bin/sh
#
# switcheroo.sh
# THE BIG SWITCH!
#
# To be run on the pfSense box as root after unpacking all the tar.gz's into
#  the suffix-1 directories.
#
# This moves all the system dirs to $bakdir, and at the same time
#  moves the [subdir1]'s to [subdir].
#
# REBOOT THE SYSTEM AFTER RUNNING THIS TO BOOT INTO THE NEW VERSION

opdir="/home/op"       # location of the static mymv10 command binary
bakdir="/home/op/backup/"

set -x
cd $opdir

# Check if the directory exists
if [ ! -d "$bakdir" ]; then
    # If the directory doesn't exist, create it
    mkdir -p "$bakdir"
    echo "Directory created: $bakdir"
else
    echo "Directory already exists: $bakdir"
fi

# get a copy of the fstab
cp /etc/fstab $opdir/.

# save-and-create fresh items
$opdir/mymv10 /cf $bakdir
mkdir /cf
mkdir /cf/conf
$opdir/mymv10 /conf $bakdir
ln -s /cf/conf /conf
cp /config/config.xml /cf/conf/.
$opdir/mymv10 /sys $bakdir
# well this one exists, but it should be empty
$opdir/mymv10 /rescue $bakdir
mkdir rescue

# now we do the move-and-swaps
$opdir/mymv10 /boot $bakdir
$opdir/mymv10 /boot1 /boot

$opdir/mymv10 /etc $bakdir
$opdir/mymv10 /etc1 /etc
ls /etc
read -p "Press enter to continue."

$opdir/mymv10 /lib $bakdir
$opdir/mymv10 /lib1 /lib

$opdir/mymv10 /libexec $bakdir
$opdir/mymv10 /libexec1 /libexec

$opdir/mymv10 /root $bakdir
$opdir/mymv10 /root1 /root

$opdir/mymv10 /sbin $bakdir
$opdir/mymv10 /sbin1 /sbin

$opdir/mymv10 /usr $bakdir
$opdir/mymv10 /usr1 /usr

$opdir/mymv10 /var $bakdir
$opdir/mymv10 /var1 /var

$opdir/mymv10 /bin $bakdir
$opdir/mymv10 /bin1 /bin

$opdir/mymv10 $opdir/fstab /etc/.

