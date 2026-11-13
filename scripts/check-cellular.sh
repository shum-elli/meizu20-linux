#!/bin/sh
set -eu
uname -a
cat /proc/device-tree/model
printf '\nIPA IOMMU regions:\n'
cat /sys/bus/platform/devices/3f40000.ipa/iommu_group/reserved_regions
systemctl --no-pager status meizu-modem.service rmtfs.service tqftpserv.service || true
nmcli -f NAME,TYPE,DEVICE connection show --active
ip -4 route
printf '\nModem list (may contain device identifiers; redact before sharing):\n'
mmcli -L
