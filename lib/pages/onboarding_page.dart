import 'package:flutter/material.dart';
import 'dart:math' as math;

class OnboardingPage extends StatefulWidget {
  final VoidCallback onContinue;

  const OnboardingPage({super.key, required this.onContinue});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideUserAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _slideUserAnimation = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0)));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Glowing Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF0FDF4), Color(0xFFF8FAFC)], // Very Light fresh theme
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          
          // Decorative programmatic circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 150,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Center(
                    child: SlideTransition(
                      position: _slideUserAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildModernHeroGraphic(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Organize Your Joy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 34,
                              height: 1.2,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Clear your mind. Sort out your life.\nTake control of your day, elegantly.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              height: 1.6,
                            ),
                          ),
                          const Spacer(),
                          
                          // Premium Button
                          GestureDetector(
                            onTap: widget.onContinue,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeroGraphic() {
    return Container(
      width: 250,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main mockup
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.check_circle, color: Color(0xFF0EA5E9)),
                ),
                const SizedBox(height: 24),
                Container(height: 12, width: 120, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 12),
                Container(height: 12, width: 80, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 32),
                
                // Demo tasks
                _mockupTask(true),
                const SizedBox(height: 12),
                _mockupTask(false),
                const SizedBox(height: 12),
                _mockupTask(false),
              ],
            ),
          ),
          
          // Floating badge 1
          Positioned(
            top: -20, right: -20,
            child: _glassBadge(Icons.star_rounded, Colors.amber),
          ),
          
          // Floating badge 2
          Positioned(
            bottom: 40, left: -25,
            child: _glassBadge(Icons.notifications_active_rounded, Colors.pinkAccent),
          ),
        ],
      ),
    );
  }

  Widget _mockupTask(bool isDone) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF10B981) : Colors.transparent,
            border: Border.all(color: isDone ? Colors.transparent : const Color(0xFFCBD5E1), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
        ),
        const SizedBox(width: 12),
        Container(
          height: 10, width: 100, 
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0), 
            borderRadius: BorderRadius.circular(5)
          )
        ),
      ],
    );
  }

  Widget _glassBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: math.pi / 12,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
