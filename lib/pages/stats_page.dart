// ── pages/stats_page.dart ─────────────────────────────────────
// Shows charts and statistics about your tasks

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';

class StatsPage extends StatelessWidget {
  final List<Todo> todos;

  const StatsPage({super.key, required this.todos});

  int get _doneCount    => todos.where((t) => t.isDone).length;
  int get _pendingCount => todos.where((t) => !t.isDone).length;
  int get _overdueCount => todos.where((t) =>
      !t.isDone && t.dueDate != null && t.dueDate!.isBefore(DateTime.now())).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? kDarkText : kText;
    final dimCol = isDark ? kDarkTextDim : kTextDim;
    final surfaceCol = isDark ? kDarkSurface : kSurface;
    final borderCol = isDark ? kDarkBorder : kBorder;

    if (todos.isEmpty) return _emptyState(textCol, dimCol);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text('Statistics', style: heading(size: 34, color: textCol)),
            ).animate().fade(duration: 400.ms),

            const SizedBox(height: 20),

            // ── Donut Chart Card ──
            _donutCard(surfaceCol, borderCol, textCol, dimCol),

            const SizedBox(height: 16),

            // ── Stat Tiles Grid ──
            _statTilesGrid(surfaceCol, borderCol, textCol, dimCol),

            const SizedBox(height: 16),

            // ── Priority Chart ──
            _barChartCard('By Priority', _priorityData(), surfaceCol, borderCol, textCol, dimCol),

            const SizedBox(height: 16),

            // ── Category Chart ──
            _barChartCard('By Category', _categoryData(), surfaceCol, borderCol, textCol, dimCol),
          ],
        ),
      ),
    );
  }

  // ── Donut Chart Card ──────────────────────────────────────
  Widget _donutCard(Color surface, Color border, Color textCol, Color dimCol) {
    final pct = todos.isEmpty ? 0.0 : _doneCount / todos.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: border),
          boxShadow: shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Completion', style: heading(size: 15, weight: FontWeight.w600, color: textCol, letterSpacing: -0.3)),
            Text('All time performance', style: body(size: 12, color: dimCol)),
            const SizedBox(height: 20),
            Row(
              children: [
                // Donut
                SizedBox(
                  width: 100, height: 100,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => CustomPaint(
                      painter: _DonutPainter(progress: value),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${(value * 100).toInt()}%',
                                style: heading(size: 22, color: textCol)),
                            Text('done',
                                style: body(size: 10, color: dimCol)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Legend
                Expanded(
                  child: Column(
                    children: [
                      _legendItem('Completed', _doneCount, kGreen, todos.length),
                      const SizedBox(height: 12),
                      _legendItem('Remaining', _pendingCount, kIndigo, todos.length),
                      const SizedBox(height: 12),
                      _legendItem('Overdue', _overdueCount, kRed, todos.length),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(delay: 100.ms, duration: 500.ms).slideY(begin: 0.03, duration: 500.ms);
  }

  Widget _legendItem(String name, int count, Color color, int total) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: body(size: 12, weight: FontWeight.w600, color: kTextMid)),
                  Text('$count', style: body(size: 12, weight: FontWeight.w700, color: kText)),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stat Tiles Grid ───────────────────────────────────────
  Widget _statTilesGrid(Color surface, Color border, Color textCol, Color dimCol) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(children: [
            _statTile(
              '${todos.length}', 'Total Tasks', Icons.task_alt_rounded,
              const Color(0xFFF0F0FF), kIndigo, surface, border, textCol, dimCol,
            ),
            const SizedBox(width: 12),
            _statTile(
              '$_doneCount', 'Completed', Icons.check_circle_outline_rounded,
              const Color(0xFFF0FFF6), kGreen, surface, border, textCol, dimCol,
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statTile(
              '$_pendingCount', 'Remaining', Icons.pending_actions_rounded,
              const Color(0xFFFFF8E6), kOrange, surface, border, textCol, dimCol,
            ),
            const SizedBox(width: 12),
            _statTile(
              '$_overdueCount', 'Overdue', Icons.warning_amber_rounded,
              const Color(0xFFFFF0F0), kRed, surface, border, textCol, dimCol,
            ),
          ]),
        ],
      ),
    ).animate().fade(delay: 200.ms, duration: 500.ms);
  }

  Widget _statTile(String val, String label, IconData icon,
      Color iconBg, Color accent, Color surface, Color border, Color textCol, Color dimCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
          boxShadow: shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(val, style: body(size: 11, weight: FontWeight.w700, color: accent)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(val, style: heading(size: 30, color: textCol, letterSpacing: -1)),
            Text(label, style: body(size: 11, color: dimCol)),
          ],
        ),
      ),
    );
  }

  // ── Bar Chart Card ────────────────────────────────────────
  Widget _barChartCard(String title, List<_BarData> data,
      Color surface, Color border, Color textCol, Color dimCol) {
    final maxVal = data.fold<int>(0, (m, d) => d.count > m ? d.count : m);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
          boxShadow: shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: heading(size: 15, weight: FontWeight.w600, color: textCol, letterSpacing: -0.3)),
            const SizedBox(height: 16),
            ...data.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(d.label, style: body(size: 13, weight: FontWeight.w500, color: textCol)),
                      Text('${d.count}', style: body(size: 13, weight: FontWeight.w700, color: textCol)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: maxVal == 0 ? 0 : d.count / maxVal),
                      duration: const Duration(milliseconds: 1300),
                      curve: Curves.easeInOut,
                      builder: (_, value, __) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: d.color,
                            borderRadius: BorderRadius.circular(20),
                          ),
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
    ).animate().fade(delay: 300.ms, duration: 500.ms);
  }

  List<_BarData> _priorityData() => [
    _BarData('High', todos.where((t) => t.priority == Priority.high).length, kRed),
    _BarData('Medium', todos.where((t) => t.priority == Priority.medium).length, kIndigo),
    _BarData('Low', todos.where((t) => t.priority == Priority.low).length, kGreen),
  ];

  List<_BarData> _categoryData() {
    final cats = <String>{};
    for (final t in todos) {
      cats.add(t.category);
    }
    return cats.map((c) => _BarData(
      c, todos.where((t) => t.category == c).length, categoryColor(c),
    )).toList();
  }

  Widget _emptyState(Color textCol, Color dimCol) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: dimCol.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No statistics yet', style: heading(size: 20, color: textCol)),
            const SizedBox(height: 6),
            Text('Add tasks to see your stats', style: body(size: 14, color: dimCol)),
          ],
        ),
      ),
    );
  }
}

class _BarData {
  final String label;
  final int count;
  final Color color;
  _BarData(this.label, this.count, this.color);
}

// ═════════════════════════════════════════════════════════════════
//  DONUT PAINTER
// ═════════════════════════════════════════════════════════════════
class _DonutPainter extends CustomPainter {
  final double progress;
  _DonutPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, trackPaint);

    // Arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final arcPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: [kIndigo, kPink],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}
