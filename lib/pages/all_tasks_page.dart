// ── pages/all_tasks_page.dart ─────────────────────────────────
// "All Tasks" screen matching HTML #s-tasks exactly.
// Search + status/category filters + FAB.

import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_edit_sheet.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AllTasksPage extends StatefulWidget {
  final List<Todo> todos;
  final Function(Todo) onToggle;
  final Function(Todo) onDelete;
  final Function(Todo todo, String title, String? note,
      Priority priority, String category, DateTime? dueDate) onEdit;
  final VoidCallback onAddTask;

  const AllTasksPage({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    required this.onAddTask,
  });

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery    = '';
  String _statusFilter   = 'All';
  String _categoryFilter = 'All';

  static const List<String> _statuses = ['All', 'Active', 'Done'];

  List<String> get _cats {
    final cats = widget.todos.map((t) => t.cat).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }

  List<Todo> get _filtered {
    return widget.todos.where((t) {
      if (_statusFilter == 'Active' && t.isDone)  return false;
      if (_statusFilter == 'Done'   && !t.isDone) return false;
      if (_categoryFilter != 'All'  && t.category != _categoryFilter) return false;
      if (_searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
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
    final tp     = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol   = isDark ? kDarkText    : kText;
    final dimCol    = isDark ? kDarkTextDim : kTextDim;
    final surfaceCol = isDark
        ? (tp.isPureBlack ? kPureSurface : kDarkSurface)
        : kSurface;
    final borderCol  = isDark ? kDarkBorder : kBorder;
    final accent1    = tp.accent1;
    final filtered   = _filtered;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: Text('All Tasks', style: heading(size: 32, color: textCol)),
          ),

          // ── Search ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceCol,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
                boxShadow: shadowSm,
              ),
              child: Row(
                children: [
                  Text('🔍', style: TextStyle(fontSize: 15, color: dimCol)),
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
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Status chips: All / Active / Done ──
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _statuses.length,
              itemBuilder: (_, i) {
                final s = _statuses[i];
                final on = _statusFilter == s;
                return GestureDetector(
                  onTap: () => setState(() => _statusFilter = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: on ? textCol : surfaceCol,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: on ? textCol : borderCol, width: 1.5),
                      boxShadow: on
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3))]
                          : shadowSm,
                    ),
                    child: Text(s,
                        style: body(size: 11, weight: FontWeight.w700,
                            color: on ? (isDark ? kDarkBg : kBg) : dimCol)),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── Category chips ──
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemCount: _cats.length,
              itemBuilder: (_, i) {
                final c = _cats[i];
                final isAll = c == 'All';
                final on = _categoryFilter == c;
                final color = isAll ? accent1 : categoryColor(c);
                final bg    = isAll
                    ? (on ? accent1 : accent1.withValues(alpha: 0.1))
                    : (on ? color : color.withValues(alpha: 0.1));
                return GestureDetector(
                  onTap: () => setState(() => _categoryFilter = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(c,
                        style: body(
                          size: 11, weight: FontWeight.w700,
                          color: on ? Colors.white : color.withValues(alpha: 0.8),
                        )),
                  ),
                );
              },
            ),
          ),

          // ── Task count ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 2),
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
                        Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No tasks found',
                            style: body(size: 16, weight: FontWeight.w600, color: dimCol)),
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Extension for convenience
extension on Todo {
  String get cat => category;
}
