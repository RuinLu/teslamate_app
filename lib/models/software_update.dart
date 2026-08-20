/// ---------------------------------------------------------
/// 🆙 【软件更新模型】(SoftwareUpdate)
/// ---------------------------------------------------------
/// 对应 GET /api/v1/cars/:CarID/updates 回显中
/// updates 数组里的每一个元素
/// ---------------------------------------------------------
class SoftwareUpdate {
  final int updateId;    // 更新记录 ID
  final String startDate; // 更新开始时间
  final String endDate;   // 更新结束时间
  final String version;   // 版本号（如 "2026.8.3.6"）

  SoftwareUpdate({
    required this.updateId,
    required this.startDate,
    required this.endDate,
    required this.version,
  });

  /// 🛠️ 拆快递：把 JSON 字典变成对象
  factory SoftwareUpdate.fromJson(Map<String, dynamic> json) {
    return SoftwareUpdate(
      updateId: (json['update_id'] as num?)?.toInt() ?? 0,
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
    );
  }
}