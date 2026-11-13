# 技术说明与验证

## 基带 online 阻断

r91 原有 meizu-pas.service 使用 driver_override=none 屏蔽 MPSS。解除屏蔽并提供只读 RMTFS 后，QMI 与 SIM 可用，但 online 返回 DeviceNotReady。自身原厂 modem_b 的 FAT `/image/modem_pr` 包含所缺的补充固件；实测共 158 文件。补充目录放到 `/usr/lib/firmware/qcom/sm8550/meizu/modem_pr`，配合 tqftpserv 后可 online 并注册 LTE。日志观察到对 `so/521_0_0.mbn` 及 MCFG 的读取。

原系统的 41 个核心 modem/IPA 文件与自身原厂备份逐项相同，因此没有替换成其他设备的基带。服务文件位于 userspace/，RMTFS 使用 `-r -P`：写请求留在内存影子，本次测试及重启前后物理 modemst1、modemst2、fsc、fsg 哈希不变。这不表示它们与更早的 9008 快照相同。

## IPA 映射阻断

更新 v4.1 本身仍复现拨号后断流，出现 SMMU IOVA `0x146a9000` / SID `0x4a0` 及 IPA fatal IRQ 0x1。自身原厂 vendor DT 指定 `qcom,additional-mapping=<0x146a8000 0x146a8000 0x2000>`。

将它转换为主线 DT 的 reserved-memory / iommu-addresses，追加到 IPA memory-region；新系统的 IOMMU reserved_regions 出现：

```text
0x00000000146a8000 0x00000000146a9fff direct
```

最终 Mu 内嵌修复后的 DTB。语义比较仅新增该节点，并修改 IPA 的 phandle 和 memory-region，见 ipa-dtb-validation.json。内核及模块仍为原来的 7.3.0 #92。本补丁的复现目标是上述特定 DTB，不保证能原样用于所有后续内核。

## Mu 适配来源

- Project-Silicium/Mu-Silicium v4.1：`6b3d90b79e191e08171bfedd3980234a7e49d340`。
- RiverKawa271828/Mu-Silicium 板级移植基线：`bdea825cf2ad9ced8bc84cd423e3a93aacd15876`。
- RiverKawa271828/Device-Binaries：`036ba9f7cfe2d5400e2be3b985512c3fdbbc67e1`。
- 移入 m2381Pkg、配置、内存布局、FdtBlob；保留 Gunyah watchdog BootShim 处理；仅对 m2381 禁用 Windows KEP 的 BDS 钩子。未引入后续 UniXNU 的设备构建依赖。

## 实测（2026-11-13，UTC+8）

标准魅族 20，单卡，允许数据漫游：最终镜像刷入 boot_b 并读回校验；Mu 构建中 49 个 EFI 镜像检查通过。Wi-Fi 可用、LTE 注册和数据可用；使用者关闭 Wi-Fi 后确认联网成功。正常重启后服务启动，存在 NetworkManager 自动激活记录；界面切换连接后，绑定 qmapmux0.0 的 ping 3/3 成功，HTTPS HTTP 200 并完整读取响应。最后检查无 failed systemd 单元，未再见前述 IPA/SMMU/modem 故障。

未独立验收通话、短信、5G SA、长期待机、长时间吞吐；未完成长期可靠性测试。不同 SIM、固件或双卡行为仍需验证。
