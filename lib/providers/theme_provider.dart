import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xFF4A90A4); // 莫奈睡莲蓝
  
  // 莫奈调色板 - 灵感来自克劳德·莫奈的画作
  static const List<Map<String, dynamic>> monetPalette = [
    {'name': '睡莲蓝', 'color': Color(0xFF4A90A4), 'painting': '《睡莲》'},
    {'name': '花园绿', 'color': Color(0xFF5B8C5A), 'painting': '《花园中的女人》'},
    {'name': '日落橙', 'color': Color(0xFFE89B3C), 'painting': '《日出·印象》'},
    {'name': '玫瑰粉', 'color': Color(0xFFC77D8E), 'painting': '《撑阳伞的女人》'},
    {'name': '雾灰蓝', 'color': Color(0xFF7B8FA8), 'painting': '《伦敦议会大厦》'},
    {'name': '天空蓝', 'color': Color(0xFF6BA3D6), 'painting': '《圣阿德雷斯的露台》'},
    {'name': '阳光黄', 'color': Color(0xFFD4A84B), 'painting': '《干草堆》'},
    {'name': '大地棕', 'color': Color(0xFF8B7355), 'painting': '《卢昂大教堂》'},
  ];

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  
  String get currentColorName {
    for (var item in monetPalette) {
      if (item['color'] == _seedColor) {
        return item['name'];
      }
    }
    return '自定义';
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setSeedColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }
}
