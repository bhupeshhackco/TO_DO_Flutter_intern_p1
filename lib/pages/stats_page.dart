// ── pages/stats_page.dart ─────────────────────────────────────
// Shows charts and statistics about your tasks

import 'package:flutter/material.dart';
import '../models/todo.dart';

class StatsPage extends StatelessWidget {
  final List<Todo> todos;
  final bool isDark;

  const StatsPage({
    super.key,
    required this.todos,
    required this.isDark,
  });

  Color get _bg =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get _card =>
      isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get _text =>
      isDark ? Colors.white : const Color(0xFF1E293B);

  // ── Computed stats ─────────────────────────────────────────
  int get total     => todos.length;
  int get done      => todos.where((t) => t.isDone).length;
  int get remaining => total - done;
  int get overdue   => todos.where((t) =>
      t.dueDate != null &&
      t.dueDate!.isBefore(DateTime.now()) &&
      !t.isDone).length;

  double get completionRate =>
      total == 0 ? 0 : done / total;

  // Category breakdown
  Map<String, int> get categoryCount {
    final map = <String, int>{};
    for (final t in todos) {
      map[t.category] = (map[t.category] ?? 0) + 1;
    }
    return map;
  }

  // Priority breakdown
  Map<Priority, int> get priorityCount {
    final map = <Priority, int>{};
    for (final t in todos) {
      map[t.priority] = (map[t.priority] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Statistics',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
      ),
      body: total == 0
          ? _emptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Summary Cards Row ──────────────────────────
                  Row(children: [
                    _summaryCard('Total', '$total', Icons.list_alt_rounded,
                        const Color(0xFF6366F1)),
                    const SizedBox(width: 10),
                    _summaryCard('Done', '$done',
                        Icons.check_circle_rounded, const Color(0xFF10B981)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _summaryCard('Remaining', '$remaining',
                        Icons.pending_rounded, const Color(0xFFF59E0B)),
                    const SizedBox(width: 10),
                    _summaryCard('Overdue', '$overdue',
                        Icons.warning_rounded, const Color(0xFFEF4444)),
                  ]),
                  const SizedBox(height: 20),

                  // ── Completion Rate ────────────────────────────
                  _sectionTitle('Completion Rate'),
                  const SizedBox(height: 12),
                  _completionCard(),
                  const SizedBox(height: 20),

                  // ── Priority Breakdown ─────────────────────────
                  _sectionTitle('By Priority'),
                  const SizedBox(height: 12),
                  _priorityChart(),
                  const SizedBox(height: 20),

                  // ── Category Breakdown ─────────────────────────
                  _sectionTitle('By Category'),
                  const SizedBox(height: 12),
                  _categoryChart(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ── Summary card ───────────────────────────────────────────
  Widget _summaryCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _text,
                )),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Completion rate card ───────────────────────────────────
  Widget _completionCard() {
    final percent = (completionRate * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$done of $total tasks done',
                  style: TextStyle(
                      fontSize: 14,
                      color: _text,
                      fontWeight: FontWeight.w600)),
              Text('$percent%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6366F1),
                  )),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 12,
              backgroundColor: const Color(0xFFEEF2FF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Priority chart (bar chart) ─────────────────────────────
  Widget _priorityChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: Priority.values.map((p) {
          final count = priorityCount[p] ?? 0;
          final frac  = total == 0 ? 0.0 : count / total;
          final color = Color(p.colorValue);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _text)),
                    Text('$count task${count == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: frac.toDouble(),
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Category chart ─────────────────────────────────────────
  Widget _categoryChart() {
    final entries = categoryCount.entries.toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: entries.map((e) {
          final frac = total == 0 ? 0.0 : e.value / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _text)),
                    Text('${e.value} task${e.value == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: frac.toDouble(),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEF2FF),
                    valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF6366F1)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _text),
      );

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.bar_chart_rounded,
                  size: 36, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 16),
            const Text('No data yet',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Add some tasks to see your stats!',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
}
