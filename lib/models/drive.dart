/// ---------------------------------------------------------
/// 🛣️ 【行程数据模型】(Drive)
/// ---------------------------------------------------------
/// 字段 100% 对应真实接口 GET /api/v1/cars/:CarID/drives 的回显！
/// （2026-08-16 样本校准；2026-08-17 为详情页扩展字段）
/// ---------------------------------------------------------
class Drive {
  final int driveId;        // 行程 ID
  final String startDate;   // 出发时间
  final String endDate;     // 到达时间
  final String startAddress; // 出发地址（可能为空）
  final String endAddress;   // 到达地址

  final double distance;    // 📏 行程距离 km
  final int durationMin;    // ⏱️ 时长（分钟）
  final String durationStr; // ⏱️ 时长字符串 "00:41"

  final int speedMax;       // 🚀 最高速度
  final double speedAvg;    // 🚗 平均速度

  final double energyUsed;  // 🔋 净耗电量 kWh
  final double consumption; // ⚡ 净能耗 Wh/km

  // ========== 🌟 详情页扩展字段 ==========
  final int startBatteryLevel; // 🔋 出发时电量 %（% Start）
  final int endBatteryLevel;   // 🔋 到达时电量 %（% End）
  final double outsideTempAvg; // 🌡️ 车外平均温度
  final double insideTempAvg;  // 🌡️ 车内平均温度
  final double powerMax;       // 💪 最大功率 kW（加速峰值）
  final double powerMin;       // ♻️ 最小功率 kW（负数 = 能量回收峰值）

  Drive({
    required this.driveId,
    required this.startDate,
    required this.endDate,
    required this.startAddress,
    required this.endAddress,
    required this.distance,
    required this.durationMin,
    required this.durationStr,
    required this.speedMax,
    required this.speedAvg,
    required this.energyUsed,
    required this.consumption,
    required this.startBatteryLevel,
    required this.endBatteryLevel,
    required this.outsideTempAvg,
    required this.insideTempAvg,
    required this.powerMax,
    required this.powerMin,
  });

  /// 🛠️ 拆快递：把 JSON 字典变成 Drive 对象
  factory Drive.fromJson(Map<String, dynamic> json) {
    // 🧅 距离藏在第二层 odometer_details 里
    final odo = json['odometer_details'] as Map<String, dynamic>?;
    // 🧅 起止电量藏在第二层 battery_details 里
    final battery = json['battery_details'] as Map<String, dynamic>?;

    return Drive(
      driveId: (json['drive_id'] as num?)?.toInt() ?? 0,
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      startAddress: json['start_address']?.toString() ?? '',
      endAddress: json['end_address']?.toString() ?? '',
      distance: (odo?['odometer_distance'] as num?)?.toDouble() ?? 0,
      durationMin: (json['duration_min'] as num?)?.toInt() ?? 0,
      durationStr: json['duration_str']?.toString() ?? '',
      speedMax: (json['speed_max'] as num?)?.toInt() ?? 0,
      speedAvg: (json['speed_avg'] as num?)?.toDouble() ?? 0,
      energyUsed: (json['energy_consumed_net'] as num?)?.toDouble() ?? 0,
      consumption: (json['consumption_net'] as num?)?.toDouble() ?? 0,
      startBatteryLevel: (battery?['start_battery_level'] as num?)?.toInt() ?? 0,
      endBatteryLevel: (battery?['end_battery_level'] as num?)?.toInt() ?? 0,
      outsideTempAvg: (json['outside_temp_avg'] as num?)?.toDouble() ?? 0,
      insideTempAvg: (json['inside_temp_avg'] as num?)?.toDouble() ?? 0,
      powerMax: (json['power_max'] as num?)?.toDouble() ?? 0,
      powerMin: (json['power_min'] as num?)?.toDouble() ?? 0,
    );
  }

  // ========== 贴心小助手 ==========

  /// 🀄 出发地址美化：空地址显示“未知地点”
  String get startText => startAddress.isEmpty ? '未知地点' : startAddress;

  /// 🀄 到达地址美化
  String get endText => endAddress.isEmpty ? '未知地点' : endAddress;
}