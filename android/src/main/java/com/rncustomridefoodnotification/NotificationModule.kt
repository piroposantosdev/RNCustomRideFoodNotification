package com.rncustomridefoodnotification

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.Promise

class NotificationModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    private val CHANNEL_ID = "ride_food_channel"
    private val activeNotifications = mutableMapOf<String, String>() // ID -> Type

    init {
        createNotificationChannel()
    }

    override fun getName(): String {
        return "NotificationModule"
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Ride Food Notifications"
            val descriptionText = "Channel for custom ride and food notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            val notificationManager: NotificationManager =
                reactApplicationContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    @ReactMethod
    fun start(type: String, attributes: ReadableMap, contentState: ReadableMap, promise: Promise) {
        val id = System.currentTimeMillis().toString()
        activeNotifications[id] = type
        showNotification(id, type, contentState)
        promise.resolve(id)
    }

    @ReactMethod
    fun update(id: String, contentState: ReadableMap, promise: Promise) {
        val type = activeNotifications[id]
        if (type != null) {
            showNotification(id, type, contentState)
            promise.resolve(null)
        } else {
            promise.reject("not_found", "Notification not found")
        }
    }

    @ReactMethod
    fun end(id: String, promise: Promise) {
        if (activeNotifications.containsKey(id)) {
            val notificationManager = NotificationManagerCompat.from(reactApplicationContext)
            notificationManager.cancel(id.hashCode())
            activeNotifications.remove(id)
            promise.resolve(null)
        } else {
            promise.reject("not_found", "Notification not found")
        }
    }

    private fun showNotification(id: String, type: String, contentState: ReadableMap) {
        val context = reactApplicationContext
        val notificationLayout = if (type == "ride") {
            RemoteViews(context.packageName, R.layout.notification_ride)
        } else {
            RemoteViews(context.packageName, R.layout.notification_food)
        }

        if (type == "ride") {
            notificationLayout.setTextViewText(R.id.ride_title, contentState.getString("statusTitle"))
            notificationLayout.setTextViewText(R.id.ride_subtitle, contentState.getString("statusDescription"))
            val progress = (contentState.getDouble("progress") * 100).toInt()
            notificationLayout.setProgressBar(R.id.ride_progress, 100, progress, false)
        } else {
            notificationLayout.setTextViewText(R.id.food_time, contentState.getString("estimatedTime"))
            notificationLayout.setTextViewText(R.id.food_status_title, contentState.getString("statusTitle"))
            notificationLayout.setTextViewText(R.id.food_status_desc, contentState.getString("statusDescription"))
            val progress = (contentState.getDouble("progress") * 100).toInt()
            notificationLayout.setProgressBar(R.id.food_progress, 100, progress, false)
        }

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Default icon, user should replace
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(notificationLayout)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setOnlyAlertOnce(true)
            .setOngoing(true)

        with(NotificationManagerCompat.from(context)) {
            // notificationId is a unique int for each notification that you must define
            notify(id.hashCode(), builder.build())
        }
    }
}
