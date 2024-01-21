#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Github: https://github.com/007revad/Synology_enable_sequential_IO
# Script verified at https://www.shellcheck.net/
#
# Synology sets the skip_seq_thresh_kb to 1024
# Setting skip_seq_thresh_kb to 0 enables sequential I/O like DSM 6 had.
#
# To run in a shell (replace /volume1/scripts/ with path to script):
# sudo -i /volume1/scripts/syno_seq_io.sh
#
# You can run this script with a parameter to specify the skip_seq_thresh_kb
# For example the following would set the cache you select back to default
# sudo -i /volume1/scripts/syno_seq_io.sh 1024
#
# If no parameter the script defaults to 0
#------------------------------------------------------------------------------

scriptver="v1.0.0"
script=Synology_enable_sequential_IO
repo="007revad/Synology_enable_sequential_IO"
#scriptname=syno_seq_io

if [[ $1 =~ ^[0-9]+$ ]]; then
    kb="$1"
else
    kb="0"
fi

echo -e "$script $scriptver - by 007revad\n"
echo -e "See https://github.com/$repo \n"

# Check script is running as root
if [[ $( whoami ) != "root" ]]; then
    echo -e "ERROR This script must be run as sudo or root!"
    exit 1
fi

# Get list of volumes with caches
caches=("$(sysctl dev | grep skip_seq_thresh_kb)")

# Get caches' current setting 
for c in "${caches[@]}"; do
    volume="$(echo "$c" | cut -d"+" -f2 | cut -d"." -f1)"
    kbs="$(echo "$c" | cut -d"=" -f2 | awk '{print $1}')"
    volumes+=("${volume}|$kbs")
done

# Select cache volume to edit
if [[ ${#volumes[@]} -gt 0 ]]; then
    echo "Setting a cache's skip_seq_thresh_kb to 0 enables sequential I/O"
    echo "Choose a volume with a cache to edit: "
    echo "---------------------"
    echo "Cache Volume  Setting"
    echo "---------------------"
    for ((i=1; i<=${#volumes[@]}; i++)); do
        info="${volumes[i-1]}"
        before_pipe="${info%%|*}"
        after_pipe="${info#*|}"
        printf "%-3s %-9s %s\n" "$i)" "$before_pipe" "$after_pipe"
    done
    echo "---------------------"
else
    echo "No caches found!" && exit 1
fi

# Parse selected element of array
read -rp "Select cache volume to edit: " choice
#IFS="|" read -r cachevol setting <<< "${volumes[choice-1]}"

# Check valid choice entered
if [[ $choice =~ ^[0-9]+$ ]] &&  [[ $choice != "0" ]] &&\
    [[ ! $choice -gt "${#volumes[@]}" ]]; then
    IFS="|" read -r cachevol setting <<< "${volumes[choice-1]}"
else
    echo "Invalid choice! $choice"
    exit
fi

# Show selected volume and it's current setting
if [[ ! $setting -eq "$kb" ]]; then
    echo -e "\nYou selected $cachevol to set to $kb\n"
else
    echo -e "\n$cachevol is already set to $kb\n"
    exit
fi

# Get cache's key name
cacheval="$(sysctl dev | grep skip_seq_thresh_kb | grep "$cachevol")"
key="$(echo "$cacheval" | cut -d"=" -f1 | cut -d" " -f1)"

# Set new cache kb value
synosetkeyvalue /etc/sysctl.conf "$key" "$kb"

# Check we set key value
check="$(synosetkeyvalue /etc/sysctl.conf "$key")"
if [[ "$check" == "$kb" ]]; then
    echo -e "Sequential I/O for $cachevol cache is enabled.\n"
elif [[ -z "$check" ]]; then
    echo -e "Sequential I/O for $cachevol cache is set to default.\n"
else
    echo -e "Sequential I/O for $cachevol cache is set to $check.\n"
fi

exit

