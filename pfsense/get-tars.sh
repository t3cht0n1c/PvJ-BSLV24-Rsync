#!/bin/sh
#
# Run on the pfSense machine.
# Make sure ssh is enabled and ready on the iso host machine.
#
# Usage: 
#        To fetch the files from the srcside via scp (!! will ask for pwd !!)
#        (beware of keyloggers; change the ssh passwrd on the srcside immediately after using)
#          get-tars.sh scp user@x.x.x.x:/path/to/tar-gz-fileset
#
#        To download via curl:
#          get-tars.sh curl x.x.x.x:8000
#

#!/bin/sh

# Define the directory path
opdir="/home/op"
subdir="pfver27"   # where the .tar.gz fileset lives

# Check if the directory exists
if [ ! -d "$opdir" ]; then
    # If the directory doesn't exist, create it
    mkdir -p "$opdir"
    echo "Directory created: $opdir"
else
    echo "Directory already exists: $opdir"
fi


if [ $1 = "scp" ]; then
    set -x
    scp $2/$subdir/bin1.tar.gz $opdir/.
    scp $2/$subdir/boot1.tar.gz $opdir/.
    scp $2/$subdir/etc1.tar.gz $opdir/.
    scp $2/$subdir/lib1.tar.gz $opdir/.
    scp $2/$subdir/libexec1.tar.gz $opdir/.
    scp $2/$subdir/root1.tar.gz $opdir/.
    scp $2/$subdir/sbin1.tar.gz $opdir/.
    scp $2/$subdir/usr1.tar.gz $opdir/.
    scp $2/$subdir/var1.tar.gz $opdir/.
    scp $2/$subdir/profiles.tar.gz $opdir/.
fi

if [ $1 = "curl" ]; then
    set -x
    curl $2/$subdir/bin1.tar.gz -o $opdir/bin.tar.gz
    curl $2/$subdir/boot1.tar.gz -o $opdir/boot1.tar.gz
    curl $2/$subdir/etc1.tar.gz -o $opdir/etc1.tar.gz
    curl $2/$subdir/lib1.tar.gz -o $opdir/lib1.tar.gz
    curl $2/$subdir/libexec1.tar.gz -o $opdir/libexec1.tar.gz
    curl $2/$subdir/root1.tar.gz -o $opdir/root1.tar.gz
    curl $2/$subdir/sbin1.tar.gz -o $opdir/sbin1.tar.gz
    curl $2/$subdir/usr1.tar.gz -o $opdir/usr1.tar.gz
    curl $2/$subdir/var1.tar.gz -o $opdir/var1.tar.gz
    curl $2/$subdir/profiles.tar.gz -o $opdir/profiles.tar.gz
fi



