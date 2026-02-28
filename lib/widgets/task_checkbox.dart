// ── widgets/task_checkbox.dart ─────────────────────────────────
// Animated checkbox with spring‑bounce on check

import 'package:flutter/material.dart';

class TaskCheckbox extends StatefulWidget {
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
  State<TaskCheckbox> createState() => _TaskCheckboxState();
}

class _TaskCheckboxState extends State<TaskCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutBack));

    _checkScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack)),
    );
  }

  @override
  void didUpdateWidget(covariant TaskCheckbox old) {
    super.didUpdateWidget(old);
    if (widget.isChecked && !old.isChecked) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isChecked ? _scale.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.isChecked
                    ? widget.accentColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: widget.isChecked
                      ? Colors.transparent
                      : widget.accentColor,
                  width: 2,
                ),
              ),
              child: widget.isChecked
                  ? Transform.scale(
                      scale: _checkScale.value,
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
