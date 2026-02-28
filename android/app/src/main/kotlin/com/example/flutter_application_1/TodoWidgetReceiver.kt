package com.example.flutter_application_1

import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class TodoWidgetReceiver : HomeWidgetGlanceWidgetReceiver<TodoWidget>() {
    override val glanceAppWidget = TodoWidget()
}
