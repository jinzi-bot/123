# iOS 端（QQ农场智能助手）

SwiftUI + WKWebView 原生壳，功能与 Android / Windows 端一致：默认加载 `http://150.138.73.130`，可随时改服务器地址，支持返回/刷新。

> **Windows 上无法编译 iOS 应用**（需要 Apple 的 Xcode，只能在 macOS 跑）。所以这里给的是**完整工程源码**，外加**一条不需要 Mac 的出包路径**。
>
> 已经用这条路编好了：`app/dist/QqFarmPanel-1.0.0-unsigned.ipa`（157 KB），直接跳到下面 **A2 用 Sideloadly 安装**即可。
> 工程仓库：https://github.com/jinzi-bot/123 （公开，改完 push 会自动重新编译）

---

## 路线 A（推荐，纯 Windows，0 成本）：GitHub Actions 编译 + Sideloadly 安装

原理：GitHub 免费提供 macOS 机器编译 → 产出**未签名 ipa** → 在 Windows 上用 Sideloadly 用你自己的 Apple ID 签名装进 iPhone。

### A1. 让 GitHub 帮你编译（约 5 分钟）

1. 打开 https://github.com/new 建一个**私有**仓库（名字随意，如 `qqfarm-ios`）
2. 把**本文件夹 `app/ios` 里的全部内容**上传到仓库根目录（网页版 "uploading an existing file" 直接拖进去即可，注意 `project.yml`、`QqFarmPanel/`、`.github/` 都要在根目录）
3. 进入仓库 **Actions** 标签 → 左侧选 **Build unsigned iOS IPA** → 右侧 **Run workflow** → 绿色按钮
4. 等 3～8 分钟，任务变绿后点进去，页面底部 **Artifacts** → 下载 `QqFarmPanel-unsigned-ipa`
5. 解压得到 `QqFarmPanel-unsigned.ipa`

> `.github/workflows/ios-unsigned-ipa.yml` 已经写好了：自动装 XcodeGen、生成工程、`CODE_SIGNING_ALLOWED=NO` 编译、打 Payload 成 ipa、上传产物。
>
> 注意：runner 必须是 `macos-15`（GitHub 已不支持 `macos-14`，会报 `The configuration 'macos-14-arm64-us-default' is not supported` 并被取消）。

### A2. 用 Sideloadly 装到 iPhone（约 5 分钟）

1. Windows 先装 **Apple Devices**（微软商店搜 "Apple Devices"）或 iTunes，用来给 iPhone 提供驱动
2. 下载 **Sideloadly**：https://sideloadly.io/
3. 数据线连 iPhone，手机上点「信任此电脑」并输入锁屏密码
4. 打开 Sideloadly：`IPA` 一栏拖入 `QqFarmPanel-unsigned.ipa`，`Apple ID` 填你的 Apple ID（不是密码给第三方，是走 Apple 官方登录）
5. 点 **Start**，中途会要求输入 Apple ID 密码和**双重认证验证码**，等进度条走完
6. 手机上：**设置 → 通用 → VPN与设备管理 → 开发者 App → 信任** 你的 Apple ID
7. iOS 16 以上还要开：**设置 → 隐私与安全性 → 开发者模式 → 打开 → 重启手机**

装好后桌面就有「QQ农场智能助手」图标。

### A3. 关于有效期

免费 Apple ID 签的 App **7 天后失效**（图标打不开）。到期后重跑一遍 Sideloadly（或 AltStore 自动续签）即可，数据不丢。
要长期使用/装到别人手机上，需要 Apple Developer 账号（$99/年），签名有效期 1 年。

---

## 路线 B：有 Mac 或借到 Mac（最省事，能直接真机调试）

```bash
brew install xcodegen          # 只装一次
cd app/ios
./build-ipa.sh                 # 一键出未签名 ipa；或者：
xcodegen generate && open QqFarmPanel.xcodeproj
```

用 Xcode 打开后：选中 `QqFarmPanel` target → **Signing & Capabilities** → Team 选你的 Apple ID
（Bundle Identifier 默认 `com.qqfarm.panel`，被占用就改成 `com.你的名字.qqfarm`）→ 选真机 → `Product → Run`。

想直接出可安装的包：`Product → Archive` → `Distribute App`。

## 路线 C：云 Mac

MacinCloud / MacStadium 等按小时租一台云 Mac，远程桌面进去，按路线 B 操作即可。

---

## 文件说明

| 文件 | 作用 |
| --- | --- |
| `project.yml` | XcodeGen 工程描述（Bundle ID、版本 1.0.0、iOS 16.0、图标） |
| `QqFarmPanel/QqFarmPanelApp.swift` | App 入口 |
| `QqFarmPanel/RootView.swift` | 主界面：直接加载面板，工具栏返回/刷新/设置 |
| `QqFarmPanel/WebPanelView.swift` | WKWebView 封装（进度、返回手势、外链跳系统、window.open 同窗口） |
| `QqFarmPanel/SettingsView.swift` | 服务器地址设置（校验、补 http://、恢复默认） |
| `QqFarmPanel/Info.plist` | 中文显示名、允许 http 明文（ATS）、横竖屏 |
| `QqFarmPanel/Assets.xcassets` | 1024 应用图标（单尺寸格式） |
| `build-ipa.sh` | macOS 上一键出未签名 ipa |
| `.github/workflows/ios-unsigned-ipa.yml` | GitHub Actions 自动编译（无需 Mac） |

## 常见问题

| 现象 | 原因 / 解决 |
| --- | --- |
| 编译报 `Signing for "QqFarmPanel" requires a development team` | 走路线 B 时在 Signing 里选 Team；走路线 A 的 CI 不需要 |
| 装完打开提示「未受信任的开发者」 | 设置 → 通用 → VPN与设备管理 → 信任 |
| 装完点不开、闪退 | iOS 16+ 没开「开发者模式」；或 7 天试用期到了，重签 |
| 白屏 / 加载不出 | 面板服务器 `http://150.138.73.130` 不通（先用手机 Safari 打开验证）；或需要登录，登录后即正常 |
| Sideloadly 认不到手机 | 没装 Apple Devices/iTunes 驱动，或没在手机上点「信任」 |
| GitHub Actions 报 `xcodegen: command not found` | 说明 `.github/workflows` 没在仓库根目录，或仓库根目录不是 ios 内容 |
