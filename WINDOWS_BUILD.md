# Windows Telegram Desktop No-Ads 构建指南

## 概述
本项目已配置支持通过GitHub Actions构建Windows版本的去广告Telegram Desktop。

## 构建要求

### 本地构建（如需要）
- **操作系统**: Windows 10/11
- **Visual Studio 2022** (包括C++工作负荷)
- **CMake** >= 3.16
- **Ninja** 构建系统
- **Git**
- **Python** 3.8+
- **Perl** (用于OpenSSL)
- **NASM** (用于某些库)

### GitHub Actions自动构建
文件: `.github/workflows/build-windows.yml`
- 自动在 `windows-latest` 运行器上构建
- 支持 x64 和 x86 架构
- 支持同时构建两个版本

## 项目结构

```
telegram-desktop-no-ads-pkgbuild/
├── .github/workflows/
│   ├── build.yml              # Arch Linux构建
│   └── build-windows.yml      # Windows构建 (新增)
├── PKGBUILD                   # Arch Linux构建脚本
├── remove-ads.patch           # 去广告补丁
└── README.md
```

## 构建流程说明

### Windows构建工作流 (build-windows.yml)

#### 1. **触发条件**
```yaml
on:
  push:
    branches:
      - master
      - windows-build
  workflow_dispatch:  # 支持手动触发
```

#### 2. **构建步骤**

| 步骤 | 说明 |
|------|------|
| Checkout | 检出代码 |
| Setup Visual Studio | 安装VS 2022编译工具 |
| Install Dependencies | 通过Chocolatey安装依赖 |
| Download Telegram | 下载Telegram Desktop源码 |
| Clone TDLib | 克隆TDLib库 |
| Apply Patches | 应用remove-ads.patch补丁 |
| Build TDLib | 编译TDLib |
| Build Telegram | 编译Telegram Desktop |
| Create Package | 打包可执行文件 |
| Upload Artifact | 上传构建产物 |

#### 3. **构建架构**
- **x64** (64位): 推荐用于现代系统
- **x86** (32位): 向后兼容，可选

## 使用指南

### 1. **通过GitHub Actions自动构建**

```bash
# 推送到master分支会自动触发构建
git add .
git commit -m "update"
git push origin master

# 或者手动触发（GitHub网页界面）
# 1. 点击 Actions 标签
# 2. 选择 "Build Windows Package"
# 3. 点击 "Run workflow"
```

### 2. **获取构建产物**

**自动构建后**:
- Actions → Build Windows Package → 点击最新构建
- 下载 `telegram-no-ads-windows-x64` 或 `telegram-no-ads-windows-x86`

### 3. **本地构建**

如果要在本地测试构建：

```powershell
# 1. 安装依赖
choco install cmake ninja visual-studio-2022-buildtools python -y

# 2. 下载源码
$version = "6.3.10"
curl.exe -L -o "tdesktop.tar.gz" `
  "https://github.com/telegramdesktop/tdesktop/releases/download/v$version/tdesktop-$version-full.tar.gz"
tar -xzf tdesktop.tar.gz

# 3. 克隆TDLib
git clone --depth 1 --branch v1.8.34 https://github.com/tdlib/td.git

# 4. 应用补丁
cd tdesktop-6.3.10-full
git apply --reject --whitespace=fix ../remove-ads.patch
cd ..

# 5. 编译
mkdir -p build
cd build
cmake ..\tdesktop-6.3.10-full -G "Visual Studio 17 2022" -A x64 `
  -DTDESKTOP_API_ID=611335 `
  -DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c
msbuild Telegram.sln /p:Configuration=Release /p:Platform=x64 /m
```

## 补丁说明

`remove-ads.patch` 包含以下去广告功能:

1. **禁用赞助消息** - 关闭频道中的赞助广告
2. **禁用视频广告** - 移除视频播放中的广告
3. **禁用反应** - 移除emoji反应功能
4. **禁用网页预览** - 关闭消息链接预览
5. **禁用置顶条** - 移除消息置顶栏
6. **禁用语音录制** - 关闭语音消息录制按钮
7. **禁用通话** - 移除通话按钮
8. **禁用故事** - 关闭Stories功能
9. **其他优化** - 移除其他无关功能

## API配置

构建时使用的Telegram API凭证:
```
API_ID: 611335
API_HASH: d524b414d21f4d37f08684c1df41ac9c
```

这些是公开的测试凭证。如需使用自己的凭证，需修改 `.github/workflows/build-windows.yml` 和本地构建脚本中的值。

## 故障排查

### 问题1: 补丁应用失败
```bash
# 使用 --reject 选项查看失败部分
cd tdesktop-6.3.10-full
git apply --reject ../remove-ads.patch
```

### 问题2: 缺少依赖
在Windows上重新安装Visual Studio并选择"C++工作负荷"

### 问题3: 构建超时
- GitHub Actions默认超时时间为6小时
- 第一次构建可能较慢，后续会使用缓存

## 配置修改

如需调整构建，编辑 `.github/workflows/build-windows.yml`:

| 配置项 | 位置 | 说明 |
|--------|------|------|
| Telegram版本 | 第`pkgver`行 | 修改版本号 |
| TDLib版本 | branch标签 | 修改TDLib版本 |
| 架构 | matrix.arch | 添加/移除x86或x64 |
| 触发分支 | on.push.branches | 修改监听分支 |

## 后续优化建议

1. ✅ **缓存依赖** - 加速后续构建
2. ✅ **代码签名** - 对生成的exe进行签名
3. ✅ **创建安装程序** - 使用NSIS打包成.exe安装程序
4. ✅ **发布管理** - 自动创建GitHub Release
5. ✅ **多版本支持** - Portable版本、安装程序版本

## 许可证
GPL-3.0

## 参考资源

- [Telegram Desktop官方](https://desktop.telegram.org/)
- [Telegram Desktop GitHub](https://github.com/telegramdesktop/tdesktop)
- [TDLib GitHub](https://github.com/tdlib/td)
- [CMake文档](https://cmake.org/)

---

有任何问题，请在GitHub Issues中报告！
