// ── pages/all_tasks_page.dart ─────────────────────────────────
// Shows ALL tasks with search + filter

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_edit_sheet.dart';

class AllTasksPage extends StatefulWidget {
  final List<Todo> todos;
  final Function(Todo) onToggle;
  final Function(Todo) onDelete;
  final Function(Todo todo, String title, String? note,
      Priority priority, String category, DateTime? dueDate) onEdit;

  const AllTasksPage({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery    = '';
  String _statusFilter   = 'All';
  String _categoryFilter = 'All';

  static const List<String> statuses   = ['All', 'Active', 'Done'];
  static const List<String> categories = ['All', 'Personal', 'Work', 'Shopping', 'Health', 'Study'];

  List<Todo> get _filtered {
    return widget.todos.where((t) {
      if (_statusFilter == 'Active' && t.isDone) return false;
      if (_statusFilter == 'Done' && !t.isDone) return false;
      if (_categoryFilter != 'All' && t.category != _categoryFilter) return false;
      if (_searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList()
      ..sort(Todo.compareTodos);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openEdit(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditSheet(
        todo: todo,
        onSave: (title, note, priority, category, dueDate) =>
            widget.onEdit(todo, title, note, priority, category, dueDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? kDarkText : kText;
    final dimCol = isDark ? kDarkTextDim : kTextDim;
    final surfaceCol = isDark ? kDarkSurface : kSurface;
    final borderCol = isDark ? kDarkBorder : kBorder;
    final filtered = _filtered;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Text('All Tasks', style: heading(size: 34, color: textCol)),
          ),

          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: surfaceCol,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
                boxShadow: shadowSm,
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: dimCol, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: body(size: 14, color: textCol),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: body(size: 14, color: dimCol),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fade(duration: 300.ms),

          const SizedBox(height: 12),

          // ── Status filter chips ──
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: statuses.length,
              itemBuilder: (_, i) {
                final s = statuses[i];
                final isActive = _statusFilter == s;
                return GestureDetector(
                  onTap: () => setState(() => _statusFilter = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive ? kText : surfaceCol,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isActive ? kText : borderCol),
                      boxShadow: isActive
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]
                          : shadowSm,
                    ),
                    child: Text(
                      s,
                      style: body(
                        size: 12,
                        weight: FontWeight.w600,
                        color: isActive ? Colors.white : dimCol,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── Category filter chips ──
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final c = categories[i];
                final isActive = _categoryFilter == c;
                final accent = c == 'All' ? kIndigo : categoryColor(c);
                return GestureDetector(
                  onTap: () => setState(() => _categoryFilter = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? accent : accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c,
                      style: body(
                        size: 11,
                        weight: FontWeight.w600,
                        color: isActive ? Colors.white : accent.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Task count ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 2),
            child: Text(
              '${filtered.length} task${filtered.length == 1 ? '' : 's'}',
              style: body(size: 12, weight: FontWeight.w600, color: dimCol),
            ),
          ),

          // ── Task list ──
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: dimCol.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No tasks found', style: body(size: 16, weight: FontWeight.w600, color: dimCol)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final t = filtered[i];
                      return TodoCard(
                        todo: t,
                        onToggle: () => widget.onToggle(t),
                        onTap: () => _openEdit(t),
                        onDelete: () => widget.onDelete(t),
                      ).animate().fade(delay: (i * 60).ms, duration: 300.ms).slideX(
                          begin: 0.02,
                          delay: (i * 60).ms,
                          duration: 300.ms,
                          curve: Curves.easeOutCubic);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
