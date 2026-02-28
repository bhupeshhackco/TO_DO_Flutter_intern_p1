// ── widgets/task_checkbox.dart ────────────────────────────────
// Rounded-square checkbox that matches the HTML .chk design.
// Tap = toggle done only. Card body tap = edit.

import 'package:flutter/material.dart';

class TaskCheckbox extends StatelessWidget {
  final bool isChecked;
  final Color accentColor;
  final VoidCallback onTap;

  const TaskCheckbox({
    super.key,
    required this.isChecked,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: isChecked ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: accentColor,
            width: 2,
          ),
        ),
        child: AnimatedScale(
          scale: isChecked ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Center(
            child: Text(
              '✓',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
