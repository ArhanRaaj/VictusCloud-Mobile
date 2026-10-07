import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:victus_app/core/theme/app_colors.dart';

class VictusBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const VictusBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: Colors.transparent,
        backgroundColor: AppColors.background,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.textPrimary);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold);
          }
          return const TextStyle(color: AppColors.textSecondary, fontSize: 12);
        }),
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index != currentIndex) {
              HapticFeedback.selectionClick();
              onTap(index);
            }
          },
          destinations: [
            _buildDestination(Icons.home_filled, Icons.home_outlined, 'Dashboard', 0),
            _buildDestination(Icons.terminal, Icons.terminal_outlined, 'Servers', 1),
            _buildDestination(Icons.receipt, Icons.receipt_outlined, 'Billing', 2),
            _buildDestination(Icons.person, Icons.person_outline, 'Account', 3),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildDestination(IconData selectedIcon, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return NavigationDestination(
      icon: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Icon(isSelected ? selectedIcon : icon),
          if (isSelected)
            Positioned(
              top: -12,
              child: Container(
                width: 24,
                height: 2,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
