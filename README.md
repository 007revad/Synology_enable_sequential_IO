# Synology enable sequential I/O

<a href="https://github.com/007revad/Synology_enable_sequential_IO/releases"><img src="https://img.shields.io/github/release/007revad/Synology_enable_sequential_IO.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FSynology_enable_sequential_IOh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false"/></a>
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

### Description

Enables sequential I/O for your SSD caches, like DSM 6 had.

**Note:** Use at your own risk. There have been reports that enabling sequential I/O for an SSD cache can cause the network chip to overheat (which is probably why Synology disabled SSD cache sequential I/O from DSM 7 onwards.

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

### Options

You can run this script with a parameter to specify the skip_seq_thresh_kb

For example the following would set the cache you select back to default

```YAML
sudo -i /volume1/scripts/syno_seq_io.sh 1024
```

**Note:** If no parameter the script defaults to 0 (which enables sequential I/O).

<br>

## Screenshots

<p align="center"><img src="/images/screenshot.png"></p>
