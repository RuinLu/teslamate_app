// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

/// ---------------------------------------------------------
/// 🚚 【底层网络客户端】(ApiClient) —— 精简单路线版
/// ---------------------------------------------------------
/// 想象成我们雇佣的“专属快递员”。
/// 精简版只认一条固定路线（NAS 地址），代码更简单易懂。
/// （双地址容灾已按需求变更暂时移除，后续在设置页加回）
/// ---------------------------------------------------------
class ApiClient {
  /// 🏠 唯一的送货路线（NAS 的 IP + 端口）
  final String baseUrl;

  /// 🛵 快递员的交通工具（Dio 网络库）
  late Dio _dio;

  /// 快递员入职培训：告诉他唯一路线是哪条
  ApiClient({required this.baseUrl}) {
    _dio = Dio();

    // ⏱️ 耐心值：5 秒内没回应才算失败（局域网通常毫秒级，5 秒很宽松）
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 5);

    // 🏁 记住路线
    _dio.options.baseUrl = baseUrl;
  }

  /// 📦 去拿数据（GET 请求）
  /// [path] 是门牌号，例如 '/api/v1/cars'
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    print('🚀 快递员出发: 正在请求 $baseUrl$path');
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      // 💥 出车祸了，记录原因并向上汇报
      print('❌ 请求失败: ${e.type} - ${e.message}');
      rethrow;
    }
  }
}