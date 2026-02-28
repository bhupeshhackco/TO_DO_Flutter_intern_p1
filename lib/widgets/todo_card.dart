// ── widgets/todo_card.dart ────────────────────────────────────
// Task card matching the HTML .task-item design exactly.
// IMPORTANT: Only the checkbox toggles done state.
//            Tapping the card body opens the edit sheet.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'task_checkbox.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  final VoidCallback onToggle;  // checkbox tap only
  final VoidCallback onTap;     // card body tap → edit
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool _isPressed = false;

  Color get _chkColor {
    switch (widget.todo.category) {
      case 'Work':     return kRed;
      case 'Shopping': return kIndigo;
      case 'Personal': return kGreen;
      case 'Health':   return kBlue;
      case 'Study':    return kOrange;
      default:         return kIndigo;
    }
  }

  bool get _isOverdue =>
      widget.todo.dueDate != null &&
      widget.todo.dueDate!.isBefore(DateTime.now()) &&
      !widget.todo.isDone;

  String _timeLabel() {
    if (widget.todo.dueDate == null) return '';
    if (widget.todo.isDone) return '';
    final diff = widget.todo.dueDate!.difference(DateTime.now());
    if (diff.isNegative) return 'Overdue';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return '< 1m';
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceCol = isDark
        ? (tp.isPureBlack ? kPureSurface : kDarkSurface)
        : kSurface;
    final borderCol = isDark ? kDarkBorder : kBorder;
    final textCol   = isDark ? kDarkText   : kText;
    final dimCol    = isDark ? kDarkTextDim : kTextDim;

    final todo = widget.todo;
    final compact = tp.compact;
    final timeLabel = _timeLabel();

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: kRed,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            const SizedBox(height: 2),
            Text('Delete', style: body(size: 11, weight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
      child: GestureDetector(
        // ── Card body tap → edit (NOT toggle) ──
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_)   => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedOpacity(
          opacity: todo.isDone ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: _isPressed ? 0.985 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(bottom: compact ? 6 : 10),
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: compact ? 10 : 14,
              ),
              decoration: BoxDecoration(
                color: surfaceCol,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isOverdue
                      ? kRed.withValues(alpha: 0.4)
                      : borderCol,
                  width: 1,
                ),
                boxShadow: shadowSm,
              ),
              child: Row(
                children: [
                  // ── Checkbox (tap = toggle) ──
                  // GestureDetector wraps only checkbox to intercept before card
                  GestureDetector(
                    onTap: widget.onToggle,
                    behavior: HitTestBehavior.opaque,
                    child: TaskCheckbox(
                      isChecked: todo.isDone,
                      accentColor: _chkColor,
                      onTap: widget.onToggle,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Content ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task title
                        Text(
                          todo.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body(
                            size: compact ? 13 : 14,
                            weight: FontWeight.w600,
                            color: todo.isDone ? dimCol : textCol,
                          ).copyWith(
                            decoration: todo.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: dimCol,
                          ),
                        ),

                        // Meta row — hidden in compact mode
                        if (!compact) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // Category pill
                              _chip(
                                todo.category,
                                isDark ? categoryBgDark(todo.category): categoryBg(todo.category),
                                categoryColor(todo.category),
                              ),

                              // Time tag
                              if (timeLabel.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '⏰ $timeLabel',
                                  style: body(size: 10, color: dimCol, weight: FontWeight.w500),
                                ),
                              ],

                              // Priority dot
                              const SizedBox(width: 6),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: _chkColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: body(size: 10, weight: FontWeight.w700, color: fg)),
      );
}
