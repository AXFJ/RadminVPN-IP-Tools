> [!IMPORTANT]
> **PLEASE DOWNLOAD [PsExec](https://learn.microsoft.com/sysinternals/downloads/psexec) AND PUT IT INTO `script` FOLDER FIRST!** 
>  
> **请先下载微软 [PsExec](https://learn.microsoft.com/sysinternals/downloads/psexec) 并将它放到 `scripts` 文件夹下！** 

### Language EN-US
# Radmin VPN IP Tools by AXFJ

Use three simple scripts to switch the Radmin VPN virtual IP and MAC address as needed. Reference: [Bilibili video](https://www.bilibili.com/video/BV1tt421b7HE)

## Requirements

- [PsExec](https://learn.microsoft.com/sysinternals/downloads/psexec) – Download and place `psexec.exe` into the `scripts` directory.

## Important

- These scripts require administrator privileges.
- They rely on PsExec (Microsoft Sysinternals) to run with SYSTEM privileges.
- Always run the backup script before resetting.
- 64-bit operating system only.

## Usage

- **Reset IP**: Run `reset-ip.bat` as administrator.
- **Back up IP**: Run `backup-ip.bat` as administrator.
- **Restore backup**: First run `reset-ip.bat` as administrator, then double-click the backed-up `.reg` file.
- **Switch MAC**: Run `change-ip.bat` as administrator.


### Language ZH-CN
# AXFJ的Radmin VPN IP工具

使用三个简单的程序来任意切换Radmin VPN虚拟IP和MAC地址。
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
- **切换MAC**：以管理员身份运行 `change-ip.bat`。
