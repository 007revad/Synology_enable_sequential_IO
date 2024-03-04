#!/usr/bin/env bash
# shellcheck disable=SC2076,SC2207
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

# v2.0.3
# Added --volumes option to make it possible to schedule script to run at boot-up.
#  - You can specify multiple comma separated volumes.
# Added --kb option to replace setting kb via first parameter.
# Bug fix for "Not persistent across reboots" issue #2
# Bug fix for when no caches are found.
# Bug fix for when multiple caches are found.


scriptver="v2.0.3"
script=Synology_enable_sequential_IO
repo="007revad/Synology_enable_sequential_IO"
#scriptname=syno_seq_io

# Check script is running as root
if [[ $( whoami ) != "root" ]]; then
    echo -e "$script $scriptver - by 007revad"
    echo -e "ERROR This script must be run as sudo or root!"
    exit 1
fi

version(){ 
    echo -e "$script $scriptver - by 007revad"
    echo -e "See https://github.com/$repo \n"
}

# Save options used
args=("$@")

usage(){ 
    cat <<EOF
$script $scriptver - by 007revad

Usage: $(basename "$0") [options]

Options:
      --volumes=VOLUME  Volume or volumes to enable sequential I/O for
                          Use when scheduling the script
                          Examples:
                          --volumes=volume_1
                          --volumes=volume_1,volume_3,volume_4
      --kb=KB           Set a specific sequential I/O kb value
                          Use to disable sequential I/O
                          --kb=1024
  -e, --email           Disable colored text in output scheduler emails
  -h, --help            Show this help message
  -v, --version         Show the script version

EOF
    exit 0
}

# Check for flags with getopt
if options="$(getopt -o abcdefghijklmnopqrstuvwxyz0123456789 -l \
    volumes:,kb:,email,help,version -- "${args[@]}")"; then
    eval set -- "$options"
    while true; do
        case "${1,,}" in
            -h|--help)          # Show usage options
                usage
                ;;
            -v|--version)       # Show script version
                scriptversion
                exit
                ;;
            --volumes)          # Volumes to process
                if [[ -n "$2" ]]; then
                    IFS=',' read -r -a cachevols <<< "$2"
                    scheduled="yes"
                    shift
                fi
                ;;
            --kb)               # kb value to set
                if [[ $2 =~ ^[0-9]+$ ]]; then
                    kb="$2"
                    shift
                fi
                ;;
            -e|--email)         # Disable colour text in task scheduler emails
                color=no
                ;;
            --)
                shift
                break
                ;;
            *)                  # Show usage options
                echo -e "Invalid option '$1'\n"
                usage "$1"
                ;;
        esac
        shift
    done
else
    echo
    usage
fi

if [[ -z "$kb" ]]; then
    kb="0"
fi

# Show script version
version

# Show options used
if [[ ${#args[@]} -gt "0" ]]; then
    echo "Using options: ${args[*]}"
fi

# Shell Colors
if [[ $color != "no" ]]; then
    #Black='\e[0;30m'   # ${Black}
    Red='\e[0;31m'      # ${Red}
    Green='\e[0;32m'    # ${Green}
    #Yellow='\e[0;33m'  # ${Yellow}
    #Blue='\e[0;34m'    # ${Blue}
    #Purple='\e[0;35m'  # ${Purple}
    Cyan='\e[0;36m'     # ${Cyan}
    #White='\e[0;37m'   # ${White}
    #Error='\e[41m'      # ${Error}
    Off='\e[0m'         # ${Off}
else
    echo ""  # For task scheduler email readability
fi


# Get list of volumes with caches
cachelist=("$(sysctl dev | grep skip_seq_thresh_kb)")
IFS=$'\n' caches=($(sort <<<"${cachelist[*]}")); unset IFS


if [[ ${#caches[@]} -lt "1" ]]; then
    echo "No caches found!" && exit 1
fi


# Get caches' current setting 
for c in "${caches[@]}"; do
    volume="$(echo "$c" | cut -d"+" -f2 | cut -d"." -f1)"
    kbs="$(echo "$c" | cut -d"=" -f2 | awk '{print $1}')"
    volumes+=("${volume}|$kbs")

    sysctl_dev="$(echo "$c" | cut -d"." -f2 | awk '{print $1}')"
    sysctl_devs+=("$sysctl_dev")
done


# Show cache volumes and current setting
if [[ $scheduled != "yes" ]]; then
    if [[ ${#volumes[@]} -gt 0 ]]; then
        echo -e "Setting a cache's skip_seq_thresh_kb to 0 enables sequential I/O\n"
        #echo "Volumes with a cache: "
        echo "----------------------"
        echo "   Cache_Vol  Setting"
        echo "----------------------"
        for ((i=1; i<=${#volumes[@]}; i++)); do
            info="${volumes[i-1]}"
            before_pipe="${info%%|*}"
            after_pipe="${info#*|}"
            printf "%-3s %-9s %s\n" "$i)" "$before_pipe" "$after_pipe"
        done
        echo "----------------------"
    else
        echo "No caches found!" && exit 1
    fi
else
    echo ""
fi


# Select volume's cache to edit if not scheduled
if [[ $scheduled != "yes" ]]; then

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
    echo -e "\nYou selected $cachevol to set to $kb\n"

    cachevols=("$cachevol")
fi


for v in "${sysctl_devs[@]}"; do
    for c in "${cachevols[@]}"; do
        if [[ $v =~ "$c" ]]; then
            cachevol="$c"

            # Get cache's key name
            cacheval="$(sysctl dev | grep skip_seq_thresh_kb | grep "$cachevol")"
            key="$(echo "$cacheval" | cut -d"=" -f1 | cut -d" " -f1)"

            # Set new cache kb value
            val="$(synosetkeyvalue /etc/sysctl.conf "$key")"
            if [[ $val != "$kb" ]]; then
                synosetkeyvalue /etc/sysctl.conf "$key" "$kb"
            fi

            if echo "$v" | grep "$cachevol" >/dev/null; then
                echo "$kb" > "/proc/sys/dev/${v}/skip_seq_thresh_kb"
            fi

            # Check we set key value
            check="$(synogetkeyvalue /etc/sysctl.conf "$key")"
            if [[ "$check" == "0" ]]; then
                echo -e "Sequential I/O for $cachevol cache is ${Green}Enabled${Off} in /etc/sysctl.conf"
            elif [[ "$check" == "1024" ]]; then
                echo -e "Sequential I/O for $cachevol cache is ${Red}Disabled${Off} in /etc/sysctl.conf"
            elif [[ -z "$check" ]]; then
                echo -e "Sequential I/O for $cachevol cache is ${Red}not set${Off} in /etc/sysctl.conf"
            else
                echo -e "Sequential I/O for $cachevol cache is set to ${Cyan}$check${Off} in /etc/sysctl.conf"
            fi

            # Check we set proc/sys/dev
            val="$(cat /proc/sys/dev/"${v}"/skip_seq_thresh_kb)"
            if [[ "$val" == "0" ]]; then
                echo -e "Sequential I/O for $cachevol cache is ${Green}Enabled${Off} in /proc/sys/dev\n"
            elif [[ "$val" == "1024" ]]; then
                echo -e "Sequential I/O for $cachevol cache is ${Red}Disabled${Off} in /proc/sys/dev\n"
            elif [[ -z "$val" ]]; then
                echo -e "Sequential I/O for $cachevol cache is ${Red}not set${Off} in /proc/sys/dev\n"
            else
                echo -e "Sequential I/O for $cachevol cache is set to ${Cyan}$val${Off} in /proc/sys/dev\n"
            fi
        fi
    done
done


if [[ $scheduled != "yes" ]]; then
    echo "You need to run this script after each reboot,"
    echo -e "or schedule a triggered task to run it as root at boot.\n"
fi


exit

