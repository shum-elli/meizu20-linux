# 来源与许可

本仓库是社区适配增量，不是 Meizu、postmarketOS、Nura 或 Mu 的官方发行版。

- [Nura / Meizu 20](https://github.com/RiverKawa271828/nura-meizu-m2381)：原始系统、设备树、刷机与回退研究，作者 RiverKawa271828。该项目声明 GPL-3.0；引用其方案须保留适用声明。
- [Mu-Silicium](https://github.com/Project-Silicium/Mu-Silicium)：上游 UEFI，及 [RiverKawa 的 m2381 移植](https://github.com/RiverKawa271828/Mu-Silicium)。Mu 的原 LICENSE 保存在 licenses/，其 GPLDrivers / GPLApplications / GPLLibrary 及其他依赖遵循各自许可；文件内 SPDX 优先。
- source/ 的 Linux 板级 DTS 和对应补丁保留原文件 SPDX 与作者声明（GPL-2.0-only，部分源内容另有 BSD-3-Clause 声明），不将整个派生文件重新许可为 MIT。
- Mu binary patch 包含来自上述 Mu 移植的源文件与设备树，不将其重新许可为 MIT。应用补丁后应同时保留原源码树中的许可证。
- Binaries、Qualcomm/Meizu 原厂组件等预编译依赖遵循其上游条款；本仓库不声称拥有它们的版权。Mu 构建使用的来源与精确提交见 docs/TECHNICAL.md；发行物不另行提供从个人 9008 备份提取的原厂 modem_pr、原始分区或 NV。

本仓库原创安装/提取/构建工具和文档采用 LICENSE 中的 MIT 许可；该许可不覆盖第三方源文件、补丁中已有内容、DTB 或预编译固件。参与者保留各自版权。实机运行的服务脚本在本次适配过程中编写。
