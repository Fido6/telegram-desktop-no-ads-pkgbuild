# Telegram Desktop No-Ads Windows构建脚本
# 用途: 在Windows本地快速构建去广告的Telegram Desktop
# 使用: .\build.ps1 -Version 6.3.10 -Architecture x64

param(
    [string]$Version = "6.3.10",
    [string]$Architecture = "x64",
    [switch]$SkipDependencies,
    [switch]$CleanBuild,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# 颜色定义
$colors = @{
    'Success' = 'Green'
    'Error'   = 'Red'
    'Warning' = 'Yellow'
    'Info'    = 'Cyan'
}

function Write-ColorOutput {
    param($Message, $ForegroundColor)
    Write-Host $Message -ForegroundColor $ForegroundColor
}

function Show-Help {
    @"
用法: .\build.ps1 [选项]

选项:
  -Version <版本>          Telegram版本号 (默认: 6.3.10)
  -Architecture <架构>      构建架构 - x64 或 x86 (默认: x64)
  -SkipDependencies        跳过依赖安装检查
  -CleanBuild             执行完整清理和重新构建
  -Help                   显示此帮助信息

示例:
  .\build.ps1
  .\build.ps1 -Version 6.3.10 -Architecture x64
  .\build.ps1 -CleanBuild -Architecture x86

"@
    exit 0
}

if ($Help) { Show-Help }

# 验证架构
if ($Architecture -notin @('x64', 'x86')) {
    Write-ColorOutput "❌ 无效的架构: $Architecture (应为 x64 或 x86)" $colors.Error
    exit 1
}

$visualStudioArch = @{'x64' = 'x64'; 'x86' = 'Win32'}[$Architecture]
$startTime = Get-Date

Write-ColorOutput "=====================================" $colors.Info
Write-ColorOutput "  Telegram Desktop No-Ads 构建脚本" $colors.Info
Write-ColorOutput "=====================================" $colors.Info
Write-ColorOutput ""
Write-ColorOutput "版本: $Version" $colors.Info
Write-ColorOutput "架构: $Architecture ($visualStudioArch)" $colors.Info
Write-ColorOutput "开始时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" $colors.Info
Write-ColorOutput ""

# 步骤1: 检查依赖
if (-not $SkipDependencies) {
    Write-ColorOutput "[1/8] 检查依赖..." $colors.Info
    
    $missingTools = @()
    
    @('git', 'cmake', 'ninja', 'msbuild') | ForEach-Object {
        if (-not (Get-Command $_ -ErrorAction SilentlyContinue)) {
            $missingTools += $_
        }
    }
    
    if ($missingTools) {
        Write-ColorOutput "❌ 缺少工具: $($missingTools -join ', ')" $colors.Error
        Write-ColorOutput "请安装: choco install cmake ninja visual-studio-2022-buildtools git -y" $colors.Warning
        exit 1
    }
    
    Write-ColorOutput "✅ 所有依赖已安装" $colors.Success
} else {
    Write-ColorOutput "[1/8] 跳过依赖检查" $colors.Info
}

# 步骤2: 清理（如果需要）
if ($CleanBuild) {
    Write-ColorOutput "[2/8] 清理旧文件..." $colors.Info
    Remove-Item -Path @("tdesktop-*-full", "td", "build", "release") -Recurse -Force -ErrorAction SilentlyContinue
    Write-ColorOutput "✅ 清理完成" $colors.Success
} else {
    Write-ColorOutput "[2/8] 跳过清理" $colors.Info
}

# 步骤3: 下载Telegram源码
Write-ColorOutput "[3/8] 下载Telegram Desktop $Version..." $colors.Info
$tarFile = "tdesktop.tar.gz"
$sourceDir = "tdesktop-$Version-full"

if (-not (Test-Path $sourceDir)) {
    $url = "https://github.com/telegramdesktop/tdesktop/releases/download/v$Version/tdesktop-$Version-full.tar.gz"
    try {
        Invoke-WebRequest -Uri $url -OutFile $tarFile -ErrorAction Stop
        tar -xzf $tarFile
        Remove-Item $tarFile
        Write-ColorOutput "✅ 下载完成" $colors.Success
    } catch {
        Write-ColorOutput "❌ 下载失败: $_" $colors.Error
        exit 1
    }
} else {
    Write-ColorOutput "✅ 源码已存在，跳过下载" $colors.Success
}

# 步骤4: 克隆TDLib
Write-ColorOutput "[4/8] 克隆TDLib..." $colors.Info
if (-not (Test-Path "td")) {
    git clone --depth 1 --branch v1.8.34 https://github.com/tdlib/td.git
    Write-ColorOutput "✅ TDLib克隆完成" $colors.Success
} else {
    Write-ColorOutput "✅ TDLib已存在，跳过克隆" $colors.Success
}

# 步骤5: 应用补丁
Write-ColorOutput "[5/8] 应用补丁..." $colors.Info
Push-Location $sourceDir
if (Test-Path ".patches_applied") {
    Write-ColorOutput "✅ 补丁已应用，跳过" $colors.Success
} else {
    try {
        patch --forward --strip=1 -i "../remove-ads.patch" 2>&1
        if ($LASTEXITCODE -eq 0) {
            New-Item ".patches_applied" -ItemType File -Force | Out-Null
            Write-ColorOutput "✅ 补丁应用成功" $colors.Success
        } else {
            Write-ColorOutput "⚠️  补丁应用可能有冲突，继续构建..." $colors.Warning
        }
    } catch {
        Write-ColorOutput "❌ 补丁应用失败: $_" $colors.Error
        Pop-Location
        exit 1
    }
}
Pop-Location

# 步骤6: 编译TDLib
Write-ColorOutput "[6/8] 编译TDLib..." $colors.Info
if (-not (Test-Path "td/build")) {
    New-Item -ItemType Directory -Path "td/build" -Force | Out-Null
    Push-Location "td/build"
    
    try {
        cmake .. -G "Visual Studio 17 2022" -A $visualStudioArch `
            -DCMAKE_BUILD_TYPE=Release `
            -DTD_E2E_ONLY=ON `
            -DBUILD_SHARED_LIBS=OFF
        
        if ($LASTEXITCODE -ne 0) { throw "CMake配置失败" }
        
        msbuild /m td.sln /p:Configuration=Release /p:Platform=$visualStudioArch `
            /p:WarningLevel=3
        
        if ($LASTEXITCODE -ne 0) { throw "TDLib编译失败" }
        Write-ColorOutput "✅ TDLib编译完成" $colors.Success
    } catch {
        Write-ColorOutput "❌ TDLib编译失败: $_" $colors.Error
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Write-ColorOutput "✅ TDLib已编译，跳过" $colors.Success
}

# 步骤7: 编译Telegram Desktop
Write-ColorOutput "[7/8] 编译Telegram Desktop..." $colors.Info
if (-not (Test-Path "build")) {
    New-Item -ItemType Directory -Path "build" -Force | Out-Null
    Push-Location "build"
    
    try {
        cmake "..\$sourceDir" -G "Visual Studio 17 2022" -A $visualStudioArch `
            -DCMAKE_BUILD_TYPE=Release `
            -DTDESKTOP_API_ID=611335 `
            -DTDESKTOP_API_HASH=d524b414d21f4d37f08684c1df41ac9c `
            -DDESKTOP_APP_USE_PACKAGED=OFF
        
        if ($LASTEXITCODE -ne 0) { throw "CMake配置失败" }
        
        msbuild /m Telegram.sln /p:Configuration=Release /p:Platform=$visualStudioArch `
            /p:WarningLevel=3
        
        if ($LASTEXITCODE -ne 0) { throw "Telegram编译失败" }
        Write-ColorOutput "✅ Telegram Desktop编译完成" $colors.Success
    } catch {
        Write-ColorOutput "❌ Telegram编译失败: $_" $colors.Error
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Write-ColorOutput "✅ Telegram已编译，跳过" $colors.Success
}

# 步骤8: 打包
Write-ColorOutput "[8/8] 创建可执行包..." $colors.Info
try {
    $outputDir = "release/Telegram-no-ads-$Version-$Architecture"
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    
    Copy-Item "build/Release/Telegram.exe" "$outputDir/" -Force
    Get-ChildItem "build/Release" -Filter "*.dll" | Copy-Item -Destination "$outputDir/" -Force
    
    $zipName = "telegram-no-ads-$Version-$Architecture-portable.zip"
    Compress-Archive -Path $outputDir -DestinationPath "release/$zipName" -Force
    
    $hash = (Get-FileHash "release/$zipName" -Algorithm SHA256).Hash
    Set-Content -Path "release/$zipName.sha256" -Value "$hash  $zipName"
    
    Write-ColorOutput "✅ 打包完成: release/$zipName" $colors.Success
    Write-ColorOutput "✅ SHA256校验和: $hash" $colors.Success
} catch {
    Write-ColorOutput "❌ 打包失败: $_" $colors.Error
    exit 1
}

# 完成
$duration = (Get-Date) - $startTime
Write-ColorOutput ""
Write-ColorOutput "=====================================" $colors.Success
Write-ColorOutput "✅ 构建成功完成！" $colors.Success
Write-ColorOutput "=====================================" $colors.Success
Write-ColorOutput "耗时: $($duration.TotalMinutes.ToString('F1'))分钟" $colors.Success
Write-ColorOutput ""
Write-ColorOutput "构建产物: release/$zipName" $colors.Info
Write-ColorOutput "运行方式: 解压ZIP文件并双击 Telegram.exe" $colors.Info
Write-ColorOutput ""
