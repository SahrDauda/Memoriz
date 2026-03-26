package com.example.memoriz

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ScriptureWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.scripture_widget).apply {
                val reference = widgetData.getString("verse_reference", "John 3:16")
                val text = widgetData.getString("verse_text", "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.")
                
                setTextViewText(R.id.verse_reference, reference)
                setTextViewText(R.id.verse_text, text)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
