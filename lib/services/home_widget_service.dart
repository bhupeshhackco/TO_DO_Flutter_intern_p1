import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/todo.dart';

class HomeWidgetService {
  static const String appGroupId = '<YOUR APP GROUP>'; // Replace with actual group if on iOS
  static const String androidWidgetName = 'TodoWidget';

  static Future<void> init() async {
    if (kIsWeb) return;
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidgetStats(List<Todo> todos) async {
    if (kIsWeb) return;
    final remainingCount = todos.where((t) => !t.isDone).length;
    final totalCount = todos.length;
    final doneCount = totalCount - remainingCount;

    await HomeWidget.saveWidgetData<int>('remainingCount', remainingCount);
    await HomeWidget.saveWidgetData<int>('doneCount', doneCount);
    await HomeWidget.saveWidgetData<int>('totalCount', totalCount);

    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: androidWidgetName, // If we have the same name for iOS
    );
  }
}
