#!/bin/sh
#
# Usage:   $ sudo generate_md5_list /path/and/outputfilename.txt

#
# Output file for the table of filenames and MD5 hashes
OUTPUT_FILE="file_hashes.txt"
OS_TYPE="Debian"
FIND_ROOT="."

# Check if the input file is provided as a command-line parameter, else use the default file
if [ $# -eq 1 ]; then
  OUTPUT_FILE="$1"
fi

# Check the Linux distribution
if [ -f "/etc/os-release" ]; then
    ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
    case "$ID" in
        debian | ubuntu | linuxmint )
            # Debian and Debian-based distributions use the 'md5sum' command
            OS_TYPE="Debian"
	    FIND_ROOT="."
            ;;
        *)
            # For other distributions, use 'md5' command (e.g., FreeBSD)
            OS_TYPE="FreeBSD"
	    FIND_ROOT="/"
            ;;
    esac
else
    # If /etc/os-release is not present, try to identify FreeBSD by checking 'uname'
    if [ "$(uname -s)" = "FreeBSD" ]; then
        OS_TYPE="FreeBSD"
    else
        echo "Unable to determine the Linux distribution or FreeBSD. Exiting."
        exit 1
    fi
fi

# Function to calculate the MD5 hash of a file
calculate_md5() {
  file="$1"
  if [ $OS_TYPE = "FreeBSD" ]; then
      md5=`md5 -q "$file"`
  else
      md5=$(md5sum "$file" | awk '{print $1}')
  fi
  echo "$md5"
}

# Check if the output file exists, and if yes, remove it
if [ -f "$OUTPUT_FILE" ]; then
  rm "$OUTPUT_FILE"
fi

# Exclude directories and files
EXCLUDE_DIRS="/tmp /var/log /usr/home"

# Traverse the root directory and create the table
echo "File Path | MD5 Hash" >> "$OUTPUT_FILE"
echo "---------------------" >> "$OUTPUT_FILE"

PROGRESS_COUNTER=0

find $FIND_ROOT -type f | while read -r file; do
  # Check if the file's directory is excluded
  skip_file=false
  for dir in $EXCLUDE_DIRS; do
    if [ "${file#$dir}" != "$file" ]; then
      skip_file=true
      break
    fi
  done

  if [ "$skip_file" = false ]; then
    md5_hash=$(calculate_md5 "$file")
    echo "$file | $md5_hash" >> "$OUTPUT_FILE"
    PROGRESS_COUNTER=$((PROGRESS_COUNTER+1))
    if [ $PROGRESS_COUNTER -gt 100 ]; then
      echo -n "."
      PROGRESS_COUNTER=0
    fi
  fi
done

echo "Table of filenames and MD5 hashes created in: $OUTPUT_FILE"

