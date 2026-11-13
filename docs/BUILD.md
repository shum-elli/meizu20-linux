# 从源码构建

验证过的工具环境：Ubuntu 24.04 / WSL2。将构建树放在 WSL 的 Linux 文件系统中。基础依赖包括 git、python3-venv、build-essential、clang、lld、gcc-aarch64-linux-gnu、binutils-aarch64-linux-gnu、nasm、uuid-dev、mono-devel、device-tree-compiler、acpica-tools、unzip 和 wget。完整依赖以所固定的 Mu 上游 setup_env.sh 为参考。Mono 需要开发组件，不只运行时。

```sh
bash scripts/build-mu.sh "$HOME/meizu20-mu41-build"
```

脚本固定 v4.1 提交，应用包含最终 FdtBlob 的完整 binary patch，初始化该设备用到的子模块，更新构建依赖并构建 RELEASE。脚本是对已经成功执行的构建步骤的参数化整理；全新环境仍可能遇到包源或上游工具依赖变动。不要加自动更新上游的 `-u`，避免将构建基线移走。

最终 DTB 已包括在 Mu binary patch 中，无需重复应用 kernel-ipa-imem.patch。后者供维护 Linux 内核设备树使用，其路径是标准内核树 `arch/arm64/boot/dts/qcom/sm8550-meizu-20.dts`。source/ 提供对应单文件前后版本，可独立审阅。

硬件实测发行镜像的 SHA256 记录在 Release；本地重新编译可能因时间戳、编译器和依赖版本不同产生不同哈希，应检查构建产物和对应 DTB 后再测试。不要声称重编译必定逐字节相同。
