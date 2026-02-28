import 'dart:ui';
import 'package:flutter/material.dart';

class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Read base color from the actual theme so it reacts to theme changes
    final baseColor = Theme.of(context).scaffoldBackgroundColor;
    
    // Get primary color to use for the glowing orbs
    final primary = Theme.of(context).primaryColor;

    return Stack(
      children: [
        // 1. Solid Base Color
        Container(color: baseColor),

        // 2. Top-Right Orb
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: isDark ? 0.35 : 0.2),
            ),
          ),
        ),

        // 3. Bottom-Left Orb
        Positioned(
          bottom: -50,
          left: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: isDark ? 0.25 : 0.15),
            ),
          ),
        ),

        // 4. Heavy Blur Layer (Frosted Glass Effect)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // 5. The actual content
        SafeArea(
          bottom: false,
          child: child,
        ),
      ],
    );
  }
}
