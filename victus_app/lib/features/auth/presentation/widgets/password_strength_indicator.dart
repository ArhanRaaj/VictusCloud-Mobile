import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = Validators.passwordStrength(password);
    int activeBars = 0;
    
    if (password.isNotEmpty) {
      switch (strength) {
        case PasswordStrength.weak: activeBars = 1; break;
        case PasswordStrength.fair: activeBars = 2; break;
        case PasswordStrength.good: activeBars = 3; break;
        case PasswordStrength.strong: activeBars = 4; break;
      }
    }

    return Row(
      children: List.generate(4, (index) {
        final isActive = index < activeBars;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
