#!/bin/sh
# SPDX-License-Identifier: MIT
set -eu
die() { echo "$*" >&2; exit 1; }
fw= apn= roaming=yes
while test "$#" -gt 0; do
    case "$1" in
        --firmware-dir) test "$#" -ge 2 || die 'Missing firmware directory'; fw=$2; shift 2 ;;
        --apn) test "$#" -ge 2 || die 'Missing APN'; apn=$2; shift 2 ;;
        --allow-roaming) roaming=no; shift ;;
        *) die 'Usage: install-cellular.sh --firmware-dir DIR --apn APN [--allow-roaming]' ;;
    esac
done
test "$(id -u)" = 0 || die 'Run as root'
test -n "$fw" && test -n "$apn" || die 'Firmware directory and APN are required'
tr '\000' '\n' < /proc/device-tree/compatible | grep -qx 'meizu,meizu-20' || die 'Not the validated m2381 board'
test "$(uname -r)" = '7.3.0' || die 'Only Nura r91 / Linux 7.3.0 has been validated'
regions=/sys/bus/platform/devices/3f40000.ipa/iommu_group/reserved_regions
grep -Eq '^0x0*146a8000 +0x0*146a9fff +direct$' "$regions" || die 'IPA IMEM map missing: install the paired Mu image first'
test -s "$fw/so/521_0_0.mbn" || die 'Supplemental firmware is incomplete'
test -e /dev/qcom_rmtfs_mem1 || die 'RMTFS memory device is missing'
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target=/usr/lib/firmware/qcom/sm8550/meizu/modem_pr
test ! -e "$target" || die 'modem_pr already exists; preserve it and review manually before reinstalling'
if nmcli -t -f NAME connection show | grep -qx 'meizu-mobile-data'; then
    die 'meizu-mobile-data already exists; preserve/edit the existing connection manually'
fi
for rel in etc/systemd/system/meizu-modem.service usr/local/sbin/meizu-modem-bringup usr/local/sbin/meizu-modem-rollback; do
    test ! -e "/$rel" || die "Refusing to overwrite /$rel"
done
backup=/var/backups/meizu20-cellular/$(date -u +%Y%m%dT%H%M%SZ)
mkdir -p "$backup"
if test -d /etc/systemd/system/rmtfs.service.d; then
    cp -a /etc/systemd/system/rmtfs.service.d "$backup/"
fi
# Install the read-only override BEFORE any package/service activation.
mkdir -p /etc/systemd/system/rmtfs.service.d
cp "$root/userspace/etc/systemd/system/rmtfs.service.d/meizu-readonly.conf" /etc/systemd/system/rmtfs.service.d/
systemctl daemon-reload
apk add rmtfs rmtfs-systemd rmtfs-udev qmi-utils qrtr tqftpserv tqftpserv-systemd
systemctl stop rmtfs.service tqftpserv.service || true
mkdir -p "$(dirname "$target")"
cp -a "$fw" "$target"
for rel in etc/systemd/system/meizu-modem.service usr/local/sbin/meizu-modem-bringup usr/local/sbin/meizu-modem-rollback; do
    mkdir -p "$(dirname "/$rel")"
    cp "$root/userspace/$rel" "/$rel"
done
chmod 755 /usr/local/sbin/meizu-modem-bringup /usr/local/sbin/meizu-modem-rollback
systemctl daemon-reload
nmcli connection add type gsm ifname '*' con-name meizu-mobile-data apn "$apn"
nmcli connection modify meizu-mobile-data gsm.home-only "$roaming" connection.autoconnect yes connection.metered yes ipv4.method auto ipv4.route-table 254 ipv4.route-metric 700 ipv6.method disabled
systemctl enable rmtfs.service tqftpserv.service meizu-modem.service
systemctl restart rmtfs.service tqftpserv.service
systemctl start meizu-modem.service
echo 'Installed. Bring up meizu-mobile-data and verify with Wi-Fi off. See docs/ROLLBACK.md if data fails.'
