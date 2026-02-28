// ── widgets/todo_card.dart ────────────────────────────────────
// Reusable card widget for displaying a single task

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';
import 'task_checkbox.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onTap;
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

class _TodoCardState extends State<TodoCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _justCompleted = false;

  bool get _isOverdue =>
      widget.todo.dueDate != null &&
      widget.todo.dueDate!.isBefore(DateTime.now()) &&
      !widget.todo.isDone;

  void _handleToggle() {
    if (!widget.todo.isDone) {
      setState(() => _justCompleted = true);
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _justCompleted = false);
      });
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? kDarkSurface : kSurface;
    final textColor = isDark ? kDarkText : kText;
    final dimColor = isDark ? kDarkTextDim : kTextDim;
    final priorityColor = Color(todo.priority.colorValue);

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
            const Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 24),
            const SizedBox(height: 2),
            Text('Delete', style: body(size: 11, weight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : (_justCompleted ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: _justCompleted
                  ? kGreen.withValues(alpha: 0.08)
                  : (todo.isDone
                      ? cardColor.withValues(alpha: 0.6)
                      : cardColor),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isOverdue
                    ? kRed.withValues(alpha: 0.4)
                    : (isDark ? kDarkBorder : kBorder),
                width: 1,
              ),
              boxShadow: shadowSm,
            ),
            child: Row(
              children: [
                // ── Checkbox ──
                TaskCheckbox(
                  isChecked: todo.isDone,
                  accentColor: priorityColor,
                  onTap: _handleToggle,
                ),
                const SizedBox(width: 14),

                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        todo.title,
                        style: body(
                          size: 14,
                          weight: FontWeight.w600,
                          color: todo.isDone ? dimColor : textColor,
                        ).copyWith(
                          decoration: todo.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: dimColor,
                        ),
                      ),

                      // Note
                      if (todo.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body(size: 12, color: dimColor),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // ── Meta row ──
                      Row(
                        children: [
                          // Category chip
                          _chip(
                            todo.category,
                            categoryBg(todo.category),
                            categoryColor(todo.category),
                          ),
                          const SizedBox(width: 6),

                          // Time chip
                          if (todo.dueDate != null) ...[
                            _timeChip(todo, dimColor),
                            const SizedBox(width: 6),
                          ],

                          // Priority dot
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(Icons.chevron_right_rounded, color: dimColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeChip(Todo todo, Color dimColor) {
    if (todo.isDone) {
      final formatted = DateFormat('MMM d, h:mm a').format(todo.dueDate!);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 12, color: dimColor),
          const SizedBox(width: 3),
          Text(formatted, style: body(size: 11, color: dimColor)),
        ],
      );
    }

    final diff = todo.dueDate!.difference(DateTime.now());
    if (diff.isNegative) {
      return _chip('Overdue', const Color(0xFFFFF0F0), kRed);
    }

    String timeLeft;
    if (diff.inDays > 0) {
      timeLeft = '${diff.inDays}d left';
    } else if (diff.inHours > 0) {
      timeLeft = '${diff.inHours}h ${diff.inMinutes % 60}m';
    } else if (diff.inMinutes > 0) {
      timeLeft = '${diff.inMinutes}m';
    } else {
      timeLeft = '< 1m';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, size: 12, color: dimColor),
        const SizedBox(width: 3),
        Text(timeLeft, style: body(size: 11, color: dimColor)),
      ],
    );
  }

  Widget _chip(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: body(size: 10, weight: FontWeight.w600, color: fg)),
      );
}
