// ── pages/home_page.dart ──────────────────────────────────────
// Main shell: 4-tab IndexedStack + bottom nav + FAB + confetti.
// Home tab: hero card + quick stats + upcoming task list.

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/home_widget_service.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
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
  bool _loading   = true;
  int  _tab       = 0; // 0=Home 1=Tasks 2=Stats 3=Profile/Appearance

  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 800));
    _loadTodos();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────
  Future<void> _loadTodos() async {
    final saved = await StorageService.loadTodos();
    setState(() {
      _todos   = saved.isEmpty ? _seed() : saved;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await StorageService.saveTodos(_todos);
    await HomeWidgetService.updateWidgetStats(_todos);
  }

  List<Todo> _seed() => [
    Todo(id:'1', title:'Complete project report', category:'Work',
         priority: Priority.high, createdAt: DateTime.now(),
         dueDate: DateTime.now().add(const Duration(days: 1))),
    Todo(id:'2', title:'Buy groceries', category:'Shopping',
         priority: Priority.medium, createdAt: DateTime.now(),
         dueDate: DateTime.now().add(const Duration(hours: 23))),
    Todo(id:'3', title:'Read for 30 minutes', category:'Personal',
         priority: Priority.low, createdAt: DateTime.now()),
  ];

  // ── Computed ──────────────────────────────────────────────
  int get _done      => _todos.where((t) => t.isDone).length;
  int get _remaining => _todos.length - _done;
  int get _overdue   => _todos.where((t) =>
      !t.isDone && t.dueDate != null && t.dueDate!.isBefore(DateTime.now())).length;

  List<Todo> get _upcomingTasks {
    final list = _todos.where((t) => !t.isDone).toList()
      ..sort(Todo.compareTodos);
    return list.take(5).toList();
  }

  // ── CRUD ──────────────────────────────────────────────────
  void _addTodo(String title, String? note, Priority priority,
      String category, DateTime? dueDate) {
    final t = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title, note: note, priority: priority,
      category: category, dueDate: dueDate, createdAt: DateTime.now(),
    );
    setState(() => _todos.insert(0, t));
    _save();
    NotificationService.scheduleTodoNotification(t);
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
    final tp = context.read<ThemeProvider>();
    setState(() => todo.isDone = !todo.isDone);
    _save();
    if (todo.isDone && !tp.noAnim) _confetti.play();
    if (todo.isDone) {
      NotificationService.cancelNotification(todo.id);
    } else {
      NotificationService.scheduleTodoNotification(todo);
    }
  }

  void _deleteTodo(Todo todo) {
    setState(() => _todos.remove(todo));
    _save();
    NotificationService.cancelNotification(todo.id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Task deleted', style: body(size: 14, color: Colors.white)),
      backgroundColor: const Color(0xFF1C1C1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      action: SnackBarAction(
        label: 'Undo', textColor: kIndigo,
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

  // ═══════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final tp     = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? (tp.isPureBlack ? kPureBg : kDarkBg)
        : kBg;

    if (_loading) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(child: CircularProgressIndicator(color: tp.accent1)),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _tab,
            children: [
              _buildDashboard(tp, isDark),
              AllTasksPage(
                todos: _todos,
                onToggle: _toggleTodo,
                onDelete: _deleteTodo,
                onEdit: _editTodo,
                onAddTask: _openAddSheet,
              ),
              StatsPage(todos: _todos),
              SettingsPage(onBack: () => setState(() => _tab = 0)),
            ],
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.3,
              numberOfParticles: 18,
              gravity: 0.3,
              colors: const [kRed, kOrange, kGreen, kIndigo, kPink, kBlue, kYellow],
            ),
          ),
        ],
      ),

      // ── FAB ─────────────────────────────────────────────────
      floatingActionButton: (_tab == 0 || _tab == 1)
          ? Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                color: isDark ? kDarkText : kText,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _openAddSheet,
                icon: Icon(Icons.add_rounded,
                    color: isDark ? kDarkBg : kBg, size: 22),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ── Bottom Nav ───────────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(tp, isDark),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  DASHBOARD
  // ═══════════════════════════════════════════════════════════
  Widget _buildDashboard(ThemeProvider tp, bool isDark) {
    final textCol  = isDark ? kDarkText    : kText;
    final dimCol   = isDark ? kDarkTextDim : kTextDim;
    final surfaceCol = isDark
        ? (tp.isPureBlack ? kPureSurface : kDarkSurface)
        : kSurface;
    final borderCol = isDark ? kDarkBorder : kBorder;
    final accent1   = tp.accent1;
    final accent2   = tp.accent2;
    final heroCardBg = isDark
        ? (tp.isPureBlack ? kPureHeroCard : kDarkHeroCard)
        : kHeroCard;

    final total = _todos.length;
    final pct   = total == 0 ? 0.0 : _done / total;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(), style: body(size: 13, color: dimCol)),
                      const SizedBox(height: 2),
                      Text('My Tasks', style: heading(size: 32, color: textCol)),
                    ],
                  ),
                  // Avatar → Appearance tab
                  GestureDetector(
                    onTap: () => setState(() => _tab = 3),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent1, accent2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Hero Progress Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _heroCard(heroCardBg, accent1, accent2, pct, total),
            ),

            const SizedBox(height: 14),

            // ── Quick Stat Cards ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _quickCard('$_overdue', 'Overdue',   kRed,    surfaceCol, borderCol,
                      onTap: () => setState(() => _tab = 2)),
                  const SizedBox(width: 10),
                  _quickCard('$_done',    'Done',      kGreen,  surfaceCol, borderCol,
                      onTap: () => setState(() => _tab = 2)),
                  const SizedBox(width: 10),
                  _quickCard('$_remaining','Remaining', accent1, surfaceCol, borderCol,
                      onTap: () => setState(() => _tab = 1)),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── Upcoming section ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upcoming',
                      style: heading(size: 17, weight: FontWeight.w700,
                          color: textCol, letterSpacing: -0.3)),
                  GestureDetector(
                    onTap: () => setState(() => _tab = 1),
                    child: Text('See all →',
                        style: body(size: 12, weight: FontWeight.w700, color: accent1)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Task list ──
            if (_upcomingTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🎉', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 10),
                    Text('All tasks done!',
                        style: body(size: 16, weight: FontWeight.w700, color: dimCol)),
                  ]),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _upcomingTasks.length,
                itemBuilder: (_, i) {
                  final t = _upcomingTasks[i];
                  return TodoCard(
                    todo: t,
                    onToggle: () => _toggleTodo(t),
                    onTap: () => _openEditSheet(t),
                    onDelete: () => _deleteTodo(t),
                  );
                },
              ),

            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  // ── Hero Card ─────────────────────────────────────────────
  Widget _heroCard(Color bg, Color accent1, Color accent2, double pct, int total) {
    final ringC  = 188.5; // circumference for r=30
    final done   = _done;
    final remaining = _remaining;
    final pctInt = (pct * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TODAY'S PROGRESS",
                        style: body(
                          size: 11, weight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.45),
                          letterSpacing: 0.10 * 11,
                        )),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: pctInt),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => Text('$v%',
                          style: heading(size: 50, color: Colors.white, letterSpacing: -2)),
                    ),
                    const SizedBox(height: 4),
                    Text('$done of $total tasks done',
                        style: body(size: 12,
                            color: Colors.white.withValues(alpha: 0.38))),
                  ],
                ),
              ),

              // Right: circular ring
              SizedBox(
                width: 68, height: 68,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => CustomPaint(
                    painter: _RingPainter(
                      progress: v,
                      trackColor: Colors.white.withValues(alpha: 0.08),
                      accent1: accent1,
                      accent2: accent2,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$done',
                              style: heading(size: 15, color: Colors.white, letterSpacing: 0)),
                          Text('done',
                              style: body(size: 8,
                                  color: Colors.white.withValues(alpha: 0.40))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [accent1, accent2]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Stats row: Total / Done / Left
          Row(
            children: [
              _heroStat('$total', 'Total'),
              _heroDivider(),
              _heroStat('$done', 'Done'),
              _heroDivider(),
              _heroStat('$remaining', 'Left'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String val, String label) => Expanded(
        child: Column(
          children: [
            Text(val, style: heading(size: 19, color: Colors.white, letterSpacing: 0)),
            const SizedBox(height: 2),
            Text(label,
                style: body(size: 10, color: Colors.white.withValues(alpha: 0.38))),
          ],
        ),
      );

  Widget _heroDivider() => Container(
        width: 1, height: 28,
        color: Colors.white.withValues(alpha: 0.10),
      );

  // ── Quick Stat Card ───────────────────────────────────────
  Widget _quickCard(String val, String label, Color accent,
      Color surface, Color border, {required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: shadowSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 7, height: 7,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
              const SizedBox(height: 8),
              Text(val, style: heading(size: 24, color: accent, letterSpacing: 0)),
              const SizedBox(height: 1),
              Text(label, style: body(size: 10, color: kTextDim, weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────
  Widget _buildBottomNav(ThemeProvider tp, bool isDark) {
    final navBg = isDark
        ? (tp.isPureBlack ? Colors.black.withValues(alpha: 0.98) : kDarkBg.withValues(alpha: 0.95))
        : kBg.withValues(alpha: 0.94);
    final borderCol = isDark ? kDarkBorder : kBorder;

    return SafeArea(
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderCol, width: 1)),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(0, Icons.home_rounded,     'Home',    isDark, tp.accent1),
                  _navItem(1, Icons.checklist_rounded, 'Tasks',   isDark, tp.accent1),
                  _navItem(2, Icons.bar_chart_rounded, 'Stats',   isDark, tp.accent1),
                  _navItem(3, Icons.person_rounded,    'Profile', isDark, tp.accent1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label, bool isDark, Color accent) {
    final isSelected = _tab == idx;
    final activeFgCol = isDark ? kDarkBg : kBg;
    final activeBgCol = isDark ? kDarkText : kText;
    final inactiveCol = isDark ? kDarkTextDim : kTextDim;

    return GestureDetector(
      onTap: () => setState(() => _tab = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeBgCol : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 21,
                color: isSelected ? activeFgCol : inactiveCol),
            // Label slides in when selected
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: isSelected ? null : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(label,
                        style: body(size: 11, weight: FontWeight.w700,
                            color: activeFgCol)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning ☀️';
    if (h < 17) return 'Good afternoon 🌤';
    return 'Good evening 🌙';
  }
}

// ═══════════════════════════════════════════════════════════════
//  RING PAINTER  (circular progress on hero card)
// ═══════════════════════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color accent1;
  final Color accent2;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.accent1,
    required this.accent2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect, -math.pi / 2, 2 * math.pi * progress, false,
        Paint()
          ..shader = SweepGradient(
            startAngle: -math.pi / 2,
            endAngle:    3 * math.pi / 2,
            colors: [accent1, accent2],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.accent1 != accent1 || old.accent2 != accent2;
}
