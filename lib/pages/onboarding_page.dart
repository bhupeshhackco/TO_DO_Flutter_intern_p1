// ── pages/onboarding_page.dart ────────────────────────────────
// Zomato / Swiggy-style multi-slide first-time user intro.
// 4 slides showcasing TaskFlow features. Animated illustrations,
// page dots, Skip + Next / Get Started buttons.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Slide data model ─────────────────────────────────────────
class _Slide {
  final String emoji;
  final Color accent;
  final Color bgGrad1;
  final Color bgGrad2;
  final String title;
  final String subtitle;
  final List<_Feature> features;

  const _Slide({
    required this.emoji,
    required this.accent,
    required this.bgGrad1,
    required this.bgGrad2,
    required this.title,
    required this.subtitle,
    required this.features,
  });
}

class _Feature {
  final String icon;
  final String text;
  const _Feature(this.icon, this.text);
}

const _slides = [
  _Slide(
    emoji: '✅',
    accent: Color(0xFF6366F1),
    bgGrad1: Color(0xFF6366F1),
    bgGrad2: Color(0xFFEC4899),
    title: 'Welcome to TaskFlow',
    subtitle: 'Your personal productivity companion — beautifully simple, incredibly powerful.',
    features: [
      _Feature('📋', 'Create tasks in seconds'),
      _Feature('🎯', 'Set priorities & categories'),
      _Feature('📅', 'Add due dates & reminders'),
    ],
  ),
  _Slide(
    emoji: '📊',
    accent: Color(0xFF00C875),
    bgGrad1: Color(0xFF00C875),
    bgGrad2: Color(0xFF0EA5E9),
    title: 'Track Your Progress',
    subtitle: 'See exactly how much you\'ve crushed today with beautiful live charts.',
    features: [
      _Feature('🍩', 'Donut completion chart'),
      _Feature('📈', 'Priority & category breakdowns'),
      _Feature('⚡', 'Real-time stats update'),
    ],
  ),
  _Slide(
    emoji: '🎨',
    accent: Color(0xFFF59E0B),
    bgGrad1: Color(0xFFF59E0B),
    bgGrad2: Color(0xFFEF4444),
    title: 'Make It Yours',
    subtitle: 'Pick your theme, accent colour, and layout to match your vibe.',
    features: [
      _Feature('🌙', 'Light, Dark & Pure Black themes'),
      _Feature('🎨', '4 accent colour palettes'),
      _Feature('⚙️', 'Compact mode & more'),
    ],
  ),
  _Slide(
    emoji: '🚀',
    accent: Color(0xFFFF4D4D),
    bgGrad1: Color(0xFFFF4D4D),
    bgGrad2: Color(0xFFFF8C00),
    title: 'Stay Motivated',
    subtitle: 'Celebrate every win — confetti fires when you tick off a task!',
    features: [
      _Feature('🎉', 'Confetti on task complete'),
      _Feature('🔔', 'Smart due-date reminders'),
      _Feature('💪', 'Streak to keep you consistent'),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════
//  WIDGET
// ═══════════════════════════════════════════════════════════════
class OnboardingPage extends StatefulWidget {
  final VoidCallback onContinue;
  const OnboardingPage({super.key, required this.onContinue});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  // Per-page animation controller
  late AnimationController _entryCtrl;
  late Animation<double>    _emojiScale;
  late Animation<Offset>    _cardSlide;
  late Animation<double>    _cardFade;

  @override
  void initState() {
    super.initState();
    _buildPageAnims();
    _entryCtrl.forward();
  }

  void _buildPageAnims() {
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));

    _emojiScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)));

    _cardSlide = Tween<Offset>(
            begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));

    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl,
            curve: const Interval(0.2, 0.9)));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goTo(int idx) {
    _pageCtrl.animateToPage(idx,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic);
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _goTo(_page + 1);
    } else {
      widget.onContinue();
    }
  }

  void _onPageChanged(int idx) {
    setState(() => _page = idx);
    _entryCtrl.reset();
    _entryCtrl.forward();
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    final size  = MediaQuery.of(context).size;
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [slide.bgGrad1, slide.bgGrad2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar: logo + Skip ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // App name
                    Text('TaskFlow',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        )),
                    // Skip (hidden on last slide)
                    if (!isLast)
                      GestureDetector(
                        onTap: widget.onContinue,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Skip',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Emoji hero ───────────────────────────────
              Expanded(
                flex: 4,
                child: Center(
                  child: ScaleTransition(
                    scale: _emojiScale,
                    child: _EmojiHero(
                      emoji: slide.emoji,
                      accent: slide.accent,
                    ),
                  ),
                ),
              ),

              // ── PageView (swipeable) ──────────────────────
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: _onPageChanged,
                  itemCount: _slides.length,
                  itemBuilder: (_, i) => SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: _SlideCard(slide: _slides[i]),
                    ),
                  ),
                ),
              ),

              // ── Page dots ────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (i) => _Dot(active: i == _page),
                  ),
                ),
              ),

              // ── Next / Get Started button ─────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: _NextButton(
                  isLast: isLast,
                  accent: slide.accent,
                  onTap: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMOJI HERO
// ═══════════════════════════════════════════════════════════════
class _EmojiHero extends StatelessWidget {
  final String emoji;
  final Color  accent;
  const _EmojiHero({required this.emoji, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        // Inner circle
        Container(
          width: 130, height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        // Emoji
        Text(emoji,
            style: const TextStyle(fontSize: 64, height: 1)),

        // Floating decorative dots
        Positioned(
          top: 10, right: 30,
          child: _FloatDot(size: 14, color: Colors.white.withValues(alpha: 0.5)),
        ),
        Positioned(
          bottom: 20, left: 24,
          child: _FloatDot(size: 10, color: Colors.white.withValues(alpha: 0.35)),
        ),
        Positioned(
          top: 30, left: 20,
          child: _FloatDot(size: 8, color: Colors.white.withValues(alpha: 0.25)),
        ),
      ],
    );
  }
}

class _FloatDot extends StatelessWidget {
  final double size;
  final Color  color;
  const _FloatDot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ═══════════════════════════════════════════════════════════════
//  SLIDE CARD
// ═══════════════════════════════════════════════════════════════
class _SlideCard extends StatelessWidget {
  final _Slide slide;
  const _SlideCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            slide.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F0F0F),
              letterSpacing: -0.6,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          // Subtitle
          Text(
            slide.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF777777),
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),

          // Feature rows
          ...slide.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: slide.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(f.icon,
                        style: const TextStyle(fontSize: 18, height: 1)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(f.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      )),
                ),
                Icon(Icons.check_circle_rounded,
                    size: 18, color: slide.accent.withValues(alpha: 0.6)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PAGE DOTS
// ═══════════════════════════════════════════════════════════════
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width:  active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? Colors.white
            : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  NEXT / GET STARTED BUTTON
// ═══════════════════════════════════════════════════════════════
class _NextButton extends StatefulWidget {
  final bool isLast;
  final Color accent;
  final VoidCallback onTap;
  const _NextButton({required this.isLast, required this.accent, required this.onTap});

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel:()  => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isLast ? 'Get Started' : 'Next',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: widget.accent,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.isLast
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_rounded,
                color: widget.accent,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
