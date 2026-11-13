# 安装和升级（已安装 Nura r91）

验证基线：标准 Meizu 20 / m2381，原厂 Flyme 12.6.0.0A 固件；Nura r91，Linux 7.3.0 #92。先保留自己的分区备份和当前可启动的 boot_b。不要套用到其他机型或改写 modemst / fsg / fsc。

## 1. 校验下载

下载同一个 Release 的镜像、源码配套包及 SHA256SUMS，在下载目录执行 `sha256sum -c SHA256SUMS`。Windows 可用 `Get-FileHash -Algorithm SHA256 文件名` 对照。

最终 Mu 镜像必须为：

```text
b59c3fa4d2054e14954a854a6226672b4d38a4618f1f308b764e4987ba0a322b  mu-v4.1-m2381-ipa-imem.img
```

## 2. 更新 boot_b

仅适用于已经按上游流程安装 r91、bootloader 已解锁、b 槽活动的设备。在 Fastboot 中先用 `fastboot getvar product` 和 `fastboot getvar current-slot` 确认设备及活动 b 槽，再执行：

```sh
fastboot flash boot_b mu-v4.1-m2381-ipa-imem.img
fastboot reboot
```

本步骤不刷 userdata 或 ESP。首次安装从 [上游 r91](https://github.com/RiverKawa271828/nura-meizu-m2381/releases/tag/r91) 开始，并遵循上游的完整安装要求；不要把本步骤视为从 Flyme 直装教程。

## 3. 提取自己的补充固件（电脑上）

备份镜像只读打开，输出到全新目录。提取工具不读取 NV 分区。

```sh
python3 -m venv .venv
. .venv/bin/activate
pip install -r scripts/requirements-extract.txt
python scripts/extract_modem_pr.py --modem-image /path/to/your/modem_b.img --output ./firmware-export
```

Windows 可用 `py -m venv .venv` 和 `.venv\Scripts\python.exe`。将仓库/源码配套包及 `firmware-export/modem_pr` 复制到手机。不要把提取目录提交到 Git。

## 4. 手机系统内安装

保持 Wi-Fi 联网以安装所需软件包。在仓库目录以 root 执行（将 APN 换成 SIM 运营商提供的值）：

```sh
sudo sh scripts/install-cellular.sh --firmware-dir /path/to/modem_pr --apn YOUR_APN
```

只有需要并接受数据漫游时才追加 `--allow-roaming`。安装器默认禁止漫游，配置为计费网络、IPv4 自动获取、IPv6 关闭、Wi-Fi 路由优先。需要用户名/密码或不同 IP 类型的运营商，请在 NetworkManager 中进一步编辑 `meizu-mobile-data`；不要照搬其他卡的 APN。

安装器先验证机型、内核、IPA 映射及补充固件，再复制文件。已有同名 APN 连接或非本项目的服务文件会拒绝覆盖。RMTFS 固定使用 `-r -P`，不写物理 NV；内存影子在重启后丢弃。

## 5. 验收

```sh
sudo sh scripts/check-cellular.sh
nmcli connection up meizu-mobile-data
```

在手机关闭 Wi-Fi，用浏览器实际联网。重开 Wi-Fi 后再检查服务、重启并复测；仅显示信号图标或已注册，不等于数据已成功。若出现 IPA fault、modem reset 或无网络，先按回退说明停用蜂窝，保留错误日志用于分析，分享前删去 SIM、电话号码、IP 和位置字段。
