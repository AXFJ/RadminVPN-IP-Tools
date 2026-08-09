### ZH-CN
# Radmin VPN IP工具

使用两个简单的程序来任意切换Radmin VPN虚拟IP。
原理参考: [B站视频](https://www.bilibili.com/video/BV1tt421b7HE)

## 环境要求

- [PsExec](https://learn.microsoft.com/sysinternals/downloads/psexec) – 下载并将 `psexec.exe` 放到 `scripts` 目录下

## 重要

- 这些脚本需要管理员权限。
- 它们依赖 PsExec（微软 Sysinternals）以 SYSTEM 权限运行。
- 重置前一定要先运行备份脚本。
- 仅限 64 位操作系统。

## 使用方法

- **重置IP**：以管理员身份运行 `reset-ip.bat`。
- **备份IP**：以管理员身份运行 `backup-ip.bat`。
- **恢复备份**：先以管理员身份运行 `reset-ip.bat`，然后双击备份的 `.reg` 文件。



### EN-US
# Radmin VPN IP Tools by 

Two simple scripts for backing up and resetting the Radmin VPN IP.
Reference: [Bilibili Video](https://www.bilibili.com/video/BV1tt421b7HE)

## Requirements

- [PsExec](https://learn.microsoft.com/sysinternals/downloads/psexec) – download and place `psexec.exe` in the `scripts` folder as the scripts.

## Important

- These scripts require Administrator privileges.
- They rely on PsExec (Microsoft Sysinternals) to operates with SYSTEM permissions.
- Always run the backup script before resetting.
- 64x operating systems only.

## Usage

- **Reset IP**: Run `reset-ip.bat` as Administrator.
- **Backup IP**: Run `backup-ip.bat` as Administrator.
- **Restore backup**: First run `reset-ip.bat` as Administrator, then double-click the backup `.reg` file.
