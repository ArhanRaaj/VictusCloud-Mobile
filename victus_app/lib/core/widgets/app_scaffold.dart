import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'pull_to_refresh.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final bool safeArea;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.safeArea = true,
    this.appBar,
    this.floatingActionButton,
    this.onRefresh,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (safeArea) {
      content = SafeArea(child: content);
    }

    if (onRefresh != null) {
      content = PullToRefresh(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
    );
  }
}
