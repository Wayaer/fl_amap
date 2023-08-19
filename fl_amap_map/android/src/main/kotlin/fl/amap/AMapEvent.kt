package fl.amap

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

class AMapEvent(binaryMessenger: BinaryMessenger) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel? = null
    private val handler = Handler(Looper.getMainLooper())

    init {
        eventChannel = EventChannel(binaryMessenger, "fl_amap/event")
        eventChannel!!.setStreamHandler(this)
    }

    fun sendEvent(arguments: Any?) {
        handler.post {
            eventSink?.success(arguments)
        }
    }

    fun dispose() {
        eventSink?.endOfStream()
        eventSink = null
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    override fun onListen(arguments: Any?, event: EventChannel.EventSink?) {
        eventSink = event
    }

    override fun onCancel(arguments: Any?) {
        dispose()
    }
}