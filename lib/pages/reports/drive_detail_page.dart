import 'package:flutter/material.dart';
import '../../models/drive.dart';
import '../../widgets/report_kit.dart';

/// ---------------------------------------------------------
/// 🛣️ 【行程详情页】(DriveDetailPage)
/// ---------------------------------------------------------
/// 点击行程列表中的某一行后进入此页。
/// 逐项展示特斯拉网页版表格的全部字段：
/// 日期 / 起终点 / 时长 / 距离 / 起止电量 / 温度 /
/// 平均&最高速度 / 最大&最小功率 / 净耗电 / 净能耗
/// ---------------------------------------------------------
class DriveDetailPage extends StatelessWidget {
  final Drive drive; // 要展示的那一趟行程

  const DriveDetailPage({super.key, required this.drive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('行程详情'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Center(
          // 限制最大宽度，宽屏上不变形
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // ========== Hero 卡片：起终点 + 时间 ==========
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 起点 → 终点（大字加粗）
                      Text(
                        '${drive.startText} → ${drive.endText}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // 出发时间 → 到达时间（灰色小字）
                      Text(
                        '${formatCnDate(drive.startDate)} → ${formatCnDate(drive.endDate)}',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ========== 详情数据网格（两列一排）==========

                // 第 1 排：距离 + 时长
                Row(children: [
                  StatCard(
                      title: '距离',
                      value: drive.distance.toStringAsFixed(1),
                      unit: 'km'),
                  const SizedBox(width: 12),
                  StatCard(title: '时长', value: drive.durationStr, unit: '时:分'),
                ]),
                const SizedBox(height: 12),

                // 第 2 排：出发电量 + 到达电量（% Start / % End）
                Row(children: [
                  StatCard(
                      title: '出发电量',
                      value: '${drive.startBatteryLevel}',
                      unit: '%'),
                  const SizedBox(width: 12),
                  StatCard(
                      title: '到达电量',
                      value: '${drive.endBatteryLevel}',
                      unit: '%'),
                ]),
                const SizedBox(height: 12),

                // 第 3 排：平均速度 + 最高速度（Ø Speed / max Speed）
                Row(children: [
                  StatCard(
                      title: '平均速度',
                      value: drive.speedAvg.toStringAsFixed(0),
                      unit: 'km/h'),
                  const SizedBox(width: 12),
                  StatCard(
                      title: '最高速度',
                      value: '${drive.speedMax}',
                      unit: 'km/h'),
                ]),
                const SizedBox(height: 12),

                // 第 4 排：最大功率 + 最小功率（max Power / 能量回收）
                Row(children: [
                  StatCard(
                      title: '最大功率',
                      value: drive.powerMax.toStringAsFixed(0),
                      unit: 'kW'),
                  const SizedBox(width: 12),
                  StatCard(
                      title: '回收功率',
                      value: drive.powerMin.toStringAsFixed(0),
                      unit: 'kW'),
                ]),
                const SizedBox(height: 12),

                // 第 5 排：车外温度 + 车内温度（Temp）
                Row(children: [
                  StatCard(
                      title: '车外均温',
                      value: drive.outsideTempAvg.toStringAsFixed(1),
                      unit: '°C'),
                  const SizedBox(width: 12),
                  StatCard(
                      title: '车内均温',
                      value: drive.insideTempAvg.toStringAsFixed(1),
                      unit: '°C'),
                ]),
                const SizedBox(height: 12),

                // 第 6 排：净耗电 + 净能耗（Energy consumed / Ø Consumption）
                Row(children: [
                  StatCard(
                      title: '净耗电',
                      value: drive.energyUsed.toStringAsFixed(2),
                      unit: 'kWh'),
                  const SizedBox(width: 12),
                  StatCard(
                      title: '净能耗',
                      value: drive.consumption.toStringAsFixed(0),
                      unit: 'Wh/km'),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}