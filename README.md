# 莫奈计算器

一款支持Material You动态取色的计算器应用，灵感来自克劳德·莫奈的印象派画作。

## ✨ 功能特点

### 🧮 计算功能
- **基础计算**: 加、减、乘、除
- **科学计算**: sin、cos、tan、log、ln、√、幂运算、阶乘等
- **角度/弧度**: 支持角度和弧度模式切换
- **括号运算**: 支持复杂的括号表达式
- **百分比计算**: 快速百分比运算
- **记忆功能**: MC、MR、M+、M- 内存操作

### 🎨 Material You 动态取色
- **系统取色**: 自动从壁纸提取主题颜色
- **莫奈调色板**: 8种莫奈画作风格配色
- **深色模式**: 支持浅色、深色、跟随系统

### 📜 历史记录
- 保存计算历史
- 快速恢复历史表达式
- 一键清除历史

## 🎨 莫奈调色板

| 颜色名称 | 来源作品 | 色值 |
|---------|---------|------|
| 睡莲蓝 | 《睡莲》系列 | #4A90A4 |
| 花园绿 | 《花园中的女人》 | #5B8C5A |
| 日落橙 | 《日出·印象》 | #E89B3C |
| 玫瑰粉 | 《撑阳伞的女人》 | #C77D8E |
| 雾灰蓝 | 《伦敦议会大厦》 | #7B8FA8 |
| 天空蓝 | 《圣阿德雷斯的露台》 | #6BA3D6 |
| 阳光黄 | 《干草堆》系列 | #D4A84B |
| 大地棕 | 《卢昂大教堂》 | #8B7355 |

## 📦 编译APK

### 方法一：GitHub Actions

1. Fork 或 Clone 此仓库
2. 进入 **Actions** 页面
3. 点击 **Build Flutter APK** → **Run workflow**
4. 编译完成后在 **Artifacts** 下载

### 方法二：本地编译

```bash
# 克隆项目
git clone https://github.com/your-username/monet-calculator.git
cd monet-calculator

# 安装依赖
flutter pub get

# 编译APK
flutter build apk --release

# APK位置: build/app/outputs/flutter-apk/app-release.apk
```

## 📁 项目结构

```
lib/
├── main.dart                 # 应用入口
├── providers/
│   ├── calculator_provider.dart  # 计算器状态管理
│   └── theme_provider.dart       # 主题状态管理
├── screens/
│   └── calculator_screen.dart    # 计算器主界面
└── widgets/
    ├── calculator_button.dart    # 计算器按钮组件
    ├── history_panel.dart        # 历史记录面板
    └── theme_panel.dart          # 主题设置面板
```

## 🔧 技术栈

- **Flutter** - 跨平台UI框架
- **dynamic_color** - Material You动态取色
- **math_expressions** - 数学表达式解析
- **provider** - 状态管理
- **shared_preferences** - 本地存储

## 📄 许可证

MIT License

---

**灵感来源**: 克劳德·莫奈 (Claude Monet, 1840-1926)
