#!/bin/sh

# Default input file containing the table of filenames and MD5 hashes from Server A
DEFAULT_INPUT_FILE="file_hashes.txt"

# Directories to exclude from comparison
EXCLUDE_DIRS="/tmp /var/log /usr/home"

# Function to calculate the MD5 hash of a file
calculate_md5() {
  file="$1"
  md5=`md5 -q "$file"`
  echo "$md5"
}

# Check if the input file is provided as a command-line parameter, else use the default file
if [ $# -eq 1 ]; then
  INPUT_FILE="$1"
else
  INPUT_FILE="$DEFAULT_INPUT_FILE"
fi

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: File hashes input file '$INPUT_FILE' not found."
  exit 1
fi

# Display the name of the file being used for the hashes source
echo "Checking system file hashes against $INPUT_FILE..."

# Traverse the root directory on Server B and check files against the input file
while IFS=" | " read -r file_path md5_expected; do
  # Check if the file's directory is excluded
  skip_file=false
  for dir in $EXCLUDE_DIRS; do
    if [ "${file_path#$dir}" != "$file_path" ]; then
      skip_file=true
      break
    fi
  done

  if [ "$skip_file" = false ]; then
    if [ -f "$file_path" ]; then
      md5_actual=$(calculate_md5 "$file_path")
      if [ "$md5_actual" != "$md5_expected" ]; then
        echo "File with mismatched MD5: $file_path"
      fi
    else
      echo "Extra file found on this server: $file_path"
    fi
  fi
done < "$INPUT_FILE"

