#!/bin/bash
# 快速验证脚本 - 检查所有必要的文件是否存在

echo "======================================"
echo "  Telegram Desktop No-Ads 项目检查"
echo "======================================"
echo ""

# 检查文件
files_to_check=(
    "PKGBUILD"
    "remove-ads.patch"
    "build.ps1"
    ".github/workflows/build.yml"
    ".github/workflows/build-windows.yml"
    ".github/workflows/build-windows-advanced.yml"
    "WINDOWS_BUILD.md"
    "README_CN.md"
    "MIGRATION_SUMMARY.md"
)

missing_files=()
found_files=()

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        found_files+=("$file")
        echo "✅ $file"
    else
        missing_files+=("$file")
        echo "❌ $file"
    fi
done

echo ""
echo "======================================"
echo "检查结果"
echo "======================================"
echo "找到: ${#found_files[@]}/${#files_to_check[@]} 文件"
echo ""

if [ ${#missing_files[@]} -eq 0 ]; then
    echo "✅ 所有文件完整！可以开始使用。"
    echo ""
    echo "后续步骤:"
    echo "1. git add ."
    echo "2. git commit -m 'Add Windows build support'"
    echo "3. git push origin master"
    echo ""
    echo "然后访问 GitHub Actions 查看自动构建进度。"
else
    echo "❌ 缺少文件:"
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
fi

echo ""
echo "======================================"
echo ""
