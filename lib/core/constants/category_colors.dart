import 'package:flutter/material.dart';
import '../../features/subscriptions/domain/subscription.dart';

/// Category color constants per Visual Design spec (06_VISUAL_DESIGN.md § 1.2)
class CategoryColors {
  // Entertainment - Ruby Red
  static const Color entertainment = Color(0xFF9A031E);

  // Utilities - Safety Orange
  static const Color utilities = Color(0xFFFB8B24);

  // Software - Persian Green
  static const Color software = Color(0xFF00A896);

  // Finance - Tyrian Purple
  static const Color finance = Color(0xFF5F0F40);

  // Gym - Mint
  static const Color gym = Color(0xFF02C39A);

  // Other - Cool Grey
  static const Color other = Color(0xFF8D99AE);

  /// Get color for a specific category
  static Color getColor(SubCategory category) {
    switch (category) {
      case SubCategory.entertainment:
        return entertainment;
      case SubCategory.utilities:
        return utilities;
      case SubCategory.software:
        return software;
      case SubCategory.finance:
        return finance;
      case SubCategory.gym:
        return gym;
      case SubCategory.other:
        return other;
    }
  }

  /// Get color with opacity for backgrounds
  static Color getColorWithOpacity(SubCategory category, double opacity) {
    return getColor(category).withValues(alpha: opacity);
  }
}
