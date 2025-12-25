# Location Tapper iOS App 完整部署指南

使用 Codemagic 云端构建，无需 Mac 即可发布到 iPhone。

## 目录

- [准备工作](#准备工作)
- [步骤 1：上传到 GitHub](#步骤1上传到-github)
- [步骤 2：注册 Codemagic](#步骤2注册-codemagic)
- [步骤 3：配置项目](#步骤3配置项目)
- [步骤 4：构建并下载](#步骤4构建并下载)
- [步骤 5：安装到 iPhone](#步骤5安装到-iphone)
- [后续更新](#后续更新)

---

## 准备工作

### 需要准备的东西

| 工具/账号 | 用途 | 获取方式 |
|-----------|------|----------|
| GitHub 账号 | 托管代码 | https://github.com |
| Codemagic 账号 | 云端构建 | https://codemagic.io |
| Apple ID | 签名 App | 现有即可 |
| AltStore | 安装 App | 后续安装 |

### 验证 Flutter 环境

```powershell
# 检查 Flutter 是否安装成功
flutter doctor

# 确保看到 ✓ Android toolchain / iOS / CocoaPods 等检查项
```

---

## 步骤 1：上传到 GitHub

### 1.1 创建 GitHub 仓库

1. 打开 https://github.com/new
2. Repository name 填 `location-tapper`
3. 选择 **Public** 或 **Private**
4. **不要**勾选 "Add a README file"
5. 点击 "Create repository"

### 1.2 本地初始化并推送

在 `C:\Users\Devops\Desktop\python\ka0` 目录打开终端：

```powershell
# 初始化 git（如果还没初始化）
git init

# 添加所有文件
git add .

# 提交代码
git commit -m "Initial commit: Location Tapper iOS app"

# 关联 GitHub 仓库（替换为你的仓库地址）
git remote add origin https://github.com/你的用户名/location-tapper.git

# 推送到 GitHub
git push -u origin master

# 或者如果提示分支名不对，用 main
git branch -M main
git push -u origin main
```

### 1.3 验证推送成功

刷新 GitHub 页面，应该能看到所有文件：

```
location-tapper/
├── lib/
│   ├── main.dart
│   └── home_screen.dart
├── ios/
├── pubspec.yaml
└── README.md
```

---

## 步骤 2：注册 Codemagic

### 2.1 注册账号

1. 打开 https://codemagic.io/start/
2. 点击 **"Sign up with GitHub"**
3. 授权 GitHub 账号
4. 完成注册

### 2.2 免费额度

Codemagic 免费版每月：
- 500 分钟 Mac mini 构建
- 3 个协作成员
- **够用了！**

---

## 步骤 3：配置项目

### 3.1 在 Codemagic 添加项目

1. 登录 Codemagic 控制台：https://codemagic.io/app/
2. 点击 **"Add new project"**
3. 选择你的 GitHub 仓库 `location-tapper`
4. 点击 "Set up build"

### 3.2 配置构建参数

在页面中设置：

```
Project name: location-tapper
Platform: iOS
Build mode: Release
```

### 3.3 配置 Apple ID 签名

**重要**：需要设置 Apple ID 才能生成可安装的 .ipa

1. 在 Codemagic 页面找到 **"iOS signing"** 部分
2. 点击 **"Add Apple ID"**
3. 填写：
   - Apple ID: 你的 Apple ID 邮箱
   - Password: 你的 Apple ID 密码（或 App 专用密码）
4. 点击 Save

> ⚠️ 如果 Apple ID 开启了两步验证，需要生成 App 专用密码：
> https://appleid.apple.com/account/manage -> 安全 -> App 专用密码

### 3.4 开始构建

1. 点击页面右上角 **"Start build"**
2. 等待构建完成（约 5-10 分钟）
3. 构建日志会显示进度

---

## 步骤 4：构建并下载

### 4.1 等待构建完成

构建状态：
- ⏳ Queued - 排队中
- 🔨 Building - 构建中
- ✅ Success - 成功
- ❌ Failed - 失败

### 4.2 下载 .ipa 文件

构建成功后：

1. 在构建详情页找到 **"Artifacts"** 部分
2. 点击下载 **`.ipa`** 文件
3. 保存到本地

```
文件名示例: location-tapper.ipa
文件大小: 约 20-50MB
```

---

## 步骤 5：安装到 iPhone

### 5.1 安装 AltServer (Windows)

**方法 A：Microsoft Store（推荐）**

1. 打开 Microsoft Store
2. 搜索 **"AltServer"**
3. 点击安装

**方法 B：手动下载**

1. 打开 https://altstore.io/
2. 点击 "Download AltServer"
3. 下载后安装

### 5.2 安装 AltStore 到 iPhone

1. 数据线连接 iPhone 到 Windows 电脑
2. iPhone 弹出提示点 **"信任"**
3. 电脑右下角任务栏找到 AltServer 图标
4. 右键点击 -> **"Install AltStore"**
5. 选择你的 iPhone
6. 输入 **Apple ID** 和 **密码**
7. 等待安装完成

> 💡 可以用另一个 Apple ID（不用开发者账号也能装）

### 5.3 安装你的 App

1. 在 Windows 上右键下载的 `.ipa` 文件
2. 选择 **"Install with AltStore"**
3. 等待安装完成
4. 在 iPhone 主屏幕找到 "Location Tapper"

### 5.4 信任开发者证书

首次打开 App 会提示"不受信任的开发者"：

1. 打开 iPhone **设置**
2. 通用 -> VPN与设备管理 / 设备管理
3. 找到你的 Apple ID
4. 点击 **"信任 Apple ID"**
5. 现在可以打开 App 了

---

## 后续更新

### 更新 App 流程

```
1. 修改代码
      │
      ▼
2. git add . && git commit -m "更新说明"
      │
      ▼
3. git push origin main
      │
      ▼
4. Codemagic 自动构建（或手动触发）
      │
      ▼
5. 下载新的 .ipa
      │
      ▼
6. AltStore 重新安装
```

### 快速触发构建

1. 打开 Codemagic 控制台
2. 找到项目
3. 点击 **"Start build"**

### 证书过期

Apple ID 签名每 7 天过期，过期后：
1. 重新下载新的 .ipa
2. AltStore 重新安装即可

---

## 常见问题

### Q: 构建失败了怎么办？

查看构建日志：
1. 点击失败的构建
2. 查看 "Build logs" 标签
3. 搜索 `error` 关键字
4. 根据错误信息修复

### Q: Apple ID 验证失败？

1. 确保 Apple ID 开启了两步验证
2. 使用 App 专用密码：https://appleid.apple.com/account/manage
3. 检查 Apple ID 地区是否支持

### Q: AltStore 安装失败？

1. 重新插拔数据线
2. 重启 AltServer
3. 确认 iPhone 信任了电脑

### Q: 能否不用 AltStore？

可以，但更麻烦：
- **Xcode** (需要 Mac)
- **TestFlight** (需要 $99/年 开发者账号)

### Q: 能发给朋友用吗？

可以！把 .ipa 文件发给他们，让他们用 AltStore 安装。无需越狱。

---

## 项目结构

```
location-tapper/
├── lib/
│   ├── main.dart              # 应用入口
│   └── home_screen.dart       # 主界面（北京时间 + 自动点击）
├── ios/                       # iOS 配置
├── android/                   # Android 配置（如果需要）
├── web/                       # Web 版本（如果需要）
├── pubspec.yaml               # 依赖配置
└── README.md                  # 本文档
```

## 自定义修改

### 修改定位点数量

编辑 `lib/home_screen.dart`：

```dart
void _generateRandomPoints() {
  final random = Random();
  for (int i = 0; i < 10; i++) {  // 改成你想要的数量
    _points.add(PointData(...));
  }
}
```

### 修改 App 名称

编辑 `ios/Runner/Info.plist`：

```xml
<key>CFBundleDisplayName</key>
<string>你的App名称</string>
```

---

## 联系方式

遇到问题可以：
1. 查看 Codemagic 文档：https://docs.codemagic.io/
2. 查看 AltStore 官网：https://altstore.io/
3. GitHub Issues

---

**祝你成功！🎉**
