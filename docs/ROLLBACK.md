# 回退

在当前系统中执行：

```sh
sudo /usr/local/sbin/meizu-modem-rollback
```

它会关闭 `meizu-mobile-data` 的自动连接，停止/禁用本项目基带、RMTFS 和 TFTP 服务，并恢复 modem 的 `driver_override=none`。补充固件保留。它不恢复 Android，也不回写旧 NV。

回刷不含 IPA IMEM 映射的旧 Mu 前，先完成上述蜂窝停用，再按上游方式将自己保存的可用镜像刷回 boot_b。否则旧映射下的数据传输可能再次触发 IPA 崩溃。请使用本机已知可用的原始 boot_b，勿混用其他手机备份。

安装前自动保存的系统文件在 `/var/backups/meizu20-cellular/`。需要完全撤销文件改动时，可对照该目录恢复服务文件及 rmtfs override，执行 `systemctl daemon-reload`；新建的服务、脚本和 modem_pr 也可在停止服务后移除。恢复其他服务前检查其是否会写 NV。完整恢复 Flyme 应按原项目的回退流程操作。
