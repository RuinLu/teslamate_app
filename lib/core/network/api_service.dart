// ignore_for_file: avoid_print

import '../../models/battery_health.dart';
import '../../models/car.dart';
import '../../models/car_status.dart';
import '../../models/charge.dart';
import '../../models/drive.dart';
import '../../models/software_update.dart';
import 'api_client.dart';

/// ---------------------------------------------------------
/// 💼 【业务大管家】(ApiService)
/// ---------------------------------------------------------
/// 负责下达业务指令，并拆解“俄罗斯套娃”JSON。
/// P4 新增：电池健康 + 更新历史 两个接口。
/// ---------------------------------------------------------
class ApiService {
  final ApiClient _client;

  ApiService(this._client);

  /// 🚗 获取所有车辆列表
  Future<List<Car>> getCars() async {
    print('💼 大管家接到任务: 获取车辆列表...');
    final response = await _client.get('/api/v1/cars');

    // 🧅 剥洋葱：data -> cars
    final Map<String, dynamic> outerMap = response.data as Map<String, dynamic>;
    final Map<String, dynamic> innerData = outerMap['data'] as Map<String, dynamic>;
    final List<dynamic> jsonList = innerData['cars'] as List<dynamic>;

    return jsonList
        .map((json) => Car.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 📡 获取指定车辆的实时状态
  Future<CarStatusResponse> getCarStatus(int carId) async {
    print('💼 大管家接到任务: 获取车辆 $carId 的实时状态...');
    final response = await _client.get('/api/v1/cars/$carId/status');
    return CarStatusResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// 🛣️ 获取行程报表列表
  Future<List<Drive>> getDrives(int carId) async {
    print('💼 大管家接到任务: 获取行程报表...');
    final response = await _client.get('/api/v1/cars/$carId/drives');

    // 🧅 剥洋葱：data -> drives（可能为 null，用 ?? [] 兜底）
    final Map<String, dynamic> outerMap = response.data as Map<String, dynamic>;
    final Map<String, dynamic> innerData = outerMap['data'] as Map<String, dynamic>;
    final List<dynamic> jsonList = (innerData['drives'] as List<dynamic>?) ?? [];

    return jsonList
        .map((json) => Drive.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 🔌 获取充电报表列表
  Future<List<Charge>> getCharges(int carId) async {
    print('💼 大管家接到任务: 获取充电报表...');
    final response = await _client.get('/api/v1/cars/$carId/charges');

    // 🧅 剥洋葱：data -> charges
    final Map<String, dynamic> outerMap = response.data as Map<String, dynamic>;
    final Map<String, dynamic> innerData = outerMap['data'] as Map<String, dynamic>;
    final List<dynamic> jsonList = (innerData['charges'] as List<dynamic>?) ?? [];

    return jsonList
        .map((json) => Charge.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 🔋 P4 新增：获取电池健康
  Future<BatteryHealth> getBatteryHealth(int carId) async {
    print('💼 大管家接到任务: 获取电池健康...');
    final response = await _client.get('/api/v1/cars/$carId/battery-health');
    return BatteryHealth.fromJson(response.data as Map<String, dynamic>);
  }

  /// 🆙 P4 新增：获取更新历史列表
  Future<List<SoftwareUpdate>> getUpdates(int carId) async {
    print('💼 大管家接到任务: 获取更新历史...');
    final response = await _client.get('/api/v1/cars/$carId/updates');

    // 🧅 剥洋葱：data -> updates
    final Map<String, dynamic> outerMap = response.data as Map<String, dynamic>;
    final Map<String, dynamic> innerData = outerMap['data'] as Map<String, dynamic>;
    final List<dynamic> jsonList = (innerData['updates'] as List<dynamic>?) ?? [];

    return jsonList
        .map((json) => SoftwareUpdate.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}