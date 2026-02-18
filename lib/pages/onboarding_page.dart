// ── pages/onboarding_page.dart ────────────────────────────────
// Welcome screen shown ONLY to first-time users

import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final VoidCallback onContinue;

  const OnboardingPage({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image (the purple wave pattern)
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding.png',
              fit: BoxFit.cover,
            ),
          ),

          // Safe area content (to avoid notch)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'One day, not too far from now, you\'ll be so\nglad you kept going',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Continue button
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: onContinue,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
