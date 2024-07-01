#!/bin/sh
#
# Script for upgrading pfSense from early versions like v2.3
#  to the current 2.7 (community editions).
#
# CONSOLE ACCESS IS REQUIRED
#
# issuing the "shutdown now" command as root on the console will
#   prompt to restart in single-user mode.
#
# ONCE in single-user mode, run this script.

# copy the commands we'll be using for the upgrade
# because we are going to delete everything else
mkdir /opt
cp /bin/* /opt/
cd /opt

# BLEH BROKEN



