/// ---------------------------------------------------------
/// 🚗 【车辆数据模型】(Car)
/// ---------------------------------------------------------
/// 对应 GET /api/v1/cars 返回的 cars 数组里的每一项。
/// 真实结构（来自 Go 源码）：
/// { "car_id": 1, "name": "比亚迪汉L",
///   "car_details": { "model": ..., "vin": ... }, ... }
/// ---------------------------------------------------------
class Car {
  final int id;        // 车辆 ID（后续所有接口都要用它当“钥匙”）
  final String name;   // 车辆昵称
  final String? model; // 车型（藏在 car_details 里）
  final String? vin;   // 车架号（藏在 car_details 里）

  Car({
    required this.id,
    required this.name,
    this.model,
    this.vin,
  });

  /// 🛠️ 拆快递：把 JSON 字典变成 Car 对象
  factory Car.fromJson(Map<String, dynamic> json) {
    // 🧅 model/vin 藏在第二层 'car_details' 里，先剥出来（可能为空，用 ? 安全读取）
    final Map<String, dynamic>? details =
        json['car_details'] as Map<String, dynamic>?;

    return Car(
      // ⚠️ 关键修复：真实字段名是 'car_id'！
      // (as num?)?.toInt() 写法在网页版和安卓版都能安全转换数字
      id: (json['car_id'] as num?)?.toInt() ?? 0,

      // 车辆昵称，服务器没传就给默认值
      name: json['name']?.toString() ?? 'Unknown Car',

      // 从第二层安全读取，读不到就是 null
      model: details?['model']?.toString(),
      vin: details?['vin']?.toString(),
    );
  }
}