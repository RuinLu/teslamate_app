// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/settings_service.dart';
import '../../core/utils/responsive.dart';
import '../../models/battery_health.dart';
import '../../models/charge.dart';
import '../../models/drive.dart';
import '../../models/software_update.dart';
import 'battery_report.dart';
import 'charges_report.dart';
import 'drives_report.dart';
import 'updates_report.dart';

/// ---------------------------------------------------------
/// 🗂️ 【报表容器页】(ReportsPage)
/// ---------------------------------------------------------
/// 职责：取数 + 日期筛选 + 把数据分发给四个子报表
/// 🌟 Tesla 风格改动：
///   SegmentedButton 选中项 = 黑底白字(浅色) / 白底黑字(深色)
///   外层加圆角容器，去掉默认边框，不显示选中图标
/// ---------------------------------------------------------
class ReportsPage extends StatefulWidget {
  // 🎚️ 模块开关，由主框架传入
  final bool showDrives;
  final bool showCharges;
  final bool showBattery;
  final bool showUpdates;

  const ReportsPage({
    super.key,
    this.showDrives = true,
    this.showCharges = true,
    this.showBattery = true,
    this.showUpdates = true,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final SettingsService _settingsService = SettingsService();

  // 📦 四个仓库的全量数据
  List<Drive> _drives = [];
  List<Charge> _charges = [];
  BatteryHealth? _batteryHealth;
  List<SoftwareUpdate> _updates = [];
  bool _isLoading = true;
  String? _error;

  /// 当前 Tab：0行程 1充电 2电池 3更新（默认选第一个开启的）
  late int _tab = widget.showDrives
      ? 0
      : widget.showCharges
          ? 1
          : widget.showBattery
              ? 2
              : 3;

  /// 📅 日期筛选范围（默认最近 7 天）
  late DateTime _startDate =
      _dayOnly(DateTime.now().subtract(const Duration(days: 6)));
  late DateTime _endDate = _dayOnly(DateTime.now());

  /// 🧹 把日期"削平"到当天 0 点，方便比较
  static DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 🚀 拉取四个仓库的全量数据
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final s = await _settingsService.load();
      final api = ApiService(ApiClient(baseUrl: s.baseUrl));
      final cars = await api.getCars();
      if (cars.isEmpty) throw Exception('没有找到车辆');
      final carId = cars.first.id;
      final drives = await api.getDrives(carId);
      final charges = await api.getCharges(carId);
      final battery = await api.getBatteryHealth(carId);
      final updates = await api.getUpdates(carId);
      if (!mounted) return;
      setState(() {
        _drives = drives;
        _charges = charges;
        _batteryHealth = battery;
        _updates = updates;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '$e';
      });
    }
  }

  // ================= 日期筛选逻辑 =================
  bool _inRange(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return false;
    final day = _dayOnly(dt);
    return !day.isBefore(_startDate) && !day.isAfter(_endDate);
  }

  List<Drive> _filteredDrives() =>
      _drives.where((d) => _inRange(d.startDate)).toList();
  List<Charge> _filteredCharges() =>
      _charges.where((c) => _inRange(c.startDate)).toList();

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: _endDate,
    );
    if (picked != null) setState(() => _startDate = _dayOnly(picked));
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = _dayOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌟 无 AppBar，SafeArea 防顶屏
      body: SafeArea(child: _buildBody()),
    );
  }

  /// 🚦 三态路由 + 模块开关
  Widget _buildBody() {
    // 四个模块全关了
    if (!widget.showDrives &&
        !widget.showCharges &&
        !widget.showBattery &&
        !widget.showUpdates) {
      return const Center(
        child: Text('没有开启任何报表模块\n请前往 设置 中开启',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey)),
      );
    }
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('😢 数据获取失败\n$_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 🌟 判断当前深浅色模式，决定 SegmentedButton 配色
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🧩 根据开关动态生成 Tab 段（固定 56 宽防换行）
    final segments = <ButtonSegment<int>>[
      if (widget.showDrives)
        const ButtonSegment(
            value: 0,
            label: SizedBox(width: 56, child: Center(child: Text('行程')))),
      if (widget.showCharges)
        const ButtonSegment(
            value: 1,
            label: SizedBox(width: 56, child: Center(child: Text('充电')))),
      if (widget.showBattery)
        const ButtonSegment(
            value: 2,
            label: SizedBox(width: 56, child: Center(child: Text('电池')))),
      if (widget.showUpdates)
        const ButtonSegment(
            value: 3,
            label: SizedBox(width: 56, child: Center(child: Text('更新')))),
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Center(
          child: ConstrainedBox(
            // 🌟 内容宽度按断点自适应
            constraints:
                BoxConstraints(maxWidth: Responsive.contentMaxWidth(context)),
            child: Column(
              children: [
                // ========== 🌟 Tesla 风格 SegmentedButton ==========
                if (segments.length > 1)
                  Container(
                    // 外层圆角容器：深灰(深色) / 浅灰(浅色)
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1C1C22)
                          : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: SegmentedButton<int>(
                      segments: segments,
                      selected: {_tab},
                      // 🌟 Tesla 风格：不显示选中图标，只靠背景色区分
                      showSelectedIcon: false,
                      onSelectionChanged: (v) =>
                          setState(() => _tab = v.first),
                      style: ButtonStyle(
                        // 选中项背景：浅色模式=黑底，深色模式=白底
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return isDark ? Colors.white : Colors.black;
                          }
                          return Colors.transparent;
                        }),
                        // 选中项文字：浅色模式=白字，深色模式=黑字
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return isDark ? Colors.black : Colors.white;
                          }
                          return Colors.grey.shade600; // 未选中=灰色
                        }),
                        // 🌟 去掉默认边框
                        side: WidgetStateProperty.all(BorderSide.none),
                        // 🌟 更大圆角
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // ========== 📅 日期选择器（行程/充电/电池 都显示）==========
                if (_tab == 0 || _tab == 1 || _tab == 2)
                  Row(
                    children: [
                      Expanded(
                          child: _dateButton(_startDate, '开始', _pickStart)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _dateButton(_endDate, '结束', _pickEnd)),
                    ],
                  ),
                if (_tab == 0 || _tab == 1 || _tab == 2)
                  const SizedBox(height: 20),

                // ========== 📤 分发数据给四个子报表 ==========
                if (_tab == 0 && widget.showDrives)
                  DrivesReport(
                      drives: _filteredDrives(),
                      startDate: _startDate,
                      endDate: _endDate),
                if (_tab == 1 && widget.showCharges)
                  ChargesReport(charges: _filteredCharges()),
                if (_tab == 2 && widget.showBattery && _batteryHealth != null)
                  BatteryReport(
                      health: _batteryHealth!,
                      drives: _drives,
                      charges: _charges,
                      startDate: _startDate,
                      endDate: _endDate),
                if (_tab == 3 && widget.showUpdates)
                  UpdatesReport(updates: _updates),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📅 日期按钮积木
  Widget _dateButton(DateTime date, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text('$label ${date.month}月${date.day}日',
                style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}