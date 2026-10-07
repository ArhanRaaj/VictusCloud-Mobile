import 'package:flutter/services.dart';

class Haptics {
  Haptics._();

  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }
  static Future<void> light() => lightTap();

  static Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }
  static Future<void> medium() => mediumTap();

  static Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }
  static Future<void> heavy() => heavyTap();

  static Future<void> selectionTap() async {
    await HapticFeedback.selectionClick();
  }
  static Future<void> selection() => selectionTap();

  static Future<void> successTap() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  static Future<void> errorTap() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}
