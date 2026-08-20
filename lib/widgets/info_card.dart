import 'package:flutter/material.dart';

/// 🧱 【UI 积木：信息卡片】—— 深浅色自适应版
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor, // 🌟 深色模式自动变深
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? theme.colorScheme.primary, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant, // 🌟 灰字也走主题
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface, // 🌟 黑字走主题，深色变白
            ),
          ),
        ],
      ),
    );
  }
}