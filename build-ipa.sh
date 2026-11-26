#!/bin/bash
# 在 macOS 上一键出未签名 ipa（之后再签名 / 或用 Xcode 直接跑真机）
# 用法：./build-ipa.sh
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "==> 未安装 XcodeGen，先执行: brew install xcodegen"
  exit 1
fi

echo "==> 生成 Xcode 工程"
xcodegen generate

echo "==> 编译（不签名）"
xcodebuild \
  -project QqFarmPanel.xcodeproj \
  -scheme QqFarmPanel \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  -destination 'generic/platform=iOS' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="build/Build/Products/Release-iphoneos/QqFarmPanel.app"
[ -d "$APP_PATH" ] || { echo "编译产物不存在: $APP_PATH"; exit 1; }

echo "==> 打包 ipa"
rm -rf Payload QqFarmPanel-unsigned.ipa
mkdir -p Payload
cp -R "$APP_PATH" Payload/
zip -qry QqFarmPanel-unsigned.ipa Payload

echo "==> 完成: $(pwd)/QqFarmPanel-unsigned.ipa"
ls -lh QqFarmPanel-unsigned.ipa
echo "   下一步：用 Sideloadly / Xcode 用你的 Apple ID 签名后安装到 iPhone"
