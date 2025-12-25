# Location Tapper iOS App

一个简单的 iOS 应用，显示北京时间，并在每分钟 00 秒时自动点击屏幕上的定位点。

## 功能特性

- 显示实时北京时间
- 在屏幕随机位置显示彩色定位点
- 每分钟 00 秒自动点击所有定位点
- 手动点击定位点功能
- 支持添加更多定位点

## 环境要求

### Windows 开发环境

- Flutter SDK 3.0+
- Git for Windows
- Visual Studio (含 C++ 桌面开发组件)
- Apple Developer 账号 (用于证书签名)

### 构建 iOS

由于 Windows 无法直接编译 iOS，需要以下方案之一：

1. **远程 Mac 构建** (推荐: Codemagic、GitHub Actions)
2. **本地虚拟机/黑苹果**
3. **使用 Flutter  web 版本临时测试**

## 安装和运行

### 1. 安装 Flutter (Windows)

```powershell
# 从官网下载并安装: https://flutter.dev/docs/get-started/install/windows

# 添加到环境变量
$env:PATH += ";C:\flutter\bin"

# 验证安装
flutter doctor
```

### 2. 进入项目目录

```powershell
cd C:\Users\Devops\Desktop\python\ka0
```

### 3. 安装依赖

```powershell
flutter pub get
```

### 4. 运行项目

由于是 iOS 项目，在 Windows 上不能直接运行。可以：

**方案 A: 改为 Web 版本测试**

修改 `pubspec.yaml`，添加 web 支持后运行：

```powershell
flutter create --platforms web .
flutter run -d chrome
```

**方案 B: 远程构建 iOS**

```powershell
# 构建 iOS Release 包 (上传到云端编译)
flutter build ipa --release
```

## 发布到 iPhone

### 方法一：Codemagic 云构建 (推荐)

1. 上传项目到 GitHub/GitLab
2. 注册 [Codemagic](https://codemagic.io/start/)
3. 连接 Git 仓库并配置构建
4. 下载生成的 .ipa 文件
5. 使用 AltStore 或 Xcode 安装到手机

### 方法二：GitHub Actions

创建 `.github/workflows/ios.yml`:

```yaml
name: Build iOS
on: [push]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build ipa --release
      - uses: actions/upload-artifact@v3
        with:
          name: ipa
          path: build/ios/iphoneos/*.ipa
```

### 方法三：本地 Mac 虚拟机/黑苹果

```bash
# 在 Mac 环境下
cd /path/to/ka0
flutter pub get
flutter run
```

### 方法四：Windows + 远程 Mac (SSH)

```powershell
# 在 Windows 上同步代码到 Mac
flutter build ipa --no-codesign
# 然后在 Mac 上签名并安装
```

## 安装 .ipa 到手机

### 1. AltStore (无需越狱)

1. 下载 AltStore: https://altstore.io/
2. 安装 AltStore 到 iPhone
3. 用 AltStore 打开下载的 .ipa 文件

### 2. Xcode 直接安装

1. 连接 iPhone 到 Mac
2. Xcode -> Window -> Devices and Simulators
3. 点击 "+" 安装 .ipa

### 3. TestFlight (官方分发)

1. 将 .ipa 上传到 App Store Connect
2. 添加测试用户
3. 通过 TestFlight 安装

## 项目结构

```
ka0/
├── lib/
│   ├── main.dart           # 应用入口
│   └── home_screen.dart    # 主界面
├── ios/
│   ├── Runner/             # iOS 原生代码
│   └── Runner.xcworkspace/ # Xcode 工作空间
├── pubspec.yaml            # 依赖配置
└── README.md               # 说明文档
```

## 自定义

### 修改定位点数量

编辑 `lib/home_screen.dart` 中的 `_generateRandomPoints` 方法：

```dart
void _generateRandomPoints() {
  final random = Random();
  for (int i = 0; i < 10; i++) {  // 修改数量
    // ...
  }
}
```

### 修改自动点击行为

在 `_autoTapPoints` 方法中调整自动点击逻辑。

## 常见问题

**Q: Windows 能直接运行 iOS 吗？**
A: 不能，iOS 编译需要 macOS 和 Xcode。Windows 上只能开发、测试 web 版本。

**Q: 如何快速测试功能？**
A: 运行 `flutter create --platforms web . && flutter run -d chrome` 测试 UI 和逻辑。

**Q: 没有 Mac 怎么发布？**
A: 使用云服务如 Codemagic、GitHub Actions，或找有 Mac 的朋友帮忙签名。

## 注意事项

- 应用需要网络连接来获取准确的北京时间
- iOS 14+ 支持
- 真机调试需要有效的 Apple Developer 账号
- Windows 开发 iOS 需要云端编译
