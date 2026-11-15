package com.hdyzute.linh_thu_ky_luat

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar
import java.util.Locale

/**
 * Widget màn hình chính: linh thú và việc hôm nay. Chữ do app soạn sẵn
 * (lib/domain/widget_snapshot.dart); ở đây chỉ hiện ra, và khi đã sang ngày
 * mới mà app chưa mở thì báo mở app thay vì hiện việc của hôm qua.
 */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val dayStartHour = widgetData.getString("day_start_hour", null)?.toIntOrNull() ?: 0
        val fresh = widgetData.getString("date", null) == logicalToday(dayStartHour)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.today_widget).apply {
                setTextViewText(R.id.widget_emoji, widgetData.getString("emoji", null) ?: "🥚")
                setTextViewText(
                    R.id.widget_title,
                    widgetData.getString("title", null) ?: "Linh Thú Kỷ Luật",
                )
                if (fresh) {
                    setTextViewText(R.id.widget_subtitle, widgetData.getString("subtitle", ""))
                    setTextViewText(R.id.widget_tasks, widgetData.getString("tasks", ""))
                } else {
                    setTextViewText(R.id.widget_subtitle, "Ngày mới đã bắt đầu")
                    setTextViewText(R.id.widget_tasks, "Mở app để xem việc hôm nay.")
                }
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    /** Ngày logic hiện tại, giống logicalDate trong lib/domain/day.dart. */
    private fun logicalToday(dayStartHour: Int): String {
        val now = Calendar.getInstance()
        if (now.get(Calendar.HOUR_OF_DAY) < dayStartHour) now.add(Calendar.DAY_OF_MONTH, -1)
        return String.format(
            Locale.US,
            "%04d-%02d-%02d",
            now.get(Calendar.YEAR),
            now.get(Calendar.MONTH) + 1,
            now.get(Calendar.DAY_OF_MONTH),
        )
    }
}
