// ── models/todo.dart ──────────────────────────────────────────
// This is our data model — like a blueprint for every task

enum Priority { low, medium, high }

extension PriorityX on Priority {
  String get label => ['Low', 'Medium', 'High'][index];

  // Color values as integers (we use Color(value) in widgets)
  int get colorValue => [
        0xFF06B6D4, // Cyan - low
        0xFF8B5CF6, // Violet - medium
        0xFFF43F5E, // Rose - high
      ][index];

  int get bgColorValue => [
        0xFFCFFAFE,
        0xFFEDE9FE,
        0xFFFFE4E6,
      ][index];
}

class Todo {
  static int compareTodos(Todo a, Todo b) {
    // 1. Priority descending (High > Medium > Low)
    final priorityDiff = b.priority.index.compareTo(a.priority.index);
    if (priorityDiff != 0) return priorityDiff;
    
    // 2. DueDate earliest first
    if (a.dueDate != null && b.dueDate != null) {
      return a.dueDate!.compareTo(b.dueDate!);
    } else if (a.dueDate != null) {
      return -1;
    } else if (b.dueDate != null) {
      return 1;
    }
    
    // 3. Fallback createdAt
    return b.createdAt.compareTo(a.createdAt);
  }

  final String id;
  String title;
  String? note;
  bool isDone;
  Priority priority;
  String category;
  DateTime? dueDate;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.note,
    this.isDone = false,
    this.priority = Priority.medium,
    this.category = 'Personal',
    this.dueDate,
    required this.createdAt,
  });

  // ── Convert to Map so we can save it to local storage ──────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'isDone': isDone,
      'priority': priority.index,
      'category': category,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ── Convert from Map back to a Todo object ─────────────────
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      isDone: map['isDone'] ?? false,
      priority: Priority.values[map['priority'] ?? 1],
      category: map['category'] ?? 'Personal',
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
