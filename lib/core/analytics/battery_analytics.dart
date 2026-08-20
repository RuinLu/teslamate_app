import '../../models/battery_health.dart';
import '../../models/charge.dart';
import '../../models/drive.dart';

/// ---------------------------------------------------------
/// 🔬 【电池分析引擎】(BatteryAnalytics)
/// ---------------------------------------------------------
/// 纯数学计算，不碰任何 UI。
/// 新增 ⑥：估算电池循环次数（查重通过，全 App 无重复）
/// ---------------------------------------------------------
class BatteryAnalytics {
  /// ① 衰减曲线：月份 -> 该月平均“估算满电续航” km
  final List<MapEntry<String, double>> degradationTrend;

  /// ② 充电效率 %
  final double chargingEfficiency;

  /// ② 平均充电功率 kW
  final double avgChargePower;

  /// ③ 每日静置损耗 %/天
  final double vampireDrainPerDay;

  /// ④ 温度分档 -> 平均能耗 Wh/km
  final List<MapEntry<String, double>> tempConsumption;

  /// ⑤ 充到 ≥90% 的次数占比 %
  final double highChargeRatio;

  /// ⑤ 放到 ≤20% 的次数占比 %
  final double deepDischargeRatio;

  /// ⑥ 估算电池容量 kWh（最大续航 × 额定能效 ÷ 100）
  final double estimatedCapacity;

  /// ⑥ 估算电池循环次数（累计充入 ÷ 估算容量）
  final double estimatedCycles;

  const BatteryAnalytics({
    required this.degradationTrend,
    required this.chargingEfficiency,
    required this.avgChargePower,
    required this.vampireDrainPerDay,
    required this.tempConsumption,
    required this.highChargeRatio,
    required this.deepDischargeRatio,
    required this.estimatedCapacity,
    required this.estimatedCycles,
  });

  /// 🀄 根据充电习惯生成中文建议
  String get habitAdvice {
    final tips = <String>[];
    if (highChargeRatio > 30) {
      tips.add('充到 90% 以上的比例偏高，日常建议充至 80~90%');
    }
    if (deepDischargeRatio > 20) {
      tips.add('用到 20% 以下的比例偏高，尽量浅放浅充');
    }
    if (tips.isEmpty) return '充电习惯良好，继续保持！';
    return '${tips.join('；')}。';
  }

  /// 🧮 总入口：一次性算出全部指标
  factory BatteryAnalytics.compute(
    List<Drive> drives,
    List<Charge> charges,
    BatteryHealth health, // 🌟 新增：算循环次数需要续航和能效
  ) {
    // ========== ① 衰减曲线（按月份归类求平均）==========
    final sortedCharges = List<Charge>.from(charges)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final monthMap = <String, List<double>>{};
    for (final c in sortedCharges) {
      final est = c.estimatedFullRange;
      if (est <= 0) continue;
      final dt = DateTime.tryParse(c.startDate);
      if (dt == null) continue;
      monthMap.putIfAbsent('${dt.year}-${dt.month}', () => []).add(est);
    }
    final degradationTrend = monthMap.entries
        .map((e) => MapEntry(
            '${e.key.split('-')[1]}月',
            e.value.reduce((a, b) => a + b) / e.value.length))
        .toList();

    // ========== ② 充电效率 + 平均充电功率 ==========
    double added = 0;
    double used = 0;
    double hours = 0;
    double addedForPower = 0; // 🌟 只累加“有时长”记录的充入量
    for (final c in charges) {
      if (c.energyUsed > 0) {
        added += c.energyAdded;
        used += c.energyUsed;
      }
      if (c.durationMin > 0) {
        hours += c.durationMin / 60;
        addedForPower += c.energyAdded;
      }
    }
    final chargingEfficiency =
        used > 0 ? (added / used * 100).clamp(0.0, 100.0).toDouble() : 0.0;
    // 🌟 平均功率只统计有时长的记录，避免缺时长数据导致功率虚高
    final avgChargePower = hours > 0 ? addedForPower / hours : 0.0;

    // ========== ⑥ 估算循环次数（复用②的累计充入 added）==========
    // 估算容量 = 最大续航 km × 额定能效 kWh/100km ÷ 100
    final estimatedCapacity = health.maxRange * health.ratedEfficiency / 100;
    final estimatedCycles =
        estimatedCapacity > 0 ? added / estimatedCapacity : 0.0;

    // ========== ③ 每日静置损耗 ==========
    final sortedDrives = List<Drive>.from(drives)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final rates = <double>[];
    for (var i = 1; i < sortedDrives.length; i++) {
      final prev = sortedDrives[i - 1];
      final next = sortedDrives[i];
      final prevEnd = DateTime.tryParse(prev.endDate);
      final nextStart = DateTime.tryParse(next.startDate);
      if (prevEnd == null || nextStart == null) continue;

      final gapHours = nextStart.difference(prevEnd).inMinutes / 60;
      if (gapHours < 6) continue;

      final diff = prev.endBatteryLevel - next.startBatteryLevel;
      if (diff > 0) rates.add(diff / (gapHours / 24));
    }
    final vampireDrainPerDay =
        rates.isEmpty ? 0.0 : rates.reduce((a, b) => a + b) / rates.length;

    // ========== ④ 温度与能耗（4 个温度档）==========
    final buckets = <String, List<double>>{
      '≤5°C': [],
      '5~15°C': [],
      '15~25°C': [],
      '≥25°C': [],
    };
    for (final d in drives) {
      if (d.consumption <= 0 || d.distance < 1) continue;
      final t = d.outsideTempAvg;
      if (t <= 5) {
        buckets['≤5°C']!.add(d.consumption);
      } else if (t <= 15) {
        buckets['5~15°C']!.add(d.consumption);
      } else if (t <= 25) {
        buckets['15~25°C']!.add(d.consumption);
      } else {
        buckets['≥25°C']!.add(d.consumption);
      }
    }
    final tempConsumption = buckets.entries
        .map((e) => MapEntry(
            e.key,
            e.value.isEmpty
                ? 0.0
                : e.value.reduce((a, b) => a + b) / e.value.length))
        .toList();

    // ========== ⑤ 充电习惯诊断 ==========
    final highCount = charges.where((c) => c.endBatteryLevel >= 90).length;
    final lowCount = drives.where((d) => d.startBatteryLevel <= 20).length;
    final highChargeRatio =
        charges.isEmpty ? 0.0 : highCount / charges.length * 100;
    final deepDischargeRatio =
        drives.isEmpty ? 0.0 : lowCount / drives.length * 100;

    return BatteryAnalytics(
      degradationTrend: degradationTrend,
      chargingEfficiency: chargingEfficiency,
      avgChargePower: avgChargePower,
      vampireDrainPerDay: vampireDrainPerDay,
      tempConsumption: tempConsumption,
      highChargeRatio: highChargeRatio,
      deepDischargeRatio: deepDischargeRatio,
      estimatedCapacity: estimatedCapacity,
      estimatedCycles: estimatedCycles,
    );
  }
}