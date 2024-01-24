package fl.amap

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class AMapPlugin : FlutterPlugin {
    private var location: AMapLocation? = null
    private var geoFence: AMapGeoFence? = null

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        location = AMapLocation(plugin)
        geoFence = AMapGeoFence(plugin)
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        location?.detached()
        geoFence?.detached()
    }

}

