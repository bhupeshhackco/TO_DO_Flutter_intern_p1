// ── widgets/add_edit_sheet.dart ───────────────────────────────
// Reusable bottom sheet for adding and editing tasks

import 'package:flutter/material.dart';
import '../models/todo.dart';

class AddEditSheet extends StatefulWidget {
  final Todo? todo; // null = add mode, non-null = edit mode
  final bool isDark;
  final Function(
    String title,
    String? note,
    Priority priority,
    String category,
    DateTime? dueDate,
  ) onSave;

  const AddEditSheet({
    super.key,
    this.todo,
    required this.isDark,
    required this.onSave,
  });

  @override
  State<AddEditSheet> createState() => _AddEditSheetState();
}

class _AddEditSheetState extends State<AddEditSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _noteCtrl;
  late Priority _priority;
  late String _category;
  DateTime? _dueDate;

  bool get isEdit => widget.todo != null;

  static const List<String> categories = [
    'Personal', 'Work', 'Shopping', 'Health', 'Study',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    _titleCtrl = TextEditingController(text: widget.todo?.title ?? '');
    _noteCtrl  = TextEditingController(text: widget.todo?.note  ?? '');
    _priority  = widget.todo?.priority  ?? Priority.medium;
    _category  = widget.todo?.category  ?? 'Personal';
    _dueDate   = widget.todo?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _surfaceColor =>
      widget.isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get _bgColor =>
      widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get _textColor =>
      widget.isDark ? Colors.white : const Color(0xFF1E293B);

  void _save() {
    final text = _titleCtrl.text.trim();
    if (text.isEmpty) return;
    widget.onSave(
      text,
      _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      _priority,
      _category,
      _dueDate,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            // Sheet title
            Text(
              isEdit ? 'Edit Task' : 'New Task',
              style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 20),

            // ── Title field ────────────────────────────────────
            _label('Task title *'),
            const SizedBox(height: 8),
            _textField(_titleCtrl, 'e.g. Finish the project', autofocus: true),
            const SizedBox(height: 14),

            // ── Note field ─────────────────────────────────────
            _label('Note (optional)'),
            const SizedBox(height: 8),
            _textField(_noteCtrl, 'Add extra details...', lines: 2),
            const SizedBox(height: 18),

            // ── Priority ───────────────────────────────────────
            _label('Priority'),
            const SizedBox(height: 10),
            Row(
              children: Priority.values.map((p) {
                final selected = _priority == p;
                final color = Color(p.colorValue);
                final bg    = Color(p.bgColorValue);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? color : bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        p.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // ── Category ───────────────────────────────────────
            _label('Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF6366F1)
                          : _bgColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // ── Due date ───────────────────────────────────────
            _label('Due date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ??
                      DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: _dueDate != null
                      ? const Color(0xFFEEF2FF)
                      : _bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _dueDate != null
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade200,
                    width: _dueDate != null ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: _dueDate != null
                        ? const Color(0xFF6366F1)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _dueDate != null
                        ? '${_dueDate!.day} / ${_dueDate!.month} / ${_dueDate!.year}'
                        : 'Pick a date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _dueDate != null
                          ? const Color(0xFF6366F1)
                          : Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  if (_dueDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _dueDate = null),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.grey),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: 26),

            // ── Save button ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  isEdit ? 'Save Changes' : 'Add Task',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _textColor.withValues(alpha: 0.6),
        ),
      );

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    bool autofocus = false,
    int lines = 1,
  }) =>
      TextField(
        controller: ctrl,
        autofocus: autofocus,
        maxLines: lines,
        onSubmitted: lines == 1 ? (_) => _save() : null,
        style: TextStyle(fontSize: 14, color: _textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: _bgColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF6366F1), width: 2),
          ),
        ),
      );
}
