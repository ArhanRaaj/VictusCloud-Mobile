import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_spacing.dart';

enum ButtonSize { small, medium, large }

abstract class BaseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonSize size;
  final bool fullWidth;

  const BaseButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
  });

  Color get backgroundColor;
  Color get textColor;
  Color get borderColor => Colors.transparent;
  Widget? get prefixIcon => null;

  double get height {
    switch (size) {
      case ButtonSize.small: return 32;
      case ButtonSize.medium: return 48;
      case ButtonSize.large: return 56;
    }
  }

  TextStyle get textStyle {
    return AppTypography.button.copyWith(color: textColor);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDisabled = isDisabled || isLoading || onPressed == null;

    Widget button = Material(
      color: effectiveDisabled ? AppColors.surfaceVariant : backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: effectiveDisabled ? Colors.transparent : borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: effectiveDisabled ? null : () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon!,
                      AppSpacing.horizontalSmall,
                    ],
                    Text(text, style: textStyle),
                  ],
                ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class VictusPrimaryButton extends BaseButton {
  const VictusPrimaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.size,
    super.fullWidth,
  });

  @override
  Color get backgroundColor => AppColors.white;

  @override
  Color get textColor => AppColors.black;
}

class VictusSecondaryButton extends BaseButton {
  const VictusSecondaryButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.size,
    super.fullWidth,
  });

  @override
  Color get backgroundColor => Colors.transparent;

  @override
  Color get textColor => AppColors.white;

  @override
  Color get borderColor => AppColors.white;
}

class VictusTextButton extends BaseButton {
  const VictusTextButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.size,
    super.fullWidth,
  });

  @override
  Color get backgroundColor => Colors.transparent;

  @override
  Color get textColor => AppColors.white;
}

class VictusDangerButton extends BaseButton {
  const VictusDangerButton({
    super.key,
    required super.text,
    super.onPressed,
    super.isLoading,
    super.isDisabled,
    super.size,
    super.fullWidth,
  });

  @override
  Color get backgroundColor => AppColors.surface;

  @override
  Color get textColor => AppColors.white;
  
  @override
  Color get borderColor => AppColors.border;

  @override
  Widget? get prefixIcon => Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.white);
}

class VictusIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const VictusIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed == null || isLoading ? null : () {
          HapticFeedback.selectionClick();
          onPressed?.call();
        },
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  }) : isOutlined = true;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return VictusSecondaryButton(
        text: text,
        onPressed: onPressed,
        isLoading: isLoading,
      );
    }
    return VictusPrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}
