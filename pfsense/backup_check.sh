#!/bin/sh

# Step 1: Check available disk space and used space
total_space=$(df -m / | awk 'NR==2 {print $2}')
used_space=$(df -m / | awk 'NR==2 {print $3}')
available_space=$(df -m / | awk 'NR==2 {print $4}')

if [ "$available_space" -gt "$used_space" ]; then
    # Enough space for backup
    echo "There is enough disk space to make a full backup."
    space_leftover=$((available_space - used_space))
    echo "Space leftover after the full backup: $space_leftover MB"
    exit 0
else
    # Not enough space for backup, find top 12 largest files
    space_needed=$((used_space - available_space))
    echo "Insufficient disk space for a full backup."
    echo "Additional space needed: $space_needed MB"

    # List top 12 largest files
    echo "Listing top 12 largest files:"
    find / -type f -exec du -h {} + | sort -rh | head -n 12
    exit 1
fi

