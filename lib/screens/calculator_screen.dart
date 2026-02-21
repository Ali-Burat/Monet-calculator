import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/calculator_button.dart';
import '../widgets/history_panel.dart';
import '../widgets/theme_panel.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showHistory = false;
  bool _showThemePanel = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 加载保存的状态
    Future.microtask(() {
      context.read<CalculatorProvider>().loadState();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final calculator = context.watch<CalculatorProvider>();
    final themeProvider = context.read<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部栏
            _buildTopBar(colorScheme, themeProvider, calculator),
            
            // 显示区域
            _buildDisplayArea(calculator, colorScheme),
            
            // 科学计算扩展面板
            if (calculator.isScientificMode)
              _buildScientificPanel(calculator, colorScheme),
            
            // 按钮区域
            Expanded(
              child: _buildButtonPad(calculator, colorScheme),
            ),
          ],
        ),
      ),
      
      // 历史记录面板
      drawer: _showHistory ? Drawer(
        child: HistoryPanel(
          onClose: () => setState(() => _showHistory = false),
        ),
      ) : null,
      
      // 主题面板
      endDrawer: _showThemePanel ? Drawer(
        width: 300,
        child: ThemePanel(
          onClose: () => setState(() => _showThemePanel = false),
        ),
      ) : null,
    );
  }

  Widget _buildTopBar(
    ColorScheme colorScheme, 
    ThemeProvider themeProvider,
    CalculatorProvider calculator,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 历史记录按钮
          IconButton(
            icon: Icon(Icons.history, color: colorScheme.onSurface),
            onPressed: () {
              setState(() => _showHistory = true);
              Scaffold.of(context).openDrawer();
            },
            tooltip: '历史记录',
          ),
          
          // 标题和模式指示
          Column(
            children: [
              Text(
                '莫奈计算器',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (calculator.isScientificMode)
                Text(
                  calculator.isRadianMode ? '弧度' : '角度',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          
          // 右侧按钮组
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 科学计算模式切换
              IconButton(
                icon: Icon(
                  calculator.isScientificMode 
                      ? Icons.calculate 
                      : Icons.calculate_outlined,
                  color: calculator.isScientificMode 
                      ? colorScheme.primary 
                      : colorScheme.onSurface,
                ),
                onPressed: calculator.toggleScientificMode,
                tooltip: '科学计算',
              ),
              // 主题切换
              IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : themeProvider.themeMode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.brightness_auto,
                  color: colorScheme.onSurface,
                ),
                onPressed: themeProvider.toggleTheme,
                tooltip: '切换主题',
              ),
              // 调色板
              IconButton(
                icon: Icon(Icons.palette, color: colorScheme.onSurface),
                onPressed: () {
                  setState(() => _showThemePanel = true);
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: '莫奈调色板',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayArea(CalculatorProvider calculator, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 表达式显示
          Container(
            height: 40,
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                calculator.expression.isEmpty 
                    ? ' ' 
                    : calculator.expression,
                style: TextStyle(
                  fontSize: 24,
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'RobotoMono',
                ),
                maxLines: 1,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 结果显示
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: calculator.result.length > 10 ? 36 : 48,
              fontWeight: FontWeight.w300,
              color: calculator.hasError 
                  ? colorScheme.error 
                  : colorScheme.onSurface,
              fontFamily: 'RobotoMono',
            ),
            child: Text(
              calculator.result,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 括号指示器
          if (calculator.openParentheses > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '(${calculator.openParentheses}个未闭合括号)',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScientificPanel(CalculatorProvider calculator, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          // 角度/弧度切换
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeChip(
                'DEG', 
                !calculator.isRadianMode, 
                colorScheme,
                () => calculator.toggleAngleMode(),
              ),
              const SizedBox(width: 8),
              _buildModeChip(
                'RAD', 
                calculator.isRadianMode, 
                colorScheme,
                () => calculator.toggleAngleMode(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 科学函数按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSciBtn('sin', calculator, colorScheme),
              _buildSciBtn('cos', calculator, colorScheme),
              _buildSciBtn('tan', calculator, colorScheme),
              _buildSciBtn('log', calculator, colorScheme),
              _buildSciBtn('ln', calculator, colorScheme),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSciBtn('√', calculator, colorScheme),
              _buildSciBtn('x²', calculator, colorScheme),
              _buildSciBtn('x³', calculator, colorScheme),
              _buildSciBtn('xʸ', calculator, colorScheme),
              _buildSciBtn('1/x', calculator, colorScheme),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSciBtn('π', calculator, colorScheme),
              _buildSciBtn('e', calculator, colorScheme),
              _buildSciBtn('n!', calculator, colorScheme),
              _buildSciBtn('|x|', calculator, colorScheme),
              _buildSciBtn('(', calculator, colorScheme),
              _buildSciBtn(')', calculator, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(
    String label, 
    bool isSelected, 
    ColorScheme colorScheme,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSciBtn(
    String label, 
    CalculatorProvider calculator, 
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () {
        if (label == '(' || label == ')') {
          calculator.inputParenthesis(label);
        } else {
          calculator.inputScientificFunction(label);
        }
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 36,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonPad(CalculatorProvider calculator, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 记忆功能行
          _buildMemoryRow(calculator, colorScheme),
          
          const SizedBox(height: 8),
          
          // 主按钮网格
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: _buildButtons(calculator, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryRow(CalculatorProvider calculator, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMemoryBtn('MC', calculator.memoryClear, colorScheme),
        _buildMemoryBtn('MR', calculator.memoryRecall, colorScheme),
        _buildMemoryBtn('M+', calculator.memoryAdd, colorScheme),
        _buildMemoryBtn('M-', calculator.memorySubtract, colorScheme),
        if (calculator.memory != 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'M: ${calculator.memory.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMemoryBtn(String label, VoidCallback onTap, ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 36,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtons(CalculatorProvider calculator, ColorScheme colorScheme) {
    final buttons = [
      // 第一行
      {'label': 'C', 'type': ButtonType.function, 'action': calculator.clear},
      {'label': '(', 'type': ButtonType.function, 'action': () => calculator.inputParenthesis('(')},
      {'label': ')', 'type': ButtonType.function, 'action': () => calculator.inputParenthesis(')')},
      {'label': '÷', 'type': ButtonType.operator, 'action': () => calculator.inputOperator('÷')},
      
      // 第二行
      {'label': '7', 'type': ButtonType.number, 'action': () => calculator.inputNumber('7')},
      {'label': '8', 'type': ButtonType.number, 'action': () => calculator.inputNumber('8')},
      {'label': '9', 'type': ButtonType.number, 'action': () => calculator.inputNumber('9')},
      {'label': '×', 'type': ButtonType.operator, 'action': () => calculator.inputOperator('×')},
      
      // 第三行
      {'label': '4', 'type': ButtonType.number, 'action': () => calculator.inputNumber('4')},
      {'label': '5', 'type': ButtonType.number, 'action': () => calculator.inputNumber('5')},
      {'label': '6', 'type': ButtonType.number, 'action': () => calculator.inputNumber('6')},
      {'label': '-', 'type': ButtonType.operator, 'action': () => calculator.inputOperator('-')},
      
      // 第四行
      {'label': '1', 'type': ButtonType.number, 'action': () => calculator.inputNumber('1')},
      {'label': '2', 'type': ButtonType.number, 'action': () => calculator.inputNumber('2')},
      {'label': '3', 'type': ButtonType.number, 'action': () => calculator.inputNumber('3')},
      {'label': '+', 'type': ButtonType.operator, 'action': () => calculator.inputOperator('+')},
      
      // 第五行
      {'label': '0', 'type': ButtonType.number, 'action': () => calculator.inputNumber('0')},
      {'label': '.', 'type': ButtonType.number, 'action': calculator.inputDecimal},
      {'label': '⌫', 'type': ButtonType.function, 'action': calculator.backspace},
      {'label': '=', 'type': ButtonType.equals, 'action': calculator.calculate},
    ];

    return buttons.map((btn) {
      return CalculatorButton(
        label: btn['label'] as String,
        type: btn['type'] as ButtonType,
        onTap: btn['action'] as VoidCallback,
      );
    }).toList();
  }
}
