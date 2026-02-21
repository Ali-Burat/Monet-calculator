import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';

class HistoryPanel extends StatelessWidget {
  final VoidCallback onClose;

  const HistoryPanel({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final calculator = context.watch<CalculatorProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('计算历史'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
        actions: [
          if (calculator.historyList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearDialog(context, calculator);
              },
              tooltip: '清除历史',
            ),
        ],
      ),
      body: calculator.historyList.isEmpty
          ? _buildEmptyState(colorScheme)
          : _buildHistoryList(calculator, colorScheme),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无计算历史',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(CalculatorProvider calculator, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: calculator.historyList.length,
      itemBuilder: (context, index) {
        final history = calculator.historyList[index];
        final parts = history.split(' = ');
        final expression = parts.isNotEmpty ? parts[0] : history;
        final result = parts.length > 1 ? parts[1] : '';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              '${calculator.historyList.length - index}',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
            ),
          ),
          title: Text(
            expression,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          subtitle: Text(
            '= $result',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          onTap: () {
            calculator.restoreFromHistory(history);
            onClose();
          },
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, CalculatorProvider calculator) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除历史'),
        content: const Text('确定要清除所有计算历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              calculator.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }
}
