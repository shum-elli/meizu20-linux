# v0.1.0 — Meizu 20 Mu v4.1 + LTE data repair

标准魅族 20 / m2381，基于 Nura r91（Linux 7.3.0 #92）与原厂 Flyme 12.6.0.0A 固件基线。

- Mu-Silicium v4.1 适配，内嵌 IPA IMEM 恒等映射修复。
- 配套系统内蜂窝服务、只读 RMTFS、TFTP 和原厂补充固件提取工具。
- LTE 数据经 Wi-Fi 关闭及正常重启后的接口绑定测试验证。
- 不含个人 userdata、原始 9008 备份、NV、SIM 信息或原厂 modem_pr；补充固件从自己的 modem_b.img 提取。

下载镜像与配套 zip，按 SHA256SUMS 校验后阅读 README 和 docs/INSTALL.md。Mu 与系统内补丁必须配套；这不是完整 rootfs 直刷包。完整系统基础镜像使用上游 r91。

未验证通话、短信、5G SA 或长期稳定性。限标准魅族 20，其他机型不适用。
