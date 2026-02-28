package com.example.flutter_application_1

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews

class TodoWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when the first widget is placed
    }

    override fun onDisabled(context: Context) {
        // Called when the last widget is removed
    }

    companion object {
        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // Read data saved by the home_widget Flutter package
            val prefs: SharedPreferences = context.getSharedPreferences(
                "HomeWidgetPreferences", Context.MODE_PRIVATE
            )

            val remaining = prefs.getInt("remainingCount", 0)
            val done = prefs.getInt("doneCount", 0)
            val total = prefs.getInt("totalCount", 0)

            val views = RemoteViews(context.packageName, R.layout.todo_widget_layout)
            views.setTextViewText(R.id.widget_remaining, remaining.toString())
            views.setTextViewText(R.id.widget_done, done.toString())
            views.setTextViewText(R.id.widget_total, total.toString())

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
