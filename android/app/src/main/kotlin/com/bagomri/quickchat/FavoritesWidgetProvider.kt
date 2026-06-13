package com.bagomri.quickchat

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Home-screen widget that shows up to 3 favourite contacts from QuickChat.
 *
 * Data is passed from Flutter via [home_widget] shared preferences under the
 * key "fav_N_name" and "fav_N_phone" (N = 0, 1, 2).
 *
 * Tapping a row builds a `quickchat://send?phone=<digits>` deep link and
 * opens MainActivity with that intent — Flutter's AppLinksService handles it.
 */
class FavoritesWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { id -> updateWidget(context, appWidgetManager, id) }
    }

    companion object {
        private val ROW_IDS = intArrayOf(
            R.id.fav_row_0, R.id.fav_row_1, R.id.fav_row_2,
        )

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val views = RemoteViews(context.packageName, R.layout.quickchat_widget)

            // "+" header button → open app home screen
            views.setOnClickPendingIntent(
                R.id.widget_open_app,
                openAppIntent(context, null),
            )
            views.setOnClickPendingIntent(
                R.id.widget_title,
                openAppIntent(context, null),
            )

            // Read up to 3 favourites written by Flutter's HomeWidgetService
            val prefs = HomeWidgetPlugin.getData(context)
            var hasFav = false
            ROW_IDS.forEachIndexed { i, rowId ->
                val name  = prefs.getString("fav_${i}_name",  null)
                val phone = prefs.getString("fav_${i}_phone", null)
                if (!name.isNullOrBlank() && !phone.isNullOrBlank()) {
                    hasFav = true
                    views.setViewVisibility(rowId, View.VISIBLE)
                    views.setTextViewText(rowId, name)
                    views.setOnClickPendingIntent(rowId, openAppIntent(context, phone))
                } else {
                    views.setViewVisibility(rowId, View.GONE)
                }
            }

            views.setViewVisibility(
                R.id.widget_empty,
                if (hasFav) View.GONE else View.VISIBLE,
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun openAppIntent(context: Context, phone: String?): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                if (phone != null) {
                    data = Uri.parse("quickchat://send?phone=${Uri.encode(phone)}")
                }
            }
            // Use phone hash (or 0) as request code to keep PendingIntents distinct
            val reqCode = phone?.hashCode() ?: 0
            return PendingIntent.getActivity(
                context, reqCode, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
