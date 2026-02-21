import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonType {
  number,
  operator,
  function,
  equals,
}

class CalculatorButton extends StatefulWidget {
  final String label;
  final ButtonType type;
  final VoidCallback onTap;
  final bool isWide;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.isWide = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color backgroundColor;
    Color foregroundColor;
    
    switch (widget.type) {
      case ButtonType.number:
        backgroundColor = colorScheme.surfaceContainerHighest;
        foregroundColor = colorScheme.onSurface;
        break;
      case ButtonType.operator:
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        break;
      case ButtonType.function:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
        break;
      case ButtonType.equals:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: _isPressed 
                ? Color.lerp(backgroundColor, foregroundColor, 0.15)
                : backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: widget.type == ButtonType.equals 
                    ? FontWeight.w500 
                    : FontWeight.w400,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getFontSize() {
    switch (widget.label) {
      case '⌫':
        return 24;
      case '=':
      case '+':
      case '-':
      case '×':
      case '÷':
        return 28;
      default:
        return 26;
    }
  }
}
