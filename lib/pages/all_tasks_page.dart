// ── pages/all_tasks_page.dart ─────────────────────────────────
// Shows ALL tasks with search + filter

import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_edit_sheet.dart';

class AllTasksPage extends StatefulWidget {
  final List<Todo> todos;
  final bool isDark;
  final Function(Todo) onToggle;
  final Function(Todo) onDelete;
  final Function(
    Todo,
    String, String?, Priority, String, DateTime?
  ) onEdit;

  const AllTasksPage({
    super.key,
    required this.todos,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  String _search     = '';
  String _filter     = 'All';   // All / Active / Done
  String _category   = 'All';

  final _searchCtrl = TextEditingController();

  static const _filters    = ['All', 'Active', 'Done'];
  static const _categories = ['All', 'Personal', 'Work', 'Shopping', 'Health', 'Study'];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Color get _bg   => widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get _text => widget.isDark ? Colors.white : const Color(0xFF1E293B);

  List<Todo> get _filtered {
    return widget.todos.where((t) {
      final matchSearch   = _search.isEmpty ||
          t.title.toLowerCase().contains(_search.toLowerCase());
      final matchFilter   = _filter == 'All'
          ? true
          : _filter == 'Active' ? !t.isDone : t.isDone;
      final matchCategory = _category == 'All' || t.category == _category;
      return matchSearch && matchFilter && matchCategory;
    }).toList();
  }

  void _openEdit(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditSheet(
        todo: todo,
        isDark: widget.isDark,
        onSave: (title, note, priority, category, dueDate) {
          widget.onEdit(todo, title, note, priority, category, dueDate);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('All Tasks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
      ),
      body: Column(children: [

        // ── Search bar ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isDark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: widget.isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(color: _text),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Colors.grey, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // ── Status filter chips ──────────────────────────────
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            children: _filters.map((f) {
              final sel = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF6366F1)
                        : widget.isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(f,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Colors.grey,
                      )),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Category filter chips ────────────────────────────
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            children: _categories.map((cat) {
              final sel = _category == cat;
              return GestureDetector(
                onTap: () => setState(() => _category = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFFEEF2FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF6366F1)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel
                            ? const Color(0xFF6366F1)
                            : Colors.grey,
                      )),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Task count ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child: Row(children: [
            Text(
              '${list.length} task${list.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),

        // ── List ─────────────────────────────────────────────
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('No tasks found',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _text)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final t = list[i];
                    return TodoCard(
                      todo: t,
                      isDark: widget.isDark,
                      onToggle: () {
                        widget.onToggle(t);
                        setState(() {});
                      },
                      onTap: () => _openEdit(t),
                      onDelete: () {
                        widget.onDelete(t);
                        setState(() {});
                      },
                    );
                  },
                ),
        ),
      ]),
    );
  }
}
