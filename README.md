# Synology enable sequential I/O

<a href="https://github.com/007revad/Synology_enable_sequential_IO/releases"><img src="https://img.shields.io/github/release/007revad/Synology_enable_sequential_IO.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FSynology_enable_sequential_IOh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false"/></a>
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

### Description

Enables sequential I/O for your SSD caches, like DSM 6 had when you unticked the "Skip sequential I/O" option.

**Note:** Monitor your NVMe drive and 10G card temperature. There have been reports online that enabling sequential I/O for an SSD cache can cause a 10G network card to overheat (which may be why Synology disabled SSD cache sequential I/O from DSM 7 onwards). It will also wear out the NVMe drive(s) much faster.

### Download the script

1. Download the latest version _Source code (zip)_ from https://github.com/007revad/Synology_enable_sequential_IO/releases
2. Save the download zip file to a folder on the Synology.
3. Unzip the zip file.

### Running the script via SSH

[How to enable SSH and login to DSM via SSH](https://kb.synology.com/en-global/DSM/tutorial/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet)

**Note:** Replace /volume1/scripts/ with the path to where the script is located.
Run the script then reboot the Synology:

```YAML
sudo -i /volume1/scripts/syno_seq_io.sh
```

### Scheduling the script in Synology's Task Scheduler

To ensure that your cache(s) still have sequential I/O enabled after a reboot you should schedule the script to run at boot.

See <a href=how_to_schedule.md/>How to schedule a script to run at boot in Synology Task Scheduler</a>

### Options

```
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
```

You can run this script with a parameter to specify the skip_seq_thresh_kb

For example the following would set the cache you select back to default

```YAML
sudo -i /volume1/scripts/syno_seq_io.sh 1024
```

**Note:** If no parameter the script defaults to 0 (which enables sequential I/O).

<br>

## Screenshots

<p align="center">Enabling sequential I/O</p>
<p align="center"><img src="/images/manual.png"></p>

<p align="center">Reset a cache to 1024 KB to disable sequential I/O</p>
<p align="center"><img src="/images/default.png"></p>

<p align="center">Scheduled to enable sequential I/O for 2 caches with --volume option</p>
<p align="center"><img src="/images/2caches.png"></p>

<p align="center">Choose from multiple caches</p>
<p align="center"><img src="/images/screenshot.png"></p>
