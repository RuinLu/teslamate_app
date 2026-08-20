import 'package:flutter/material.dart';
import '../../models/charge.dart';
import '../../widgets/report_kit.dart';

/// ---------------------------------------------------------
/// 🔌 【充电报表】(ChargesReport)
/// ---------------------------------------------------------
/// 纯渲染组件：自己不取数据，由容器页把“筛选后”的数据传进来。
/// 内容：统计卡 + 充电列表
/// ---------------------------------------------------------
class ChargesReport extends StatelessWidget {
  final List<Charge> charges; // 筛选后的充电数据

  const ChargesReport({
    super.key,
    required this.charges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 📈 统计 1：总充入电量（fold = 累加器）
    final totalAdded = charges.fold<double>(0, (s, c) => s + c.energyAdded);

    // 📈 统计 2：总花费
    final totalCost = charges.fold<double>(0, (s, c) => s + c.cost);

    return Column(
      children: [
        // ========== 统计卡三兄弟（窄屏自动 2 个一排）==========
        AdaptiveStatRow(cards: [
          StatCard(title: '充电次数', value: '${charges.length}', unit: '次'),
          StatCard(
              title: '总充入',
              value: totalAdded.toStringAsFixed(1),
              unit: 'kWh'),
          StatCard(
              title: '总花费',
              value: totalCost.toStringAsFixed(1),
              unit: '元'),
        ]),
        const SizedBox(height: 16),

        // ========== 充电列表 ==========
        const ReportSectionTitle('充电列表'),
        if (charges.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('该日期范围内暂无充电数据',
                style: TextStyle(color: Colors.grey)),
          ),
        // 最多显示 20 条，防止列表过长
        ...charges.take(20).map((c) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor, // 走主题色，深色模式自动适配
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.bolt, color: Colors.orange),
                title: Text(c.addressText), // 充电地点
                // 副标题：时间 · 时长 · 电量从 x% 充到 y%
                subtitle: Text(
                    '${formatCnDate(c.startDate)} · ${c.durationStr} · ${c.startBatteryLevel}%→${c.endBatteryLevel}%'),
                // 右侧：充入电量
                trailing: Text('+${c.energyAdded.toStringAsFixed(1)} kWh',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )),
      ],
    );
  }
}