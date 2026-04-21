package com.rncustomridefoodnotification

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.widget.RemoteViews
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.Promise
import com.facebook.react.modules.core.PermissionAwareActivity
import com.facebook.react.modules.core.PermissionListener

class NotificationModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), PermissionListener {

    private val CHANNEL_ID = "ride_food_channel"
    private val PERMISSION_REQUEST_CODE = 1001
    private val activeNotifications = mutableMapOf<String, String>() // ID -> Type

    private var pendingStartType: String? = null
    private var pendingStartAttributes: ReadableMap? = null
    private var pendingStartContentState: ReadableMap? = null
    private var pendingStartPromise: Promise? = null

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

    private fun hasNotificationPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val permissionGranted = ContextCompat.checkSelfPermission(
                reactApplicationContext,
                Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            val notificationsEnabled = NotificationManagerCompat.from(reactApplicationContext).areNotificationsEnabled()
            return permissionGranted && notificationsEnabled
        }
        return NotificationManagerCompat.from(reactApplicationContext).areNotificationsEnabled()
    }

    @ReactMethod
    fun start(type: String, attributes: ReadableMap, contentState: ReadableMap, promise: Promise) {
        if (hasNotificationPermission()) {
            doStart(type, attributes, contentState, promise)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val activity = currentActivity
            if (activity is PermissionAwareActivity) {
                pendingStartType = type
                pendingStartAttributes = attributes
                pendingStartContentState = contentState
                pendingStartPromise = promise
                activity.requestPermissions(
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    PERMISSION_REQUEST_CODE,
                    this
                )
            } else {
                // Fallback: try to show anyway
                doStart(type, attributes, contentState, promise)
            }
        } else {
            doStart(type, attributes, contentState, promise)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val type = pendingStartType
            val attributes = pendingStartAttributes
            val contentState = pendingStartContentState
            val promise = pendingStartPromise

            // Clear pending state
            pendingStartType = null
            pendingStartAttributes = null
            pendingStartContentState = null
            pendingStartPromise = null

            if (type != null && attributes != null && contentState != null && promise != null) {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    doStart(type, attributes, contentState, promise)
                } else {
                    promise.reject("permission_denied", "Notification permission was denied")
                }
            }
            return true
        }
        return false
    }

    private fun doStart(type: String, attributes: ReadableMap, contentState: ReadableMap, promise: Promise) {
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
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(notificationLayout)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setOnlyAlertOnce(true)
            .setOngoing(true)

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        android.util.Log.d("NotificationModule", "Posting notification id=${id.hashCode()}, areEnabled=${NotificationManagerCompat.from(context).areNotificationsEnabled()}")
        try {
            notificationManager.notify(id.hashCode(), builder.build())
            android.util.Log.d("NotificationModule", "Notification posted successfully")
        } catch (e: SecurityException) {
            android.util.Log.e("NotificationModule", "SecurityException posting notification", e)
        } catch (e: Exception) {
            android.util.Log.e("NotificationModule", "Exception posting notification", e)
        }
    }
}
