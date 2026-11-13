# Meizu 20 Linux: cellular data + Mu v4.1

魅族 20（m2381 / SM8550）的 **Nura r91 / postmarketOS 移动数据修复**，以及 **Mu-Silicium v4.1 板级适配**。

在标准魅族 20、Flyme 12.6.0.0A 的原厂固件基线上完成验证：LTE 数据可用，关闭 Wi-Fi 后实际联网成功；正常重启后再次通过蜂窝接口 ping 和 HTTPS 验证。

这是基于 [RiverKawa271828/nura-meizu-m2381](https://github.com/RiverKawa271828/nura-meizu-m2381) 的增量适配发行版。完整基础系统使用 [Nura r91](https://github.com/RiverKawa271828/nura-meizu-m2381/releases/tag/r91)，本仓库提供新增修复及构建来源，不包含个人 userdata 镜像。

## 下载与安装

- [Releases：Mu 镜像、DTB、配套源码包及 SHA256SUMS](https://github.com/shum-elli/meizu20-linux/releases)
- [安装和升级](docs/INSTALL.md)
- [回退](docs/ROLLBACK.md)
- [技术说明及实测边界](docs/TECHNICAL.md)
- [从源码构建 Mu](docs/BUILD.md)
- [来源与许可](NOTICE.md)

## 修复分别在哪里？

| 部分 | 位置 | 作用 |
| --- | --- | --- |
| Mu v4.1 + IPA IMEM DTB | `boot_b` | 更新 UEFI，补上 IPA 所需的 IOMMU 恒等映射 |
| 蜂窝服务、只读 RMTFS、TFTP、原厂补充固件、APN | postmarketOS 根文件系统 | 启动基带、提供固件、注册及建立数据连接 |
| r91 内核及 ESP | 沿用基础版本 | 本次仍为 Linux 7.3.0 #92，不要求重刷 ESP |

**需要 Mu 与系统内的蜂窝修复配套，单独替换 Mu 或 ESP 不完整。** 初次安装系统请先阅读上游刷机说明；本仓库升级步骤面向已运行 r91 的设备。

没有独立验证通话、短信、5G SA、相机、GNSS、长期待机及长时间吞吐；LTE 联网成功不代表这些功能已经完成。仅实测标准魅族 20，不涵盖 Pro、Classic 或其他机型。Mu 能提供 UEFI 引导环境，但其他 ARM64 系统仍需要匹配的设备树、内核和驱动。

## 内容

`patches/` 提供相对上游 v4.1 的完整 git binary patch 和 Linux DTS 补丁；`source/` 保留对应板级 DTS 前后版本；`userspace/` 是实机运行过的四个服务/脚本文件；`scripts/` 提供安装、检查、原厂补充固件提取和构建工具。

原始 9008 备份、NV、SIM 标识、Wi-Fi 配置和个人日志不包含在发行物中。原厂 `modem_pr` 补充固件由使用者从自己的 `modem_b.img` 只读提取。
