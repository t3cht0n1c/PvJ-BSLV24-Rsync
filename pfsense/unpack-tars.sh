#!/bin/sh
#
# unpack-tars.sh
# To be run as root on the pfSense machine.
#
# This unpacks all the new system files into suffix-1 directories 
#  in prep to do the mv-script switcharoo
# 
# BEFORE RUNNING, transfer all of the tar.gz files into the / directory.

opdir="/home/op"
set -x
cd /
mkdir bin1
tar xzf $opdir/bin1.tar.gz --strip-components=3 -C /bin1
mkdir boot1
tar xzf $opdir/boot1.tar.gz --strip-components=3 -C /boot1
mkdir etc1
tar xzf $opdir/etc1.tar.gz --strip-components=3 -C /etc1
mkdir lib1
tar xzf $opdir/lib1.tar.gz --strip-components=3 -C /lib1
mkdir libexec1
tar xzf $opdir/libexec1.tar.gz --strip-components=3 -C /libexec1
mkdir root1
tar xzf $opdir/root1.tar.gz --strip-components=3 -C /root1
mkdir sbin1
tar xzf $opdir/sbin1.tar.gz --strip-components=3 -C /sbin1
mkdir usr1
tar xzf $opdir/usr1.tar.gz --strip-components=3 -C /usr1
mkdir var1
tar xzf $opdir/var1.tar.gz --strip-components=3 -C /var1
mkdir net
# no tar.gz file for net
tar xzf $opdir/profiles.tar.gz --strip-components=1 -C /
chown root:operator /.cshrc
chown root:operator /.profile
chown root:operator /.rnd
chown root:operator /entropy

