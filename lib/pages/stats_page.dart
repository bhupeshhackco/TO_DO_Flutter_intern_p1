// ── pages/stats_page.dart ─────────────────────────────────────
// Statistics screen matching HTML #s-stats exactly:
// donut card, 2×2 stat tiles, priority bars, category bars.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class StatsPage extends StatelessWidget {
  final List<Todo> todos;

  const StatsPage({super.key, required this.todos});

  int get _doneCount    => todos.where((t) => t.isDone).length;
  int get _pendingCount => todos.where((t) => !t.isDone).length;
  int get _overdueCount => todos.where((t) =>
      !t.isDone && t.dueDate != null && t.dueDate!.isBefore(DateTime.now())).length;

  @override
  Widget build(BuildContext context) {
    final tp      = context.watch<ThemeProvider>();
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? kDarkText    : kText;
    final dimCol  = isDark ? kDarkTextDim : kTextDim;
    final surfaceCol = isDark
        ? (tp.isPureBlack ? kPureSurface : kDarkSurface)
        : kSurface;
    final borderCol = isDark ? kDarkBorder : kBorder;
    final barTrack  = isDark ? (tp.isPureBlack ? const Color(0xFF1A1A1A) : const Color(0xFF2C2C2E)) : const Color(0xFFF0F0F0);
    final accent1   = tp.accent1;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Text('Statistics', style: heading(size: 32, color: textCol)),
            ),

            const SizedBox(height: 16),

            // ── Donut Card ──
            _donutCard(surfaceCol, borderCol, textCol, dimCol, barTrack, accent1),

            const SizedBox(height: 14),

            // ── Stat Tiles Grid ──
            _statGrid(surfaceCol, borderCol, textCol, dimCol, accent1),

            const SizedBox(height: 14),

            // ── By Priority ──
            _barCard('By Priority', _priorityRows(accent1), surfaceCol, borderCol, textCol, dimCol, barTrack),

            const SizedBox(height: 14),

            // ── By Category ──
            _barCard('By Category', _categoryRows(), surfaceCol, borderCol, textCol, dimCol, barTrack),
          ],
        ),
      ),
    );
  }

  // ── Donut Chart Card ──────────────────────────────────────
  Widget _donutCard(Color surface, Color border, Color textCol, Color dimCol, Color barTrack, Color accent1) {
    final pct = todos.isEmpty ? 0.0 : _doneCount / todos.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: border),
          boxShadow: shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Completion Overview',
                style: heading(size: 17, weight: FontWeight.w700, color: textCol, letterSpacing: -0.3)),
            const SizedBox(height: 2),
            Text('All time performance', style: body(size: 12, color: dimCol)),
            const SizedBox(height: 18),
            Row(
              children: [
                // Donut
                SizedBox(
                  width: 96, height: 96,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => CustomPaint(
                      painter: _DonutPainter(progress: value, trackColor: barTrack),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${(value * 100).toInt()}%',
                                style: heading(size: 20, color: textCol, letterSpacing: -0.5)),
                            Text('done', style: body(size: 9, color: dimCol)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 22),
                // Legend
                Expanded(
                  child: Column(
                    children: [
                      _legendRow('Completed', _doneCount, kGreen, todos.length, barTrack),
                      const SizedBox(height: 10),
                      _legendRow('Remaining',  _pendingCount, accent1, todos.length, barTrack),
                      const SizedBox(height: 10),
                      _legendRow('Overdue',    _overdueCount, kRed, todos.length, barTrack),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendRow(String name, int count, Color color, int total, Color barTrack) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        Container(width: 9, height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: body(size: 11, weight: FontWeight.w700, color: kTextMid)),
              const SizedBox(height: 4),
              Container(
                height: 4,
                decoration: BoxDecoration(color: barTrack, borderRadius: BorderRadius.circular(10)),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction),
                  duration: const Duration(milliseconds: 1300),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: v,
                    child: Container(
                      decoration: BoxDecoration(
                          color: color, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('$count', style: body(size: 12, weight: FontWeight.w800, color: kText)),
      ],
    );
  }

  // ── 2×2 Stat Tiles ────────────────────────────────────────
  Widget _statGrid(Color surface, Color border, Color textCol, Color dimCol, Color accent1) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(children: [
            _statTile('${todos.length}', 'Tasks added', '📋', 'Total',
                kIndigo.withValues(alpha: 0.12), kIndigo, surface, border, textCol, dimCol),
            const SizedBox(width: 10),
            _statTile('$_doneCount', 'Completed', '✅', 'Done',
                kGreen.withValues(alpha: 0.12), kGreen, surface, border, textCol, dimCol),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _statTile('$_pendingCount', 'Remaining', '⏳', 'Left',
                kOrange.withValues(alpha: 0.12), kOrange, surface, border, textCol, dimCol),
            const SizedBox(width: 10),
            _statTile('$_overdueCount', 'Overdue', '⚠️', 'Risk',
                kRed.withValues(alpha: 0.12), kRed, surface, border, textCol, dimCol),
          ]),
        ],
      ),
    );
  }

  Widget _statTile(String val, String label, String emoji, String badge,
      Color iconBg, Color accent, Color surface, Color border, Color textCol, Color dimCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border), boxShadow: shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(badge,
                      style: body(size: 9, weight: FontWeight.w800, color: accent, letterSpacing: 0.04 * 9)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(val, style: heading(size: 28, color: textCol, letterSpacing: -0.5)),
            Text(label, style: body(size: 10, color: dimCol, weight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Bar Chart Card ────────────────────────────────────────
  Widget _barCard(String title, List<_BarRow> rows,
      Color surface, Color border, Color textCol, Color dimCol, Color barTrack) {
    final maxVal = rows.fold<int>(0, (m, r) => r.count > m ? r.count : m);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface, borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border), boxShadow: shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: heading(size: 17, weight: FontWeight.w700, color: textCol, letterSpacing: -0.3)),
            const SizedBox(height: 16),
            ...rows.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.label, style: body(size: 12, weight: FontWeight.w700, color: kTextMid)),
                      Text('${r.count}', style: body(size: 11, weight: FontWeight.w700, color: textCol)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 7,
                    decoration: BoxDecoration(color: barTrack, borderRadius: BorderRadius.circular(20)),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: maxVal == 0 ? 0 : r.count / maxVal),
                      duration: const Duration(milliseconds: 1300),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: v,
                        child: Container(
                          decoration: BoxDecoration(
                              color: r.color, borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<_BarRow> _priorityRows(Color accent1) => [
    _BarRow('🔴 High',   todos.where((t) => t.priority == Priority.high).length,   kRed),
    _BarRow('🟣 Medium', todos.where((t) => t.priority == Priority.medium).length, accent1),
    _BarRow('🟢 Low',    todos.where((t) => t.priority == Priority.low).length,    kGreen),
  ];

  List<_BarRow> _categoryRows() {
    final cats = <String>{};
    for (final t in todos) cats.add(t.category);
    return cats.map((c) => _BarRow(c,
        todos.where((t) => t.category == c).length,
        categoryColor(c))).toList();
  }
}

class _BarRow {
  final String label;
  final int count;
  final Color color;
  _BarRow(this.label, this.count, this.color);
}

// ── Donut Painter ─────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  _DonutPainter({required this.progress, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11,
    );

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect, -math.pi / 2, 2 * math.pi * progress, false,
        Paint()
          ..shader = const SweepGradient(
            startAngle: -math.pi / 2,
            endAngle: 3 * math.pi / 2,
            colors: [kIndigo, kPink],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress || old.trackColor != trackColor;
}
