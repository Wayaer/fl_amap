package fl.amap.map

import android.content.Context
import androidx.lifecycle.Lifecycle
import com.amap.api.location.AMapLocationClient
import com.amap.api.maps.MapsInitializer
import fl.amap.map.map.AMapPlatformViewFactory
import fl.channel.FlChannelPlugin
import fl.channel.FlEventChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class AMapMapPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var binaryMessenger: BinaryMessenger


    companion object {
        var lifecycle: Lifecycle? = null
        var flEventChannel: FlEventChannel? = null
    }

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = plugin.binaryMessenger
        channel = MethodChannel(plugin.binaryMessenger, "fl_amap_map")
        context = plugin.applicationContext
        channel.setMethodCallHandler(this)
        plugin.platformViewRegistry.registerViewFactory(
            "fl_amap_map", AMapPlatformViewFactory(plugin.binaryMessenger)
        )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setApiKey" -> {
                val key = call.argument<String>("key")!!
                val isAgree = call.argument<Boolean>("isAgree")!!
                val isContains = call.argument<Boolean>("isContains")!!
                val isShow = call.argument<Boolean>("isShow")!!
                val enableHTTPS = call.argument<Boolean>("enableHTTPS")!!
                AMapLocationClient.updatePrivacyAgree(context, isAgree)
                AMapLocationClient.updatePrivacyShow(context, isContains, isShow)
                AMapLocationClient.setApiKey(key)
                MapsInitializer.setApiKey(key)
                MapsInitializer.initialize(context)
                MapsInitializer.setProtocol(if (enableHTTPS) MapsInitializer.HTTPS else MapsInitializer.HTTP)
                MapsInitializer.updatePrivacyAgree(context, isAgree)
                MapsInitializer.updatePrivacyShow(context, isContains, isShow)
                flEventChannel = FlChannelPlugin.getEventChannel("fl_amap_map_event")
                result.success(true)
            }
        }

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val reference = binding.lifecycle as HiddenLifecycleReference
        lifecycle = reference.lifecycle
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        lifecycle = null
    }

}

