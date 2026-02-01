注意: 这是一个建议性文件，如果你的项目还没有README.md，可以用这个作为基础。
如果已经有README.md，建议在其中添加Windows部分。

---

# Telegram Desktop No-Ads

![Build Status](https://img.shields.io/github/actions/workflow/status/YOUR_USERNAME/telegram-desktop-no-ads-pkgbuild/build.yml?branch=master&label=Arch%20Linux%20Build)
![Windows Build Status](https://img.shields.io/github/actions/workflow/status/YOUR_USERNAME/telegram-desktop-no-ads-pkgbuild/build-windows.yml?branch=master&label=Windows%20Build)
![License](https://img.shields.io/badge/license-GPLv3-blue)

简体中文 | [English](README_EN.md)

## 🎯 项目介绍

这是一个基于官方 Telegram Desktop 源代码的**去广告、去冗余功能**的修改版本。通过应用定制化补丁，移除了：

- 🚫 赞助消息（频道广告）
- 🚫 视频广告
- 🚫 Emoji 反应
- 🚫 网页预览
- 🚫 消息置顶栏
- 🚫 故事功能
- 🚫 语音消息录制
- 🚫 通话功能

以及其他无关功能，提供更简洁的 Telegram 体验。

## 📋 支持的平台

| 平台 | 状态 | 工作流 |
|------|------|--------|
| **Arch Linux** | ✅ 完全支持 | `build.yml` |
| **Windows x64** | ✅ 完全支持 | `build-windows.yml` |
| **Windows x86** | ✅ 完全支持 | `build-windows.yml` |

## 🚀 快速开始

### Windows 用户

#### 自动构建（推荐）

1. **自动触发**：推送代码到 `master` 分支
   ```bash
   git push origin master
   ```

2. **手动触发**：
   - 打开 GitHub → Actions 标签
   - 选择 "Build Windows Package"
   - 点击 "Run workflow"

3. **获取结果**：
   - 等待构建完成（约 15-45 分钟）
   - 从 Release 或 Artifacts 下载

#### 本地构建

```powershell
# 使用 PowerShell 构建脚本
.\build.ps1

# 指定特定版本和架构
.\build.ps1 -Version 6.3.10 -Architecture x64
```

**要求**：
- Windows 10/11
- Visual Studio 2022 (含 C++ 工作负荷)
- CMake 3.16+
- Ninja, Git, Python 3.8+

### Arch Linux 用户

```bash
# 使用 makepkg 构建
makepkg --syncdeps --noconfirm

# 或使用 GitHub Actions 自动构建
git push origin master
```

## 📥 下载预编译版本

前往 [Releases](../../releases) 页面下载最新的预编译版本。

### Windows

- `telegram-no-ads-X.X.X-x64-portable.zip` - 64 位绿色版本
- `telegram-no-ads-X.X.X-x86-portable.zip` - 32 位绿色版本

**使用方式**：解压 ZIP 文件并直接运行 `Telegram.exe`

### Arch Linux

- `telegram-desktop-no-ads-X.X.X-1-x86_64.pkg.tar.zst` - 安装包

## 📖 完整文档

- **[中文快速指南](README_CN.md)** - 三种使用方式、常见问题
- **[Windows 详细文档](WINDOWS_BUILD.md)** - 系统要求、构建流程、故障排查
- **[迁移总结](MIGRATION_SUMMARY.md)** - 项目升级详情

## 🔍 验证文件完整性

所有 Release 版本都包含 SHA256 校验和。

```bash
# Windows (PowerShell)
(Get-FileHash "telegram-no-ads-6.3.10-x64-portable.zip" -Algorithm SHA256).Hash
# 对比 .sha256 文件中的值

# Linux
sha256sum -c telegram-no-ads-6.3.10-x64-portable.zip.sha256
```

## 🛠️ 定制开发

### 修改补丁

所有去广告代码都在 `remove-ads.patch` 文件中。要修改功能：

1. 编辑 `remove-ads.patch`
2. 提交更改
3. GitHub Actions 会自动使用新补丁构建

### 自定义 API 凭证

修改工作流文件中的 `TDESKTOP_API_ID` 和 `TDESKTOP_API_HASH`：

```yaml
-DTDESKTOP_API_ID=YOUR_ID
-DTDESKTOP_API_HASH=YOUR_HASH
```

[获取自己的 API 凭证](https://core.telegram.org/api/obtaining_api_id)

## 📊 项目结构

```
├── .github/workflows/
│   ├── build.yml                    # Arch Linux 自动构建
│   ├── build-windows.yml            # Windows 基础构建
│   └── build-windows-advanced.yml   # Windows 高级构建
├── build.ps1                        # Windows 本地构建脚本
├── PKGBUILD                         # Arch Linux 构建脚本
├── remove-ads.patch                 # 去广告补丁
├── README.md                        # 项目主文档（本文件）
├── README_CN.md                     # 中文快速指南
├── WINDOWS_BUILD.md                 # Windows 详细文档
└── MIGRATION_SUMMARY.md             # 项目升级总结
```

## ❓ 常见问题

### Q: 这个安全吗？
A: 是的。项目基于官方 Telegram Desktop 源代码，所有修改都是开源透明的，可以在 `remove-ads.patch` 中查看。

### Q: 官方会警告我吗？
A: 个人使用不会。但不要商业发行修改版本。

### Q: 能恢复官方功能吗？
A: 可以。只需要恢复原版本或修改补丁文件。

### Q: 多久更新一次？
A: 跟随官方 Telegram Desktop 的更新。通常 1-2 周一个新版本。

### Q: 支持 macOS 或其他系统吗？
A: 当前支持 Arch Linux 和 Windows。macOS 需要额外配置。

### Q: 如何报告问题？
A: 提交 GitHub Issue，包含：
- 操作系统和版本
- 构建工作流（如有）
- 错误信息

## 🔄 更新日志

### v6.3.10 (2025-02-01)
- ✨ 新增 Windows x64/x86 自动构建支持
- ✨ 新增 PowerShell 本地构建脚本
- 📖 完善中文文档
- 🔧 优化构建工作流

### v6.2.0 (之前)
- 初始 Arch Linux 支持

## 👨‍💻 贡献

欢迎提交 Issue 和 Pull Request！

### 贡献流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开 Pull Request

## 📝 许可证

本项目采用 **GPLv3** 许可证。详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [Telegram Desktop](https://github.com/telegramdesktop/tdesktop) - 官方项目
- [TDLib](https://github.com/tdlib/td) - Telegram 库
- [原始去广告补丁](https://github.com/vehlwn/tdesktop) - vehlwn

## 📞 联系方式

- 📧 通过 Issue 提问
- 💬 GitHub Discussions
- 🐛 报告 Bug

---

**享受无广告的 Telegram 体验！** ✨

如有任何问题或建议，欢迎反馈！
