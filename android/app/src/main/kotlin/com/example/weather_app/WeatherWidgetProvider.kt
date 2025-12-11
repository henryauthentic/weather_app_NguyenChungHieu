package com.example.weather_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class WeatherWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {

        for (widgetId in appWidgetIds) {

            val views = RemoteViews(context.packageName, R.layout.weather_widget_layout)

            // Read data from Flutter saved via HomeWidget.saveWidgetData(...)
            val prefs = HomeWidgetPlugin.getData(context)

            val city = prefs.getString("city", "Unknown")
            val temperature = prefs.getString("temp", "--°C")
            val condition = prefs.getString("condition", "Loading...")
            val updatedAt = prefs.getString("updated_at", "")

            views.setTextViewText(R.id.txtCity, city)
            views.setTextViewText(R.id.txtTemperature, temperature)
            views.setTextViewText(R.id.txtCondition, condition)
            views.setTextViewText(R.id.txtUpdatedAt, updatedAt)

            // Clicking widget → open app
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            views.setOnClickPendingIntent(R.id.widgetRoot, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
