/// ---------------------------------------------------------
/// 🔌 【充电数据模型】(Charge)
/// ---------------------------------------------------------
/// 字段 100% 对应官方源码 v1_TeslaMateAPICarsCharges.go 的结构体！
/// 接口：GET /api/v1/cars/:CarID/charges
/// P5 新增：endRatedRange（计算“满电续航衰减曲线”必需）
/// ---------------------------------------------------------
class Charge {
  final int chargeId;      // 充电记录 ID
  final String startDate;  // 开始充电时间
  final String endDate;    // 结束充电时间
  final String address;    // 充电地点

  final double energyAdded; // 🔋 充入电量 kWh
  final double energyUsed;  // 🔋 使用电量 kWh（墙端耗电）
  final double cost;        // 💰 花费

  final int durationMin;    // ⏱️ 时长（分钟）
  final String durationStr; // ⏱️ 时长字符串

  final int startBatteryLevel; // 充电前电量 %
  final int endBatteryLevel;   // 充电后电量 %

  // ========== 🌟 P5 新增字段 ==========
  /// 📏 充电结束时的“额定续航” km
  /// 用途：endRatedRange ÷ endBatteryLevel × 100 = 当次估算的满电续航
  final double endRatedRange;

  Charge({
    required this.chargeId,
    required this.startDate,
    required this.endDate,
    required this.address,
    required this.energyAdded,
    required this.energyUsed,
    required this.cost,
    required this.durationMin,
    required this.durationStr,
    required this.startBatteryLevel,
    required this.endBatteryLevel,
    required this.endRatedRange,
  });

  /// 🛠️ 拆快递：把 JSON 字典变成 Charge 对象
  factory Charge.fromJson(Map<String, dynamic> json) {
    // 🧅 充电前后的电量藏在第二层 battery_details 里
    final battery = json['battery_details'] as Map<String, dynamic>?;
    // 🧅 额定续航藏在第二层 range_rated 里
    final rated = json['range_rated'] as Map<String, dynamic>?;

    return Charge(
      chargeId: (json['charge_id'] as num?)?.toInt() ?? 0,
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      energyAdded: (json['charge_energy_added'] as num?)?.toDouble() ?? 0,
      energyUsed: (json['charge_energy_used'] as num?)?.toDouble() ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      durationMin: (json['duration_min'] as num?)?.toInt() ?? 0,
      durationStr: json['duration_str']?.toString() ?? '',
      startBatteryLevel:
          (battery?['start_battery_level'] as num?)?.toInt() ?? 0,
      endBatteryLevel: (battery?['end_battery_level'] as num?)?.toInt() ?? 0,
      endRatedRange: (rated?['end_range'] as num?)?.toDouble() ?? 0,
    );
  }

  // ========== 贴心小助手 ==========

  /// 🀄 地点美化：空地址显示“未知地点”
  String get addressText => address.isEmpty ? '未知地点' : address;

  /// 📈 充了多少格电（结束 - 开始）
  int get batteryGained => endBatteryLevel - startBatteryLevel;

  /// 🔬 本次充电估算的“满电续航” km
  /// （结束续航 ÷ 结束电量 × 100；电量太低时误差大，返回 0 表示不可信）
  double get estimatedFullRange =>
      endBatteryLevel >= 50 && endRatedRange > 0
          ? endRatedRange / endBatteryLevel * 100
          : 0;
}