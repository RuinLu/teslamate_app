import 'package:fl_chart/fl_chart.dart'; // 📊 图表库
import 'package:flutter/material.dart';
import '../../models/drive.dart';
import '../../widgets/report_kit.dart';
import 'drive_detail_page.dart'; // 🌟 详情页（点击行程跳转用）

/// ---------------------------------------------------------
/// 🛣️ 【行程报表】(DrivesReport)
/// ---------------------------------------------------------
/// 纯渲染组件：自己不取数据，由容器页把"筛选后"的数据传进来。
/// 内容：统计卡 + 每日能耗柱状图 + 行程列表（可点击进详情）
/// 🌟 列表默认只显示 5 条，点击"展开全部"看其余
/// 🌟 Tesla 风格：展开按钮使用中性灰色，不使用主题强调色
/// ---------------------------------------------------------
class DrivesReport extends StatefulWidget {
  final List<Drive> drives; // 筛选后的行程数据
  final DateTime startDate; // 选择的开始日（图表按天归类用）
  final DateTime endDate;   // 选择的结束日

  const DrivesReport({
    super.key,
    required this.drives,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<DrivesReport> createState() => _DrivesReportState();
}

class _DrivesReportState extends State<DrivesReport> {
  /// 🌟 默认收起：列表只显示 5 条
  bool _expanded = false;

  /// 📊 把区间内"每一天"的能耗归类求和
  /// 返回：key = "8/16" 标签，value = 当天能耗 kWh
  List<MapEntry<String, double>> _dailyEnergy() {
    final totalDays = widget.endDate.difference(widget.startDate).inDays + 1;
    return List.generate(totalDays, (i) {
      final day = widget.startDate.add(Duration(days: i));
      double sum = 0;
      for (final d in widget.drives) {
        final dt = DateTime.tryParse(d.startDate);
        // 出发日 == 当前统计日，就累加
        if (dt != null && DateTime(dt.year, dt.month, dt.day) == day) {
          sum += d.energyUsed;
        }
      }
      return MapEntry('${day.month}/${day.day}', sum);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drives = widget.drives; // 起个短别名，下面写起来清爽

    // 📈 统计 1：区间总里程（fold = 累加器）
    final totalKm = drives.fold<double>(0, (s, d) => s + d.distance);
    // 📈 统计 2：平均能耗 = 总耗电 ÷ 总里程 × 1000（按里程加权）
    final totalEnergy = drives.fold<double>(0, (s, d) => s + d.energyUsed);
    final avgConsumption = totalKm > 0 ? totalEnergy / totalKm * 1000 : 0.0;

    // 🌟 列表显示条数：收起 = 5 条，展开 = 全部
    final visibleDrives = _expanded ? drives : drives.take(5).toList();

    return Column(
      children: [
        // ========== 统计卡三兄弟（窄屏自动 2 个一排）==========
        AdaptiveStatRow(cards: [
          StatCard(
              title: '区间里程',
              value: totalKm.toStringAsFixed(0),
              unit: 'km'),
          StatCard(
              title: '平均能耗',
              value: avgConsumption.toStringAsFixed(0),
              unit: 'Wh/km'),
          StatCard(title: '行程次数', value: '${drives.length}', unit: '次'),
        ]),
        const SizedBox(height: 16),

        // ========== 每日能耗柱状图 ==========
        _chartCard(theme),
        const SizedBox(height: 16),

        // ========== 行程列表（可点击进详情）==========
        const ReportSectionTitle('行程列表'),
        if (drives.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('该日期范围内暂无行程数据',
                style: TextStyle(color: Colors.grey)),
          ),

        // 🌟 收起显示 5 条，展开显示全部
        ...visibleDrives.map((d) => InkWell(
              // 点击这趟行程 -> 跳转详情页
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriveDetailPage(drive: d),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16), // 水波纹裁剪成圆角
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor, // 走主题色，深色模式自动适配
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.route, color: Colors.green),
                  title: Text('${d.startText} → ${d.endText}'),
                  subtitle: Text(
                      '${formatCnDate(d.startDate)} · ${d.durationStr} · ${d.consumption.toStringAsFixed(0)} Wh/km'),
                  trailing: Text('${d.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            )),

        // ========== 🌟 Tesla 风格展开/收起按钮 ==========
        // 设计要点：
        // 1. 不用 TextButton（会使用主题强调色），改用 InkWell + Container
        // 2. 圆角灰色背景，文字和图标使用中性灰色
        // 3. 整体更扁平、更中性，符合 Tesla 官方风格
        if (drives.length > 5)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                // 🌟 使用主题表面色，深色模式自动适配
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    // 🌟 使用中性灰色，不使用主题强调色
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _expanded ? '收起' : '展开全部 ${drives.length} 条行程',
                    style: TextStyle(
                      fontSize: 14,
                      // 🌟 使用中性灰色，不使用主题强调色
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 📊 每日能耗柱状图卡片（数值标签 + 点击气泡）
  Widget _chartCard(ThemeData theme) {
    final days = _dailyEnergy();
    // Y 轴上限 = 最大值 * 1.3，留出头部空间放数值标签
    final maxVal = days.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maxY = maxVal * 1.3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('每日能耗 (kWh)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround, // 柱子均匀分布
                maxY: maxY > 0 ? maxY : 10, // 全 0 时兜底，防崩
                barGroups: [
                  for (var i = 0; i < days.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: days[i].value, // 柱高 = 当天能耗
                          color: Colors.green,
                          width: days.length > 14 ? 8 : 14, // 天数多时柱变细
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                ],
                // 坐标轴：只保留底部"数值+日期"标签，其余全隐藏（极简风）
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32, // 给两行标签预留 32px 高度，防溢出
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink(); // 越界保护
                        }
                        // 超过 10 天时只显示偶数位标签，防拥挤
                        if (days.length > 10 && idx.isOdd) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 🔢 数值（绿色加粗小字）
                              Text(
                                days[idx].value.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                              // 📅 日期（灰色小字）
                              Text(
                                days[idx].key,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false), // 不要边框
                gridData: const FlGridData(show: false), // 不要网格线
                // 💬 点击柱子弹出气泡，显示精确数值
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${days[group.x].key}  ${rod.toY.toStringAsFixed(2)} kWh',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}