// ── pages/home_page.dart ──────────────────────────────────────
// Main dashboard — shows today's tasks, progress, quick actions

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/home_widget_service.dart';
import '../theme/app_theme.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_edit_sheet.dart';
import 'all_tasks_page.dart';
import 'stats_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> _todos = [];
  bool _loading     = true;
  int _currentTab   = 0;
  bool _reminderShown = false;
  late ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(milliseconds: 800));
    _loadTodos();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
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

  Future<void> _save() async {
    await StorageService.saveTodos(_todos);
    await HomeWidgetService.updateWidgetStats(_todos);
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

  List<Todo> get _todayTasks {
    final list = _todos.where((t) => !t.isDone).toList();
    list.sort(Todo.compareTodos);
    return list.take(5).toList();
  }

  // ── Reminder dialog ───────────────────────────────────────
  void _showReminder() {
    if (_reminderShown || _remainingCount == 0) return;
    _reminderShown = true;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? kDarkSurface : kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: kIndigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.notifications_active_rounded,
                  size: 32, color: kIndigo),
            ),
            const SizedBox(height: 16),
            Text('Hey, welcome back! 👋',
                style: heading(size: 18, color: isDark ? kDarkText : kText)),
            const SizedBox(height: 8),
            Text(
              'You have $_remainingCount task${_remainingCount == 1 ? '' : 's'} remaining. Let\'s crush them today!',
              style: body(size: 14, color: kTextMid),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kText,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text("Let's go! 💪",
                    style: body(size: 15, weight: FontWeight.w600, color: Colors.white)),
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
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      note: note,
      priority: priority,
      category: category,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    setState(() {
      _todos.insert(0, newTodo);
    });
    _save();
    NotificationService.scheduleTodoNotification(newTodo);
  }

  void _editTodo(Todo todo, String title, String? note,
      Priority priority, String category, DateTime? dueDate) async {
    setState(() {
      todo.title    = title;
      todo.note     = note;
      todo.priority = priority;
      todo.category = category;
      todo.dueDate  = dueDate;
    });
    _save();
    await NotificationService.cancelNotification(todo.id);
    if (!todo.isDone) {
      NotificationService.scheduleTodoNotification(todo);
    }
  }

  void _toggleTodo(Todo todo) {
    final wasNotDone = !todo.isDone;
    setState(() => todo.isDone = !todo.isDone);
    _save();
    if (todo.isDone) {
      NotificationService.cancelNotification(todo.id);
      if (wasNotDone) _confettiCtrl.play();
    } else {
      NotificationService.scheduleTodoNotification(todo);
    }
  }

  void _deleteTodo(Todo todo) {
    setState(() => _todos.remove(todo));
    _save();
    NotificationService.cancelNotification(todo.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Task deleted', style: body(size: 14, color: Colors.white)),
      backgroundColor: isDark ? kDarkSurface : kHeroCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: SnackBarAction(
        label: 'Undo',
        textColor: kIndigo,
        onPressed: () {
          setState(() => _todos.add(todo));
          _save();
          if (!todo.isDone) NotificationService.scheduleTodoNotification(todo);
        },
      ),
    ));
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditSheet(onSave: _addTodo),
    );
  }

  void _openEditSheet(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditSheet(
        todo: todo,
        onSave: (title, note, priority, category, dueDate) =>
            _editTodo(todo, title, note, priority, category, dueDate),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? kDarkBg : kPageBg,
        body: const Center(child: CircularProgressIndicator(color: kIndigo)),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? kDarkBg : kPageBg,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTab,
            children: [
              _buildDashboard(),
              AllTasksPage(
                todos: _todos,
                onToggle: _toggleTodo,
                onDelete: _deleteTodo,
                onEdit: _editTodo,
              ),
              StatsPage(todos: _todos),
            ],
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirection: math.pi / 2,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.3,
              numberOfParticles: 15,
              gravity: 0.3,
              colors: const [kRed, kOrange, kGreen, kIndigo, kPink, kBlue, kYellow],
            ),
          ),
        ],
      ),

      // ── Bottom Nav ────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(isDark),

      // ── FAB ───────────────────────────────────────────────
      floatingActionButton: _currentTab == 0
          ? Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: kText,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _openAddSheet,
                icon: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ).animate().scale(delay: 400.ms, duration: 500.ms, curve: Curves.easeOutBack)
          : null,
    );
  }

  // ═════════════════════════════════════════════════════════════
  //  DASHBOARD
  // ═════════════════════════════════════════════════════════════
  Widget _buildDashboard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? kDarkText : kText;
    final dimCol = isDark ? kDarkTextDim : kTextDim;
    final pct = _todos.isEmpty ? 0 : (_doneCount / _todos.length * 100).toInt();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _greeting(dimCol),
                      const SizedBox(height: 2),
                      Text('My Tasks', style: heading(size: 34, color: textCol)),
                    ],
                  ),
                  // Settings avatar
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsPage())),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kIndigo, kPink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 500.ms).slideY(begin: -0.05, duration: 500.ms),

            const SizedBox(height: 20),

            // ── HERO PROGRESS CARD ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: kHeroCard,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Left: progress text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "TODAY'S PROGRESS",
                                style: body(
                                  size: 11,
                                  weight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.45),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(begin: 0, end: pct),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeOutCubic,
                                builder: (_, val, __) => Text(
                                  '$val%',
                                  style: heading(size: 52, color: Colors.white, letterSpacing: -2),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_doneCount of ${_todos.length} tasks done',
                                style: body(size: 13, color: Colors.white.withValues(alpha: 0.4)),
                              ),
                            ],
                          ),
                        ),

                        // Right: circular progress
                        SizedBox(
                          width: 70, height: 70,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: _todos.isEmpty ? 0 : _doneCount / _todos.length),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, __) => CustomPaint(
                              painter: _CircularProgressPainter(
                                progress: value,
                                trackColor: Colors.white.withValues(alpha: 0.08),
                                gradientColors: [kIndigo, kPink],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$_doneCount',
                                        style: heading(size: 16, color: Colors.white)),
                                    Text('done',
                                        style: body(size: 9, color: Colors.white.withValues(alpha: 0.4))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _todos.isEmpty ? 0 : _doneCount / _todos.length),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (_, value, __) => FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: heroGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats row
                    Row(
                      children: [
                        _heroStat('${_todos.length}', 'Total'),
                        _divider(),
                        _heroStat('$_doneCount', 'Done'),
                        _divider(),
                        _heroStat('$_remainingCount', 'Left'),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: -0.08, duration: 600.ms, curve: Curves.easeOutCubic).fade(duration: 600.ms),

            const SizedBox(height: 16),

            // ── QUICK STATS ROW ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _quickStatCard('$_remainingCount', 'Pending', kRed, isDark),
                  const SizedBox(width: 10),
                  _quickStatCard('$_doneCount', 'Done', kGreen, isDark),
                  const SizedBox(width: 10),
                  _quickStatCard('${_todos.length}', 'Total', kIndigo, isDark),
                ],
              ),
            ).animate().fade(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // ── ALL DONE ──
            if (_allDone) _buildAllDoneCard(isDark),

            // ── UPCOMING TASKS ──
            if (!_allDone) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming', style: heading(size: 18, weight: FontWeight.w600, color: textCol, letterSpacing: -0.3)),
                    GestureDetector(
                      onTap: () => setState(() => _currentTab = 1),
                      child: Text('See all →', style: body(size: 13, weight: FontWeight.w600, color: kIndigo)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_todayTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kGreen.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.celebration_rounded, size: 32, color: kGreen),
                        ),
                        const SizedBox(height: 12),
                        Text('No pending tasks', style: body(size: 16, weight: FontWeight.w600, color: dimCol)),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _todayTasks.length,
                  itemBuilder: (_, i) {
                    final t = _todayTasks[i];
                    return TodoCard(
                      todo: t,
                      onToggle: () => _toggleTodo(t),
                      onTap: () => _openEditSheet(t),
                      onDelete: () => _deleteTodo(t),
                    ).animate().fade(delay: (i * 80).ms, duration: 400.ms).slideX(
                        begin: 0.03,
                        delay: (i * 80).ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic);
                  },
                ),

              // Completed section
              if (_doneCount > 0) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Completed', style: heading(size: 18, weight: FontWeight.w600, color: textCol, letterSpacing: -0.3)),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _todos.where((t) => t.isDone).length,
                  itemBuilder: (_, i) {
                    final doneTodos = _todos.where((t) => t.isDone).toList();
                    final t = doneTodos[i];
                    return TodoCard(
                      todo: t,
                      onToggle: () => _toggleTodo(t),
                      onTap: () => _openEditSheet(t),
                      onDelete: () => _deleteTodo(t),
                    ).animate().fade(delay: (i * 80).ms, duration: 400.ms);
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

  // ── Hero stat item ────────────────────────────────────────
  Widget _heroStat(String val, String label) => Expanded(
        child: Column(
          children: [
            Text(val, style: heading(size: 20, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label, style: body(size: 10, color: Colors.white.withValues(alpha: 0.4))),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withValues(alpha: 0.1),
      );

  // ── Quick stat card ───────────────────────────────────────
  Widget _quickStatCard(String val, String label, Color accent, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? kDarkSurface : kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? kDarkBorder : kBorder),
          boxShadow: shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(height: 10),
            Text(val, style: heading(size: 26, color: accent)),
            Text(label, style: body(size: 11, color: isDark ? kDarkTextDim : kTextDim)),
          ],
        ),
      ),
    );
  }

  // ── All done card ─────────────────────────────────────────
  Widget _buildAllDoneCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kGreen.withValues(alpha: 0.1), kIndigo.withValues(alpha: 0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? kDarkBorder : kBorder),
        ),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('All tasks done!', style: heading(size: 20, color: isDark ? kDarkText : kText)),
            const SizedBox(height: 6),
            Text('You\'re a productivity champion.', style: body(size: 14, color: kTextMid)),
          ],
        ),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }

  // ── Greeting ──────────────────────────────────────────────
  Widget _greeting(Color dimCol) {
    final h = DateTime.now().hour;
    String text;
    String emoji;
    if (h < 12) {
      text = 'Good morning';
      emoji = '☀️';
    } else if (h < 17) {
      text = 'Good afternoon';
      emoji = '👋';
    } else {
      text = 'Good evening';
      emoji = '🌙';
    }
    return Text('$text $emoji', style: body(size: 13, color: dimCol));
  }

  // ── Bottom Nav ────────────────────────────────────────────
  Widget _buildBottomNav(bool isDark) {
    return SafeArea(
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        decoration: BoxDecoration(
          color: (isDark ? kDarkBg : kBg).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? kDarkBorder : kBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                _navItem(1, Icons.checklist_outlined, Icons.checklist_rounded, 'Tasks'),
                _navItem(2, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Stats'),
                _navItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    final isSelected = _currentTab == index;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          return;
        }
        setState(() => _currentTab = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? kText : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? solidIcon : outlineIcon,
              color: isSelected ? Colors.white : kTextDim,
              size: 22,
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: isSelected ? null : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(label, style: body(size: 12, weight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
//  CIRCULAR PROGRESS PAINTER
// ═════════════════════════════════════════════════════════════════
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final List<Color> gradientColors;

  _CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius, trackPaint);

    // Arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final arcPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: gradientColors,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter old) =>
      old.progress != progress;
}
