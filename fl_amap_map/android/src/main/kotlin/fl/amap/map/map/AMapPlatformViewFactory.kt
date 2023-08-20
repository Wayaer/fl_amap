package fl.amap.map.map

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class AMapPlatformViewFactory(
    private val binaryMessenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        val channel = MethodChannel(binaryMessenger, "fl_amap_map_$viewId")
        return AMapView(context, channel, viewId, args as Map<*, *>)
    }

}
