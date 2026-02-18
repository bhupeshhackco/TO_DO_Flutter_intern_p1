// ── pages/home_page.dart ──────────────────────────────────────
// Main dashboard — shows today's tasks, progress, quick actions

import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_edit_sheet.dart';
import 'all_tasks_page.dart';
import 'stats_page.dart';

class HomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todos = [];
  bool _loading     = true;
  int _currentTab   = 0;
  bool _reminderShown = false;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // ── Load from local storage ───────────────────────────────
  Future<void> _loadTodos() async {
    final saved = await StorageService.loadTodos();
    setState(() {
      _todos   = saved.isEmpty ? _seedTodos() : saved;
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showReminder();
    });
  }

  // ── Save to local storage ─────────────────────────────────
  Future<void> _save() async {
    await StorageService.saveTodos(_todos);
  }

  List<Todo> _seedTodos() {
    return [
      Todo(id: '1', title: 'Buy groceries',     category: 'Shopping',
           priority: Priority.medium, createdAt: DateTime.now(),
           dueDate: DateTime.now().add(const Duration(days: 1))),
      Todo(id: '2', title: 'Read for 30 minutes', category: 'Personal',
           priority: Priority.low,    createdAt: DateTime.now()),
      Todo(id: '3', title: 'Complete project report', category: 'Work',
           priority: Priority.high,   createdAt: DateTime.now(),
           dueDate: DateTime.now().add(const Duration(days: 2))),
    ];
  }

  // ── Computed ──────────────────────────────────────────────
  int get _doneCount      => _todos.where((t) => t.isDone).length;
  int get _remainingCount => _todos.length - _doneCount;
  bool get _allDone       =>
      _todos.isNotEmpty && _doneCount == _todos.length;

  // Today's incomplete tasks (show max 5 on dashboard)
  List<Todo> get _todayTasks => _todos
      .where((t) => !t.isDone)
      .take(5)
      .toList();

  // ── Reminder dialog ───────────────────────────────────────
  void _showReminder() {
    if (_reminderShown || _remainingCount == 0) return;
    _reminderShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.notifications_active_rounded,
                  size: 32, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 16),
            const Text('Hey, welcome back! 👋',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'You have $_remainingCount task${_remainingCount == 1 ? '' : 's'} remaining. Let\'s crush them today!',
              style: const TextStyle(
                  fontSize: 14, color: Colors.grey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Let's go! 💪",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CRUD ──────────────────────────────────────────────────
  void _addTodo(String title, String? note, Priority priority,
      String category, DateTime? dueDate) {
    setState(() {
      _todos.insert(
        0,
        Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          note: note,
          priority: priority,
          category: category,
          dueDate: dueDate,
          createdAt: DateTime.now(),
        ),
      );
    });
    _save();
  }

  void _editTodo(Todo todo, String title, String? note,
      Priority priority, String category, DateTime? dueDate) {
    setState(() {
      todo.title    = title;
      todo.note     = note;
      todo.priority = priority;
      todo.category = category;
      todo.dueDate  = dueDate;
    });
    _save();
  }

  void _toggleTodo(Todo todo) {
    setState(() => todo.isDone = !todo.isDone);
    _save();
  }

  void _deleteTodo(Todo todo) {
    setState(() => _todos.remove(todo));
    _save();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Task deleted'),
      backgroundColor:
          widget.isDark ? const Color(0xFF1E293B) : const Color(0xFF1E293B),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: SnackBarAction(
        label: 'Undo',
        textColor: const Color(0xFF6366F1),
        onPressed: () {
          setState(() => _todos.add(todo));
          _save();
        },
      ),
    ));
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditSheet(
        isDark: widget.isDark,
        onSave: _addTodo,
      ),
    );
  }

  void _openEditSheet(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditSheet(
        todo: todo,
        isDark: widget.isDark,
        onSave: (title, note, priority, category, dueDate) =>
            _editTodo(todo, title, note, priority, category, dueDate),
      ),
    );
  }

  // ── Colors ────────────────────────────────────────────────
  Color get _bg =>
      widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get _text =>
      widget.isDark ? Colors.white : const Color(0xFF1E293B);

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF6366F1),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildDashboard(),
          AllTasksPage(
            todos: _todos,
            isDark: widget.isDark,
            onToggle: _toggleTodo,
            onDelete: _deleteTodo,
            onEdit: _editTodo,
          ),
          StatsPage(todos: _todos, isDark: widget.isDark),
        ],
      ),

      // ── Bottom Nav ───────────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        backgroundColor:
            widget.isDark ? const Color(0xFF1E293B) : Colors.white,
        indicatorColor: const Color(0xFFEEF2FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded,
                color: Color(0xFF6366F1)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded,
                color: Color(0xFF6366F1)),
            label: 'All Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded,
                color: Color(0xFF6366F1)),
            label: 'Stats',
          ),
        ],
      ),

      // ── FAB (only on home) ────────────────────────────────
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
              onPressed: _openAddSheet,
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }

  // ── Dashboard screen ──────────────────────────────────────
  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HERO HEADER ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              )),
                          const SizedBox(height: 2),
                          const Text('My Tasks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),

                      // Dark mode toggle
                      GestureDetector(
                        onTap: () async {
                          widget.onToggleTheme();
                          await StorageService.saveDarkMode(!widget.isDark);
                        },
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.isDark
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round,
                            color: Colors.white, size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stat chips
                  Row(children: [
                    _statChip('${_todos.length}', 'Total',
                        Colors.white.withValues(alpha: 0.2), Colors.white),
                    const SizedBox(width: 10),
                    _statChip('$_doneCount', 'Done',
                        const Color(0xFF10B981).withValues(alpha: 0.25),
                        const Color(0xFF34D399)),
                    const SizedBox(width: 10),
                    _statChip('$_remainingCount', 'Left',
                        const Color(0xFFF59E0B).withValues(alpha: 0.25),
                        const Color(0xFFFBBF24)),
                  ]),
                  const SizedBox(height: 16),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: _todos.isEmpty
                          ? 0
                          : _doneCount / _todos.length,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF34D399)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(_todos.isEmpty ? 0 : (_doneCount / _todos.length * 100)).toInt()}% complete',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── ALL DONE celebration ────────────────────────
            if (_allDone) _buildAllDoneCard(),

            // ── UPCOMING TASKS ──────────────────────────────
            if (!_allDone) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _text,
                        )),
                    GestureDetector(
                      onTap: () => setState(() => _currentTab = 1),
                      child: const Text('See all',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_todayTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'No pending tasks 🎉',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade400),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _todayTasks.length,
                  itemBuilder: (_, i) {
                    final t = _todayTasks[i];
                    return TodoCard(
                      todo: t,
                      isDark: widget.isDark,
                      onToggle: () => _toggleTodo(t),
                      onTap: () => _openEditSheet(t),
                      onDelete: () => _deleteTodo(t),
                    );
                  },
                ),

              // ── COMPLETED SECTION ─────────────────────────
              if (_doneCount > 0) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Completed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      )),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount:
                      _todos.where((t) => t.isDone).length,
                  itemBuilder: (_, i) {
                    final doneTodos =
                        _todos.where((t) => t.isDone).toList();
                    final t = doneTodos[i];
                    return TodoCard(
                      todo: t,
                      isDark: widget.isDark,
                      onToggle: () => _toggleTodo(t),
                      onTap: () => _openEditSheet(t),
                      onDelete: () => _deleteTodo(t),
                    );
                  },
                ),
              ],
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── All done celebration card ─────────────────────────────
  Widget _buildAllDoneCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(children: [
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text('All tasks done!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '"The most effective\nway to do it,\nis to do it."',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Text('— Amelia Earhart',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  for (var t in _todos) {
                    t.isDone = false;
                  }
                });
                _save();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Let's go 🚀",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Helper widgets ────────────────────────────────────────
  Widget _statChip(
      String val, String label, Color bg, Color fg) =>
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(val,
              style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: fg.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ]),
      );

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 🌙';
  }
}
