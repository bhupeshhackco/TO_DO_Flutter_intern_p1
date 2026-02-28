// ── services/storage_service.dart ────────────────────────────
// Handles saving and loading tasks from local storage
// Uses shared_preferences package

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';
import '../providers/theme_provider.dart';

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
    // Mark that we've saved at least once (distinguishes first-launch from empty list)
    await prefs.setBool('hasSavedTodos', true);
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

  // ── Check if todos have ever been saved ─────────────────────
  static Future<bool> hasSavedTodos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSavedTodos') ?? false;
  }

  // ── Save/Load ThemeMode ───────────────────────────────
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    return ThemeMode.values[index];
  }

  // ── Save/Load Color Scheme ───────────────────────────────
  static Future<void> saveColorScheme(AppColorScheme scheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('colorScheme', scheme.index);
  }

  static Future<AppColorScheme> loadColorScheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('colorScheme') ?? AppColorScheme.defaultScheme.index;
    return AppColorScheme.values[index];
  }

  // ── Save/Load Pure Black Mode ───────────────────────────────
  static Future<void> savePureBlack(bool isPure) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPureBlack', isPure);
  }

  static Future<bool> loadPureBlack() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPureBlack') ?? false;
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

  // ── Generic bool prefs ──────────────────────────────────────
  static Future<void> saveBool(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  static Future<bool> loadBool(String key, bool defaultVal) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultVal;
  }
}
