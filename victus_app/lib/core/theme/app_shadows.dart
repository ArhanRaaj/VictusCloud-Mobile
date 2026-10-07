import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // Pure monochrome shadows, extremely subtle
  static final List<BoxShadow> none = [];
  
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> md = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> lg = [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // Specific usage
  static List<BoxShadow> get cardShadow => none; // Cards use borders in this design system
  static List<BoxShadow> get dropdownShadow => md;
  static List<BoxShadow> get modalShadow => lg;
}
