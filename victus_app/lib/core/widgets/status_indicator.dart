import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';

enum ServerStatus { running, offline, starting, stopping, error, installing, suspended }

class StatusIndicator extends StatefulWidget {
  final ServerStatus status;
  const StatusIndicator({super.key, required this.status});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIcon() {
    switch (widget.status) {
      case ServerStatus.running:
        return FadeTransition(
          opacity: _pulseAnimation,
          child: Container(
            width: 12, height: 12,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      case ServerStatus.offline:
        return Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
        );
      case ServerStatus.starting:
      case ServerStatus.stopping:
        return FadeTransition(
          opacity: _pulseAnimation,
          child: Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
            ),
          ),
        );
      case ServerStatus.error:
        return const Icon(Icons.priority_high, color: AppColors.white, size: 14);
      case ServerStatus.installing:
        return RotationTransition(
          turns: _controller,
          child: const Icon(Icons.sync, color: AppColors.white, size: 14),
        );
      case ServerStatus.suspended:
        return const Icon(Icons.remove, color: AppColors.white, size: 14);
    }
  }

  String _getStatusText() {
    switch (widget.status) {
      case ServerStatus.running: return 'Running';
      case ServerStatus.offline: return 'Offline';
      case ServerStatus.starting: return 'Starting';
      case ServerStatus.stopping: return 'Stopping';
      case ServerStatus.error: return 'Error';
      case ServerStatus.installing: return 'Installing';
      case ServerStatus.suspended: return 'Suspended';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        AppSpacing.horizontalSmall,
        Text(_getStatusText(), style: AppTypography.caption),
      ],
    );
  }
}
