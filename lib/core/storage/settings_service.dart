import 'package:shared_preferences/shared_preferences.dart';

/// ---------------------------------------------------------
/// 🗃️ 【App 设置模型】(AppSettings)
/// ---------------------------------------------------------
/// 把“所有设置项”装进一个对象里，方便传递和复制。
/// ---------------------------------------------------------
class AppSettings {
  /// 🏠 服务器地址（按需求变更，只保留单个地址）
  final String baseUrl;

  /// 🎚️ 五个模块开关
  final bool showStatus; // 实时状态
  final bool showDrives; // 行程报表
  final bool showCharges; // 充电报表
  final bool showBattery; // 电池健康
  final bool showUpdates; // 更新历史

  /// 默认地址（⚠️ 改成你 NAS 的地址）
  static const String defaultBaseUrl = 'http://192.168.50.252:8080';

  const AppSettings({
    this.baseUrl = defaultBaseUrl,
    this.showStatus = true,
    this.showDrives = true,
    this.showCharges = true,
    this.showBattery = true,
    this.showUpdates = true,
  });

  /// 🐑 复制并修改：只想改一个字段时，其他字段保持不变
  AppSettings copyWith({
    String? baseUrl,
    bool? showStatus,
    bool? showDrives,
    bool? showCharges,
    bool? showBattery,
    bool? showUpdates,
  }) {
    return AppSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      showStatus: showStatus ?? this.showStatus,
      showDrives: showDrives ?? this.showDrives,
      showCharges: showCharges ?? this.showCharges,
      showBattery: showBattery ?? this.showBattery,
      showUpdates: showUpdates ?? this.showUpdates,
    );
  }
}

/// ---------------------------------------------------------
/// 💾 【设置存储服务】(SettingsService)
/// ---------------------------------------------------------
/// 负责把设置“写进手机硬盘”，App 重启后依然记得。
/// ---------------------------------------------------------
class SettingsService {
  // 每个设置项在硬盘上的“抽屉名”
  static const _kBaseUrl = 'base_url';
  static const _kShowStatus = 'show_status';
  static const _kShowDrives = 'show_drives';
  static const _kShowCharges = 'show_charges';
  static const _kShowBattery = 'show_battery';
  static const _kShowUpdates = 'show_updates';

  /// 📖 读取设置（没存过就返回默认值）
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      baseUrl: prefs.getString(_kBaseUrl) ?? AppSettings.defaultBaseUrl,
      showStatus: prefs.getBool(_kShowStatus) ?? true,
      showDrives: prefs.getBool(_kShowDrives) ?? true,
      showCharges: prefs.getBool(_kShowCharges) ?? true,
      showBattery: prefs.getBool(_kShowBattery) ?? true,
      showUpdates: prefs.getBool(_kShowUpdates) ?? true,
    );
  }

  /// 💾 保存设置
  Future<void> save(AppSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, s.baseUrl);
    await prefs.setBool(_kShowStatus, s.showStatus);
    await prefs.setBool(_kShowDrives, s.showDrives);
    await prefs.setBool(_kShowCharges, s.showCharges);
    await prefs.setBool(_kShowBattery, s.showBattery);
    await prefs.setBool(_kShowUpdates, s.showUpdates);
  }
}