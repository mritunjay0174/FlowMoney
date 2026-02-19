import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

BoxDecoration cardDecoration({
  Color color = AppColors.cardBg,
  double radius = AppSpacing.radiusLg,
  bool hasShadow = true,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: hasShadow
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ]
        : null,
  );
}

BoxDecoration primaryGradientDecoration({double radius = AppSpacing.radiusLg}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF312E81),
        Color(0xFF4F46E5),
        Color(0xFF7C3AED),
      ],
    ),
    borderRadius: BorderRadius.circular(radius),
  );
}
