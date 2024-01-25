package fl.amap

import android.app.Notification
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.location.AMapLocationQualityReport
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class AMapLocation(plugin: FlutterPlugin.FlutterPluginBinding) : MethodChannel.MethodCallHandler,
    AMapLocationListener {
    private var channel: MethodChannel = MethodChannel(plugin.binaryMessenger, "fl.amap.Location")

    private val context = plugin.applicationContext

    init {
        channel.setMethodCallHandler(this)
    }

    private var result: MethodChannel.Result? = null
    private val option = AMapLocationClientOption()
    private var client: AMapLocationClient? = null

    // 是否在定位
    private var isLocation = false

    override fun onLocationChanged(location: AMapLocation?) {
        if (result == null) {
            channel.invokeMethod("onLocationChanged", location?.data)
        } else {
            client?.stopLocation()
            result!!.success(location?.data)
            result = null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        when (call.method) {
            "setApiKey" -> {
                val key = call.argument<String>("key")!!
                val isAgree = call.argument<Boolean>("isAgree")!!
                val isContains = call.argument<Boolean>("isContains")!!
                val isShow = call.argument<Boolean>("isShow")!!
                AMapLocationClient.updatePrivacyAgree(context, isAgree)
                AMapLocationClient.updatePrivacyShow(context, isContains, isShow)
                AMapLocationClient.setApiKey(key)
                result.success(true)
            }

            "initialize" -> {
                client = client ?: AMapLocationClient(context)
                if (call.arguments != null) setLocationOption(call.arguments as Map<*, *>)
                client?.setLocationListener(this)
                result.success(true)
            }

            "dispose" -> {
                client?.unRegisterLocationListener(this)
                client?.stopLocation()
                client?.onDestroy()
                client = null
                result.success(true)
            }

            "getLocation" -> {
                try {
                    this.result = result
                    option.isOnceLocation = true
                    if (call.arguments != null) setLocationOption(call.arguments as Map<*, *>)
                    client?.startLocation()
                    if (client == null) result.success(null)
                } catch (e: Exception) {
                    result.success(null)
                }
            }

            "enableBackgroundLocation" -> {
                client?.enableBackgroundLocation(999, Notification())
                result.success(true)
            }

            "disableBackgroundLocation" -> {
                client?.disableBackgroundLocation(call.arguments as Boolean)
                result.success(true)
            }

            "startLocation" -> {
                if (isLocation) {
                    result.success(false)
                    return
                }
                try {
                    option.isOnceLocation = false
                    if (call.arguments != null) setLocationOption(call.arguments as Map<*, *>)
                    client?.startLocation()
                    isLocation = client != null
                    result.success(client != null)
                } catch (e: Exception) {
                    println("=======$e")
                    result.success(false)
                }
            }

            "stopLocation" -> {
                client?.stopLocation()
                isLocation = false
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }


    private fun setLocationOption(arguments: Map<*, *>) {
        println(arguments)
        option.locationMode =
            AMapLocationClientOption.AMapLocationMode.values()[arguments["locationMode"] as Int]
        val protocol =
            AMapLocationClientOption.AMapLocationProtocol.values()[arguments["locationProtocol"] as Int]
        AMapLocationClientOption.setLocationProtocol(protocol)
        val locationPurpose = arguments["locationPurpose"] as Int?
        option.locationPurpose =
            if (locationPurpose == null) null else AMapLocationClientOption.AMapLocationPurpose.values()[locationPurpose]
        option.geoLanguage =
            AMapLocationClientOption.GeoLanguage.values()[(arguments["geoLanguage"] as Int)]
        option.isGpsFirst = arguments["gpsFirst"] as Boolean
        option.gpsFirstTimeout = (arguments["gpsFirstTimeout"] as Int).toLong()
        option.isMockEnable = arguments["mockEnable"] as Boolean
        option.isNeedAddress = arguments["needAddress"] as Boolean
        option.isWifiScan = arguments["wifiScan"] as Boolean
        option.isBeidouFirst = arguments["beiDouFirst"] as Boolean
        option.deviceModeDistanceFilter =
            (arguments["deviceModeDistanceFilter"] as Double).toFloat()
        option.httpTimeOut = (arguments["httpTimeOut"] as Int).toLong()
        option.interval = (arguments["interval"] as Int).toLong()
        option.isLocationCacheEnable = arguments["locationCacheEnable"] as Boolean
        option.isOnceLocationLatest = arguments["onceLocationLatest"] as Boolean
        option.isSelfStartServiceEnable = arguments["selfStartServiceEnable"] as Boolean
        option.isSensorEnable = arguments["sensorEnable"] as Boolean
        client?.setLocationOption(option)
    }

    fun detached() {
        channel.setMethodCallHandler(null)
    }


    private val AMapLocation.data: Map<String, Any?>
        get() = mapOf(
            "errorInfo" to errorInfo,
            "errorCode" to errorCode,
            "description" to description,
            "accuracy" to accuracy,
            "adCode" to adCode,
            "address" to address,
            "altitude" to altitude,
            "bearing" to bearing,
            "buildingId" to buildingId,
            "country" to country,
            "province" to province,
            "city" to city,
            "cityCode" to cityCode,
            "district" to district,
            "street" to street,
            "streetNum" to streetNum,
            "conScenario" to conScenario,
            "coordType" to coordType,
            "floor" to floor,
            "gpsAccuracyStatus" to gpsAccuracyStatus,
            "locationDetail" to locationDetail,
            "locationType" to locationType,
            "poiName" to poiName,
            "aoiName" to aoiName,
            "provider" to provider,
            "latitude" to latitude,
            "longitude" to longitude,
            "satellites" to satellites,
            "speed" to speed,
            "trustedLevel" to trustedLevel,
            "timestamp" to time.toDouble(),
            "locationQualityReport" to locationQualityReport.data,
        )
    private val AMapLocationQualityReport.data: Map<String, Any?>
        get() = mapOf(
            "adviseMessage" to adviseMessage,
            "gpsSatellites" to gpsSatellites,
            "gpsStatus" to gpsStatus,
            "netUseTime" to netUseTime,
            "networkType" to networkType,
            "isWifiAble" to isWifiAble,
            "isInstalledHighDangerMockApp" to isInstalledHighDangerMockApp,
        )


}