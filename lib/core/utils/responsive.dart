import 'package:flutter/material.dart';

/// ---------------------------------------------------------
/// 📱 【屏幕适配工具】(Responsive)
/// ---------------------------------------------------------
/// 行业标准的“断点自适应”（Material 3 窗口尺寸类）：
/// - small    < 400dp  超小屏（iPhone SE、老安卓 320/360）
/// - compact  < 600dp  主流手机（375 ~ 430）
/// - medium   <= 840dp 折叠屏展开 / 小平板（673 / 768）
/// - expanded > 840dp  大平板 / 电脑网页（1024+）
///
/// 用法：页面不写死尺寸，统一来这里“按档取号”。
/// ---------------------------------------------------------
enum ScreenType { small, compact, medium, expanded }

class Responsive {
  /// 🎚️ 根据屏幕宽度判断档位
  static ScreenType screenType(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 400) return ScreenType.small;
    if (w < 600) return ScreenType.compact;
    if (w <= 840) return ScreenType.medium;
    return ScreenType.expanded;
  }

  /// 📏 是否超小屏？（触发：卡片换行、字号缩小）
  static bool isSmall(BuildContext context) =>
      screenType(context) == ScreenType.small;

  /// 📏 是否平板/大屏？（触发：内容加宽、字号放大）
  static bool isLarge(BuildContext context) {
    final t = screenType(context);
    return t == ScreenType.medium || t == ScreenType.expanded;
  }

  /// 🔢 按档位取尺寸（字号、图标大小等）
  /// [small] 超小屏值，[normal] 手机值，[large] 平板值（不传=同手机）
  static double adapt(
    BuildContext context, {
    required double small,
    required double normal,
    double? large,
  }) {
    final t = screenType(context);
    if (t == ScreenType.small) return small;
    if (t == ScreenType.medium || t == ScreenType.expanded) {
      return large ?? normal;
    }
    return normal;
  }

  /// 📐 内容最大宽度：手机 600 / 小平板 720 / 大屏 800
  /// （手机上保持现状，平板和电脑不再浪费两侧空间）
  static double contentMaxWidth(BuildContext context) {
    final t = screenType(context);
    if (t == ScreenType.medium) return 720;
    if (t == ScreenType.expanded) return 800;
    return 600;
  }
}