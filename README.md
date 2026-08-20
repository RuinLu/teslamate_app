# TeslaMate App

一个基于 Flutter 开发的 TeslaMate 第三方移动端仪表盘应用，采用 Tesla 官方配色设计，提供车辆状态监控、行驶报表、充电记录、电池状态等功能。

## ✨ 特性

- 🎨 **Tesla 官方配色** - 还原 Tesla 品牌视觉体验
- 🌗 **深浅色模式** - 自动跟随系统主题切换
- 📱 **响应式设计** - 支持文字缩放保护，适配不同用户需求
- 📊 **实时状态监控** - 查看车辆实时状态信息
- 📈 **数据报表** - 行驶里程、充电记录、电池健康度等统计分析
- ⚙️ **自定义配置** - 灵活配置显示内容和服务器地址
- 🔄 **状态保持** - Tab 切换不丢失页面状态

## 📸 截图

https://raw.githubusercontent.com/RuinLu/teslamate_app/refs/heads/main/resource/%E7%8A%B6%E6%80%81.png
https://raw.githubusercontent.com/RuinLu/teslamate_app/refs/heads/main/resource/%E6%8A%A5%E8%A1%A8-%E7%94%B5%E6%B1%A0.png
https://raw.githubusercontent.com/RuinLu/teslamate_app/refs/heads/main/resource/%E6%8A%A5%E8%A1%A8-%E8%A1%8C%E7%A8%8B.png

## 🚀 快速开始
1.安装teslamate，搜索github
2.安装teslamateapi，搜索github
3.安装软件
4.在设置中填入teslamateapi的地址
5.开始使用
### 开发环境要求

- Flutter SDK >= 3.13.0
- Dart SDK >= 3.13.0
- Android Studio / Xcode (用于移动端开发)

### 安装步骤

1. 克隆项目
```bash
git clone <repository-url>
cd teslamate_app
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

## 📦 主要依赖

| 依赖包 | 用途 |
|--------|------|
| `dio` | HTTP 网络请求 |
| `shared_preferences` | 本地存储配置 |
| `fl_chart` | 图表可视化 |
| `flutter_localizations` | 国际化支持 |

## 🏗️ 项目结构

```
lib/
├── main.dart              # 应用入口和主框架
├── core/                  # 核心功能模块
│   └── storage/           # 本地存储服务
├── models/                # 数据模型定义
├── pages/                 # 页面组件
│   ├── status_page.dart   # 车辆状态页
│   ├── reports/           # 报表相关页面
│   └── settings_page.dart # 设置页
└── widgets/               # 可复用组件
```

## 🎯 功能模块

### 1. 状态页面 (StatusPage)
- 车辆实时状态展示
- 在线/离线状态监控

### 2. 报表页面 (ReportsPage)
- 行驶记录统计
- 充电历史分析
- 电池健康度趋势
- 软件更新记录

### 3. 设置页面 (SettingsPage)
- TeslaMate 服务器地址配置
- 各模块显示开关控制

## 🛠️ 开发指南

### 代码风格
项目遵循 Flutter 官方代码规范，使用 `flutter_lints` 进行代码质量检查。

### 构建发布

#### Android
```bash
flutter build apk --release
# 或构建 App Bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 📝 配置说明

应用支持以下配置项（存储在本地）：
- `baseUrl`: TeslaMate API 服务器地址
- `showStatus`: 是否显示状态模块
- `showDrives`: 是否显示行驶记录
- `showCharges`: 是否显示充电记录
- `showBattery`: 是否显示电池信息
- `showUpdates`: 是否显示更新记录

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目基于 MIT 许可证开源

## 🙏 致谢

- [TeslaMate](https://github.com/adriankumpf/teslamate) - 强大的自托管 Tesla 数据分析工具
- [Flutter](https://flutter.dev/) - 跨平台 UI 框架

---

> ⚠️ **免责声明**: 本应用为第三方开源项目，与 Tesla 公司无官方关联。
