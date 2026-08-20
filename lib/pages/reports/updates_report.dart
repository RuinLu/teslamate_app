import 'package:flutter/material.dart';
import '../../models/software_update.dart';
import '../../widgets/report_kit.dart';

/// ---------------------------------------------------------
/// 🆙 【更新历史报表】(UpdatesReport)
/// ---------------------------------------------------------
/// 纯渲染组件：容器页把更新列表传进来。
/// 内容：版本更新记录列表（版本号 + 安装日期）
/// ---------------------------------------------------------
class UpdatesReport extends StatelessWidget {
  final List<SoftwareUpdate> updates; // 更新记录列表

  const UpdatesReport({super.key, required this.updates});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ========== 列表标题 ==========
        ReportSectionTitle('更新历史（共 ${updates.length} 次）'),

        // 空数据提示
        if (updates.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('暂无更新记录', style: TextStyle(color: Colors.grey)),
          ),

        // ========== 更新记录列表 ==========
        ...updates.map((u) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor, // 走主题色，深色模式自动适配
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                // 左侧：系统更新图标
                leading: const Icon(Icons.system_update, color: Colors.blue),
                // 标题：版本号（大字加粗更醒目）
                title: Text(
                  u.version,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // 副标题：安装日期
                subtitle: Text('安装于 ${formatCnDate(u.endDate)}'),
                // 右侧：小标签“已安装”
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '已安装',
                    style: TextStyle(color: Colors.green, fontSize: 11),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}