// ── services/storage_service.dart ────────────────────────────
// Handles saving and loading tasks from local storage
// Uses shared_preferences package

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  // The key we use to store data
  static const String _key = 'todos';

  // ── Save all todos to local storage ────────────────────────
  static Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert each todo to a map, then encode as JSON string
    final List<String> jsonList =
        todos.map((t) => jsonEncode(t.toMap())).toList();

    await prefs.setStringList(_key, jsonList);
  }

  // ── Load all todos from local storage ──────────────────────
  static Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String>? jsonList = prefs.getStringList(_key);

    // If nothing saved yet, return empty list
    if (jsonList == null) return [];

    // Convert each JSON string back to a Todo object
    return jsonList
        .map((item) => Todo.fromMap(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  // ── Save dark mode preference ───────────────────────────────
  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
  }

  // ── Load dark mode preference ───────────────────────────────
  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDark') ?? false;
  }

  // ── Check if first time user ────────────────────────────────
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenOnboarding') ?? true;
  }

  // ── Mark onboarding as seen ─────────────────────────────────
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', false);
  }
}
