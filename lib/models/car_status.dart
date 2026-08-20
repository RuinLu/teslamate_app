/// ---------------------------------------------------------
/// 📡 【车辆状态模型】(CarStatusResponse)
/// ---------------------------------------------------------
/// 100% 对应 GET /api/v1/cars/:CarID/status 真实回显！
/// 结构：data -> car / status / units
/// 🌟 新增：stateSince（最后上报时间）、carName（车辆名称）
/// ---------------------------------------------------------
/// 最外层：整个响应
class CarStatusResponse {
  final String carName; // 🚗 车辆名称（data.car.car_name）
  final CarStatus status; // 状态主体
  final Units units; // 单位制

  CarStatusResponse({
    required this.carName,
    required this.status,
    required this.units,
  });

  factory CarStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? {};
    final car = (data['car'] as Map<String, dynamic>?) ?? {};
    return CarStatusResponse(
      carName: car['car_name']?.toString() ?? '',
      status: CarStatus.fromJson(
          (data['status'] as Map<String, dynamic>?) ?? {}),
      units: Units.fromJson((data['units'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

/// 状态主体（status 节点）
class CarStatus {
  final String displayName; // 显示名称
  final String state;       // 在线状态：online/asleep/offline/charging
  final String stateSince;  // 🌟 最后上报/状态变化时间
  final double odometer;    // 总里程 km

  final CarSecurity carStatus;         // 安防
  final ClimateDetails climateDetails; // 温度
  final BatteryDetails batteryDetails; // 电池
  final ChargingDetails chargingDetails; // 充电
  final TpmsDetails tpmsDetails;       // 胎压

  CarStatus({
    required this.displayName,
    required this.state,
    required this.stateSince,
    required this.odometer,
    required this.carStatus,
    required this.climateDetails,
    required this.batteryDetails,
    required this.chargingDetails,
    required this.tpmsDetails,
  });

  factory CarStatus.fromJson(Map<String, dynamic> json) {
    return CarStatus(
      displayName: json['display_name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      stateSince: json['state_since']?.toString() ?? '',
      odometer: (json['odometer'] as num?)?.toDouble() ?? 0,
      carStatus: CarSecurity.fromJson(
          (json['car_status'] as Map<String, dynamic>?) ?? {}),
      climateDetails: ClimateDetails.fromJson(
          (json['climate_details'] as Map<String, dynamic>?) ?? {}),
      batteryDetails: BatteryDetails.fromJson(
          (json['battery_details'] as Map<String, dynamic>?) ?? {}),
      chargingDetails: ChargingDetails.fromJson(
          (json['charging_details'] as Map<String, dynamic>?) ?? {}),
      tpmsDetails: TpmsDetails.fromJson(
          (json['tpms_details'] as Map<String, dynamic>?) ?? {}),
    );
  }
}

/// 🔒 安防（car_status 节点）
class CarSecurity {
  final bool healthy;   // 车辆健康
  final bool locked;    // 锁车
  final bool sentryMode; // 哨兵模式
  final bool windowsOpen; // 车窗
  final bool doorsOpen;   // 车门

  CarSecurity({
    required this.healthy,
    required this.locked,
    required this.sentryMode,
    required this.windowsOpen,
    required this.doorsOpen,
  });

  factory CarSecurity.fromJson(Map<String, dynamic> json) {
    return CarSecurity(
      healthy: json['healthy'] == true,
      locked: json['locked'] == true,
      sentryMode: json['sentry_mode'] == true,
      windowsOpen: json['windows_open'] == true,
      doorsOpen: json['doors_open'] == true,
    );
  }
}

/// 🌡️ 温度（climate_details 节点）
class ClimateDetails {
  final bool isClimateOn;   // 空调开启
  final double insideTemp;  // 车内温度
  final double outsideTemp; // 车外温度

  ClimateDetails({
    required this.isClimateOn,
    required this.insideTemp,
    required this.outsideTemp,
  });

  factory ClimateDetails.fromJson(Map<String, dynamic> json) {
    return ClimateDetails(
      isClimateOn: json['is_climate_on'] == true,
      insideTemp: (json['inside_temp'] as num?)?.toDouble() ?? 0,
      outsideTemp: (json['outside_temp'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// 🔋 电池（battery_details 节点）
class BatteryDetails {
  final double estBatteryRange;    // 预估续航
  final double ratedBatteryRange;  // 额定续航
  final double idealBatteryRange;  // 理想续航
  final int batteryLevel;          // 电量 %
  final int usableBatteryLevel;    // 可用电量 %

  BatteryDetails({
    required this.estBatteryRange,
    required this.ratedBatteryRange,
    required this.idealBatteryRange,
    required this.batteryLevel,
    required this.usableBatteryLevel,
  });

  factory BatteryDetails.fromJson(Map<String, dynamic> json) {
    return BatteryDetails(
      estBatteryRange: (json['est_battery_range'] as num?)?.toDouble() ?? 0,
      ratedBatteryRange: (json['rated_battery_range'] as num?)?.toDouble() ?? 0,
      idealBatteryRange: (json['ideal_battery_range'] as num?)?.toDouble() ?? 0,
      batteryLevel: (json['battery_level'] as num?)?.toInt() ?? 0,
      usableBatteryLevel:
          (json['usable_battery_level'] as num?)?.toInt() ?? 0,
    );
  }
}

/// ⚡ 充电（charging_details 节点）
class ChargingDetails {
  final bool pluggedIn;          // 插枪
  final String chargingState;    // 充电状态
  final double chargeEnergyAdded; // 本次充入
  final int chargeLimitSoc;      // 充电限制 %
  final double chargerPower;     // 充电功率 kW

  ChargingDetails({
    required this.pluggedIn,
    required this.chargingState,
    required this.chargeEnergyAdded,
    required this.chargeLimitSoc,
    required this.chargerPower,
  });

  factory ChargingDetails.fromJson(Map<String, dynamic> json) {
    return ChargingDetails(
      pluggedIn: json['plugged_in'] == true,
      chargingState: json['charging_state']?.toString() ?? '',
      chargeEnergyAdded:
          (json['charge_energy_added'] as num?)?.toDouble() ?? 0,
      chargeLimitSoc: (json['charge_limit_soc'] as num?)?.toInt() ?? 0,
      chargerPower: (json['charger_power'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// 🛞 胎压（tpms_details 节点）
class TpmsDetails {
  final double pressureFL; // 左前
  final double pressureFR; // 右前
  final double pressureRL; // 左后
  final double pressureRR; // 右后

  TpmsDetails({
    required this.pressureFL,
    required this.pressureFR,
    required this.pressureRL,
    required this.pressureRR,
  });

  factory TpmsDetails.fromJson(Map<String, dynamic> json) {
    return TpmsDetails(
      pressureFL: (json['tpms_pressure_fl'] as num?)?.toDouble() ?? 0,
      pressureFR: (json['tpms_pressure_fr'] as num?)?.toDouble() ?? 0,
      pressureRL: (json['tpms_pressure_rl'] as num?)?.toDouble() ?? 0,
      pressureRR: (json['tpms_pressure_rr'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// 📏 单位制（units 节点）
class Units {
  final String length;     // km / mi
  final String pressure;   // bar / psi
  final String temperature; // C / F

  Units({
    required this.length,
    required this.pressure,
    required this.temperature,
  });

  factory Units.fromJson(Map<String, dynamic> json) {
    return Units(
      length: json['unit_of_length']?.toString() ?? 'km',
      pressure: json['unit_of_pressure']?.toString() ?? 'bar',
      temperature: json['unit_of_temperature']?.toString() ?? 'C',
    );
  }
}