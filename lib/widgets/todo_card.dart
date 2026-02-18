// ── widgets/todo_card.dart ────────────────────────────────────
// Reusable card widget for displaying a single task

import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.isDark,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  bool get _isOverdue =>
      todo.dueDate != null &&
      todo.dueDate!.isBefore(DateTime.now()) &&
      !todo.isDone;

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor =
        isDark ? Colors.white : const Color(0xFF1E293B);
    final priorityColor = Color(todo.priority.colorValue);

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text('Delete',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: todo.isDone
                ? cardColor.withValues(alpha: 0.5)
                : cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isOverdue
                  ? const Color(0xFFEF4444)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.grey.shade100,
              width: _isOverdue ? 1.5 : 1,
            ),
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
          child: Row(
            children: [

              // Left priority bar
              Container(
                width: 4,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: todo.isDone
                      ? Colors.grey.shade300
                      : priorityColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: todo.isDone
                        ? const Color(0xFF6366F1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: todo.isDone
                          ? const Color(0xFF6366F1)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: todo.isDone
                      ? const Icon(Icons.check,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: todo.isDone ? Colors.grey : textColor,
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Colors.grey,
                      ),
                    ),

                    // Note
                    if (todo.note != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        todo.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],

                    const SizedBox(height: 6),

                    // Badges row
                    Row(children: [
                      // Category badge
                      _badge(todo.category,
                          const Color(0xFFEEF2FF),
                          const Color(0xFF6366F1)),
                      const SizedBox(width: 6),

                      // Due date badge
                      if (todo.dueDate != null)
                        _badge(
                          _isOverdue
                              ? 'Overdue!'
                              : '${todo.dueDate!.day}/${todo.dueDate!.month}',
                          _isOverdue
                              ? const Color(0xFFFFF1F2)
                              : const Color(0xFFF1F5F9),
                          _isOverdue
                              ? const Color(0xFFEF4444)
                              : Colors.grey,
                        ),
                    ]),
                  ],
                ),
              ),

              // Edit icon
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color fg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: fg),
        ),
      );
}
