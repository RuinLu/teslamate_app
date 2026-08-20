import 'package:flutter/material.dart';

/// ---------------------------------------------------------
/// 🧰 【报表共用工具箱】(report_kit)
/// ---------------------------------------------------------
/// 升级内容：
/// 1. StatCard 新增 [expand] 开关（默认 true，老页面不受影响）
/// 2. 🌟 新增 AdaptiveStatRow：宽屏一排，窄屏(<400dp)每排 2 个自动换行
/// ---------------------------------------------------------

/// 🀄 日期汉化工具函数
/// 把 "2026-08-16T13:28:10+08:00" 变成 "8月16日 13:28"
String formatCnDate(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso; // 解析失败原样返回，保证不崩
  // 🌟 时区修复：Dart 会把带时区的时间转成 UTC 存储，
  //    必须 toLocal() 转回本地时间，否则差 8 小时！
  final local = dt.toLocal();
  final hh = local.hour.toString().padLeft(2, '0'); // 补零：9 -> 09
  final mm = local.minute.toString().padLeft(2, '0');
  return '${local.month}月${local.day}日 $hh:$mm';
}

/// 🧱 统计小卡片（标题 + 大数字 + 单位 + 可选计算说明）
///
/// 参数说明：
/// - [inlineUnit] = true 时，单位和数字同一行
/// - [note] 非空时，底部显示计算方式说明小灰字
/// - [expand] = true 时自带 Expanded（可直接放 Row 里）；
///   交给 AdaptiveStatRow 管理宽度时会自动设为 false
class StatCard extends StatelessWidget {
  final String title; // 标题（如 "充电效率"）
  final String value; // 大数字（如 "94.1"）
  final String unit;  // 单位（如 "%"）
  final bool inlineUnit; // 单位是否与数字同行
  final String? note;    // 计算方式说明（可选）
  final bool expand;     // 🌟 是否自带 Expanded

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.inlineUnit = false,
    this.note,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 卡片本体（不含宽度约束）
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor, // 走主题色，深色模式自动适配
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 标题
          Text(title,
              style: TextStyle(
                  fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),

          // 数字 + 单位：同行 or 分行
          if (inlineUnit)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit,
                      style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant)),
                ),
              ],
            )
          else ...[
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(unit,
                style: TextStyle(
                    fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
          ],

          // 计算方式说明（可选小灰字）
          if (note != null) ...[
            const SizedBox(height: 6),
            Text(
              note!,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );

    // 🌟 expand=true 才包 Expanded，宽度交给父级时不包
    return expand ? Expanded(child: card) : card;
  }
}

/// 🧱 🌟 自适应统计卡行
/// 宽屏(≥400dp)：一排均分；窄屏(<400dp)：每排 2 个自动换行。
/// 用法：把原来的 Row(children:[StatCard...]) 换成
///       AdaptiveStatRow(cards: [StatCard(...), ...])
class AdaptiveStatRow extends StatelessWidget {
  final List<StatCard> cards; // 统计卡列表
  final double spacing;       // 卡片间距

  const AdaptiveStatRow({
    super.key,
    required this.cards,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    // 重建一批“不带 Expanded”的卡片，宽度完全由本组件管理
    final plain = cards
        .map((c) => StatCard(
              title: c.title,
              value: c.value,
              unit: c.unit,
              inlineUnit: c.inlineUnit,
              note: c.note,
              expand: false,
            ))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // ========== 宽屏：一排均分 ==========
        if (constraints.maxWidth >= 400) {
          return Row(
            children: [
              for (var i = 0; i < plain.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                Expanded(child: plain[i]),
              ],
            ],
          );
        }

        // ========== 窄屏：每排 2 个，自动换行 ==========
        final half = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              plain.map((c) => SizedBox(width: half, child: c)).toList(),
        );
      },
    );
  }
}

/// 🧱 报表分区标题（左对齐加粗文字，如 "行程列表"）
class ReportSectionTitle extends StatelessWidget {
  final String text;

  const ReportSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}