/// ---------------------------------------------------------
/// 🔋 【电池健康模型】(BatteryHealth)
/// ---------------------------------------------------------
/// 100% 对应 GET /api/v1/cars/:CarID/battery-health 回显！
/// 结构：data -> battery_health -> {...}
/// 🌟 修复：健康度封顶 100（估算波动不允许超过物理上限）
/// ---------------------------------------------------------
class BatteryHealth {
  final double maxRange;        // 📏 历史最大续航 km（电池最健康时）
  final double currentRange;    // 📏 当前满电预估续航 km
  final double ratedEfficiency; // ⚡ 额定能效（kWh/100km）
  final double healthPercentage; // 🏥 官方健康度（你的车返回 0，不可用）

  BatteryHealth({
    required this.maxRange,
    required this.currentRange,
    required this.ratedEfficiency,
    required this.healthPercentage,
  });

  /// 🧮 计算健康度 = 当前续航 ÷ 最大续航 × 100
  /// 🌟 封顶 100：当前估算可能因标定/温度暂时超过历史最大，
  ///    但物理上健康度不可能超过 100，超出部分属于估算噪声
  double get computedHealth => maxRange > 0
      ? (currentRange / maxRange * 100).clamp(0.0, 100.0).toDouble()
      : 0;

  /// 📉 已衰减续航（km）；负数 = 当前比历史最大还高（估算波动）
  double get rangeLoss => maxRange - currentRange;

  /// 🌟 是否有明显衰减？（>0.05km 才算，UI 用它决定文案）
  bool get hasLoss => rangeLoss > 0.05;

  /// 🛠️ 拆快递：从最外层 JSON 一路剥到 battery_health
  factory BatteryHealth.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final bh = (data['battery_health'] as Map<String, dynamic>?) ?? {};

    return BatteryHealth(
      maxRange: (bh['max_range'] as num?)?.toDouble() ?? 0,
      currentRange: (bh['current_range'] as num?)?.toDouble() ?? 0,
      ratedEfficiency: (bh['rated_efficiency'] as num?)?.toDouble() ?? 0,
      healthPercentage:
          (bh['battery_health_percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}