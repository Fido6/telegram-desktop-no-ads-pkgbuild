# 快速开始指南

## 🎯 目标
将Telegram Desktop转向Windows版本并去除广告。

## 📋 已完成的工作

你现在有两个构建工作流可用:

### 1️⃣ **基础版本** (`build-windows.yml`)
- ✅ 同时构建x64和x86
- ✅ 上传构建产物到Artifacts
- ✅ 自动发布Release
- 简单直接，适合快速测试

### 2️⃣ **高级版本** (`build-windows-advanced.yml`)
- ✅ 支持自定义版本和架构
- ✅ 创建可移植的ZIP包
- ✅ 生成SHA256校验和
- ✅ 更详细的日志和错误处理
- ✅ 依赖缓存加速
- 功能完整，适合生产使用

## 🚀 快速使用

### 方式1️⃣: 自动触发（推荐）

```bash
# 1. 修改需要的内容并提交
git add .
git commit -m "Update patches or configuration"

# 2. 推送到master分支
git push origin master

# 3. 去GitHub查看Actions进度
# https://github.com/YOUR_USERNAME/telegram-desktop-no-ads-pkgbuild/actions
```

### 方式2️⃣: 手动触发

1. 打开 GitHub 网页版本库
2. 点击 **Actions** 标签
3. 选择 **Build Windows Package** 或 **Build Windows Package (Advanced)**
4. 点击 **Run workflow** 按钮
5. 选择参数（如使用高级版本）
6. 点击 **Run workflow** 确认

### 方式3️⃣: 本地构建

```powershell
# 安装依赖
choco install cmake ninja visual-studio-2022-buildtools python -y

# 下载并解压
$ver = "6.3.10"
Invoke-WebRequest -Uri "https://github.com/telegramdesktop/tdesktop/releases/download/v$ver/tdesktop-$ver-full.tar.gz" -OutFile "tdesktop.tar.gz"
tar -xzf tdesktop.tar.gz

# 克隆TDLib
git clone --depth 1 --branch v1.8.34 https://github.com/tdlib/td.git

# 应用补丁
cd tdesktop-6.3.10-full
patch -p1 < ../remove-ads.patch
cd ..

# 构建
mkdir build && cd build
cmake ..\tdesktop-6.3.10-full -G "Visual Studio 17 2022" -A x64 `
  -DTDESKTOP_API_ID=611335 -DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c
msbuild /m Telegram.sln /p:Configuration=Release /p:Platform=x64
```

## 📥 获取构建结果

### 从GitHub Actions

1. 打开 Actions 标签
2. 点击最新的构建任务
3. 向下滚动到 **Artifacts** 部分
4. 下载对应架构的文件（x64或x86）

### 从Release

1. 打开 **Releases** 标签
2. 找到最新的 `v6.3.10-windows` Release
3. 下载对应架构的ZIP文件

## ✅ 验证构建

### 检查文件完整性

```powershell
# 使用高级版本提供的SHA256校验和
Get-FileHash "telegram-no-ads-6.3.10-x64-portable.zip" -Algorithm SHA256
# 对比 telegram-no-ads-6.3.10-x64-portable.zip.sha256 中的值
```

### 运行Telegram

1. 解压ZIP文件
2. 双击 `Telegram.exe`
3. 登录你的账号
4. 验证没有广告 ✨

## 🔧 常见问题

### Q: 构建失败了怎么办？

**A:** 检查以下几点：
1. **网络问题** - 确保能访问GitHub和Telegram官方源
2. **补丁冲突** - 如果TDLib或Telegram版本更新了，补丁可能不兼容
   ```bash
   # 查看失败详情
   cd tdesktop-X.X.X-full
   patch --dry-run -p1 < ../remove-ads.patch
   ```
3. **依赖问题** - 本地构建时确保所有依赖已安装

### Q: 怎么修改Telegram版本？

**A:** 编辑工作流文件中的版本号：
- 基础版本: [build-windows.yml](line 74) 修改 `6.3.10`
- 高级版本: GitHub Actions界面中手动输入

### Q: 可以同时构建32位和64位吗？

**A:** 可以！
- **基础版本**: 自动同时构建
- **高级版本**: 选择 `both` 选项

### Q: 构建时间要多久？

**A:** 
- 首次构建: ~30-45分钟（需要下载和编译所有依赖）
- 后续构建: ~15-20分钟（使用缓存）

### Q: 能修改去广告补丁吗？

**A:** 可以！编辑 [remove-ads.patch](remove-ads.patch) 文件后推送，下次构建会使用新的补丁。

## 📚 文件说明

| 文件 | 说明 |
|------|------|
| `build-windows.yml` | 基础Windows构建工作流 |
| `build-windows-advanced.yml` | 高级Windows构建工作流（推荐生产使用） |
| `build.yml` | Arch Linux构建工作流 |
| `remove-ads.patch` | 去广告补丁（17个patch合并） |
| `PKGBUILD` | Arch Linux构建脚本 |
| `WINDOWS_BUILD.md` | Windows构建详细文档 |
| `README_CN.md` | 本文件 |

## 🔐 安全性注意

- API凭证(`API_ID`和`API_HASH`)是公开的测试凭证
- 如需生产环境，请注册自己的凭证: https://core.telegram.org/api/obtaining_api_id
- 所有编译产物都可以验证源码和补丁

## 🎓 学习资源

- [Telegram Desktop GitHub](https://github.com/telegramdesktop/tdesktop)
- [TDLib文档](https://core.telegram.org/tdlib)
- [CMake参考](https://cmake.org/cmake/help/latest/)
- [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/)

## 💡 后续优化建议

- [ ] 添加NSIS安装程序(.exe)
- [ ] 实现自动代码签名
- [ ] 添加更新检查功能
- [ ] 集成VirusTotal扫描
- [ ] 支持更多语言
- [ ] 创建便携式配置

## ❓ 需要帮助？

- 📖 查看详细文档: [WINDOWS_BUILD.md](WINDOWS_BUILD.md)
- 🐛 提交Issue报告问题
- 💬 讨论特性需求

---

**现在你可以开始构建Windows版本的去广告Telegram了！** 🎉
