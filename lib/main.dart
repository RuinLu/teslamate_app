import 'package:flutter/material.dart';
import 'core/storage/settings_service.dart';
import 'pages/status_page.dart';
import 'pages/reports/reports_page.dart';
import 'pages/settings_page.dart';

/// ---------------------------------------------------------
/// 🎨 【Tesla 官方配色基因】
/// ---------------------------------------------------------
const Color teslaRed = Color(0xFFE82127); // 品牌灵魂红
const Color darkBg = Color(0xFF000000);   // 深色模式：纯黑背景
const Color darkCard = Color(0xFF171717); // 深色模式：深灰卡片
const Color lightBg = Color(0xFFFFFFFF);  // 浅色模式：纯白背景
const Color lightCard = Color(0xFFF4F4F4);// 浅色模式：浅灰卡片

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeslaMate 仪表盘',
      debugShowCheckedModeBanner: false,
      // 🛡️ 文字缩放保护罩：系统字体放大（长辈模式）限制在 0.8~1.3 倍，防布局崩坏
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.8,
        maxScaleFactor: 1.3,
        child: child ?? const SizedBox.shrink(),
      ),
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system, // 跟随手机系统深浅色
      home: const MainFrame(),
    );
  }

  /// 🌞 浅色主题
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightCard,
      primaryColor: teslaRed,
      colorScheme: ColorScheme.light(
        primary: teslaRed,
        secondary: teslaRed,
        surface: lightCard,
        onSurface: Colors.black,
        onSurfaceVariant: Colors.grey.shade700,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightBg,
        selectedItemColor: Colors.black, // 选中：纯黑
        unselectedItemColor: Colors.grey.shade600, // 未选中：灰
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );
  }

  /// 🌙 深色主题
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      primaryColor: teslaRed,
      colorScheme: ColorScheme.dark(
        primary: teslaRed,
        secondary: teslaRed,
        surface: darkCard,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.grey.shade400,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBg,
        selectedItemColor: Colors.white, // 选中：纯白
        unselectedItemColor: Colors.grey.shade600, // 未选中：灰
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );
  }
}

/// ---------------------------------------------------------
/// 🏠 【主框架】(MainFrame)
/// ---------------------------------------------------------
/// 负责：底部导航、路由切换、读取全局配置并分发给子页面
/// ---------------------------------------------------------
class MainFrame extends StatefulWidget {
  const MainFrame({super.key});

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  int _currentIndex = 0;
  final SettingsService _settingsService = SettingsService();
  
  // 全局配置状态
  String _baseUrl = '';
  bool _showStatus = true;
  bool _showDrives = true;
  bool _showCharges = true;
  bool _showBattery = true;
  bool _showUpdates = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 🚀 从本地硬盘读取配置
  Future<void> _loadSettings() async {
    final s = await _settingsService.load();
    setState(() {
      _baseUrl = s.baseUrl;
      _showStatus = s.showStatus;
      _showDrives = s.showDrives;
      _showCharges = s.showCharges;
      _showBattery = s.showBattery;
      _showUpdates = s.showUpdates;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: teslaRed)),
      );
    }

    return Scaffold(
      // 🏠 页面主体（使用 IndexedStack 保持页面状态，切换 Tab 不重新加载）
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StatusPage(baseUrl: _baseUrl, enabled: _showStatus),
          ReportsPage(
            showDrives: _showDrives,
            showCharges: _showCharges,
            showBattery: _showBattery,
            showUpdates: _showUpdates,
          ),
          const SettingsPage(),
        ],
      ),
      // 🧭 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 强制均分宽度
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: '状态',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: '报表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}