import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorProvider extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  String _history = '';
  List<String> _historyList = [];
  bool _isNewCalculation = true;
  bool _hasError = false;
  
  // 科学计算模式
  bool _isScientificMode = false;
  bool _isRadianMode = true;
  
  // 记忆功能
  double _memory = 0;
  
  // 括号计数
  int _openParentheses = 0;

  // Getters
  String get expression => _expression;
  String get result => _result;
  String get history => _history;
  List<String> get historyList => _historyList;
  bool get isNewCalculation => _isNewCalculation;
  bool get hasError => _hasError;
  bool get isScientificMode => _isScientificMode;
  bool get isRadianMode => _isRadianMode;
  double get memory => _memory;
  int get openParentheses => _openParentheses;

  // 输入数字
  void inputNumber(String number) {
    if (_isNewCalculation) {
      _expression = number;
      _isNewCalculation = false;
    } else {
      // 防止多个前导零
      if (_expression == '0' && number == '0') return;
      if (_expression == '0' && number != '.') {
        _expression = number;
      } else {
        _expression += number;
      }
    }
    _hasError = false;
    notifyListeners();
  }

  // 输入小数点
  void inputDecimal() {
    if (_isNewCalculation) {
      _expression = '0.';
      _isNewCalculation = false;
    } else {
      // 获取当前数字
      List<String> parts = _expression.split(RegExp(r'[+\-×÷]'));
      String currentNumber = parts.isNotEmpty ? parts.last : '';
      
      // 如果当前数字已包含小数点，则不再添加
      if (!currentNumber.contains('.')) {
        if (_expression.isEmpty || 
            RegExp(r'[+\-×÷]$').hasMatch(_expression) ||
            _expression.endsWith('(')) {
          _expression += '0.';
        } else {
          _expression += '.';
        }
      }
    }
    _hasError = false;
    notifyListeners();
  }

  // 输入运算符
  void inputOperator(String operator) {
    if (_expression.isEmpty) {
      if (operator == '-') {
        _expression = operator;
      }
    } else if (RegExp(r'[+\-×÷]$').hasMatch(_expression)) {
      // 替换最后一个运算符
      _expression = _expression.substring(0, _expression.length - 1) + operator;
    } else {
      _expression += operator;
    }
    _isNewCalculation = false;
    _hasError = false;
    notifyListeners();
  }

  // 输入括号
  void inputParenthesis(String paren) {
    if (paren == '(') {
      if (_expression.isEmpty || 
          RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
        _expression += '(';
        _openParentheses++;
      } else {
        // 在数字后添加括号需要乘号
        _expression += '×(';
        _openParentheses++;
      }
    } else if (paren == ')' && _openParentheses > 0) {
      // 只有在有未闭合的左括号时才能添加右括号
      if (!RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
        _expression += ')';
        _openParentheses--;
      }
    }
    _isNewCalculation = false;
    _hasError = false;
    notifyListeners();
  }

  // 输入科学函数
  void inputScientificFunction(String func) {
    String insertFunc = func;
    
    switch (func) {
      case 'sin':
      case 'cos':
      case 'tan':
      case 'log':
      case 'ln':
        insertFunc = '$func(';
        _openParentheses++;
        break;
      case '√':
        insertFunc = 'sqrt(';
        _openParentheses++;
        break;
      case 'x²':
        if (_expression.isNotEmpty && !RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
          _expression += '^2';
        }
        notifyListeners();
        return;
      case 'x³':
        if (_expression.isNotEmpty && !RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
          _expression += '^3';
        }
        notifyListeners();
        return;
      case 'xʸ':
        if (_expression.isNotEmpty && !RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
          _expression += '^';
        }
        notifyListeners();
        return;
      case '1/x':
        if (_expression.isNotEmpty && !RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
          _expression = '1/($_expression)';
        }
        notifyListeners();
        return;
      case 'n!':
        if (_expression.isNotEmpty && !RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
          _expression = 'factorial($_expression)';
        }
        notifyListeners();
        return;
      case 'π':
        if (_expression.isEmpty || RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
          _expression += 'pi';
        } else {
          _expression += '×pi';
        }
        break;
      case 'e':
        if (_expression.isEmpty || RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
          _expression += 'e';
        } else {
          _expression += '×e';
        }
        break;
      case '|x|':
        insertFunc = 'abs(';
        _openParentheses++;
        break;
    }
    
    if (_expression.isEmpty || RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
      _expression += insertFunc;
    } else {
      _expression += '×$insertFunc';
    }
    
    _isNewCalculation = false;
    _hasError = false;
    notifyListeners();
  }

  // 百分比
  void inputPercent() {
    if (_expression.isNotEmpty && !RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
      try {
        // 获取最后一个数字
        RegExpMatch? match = RegExp(r'[\d.]+$').firstMatch(_expression);
        if (match != null) {
          String lastNumber = match.group(0)!;
          double value = double.parse(lastNumber) / 100;
          _expression = _expression.substring(0, match.start) + value.toString();
        }
      } catch (e) {
        // 忽略错误
      }
    }
    notifyListeners();
  }

  // 正负号切换
  void toggleSign() {
    if (_expression.isNotEmpty) {
      if (_expression.startsWith('-')) {
        _expression = _expression.substring(1);
      } else {
        _expression = '-$_expression';
      }
      notifyListeners();
    }
  }

  // 计算结果
  void calculate() {
    if (_expression.isEmpty) return;
    
    // 自动补全括号
    String expr = _expression;
    for (int i = 0; i < _openParentheses; i++) {
      expr += ')';
    }
    
    try {
      // 替换显示符号为计算符号
      expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
      
      Parser p = Parser();
      Expression exp = p.parse(expr);
      
      ContextModel cm = ContextModel();
      
      // 设置角度/弧度模式
      if (!_isRadianMode) {
        // 角度模式需要转换
        cm.bindVariableName('pi', Number(3.14159265359));
      }
      
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      // 格式化结果
      if (eval == eval.toInt()) {
        _result = eval.toInt().toString();
      } else {
        // 处理浮点数精度问题
        String resultStr = eval.toStringAsFixed(10);
        // 移除尾部的零
        resultStr = resultStr.replaceAll(RegExp(r'0+$'), '');
        if (resultStr.endsWith('.')) {
          resultStr = resultStr.substring(0, resultStr.length - 1);
        }
        _result = resultStr;
      }
      
      // 添加到历史记录
      _history = '$_expression = $_result';
      _historyList.insert(0, _history);
      if (_historyList.length > 50) {
        _historyList.removeLast();
      }
      
      _expression = _result;
      _isNewCalculation = true;
      _openParentheses = 0;
      _hasError = false;
      
    } catch (e) {
      _result = '错误';
      _hasError = true;
    }
    
    notifyListeners();
  }

  // 清除
  void clear() {
    _expression = '';
    _result = '0';
    _isNewCalculation = true;
    _openParentheses = 0;
    _hasError = false;
    notifyListeners();
  }

  // 退格
  void backspace() {
    if (_expression.isNotEmpty) {
      String removed = _expression.substring(_expression.length - 1);
      if (removed == '(') _openParentheses--;
      if (removed == ')') _openParentheses++;
      
      _expression = _expression.substring(0, _expression.length - 1);
      
      if (_expression.isEmpty) {
        _result = '0';
        _isNewCalculation = true;
      }
    }
    notifyListeners();
  }

  // 清除历史
  void clearHistory() {
    _historyList.clear();
    _history = '';
    notifyListeners();
  }

  // 切换科学计算模式
  void toggleScientificMode() {
    _isScientificMode = !_isScientificMode;
    notifyListeners();
  }

  // 切换角度/弧度模式
  void toggleAngleMode() {
    _isRadianMode = !_isRadianMode;
    notifyListeners();
  }

  // 记忆功能
  void memoryClear() {
    _memory = 0;
    notifyListeners();
  }

  void memoryRecall() {
    if (_memory != 0) {
      if (_expression.isEmpty || RegExp(r'[+\-×÷(]$').hasMatch(_expression)) {
        _expression += _memory.toString();
      } else {
        _expression += '×${_memory.toString()}';
      }
      _isNewCalculation = false;
      notifyListeners();
    }
  }

  void memoryAdd() {
    try {
      double current = double.tryParse(_result) ?? 0;
      _memory += current;
      notifyListeners();
    } catch (e) {
      // 忽略错误
    }
  }

  void memorySubtract() {
    try {
      double current = double.tryParse(_result) ?? 0;
      _memory -= current;
      notifyListeners();
    } catch (e) {
      // 忽略错误
    }
  }

  // 从历史记录恢复
  void restoreFromHistory(String historyItem) {
    List<String> parts = historyItem.split(' = ');
    if (parts.isNotEmpty) {
      _expression = parts[0];
      _isNewCalculation = false;
      notifyListeners();
    }
  }

  // 保存和加载状态
  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _historyList);
    await prefs.setDouble('memory', _memory);
  }

  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _historyList = prefs.getStringList('history') ?? [];
    _memory = prefs.getDouble('memory') ?? 0;
    notifyListeners();
  }
}
