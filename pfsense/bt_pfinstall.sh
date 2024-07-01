#!/bin/bash
#
# script to install a new version of pfSense without a CDROM drive
# K10 230730 written for Pros-Vs-Joes 2023
#
# NOTES:
#  - This leaves /root untouched, so check it carefully for IoCs.

# 1. Verify the /bin binaries are not compromised

read -p "Have you verified the binaries in /bin are good versions? (y/n) " verified
case ${verified:0:1} in
  n|N )
      echo "Complete that validation and then run this script again."
      exit 0
      ;;
esac


# 2. Verify there is enough disk space to save a backup of the current system



# 3. Make our own copy of /bin to use while we are overwriting everything
sudo mkdir /opt
sudo cp /bin/* /opt/



# 3. 

