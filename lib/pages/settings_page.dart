import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_service.dart';
import '../core/storage/settings_service.dart';

/// ---------------------------------------------------------
/// ⚙️ 【设置页】：模块开关 + 服务器地址（持久化）
/// ---------------------------------------------------------
/// 🎨 本页配色（Tesla 官方风格 · 无红版）：
/// - 开关“开” = 高亮蓝（特斯拉 App 激活态蓝）
/// - 开关“关” = 中性灰
/// - 主按钮 = 浅色系黑底白字 / 深色系白底黑字（单色风）
/// - 红色全局只留给“异常值”，本页不使用
/// ---------------------------------------------------------
class SettingsPage extends StatefulWidget {
  /// 📢 设置保存后通知主框架刷新（状态页/报表页跟着变）
  final VoidCallback? onSettingsChanged;

  const SettingsPage({super.key, this.onSettingsChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService();
  AppSettings _settings = const AppSettings();
  bool _loaded = false;
  bool _testing = false;

  /// 地址输入框的“遥控器”
  late final TextEditingController _urlController;

  // 🎨 特斯拉 App 式高亮蓝：仅用于开关“开启”态
  static const Color _kActiveBlue = Color(0xFF3E6EF5);

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose(); // 页面销毁时回收遥控器，防止内存泄漏
    super.dispose();
  }

  /// 📖 从硬盘读取设置
  Future<void> _loadSettings() async {
    final s = await _settingsService.load();
    if (!mounted) return;
    _urlController.text = s.baseUrl; // 把地址填进输入框
    setState(() {
      _settings = s;
      _loaded = true;
    });
  }

  /// 💾 通用更新方法：改设置 -> 存硬盘 -> 通知主框架
  Future<void> _update(AppSettings newSettings) async {
    setState(() => _settings = newSettings);
    await _settingsService.save(newSettings);
    widget.onSettingsChanged?.call();
  }

  /// 🧪 测试连接：用输入框里的地址临时派一个快递员去试试
  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _snack('❌ 地址不能为空');
      return;
    }
    setState(() => _testing = true);
    try {
      final api = ApiService(ApiClient(baseUrl: url));
      final cars = await api.getCars();
      _snack('✅ 连接成功！发现 ${cars.length} 辆车');
    } catch (e) {
      _snack('❌ 连接失败，请检查地址');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  /// 💾 保存服务器地址
  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _snack('❌ 地址不能为空');
      return;
    }
    await _update(_settings.copyWith(baseUrl: url));
    _snack('✅ 服务器地址已保存');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 小标题积木
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌗 读取当前深浅色，决定单色按钮用黑还是白
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 🚫 无 AppBar（此前已去除），SafeArea 防内容顶到状态栏
      body: SafeArea(
        child: !_loaded
            ? const Center(
                child: CircularProgressIndicator(color: Colors.grey),
              )
            : SwitchTheme(
                // 🎨 全页开关统一配色（现代非弃用 API，一处生效）
                data: SwitchThemeData(
                  // 滑块：开 = 高亮蓝；关 = 浅灰(浅)/深灰(深)
                  thumbColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _kActiveBlue;
                    }
                    return isDark ? Colors.grey.shade400 : Colors.grey.shade50;
                  }),
                  // 轨道：开 = 半透明蓝；关 = 中性灰
                  trackColor:
                      WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _kActiveBlue.withValues(alpha: 0.35);
                    }
                    return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
                  }),
                ),
                child: ListView(
                  children: [
                    // ========== 模块开关区 ==========
                    _sectionTitle('模块开关'),
                    SwitchListTile(
                      secondary: const Icon(Icons.speed),
                      title: const Text('实时状态'),
                      value: _settings.showStatus,
                      onChanged: (v) =>
                          _update(_settings.copyWith(showStatus: v)),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.route),
                      title: const Text('行程报表'),
                      value: _settings.showDrives,
                      onChanged: (v) =>
                          _update(_settings.copyWith(showDrives: v)),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.bolt),
                      title: const Text('充电报表'),
                      value: _settings.showCharges,
                      onChanged: (v) =>
                          _update(_settings.copyWith(showCharges: v)),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.battery_std),
                      title: const Text('电池健康'),
                      value: _settings.showBattery,
                      onChanged: (v) =>
                          _update(_settings.copyWith(showBattery: v)),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.system_update),
                      title: const Text('更新历史'),
                      value: _settings.showUpdates,
                      onChanged: (v) =>
                          _update(_settings.copyWith(showUpdates: v)),
                    ),
                    const Divider(height: 32),

                    // ========== 服务器设置区 ==========
                    _sectionTitle('服务器设置'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      // 🎨 局部覆盖主题主色为单色，
                      //    输入框聚焦边框/光标/标签不再吃全局红色主题
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme:
                              Theme.of(context).colorScheme.copyWith(
                                    primary:
                                        isDark ? Colors.white : Colors.black,
                                  ),
                        ),
                        child: TextField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: '服务器地址',
                            hintText: 'http://192.168.x.x:8080',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _saveUrl,
                              icon: const Icon(Icons.save),
                              label: const Text('保存地址'),
                              // 🎨 特斯拉单色主按钮：浅=黑底白字 / 深=白底黑字
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    isDark ? Colors.white : Colors.black,
                                foregroundColor:
                                    isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _testing ? null : _testConnection,
                              icon: _testing
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey),
                                    )
                                  : const Icon(Icons.network_check),
                              label: const Text('测试连接'),
                              // 🎨 中性灰描边按钮，不吃全局红色主题
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                                side: BorderSide(
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade400),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),

                    // ========== 其他 ==========
                    const ListTile(
                      leading: Icon(Icons.straighten),
                      title: Text('单位制'),
                      subtitle: Text('跟随服务器设置（公制 km/°C）'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('关于'),
                      subtitle: Text('TeslaMate 仪表盘 v1.0.0 · P2'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}