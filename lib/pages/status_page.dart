import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_service.dart';
import '../models/car.dart';
import '../models/car_status.dart';
import '../widgets/info_card.dart';
import '../core/utils/responsive.dart';
import '../widgets/report_kit.dart'; // 🌟 引入 formatCnDate 汉化工具

/// ---------------------------------------------------------
/// 🏠 【状态页】：实时状态仪表盘
/// ---------------------------------------------------------
/// 本轮变更：
/// 1. 🚫 去掉顶部 AppBar，更沉浸（SafeArea 防顶屏）
/// 2. 🚗 顶部显示车辆名称
/// 3. 🕐 首卡显示“最后上报时间”（state_since）
/// ---------------------------------------------------------
class StatusPage extends StatefulWidget {
  /// 🏠 服务器地址，由主框架传入
  final String baseUrl;

  /// 🎚️ 模块开关：关掉时显示占位页
  final bool enabled;

  const StatusPage({
    super.key,
    required this.baseUrl,
    this.enabled = true,
  });

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  Car? _currentCar;
  CarStatusResponse? _statusResponse;
  bool _isLoading = true;
  String? _errorMessage;

  // 🏠 用主框架传来的地址创建快递员
  late final ApiService apiService = ApiService(
    ApiClient(baseUrl: widget.baseUrl),
  );

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// 🚀 拉取数据（三态：加载中/失败/成功）
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cars = await apiService.getCars();
      if (cars.isEmpty) throw Exception('没有找到车辆');
      final firstCar = cars.first;
      final status = await apiService.getCarStatus(firstCar.id);
      if (!mounted) return;
      setState(() {
        _currentCar = firstCar;
        _statusResponse = status;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '$e';
      });
    }
  }

  /// 🀄 车辆状态汉化映射
  String _stateText(String? state) {
    switch (state) {
      case 'online':
        return '在线';
      case 'asleep':
        return '休眠';
      case 'offline':
        return '离线';
      case 'charging':
        return '充电中';
      default:
        return '未知';
    }
  }

  /// 状态是否“活跃”（决定标签颜色：绿=活跃，灰=休眠）
  bool _isAlive(String? state) => state == 'online' || state == 'charging';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      // 🚫 去掉 AppBar；SafeArea 保证内容不顶到状态栏
      body: SafeArea(child: _buildBody(theme)),
    );
  }

  /// 🚦 三态路由
  Widget _buildBody(ThemeData theme) {
    // 🎚️ 模块被关掉时，显示占位页
    if (!widget.enabled) {
      return const Center(
        child: Text(
          '实时状态模块已关闭\n请前往 设置 中开启',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null || _statusResponse == null) {
      return _buildErrorView();
    }
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: _buildDashboard(theme),
    );
  }

  /// 😢 失败页
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '😢 数据获取失败\n$_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 仪表盘主体
  Widget _buildDashboard(ThemeData theme) {
    final status = _statusResponse!.status;
    final units = _statusResponse!.units;
    final tempUnit = units.temperature == 'C' ? '°C' : '°F';
    final lenUnit = units.length == 'mi' ? 'mi' : 'km';
    final alive = _isAlive(status.state);

    // 🚗 车辆名称：优先接口 car_name，兜底车辆列表的 name
    final carName = _statusResponse!.carName.isNotEmpty
        ? _statusResponse!.carName
        : (_currentCar?.name ?? '我的车辆');

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Center(
        child: ConstrainedBox(
            // 🌟 内容宽度按断点自适应（手机600 / 平板720 / 大屏800）
          constraints:
              BoxConstraints(maxWidth: Responsive.contentMaxWidth(context)),
          child: Column(
            children: [
              // ========== 🚗 车辆名称标题 ==========
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      carName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // ========== Hero 卡片：状态 + 电量 + 上报时间 ==========
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // 中文状态标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (alive ? Colors.green : Colors.grey)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _stateText(status.state),
                        style: TextStyle(
                          color: alive ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 巨大电量数字
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.battery_full,
                            size: Responsive.adapt(context,
                                small: 36, normal: 48, large: 56),
                            color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '${status.batteryDetails.batteryLevel}',
                          style: TextStyle(
                            fontSize: Responsive.adapt(context,
                                small: 48, normal: 64, large: 72),
                            fontWeight: FontWeight.w900,
                            height: 1,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                              fontSize: Responsive.adapt(context,
                                  small: 24, normal: 32, large: 36),
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${status.batteryDetails.estBatteryRange.toStringAsFixed(1)} $lenUnit 预估续航',
                      style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    // ⚡ 插枪时才显示的充电信息
                    if (status.chargingDetails.pluggedIn) ...[
                      const SizedBox(height: 8),
                      Text(
                        '⚡ 充电中 ${status.chargingDetails.chargerPower.toStringAsFixed(1)} kW',
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                    // 🌟 最后上报时间（state_since）
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '最后上报 ${formatCnDate(status.stateSince)}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ========== 温度 ==========
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      icon: Icons.thermostat,
                      title: '车内温度',
                      value:
                          '${status.climateDetails.insideTemp.toStringAsFixed(1)}$tempUnit',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoCard(
                      icon: Icons.cloud,
                      title: '车外温度',
                      value:
                          '${status.climateDetails.outsideTemp.toStringAsFixed(1)}$tempUnit',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ========== 安防 ==========
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      icon: status.carStatus.locked
                          ? Icons.lock
                          : Icons.lock_open,
                      title: '锁车状态',
                      value: status.carStatus.locked ? '已锁车' : '未锁车',
                      color: status.carStatus.locked ? Colors.blue : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoCard(
                      icon: Icons.verified_user,
                      title: '哨兵模式',
                      value: status.carStatus.sentryMode ? '开启' : '关闭',
                      color:
                          status.carStatus.sentryMode ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ========== 胎压监测大卡片 ==========
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('胎压监测',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 16),
                    Row(children: [
                      _tpmsCell('左前', status.tpmsDetails.pressureFL),
                      const SizedBox(width: 16),
                      _tpmsCell('右前', status.tpmsDetails.pressureFR),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      _tpmsCell('左后', status.tpmsDetails.pressureRL),
                      const SizedBox(width: 16),
                      _tpmsCell('右后', status.tpmsDetails.pressureRR),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🧱 【胎压小格】显示单个车轮的胎压
  /// 🌟 异常语义（全局统一）：红色只留给异常值
  ///   - 胎压 < 2.5 bar  → 红色警示 + 淡红背景 + 警告小图标
  ///   - 胎压正常       → 绿色（正常态颜色）
  ///   - 胎压 ≤ 0       → 灰色占位符（传感器未上报，避免误报红）
  Widget _tpmsCell(String label, double pressure) {
    final bool noData = pressure <= 0;          // 传感器未上报
    final bool low = !noData && pressure < 2.5; // 🌟 低胎压阈值：2.5 bar

    // 数值颜色：红 = 异常 / 绿 = 正常 / 灰 = 无数据
    final Color valueColor =
        low ? Colors.red : (noData ? Colors.grey : Colors.green);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          // 🌟 低胎压时铺一层淡红背景强化警示；正常时完全透明
          color: low ? Colors.red.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 标签行：低胎压时前面加一个红色小警告图标
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (low)
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: Colors.red),
                if (low) const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 数值行：无数据显示 '--'，有数据显示 x.x bar
            Text(
              noData ? '--' : '${pressure.toStringAsFixed(1)} bar',
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}