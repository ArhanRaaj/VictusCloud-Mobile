import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';

class PullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.black,
      backgroundColor: AppColors.white,
      strokeWidth: 2.5,
      child: child,
    );
  }
}
