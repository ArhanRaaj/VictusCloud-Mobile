import 'package:flutter/material.dart';
import 'package:victus_app/core/theme/app_colors.dart';
import 'package:victus_app/core/theme/app_typography.dart';
import 'package:victus_app/core/theme/app_animations.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? hintText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.enabled = true,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.errorText != null
        ? AppColors.error
        : (_isFocused ? AppColors.white : AppColors.border);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTypography.label),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: AppAnimations.fast,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode ?? _focusNode,
            enabled: widget.enabled,
            obscureText: _obscureText,
            style: AppTypography.body.copyWith(color: AppColors.white),
            validator: widget.validator,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hint ?? widget.hintText,
              hintStyle: AppTypography.body.copyWith(color: AppColors.grey),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
