import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/analytics/battery_analytics.dart';
import '../../models/battery_health.dart';
import '../../models/charge.dart';
import '../../models/drive.dart';
import '../../widgets/report_kit.dart';

/// ---------------------------------------------------------
/// 🔋 【电池报表】P5 深度分析版（日期筛选版）
/// ---------------------------------------------------------
/// 本轮变更：支持日期范围筛选。
/// 统计类指标全部按 [startDate, endDate] 过滤后计算；
/// 健康度大卡是“当前快照”，保持全局不受日期影响。
/// ---------------------------------------------------------
class BatteryReport extends StatelessWidget {
  final BatteryHealth health; // 官方电池健康快照
  final List<Drive> drives;   // 全量行程
  final List<Charge> charges; // 全量充电

  /// 📅 可选日期范围（不传就默认最近 7 天，保证单独使用也不崩）
  final DateTime? startDate;
  final DateTime? endDate;

  const BatteryReport({
    super.key,
    required this.health,
    required this.drives,
    required this.charges,
    this.startDate,
    this.endDate,
  });

  /// 🎨 健康度颜色：>=90 绿，>=80 橙，否则红
  Color _healthColor(double v) {
    if (v >= 90) return Colors.green;
    if (v >= 80) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 📅 确定有效日期范围（没传就用默认最近 7 天）
    final end = endDate ?? DateTime.now();
    final start = startDate ?? end.subtract(const Duration(days: 6));

    // 🔍 按日期过滤行程和充电（统计指标只用范围内的数据）
    bool inRange(String iso) {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return false;
      final day = DateTime(dt.year, dt.month, dt.day);
      return !day.isBefore(start) && !day.isAfter(end);
    }

    final fDrives = drives.where((d) => inRange(d.startDate)).toList();
    final fCharges = charges.where((c) => inRange(c.startDate)).toList();

    // 🧮 用“过滤后”的数据计算指标
    final a = BatteryAnalytics.compute(fDrives, fCharges, health);

    // 优先官方值，官方为 0 时用计算值（健康度是全局快照）
    final percent = health.healthPercentage > 0
        ? health.healthPercentage
        : health.computedHealth;
    final color = _healthColor(percent);

    return Column(
      children: [
        // ========== 0. 健康度 Hero 卡片（全局快照）==========
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.battery_std, size: 40, color: color),
                  const SizedBox(width: 8),
                  Text(
                    percent.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      color: color,
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                        fontSize: 28,
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('电池健康度',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 4),
              const Text('＝ 当前满电续航 ÷ 历史最大续航 × 100%',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percent / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  color: color,
                  backgroundColor: Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                health.hasLoss
                    ? '当前满电续航 ${health.currentRange.toStringAsFixed(1)} km · 已衰减 ${health.rangeLoss.toStringAsFixed(1)} km'
                    : '当前满电续航 ${health.currentRange.toStringAsFixed(1)} km · 无明显衰减',
                style: TextStyle(
                    fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ========== ① 满电续航衰减曲线（范围内）==========
        _trendCard(theme, a),
        const SizedBox(height: 16),

        // ========== ② 充电效率 + 静置损耗（窄屏自动换行）==========
        AdaptiveStatRow(cards: [
          StatCard(
            title: '充电效率',
            value: a.chargingEfficiency.toStringAsFixed(1),
            unit: '%',
            inlineUnit: true,
            note: '＝ 充入 ÷ 墙端耗电 × 100%',
          ),
          StatCard(
            title: '每日静置损耗',
            value: a.vampireDrainPerDay.toStringAsFixed(2),
            unit: '%/天',
            inlineUnit: true,
            note: '停放≥6h 掉电 ÷ 停放天数',
          ),
        ]),
        const SizedBox(height: 12),

        // ========== ② 平均充电功率 + ⑥ 电池循环次数（窄屏自动换行）==========
        AdaptiveStatRow(cards: [
          StatCard(
            title: '平均充电功率',
            value: a.avgChargePower.toStringAsFixed(1),
            unit: 'kW',
            inlineUnit: true,
            note: '＝ 总充入 ÷ 总充电时长',
          ),
          StatCard(
            title: '电池循环次数',
            value: a.estimatedCycles.toStringAsFixed(1),
            unit: '次',
            inlineUnit: true,
            note:
                '＝ 累计充入 ÷ 估算容量${a.estimatedCapacity.toStringAsFixed(0)}kWh',
          ),
        ]),
        const SizedBox(height: 16),

        // ========== ④ 温度与能耗柱状图 ==========
        _tempChartCard(theme, a),
        const SizedBox(height: 16),

        // ========== ⑤ 充电习惯诊断卡 ==========
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('充电习惯诊断',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('依据 充到≥90% 与 深放≤20% 两类比例生成建议',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 12),
              Text(
                '充到≥90%：${a.highChargeRatio.toStringAsFixed(0)}%  ｜  深放≤20%：${a.deepDischargeRatio.toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                '💡 ${a.habitAdvice}',
                style: const TextStyle(fontSize: 13, color: Colors.orange),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 📉  衰减曲线卡片（折线图）
  Widget _trendCard(ThemeData theme, BatteryAnalytics a) {
    final trend = a.degradationTrend;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('满电续航趋势',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('每次充电：结束续航 ÷ 结束电量 × 100，按月取平均',
              style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 16),
          if (trend.length < 2)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('数据积累中…\n多充几次电就能解锁衰减曲线',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            )
          else
            SizedBox(
              height: 160,
              child: _buildLineChart(trend),
            ),
        ],
      ),
    );
  }

  /// 📉 折线图本体
  Widget _buildLineChart(List<MapEntry<String, double>> trend) {
    final values = trend.map((e) => e.value);
    final minY = values.reduce((a, b) => a < b ? a : b) - 5;
    final maxY = values.reduce((a, b) => a > b ? a : b) + 5;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (trend.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 18,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= trend.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(trend[idx].key,
                      style: const TextStyle(fontSize: 9, color: Colors.grey)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < trend.length; i++)
                FlSpot(i.toDouble(), trend[i].value),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.15),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots
                  .map((s) => LineTooltipItem(
                        '${trend[s.x.toInt()].key}  ${s.y.toStringAsFixed(1)} km',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      ))
                  .toList();
            },
          ),
        ),
      ),
    );
  }

  /// 🌡️ ④ 温度与能耗柱状图卡片
  Widget _tempChartCard(ThemeData theme, BatteryAnalytics a) {
    final buckets = a.tempConsumption;
    final maxVal = buckets.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = maxVal * 1.3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('温度与能耗 (Wh/km)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('按车外温度分档，取同档行程的平均能耗',
              style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY : 10,
                barGroups: [
                  for (var i = 0; i < buckets.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: buckets[i].value,
                          color: Colors.green,
                          width: 24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= buckets.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                buckets[idx].value.toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                buckets[idx].key,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}