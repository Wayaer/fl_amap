package fl.amap

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.graphics.Color
import android.os.Build
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationListener
import com.amap.api.location.AMapLocationQualityReport
import com.amap.api.location.CoordinateConverter
import com.amap.api.location.DPoint
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
            isLocation = false
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
                isLocation = false
                client?.unRegisterLocationListener(this)
                client?.stopLocation()
                client?.onDestroy()
                client = null
                result.success(true)
            }

            "getLocation" -> {
                if (isLocation) {
                    result.success(null)
                    return
                }
                try {
                    this.result = result
                    option.isOnceLocation = true
                    if (call.arguments != null) setLocationOption(call.arguments as Map<*, *>)
                    isLocation = true
                    client?.startLocation()
                    if (client == null) result.success(null)
                } catch (e: Exception) {
                    isLocation = false
                    result.success(null)
                }
            }

            "enableBackgroundLocation" -> {
                val args = call.arguments as Map<*, *>
                client?.enableBackgroundLocation(
                    args["notificationId"] as Int, buildNotification(args)
                )
                result.success(client != null)
            }

            "disableBackgroundLocation" -> {
                client?.disableBackgroundLocation(call.arguments as Boolean)
                result.success(client != null)
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
                    isLocation = false
                    result.success(false)
                }
            }

            "stopLocation" -> {
                client?.stopLocation()
                isLocation = false
                result.success(true)
            }

            "isAMapDataAvailable" -> {
                result.success(isAMapDataAvailable(call.arguments as Map<*, *>))
            }

            "calculateLineDistance" -> {
                result.success(calculateLineDistance(call.arguments as Map<*, *>))
            }

            "coordinateConverter" -> {
                result.success(coordinateConverter(call.arguments as Map<*, *>))
            }

            else -> result.notImplemented()
        }
    }

    private fun isAMapDataAvailable(args: Map<*, *>): Boolean {
        return CoordinateConverter.isAMapDataAvailable(
            args["latitude"] as Double,
            args["longitude"] as Double,
        )
    }

    private fun calculateLineDistance(args: Map<*, *>): Float {
        val start = DPoint(args["startLatitude"] as Double, args["startLongitude"] as Double)
        val end = DPoint(args["endLatitude"] as Double, args["endLongitude1"] as Double)
        return CoordinateConverter.calculateLineDistance(start, end)
    }

    private fun coordinateConverter(args: Map<*, *>): Map<String, Any?> {
        val dPoint = DPoint()
        dPoint.latitude = args["latitude"] as Double
        dPoint.longitude = args["longitude"] as Double
        val coordinateConverter = CoordinateConverter(context)
        coordinateConverter.from(CoordinateConverter.CoordType.entries[args["from"] as Int])
        try {
            coordinateConverter.coord(dPoint)
            val point = coordinateConverter.convert()
            return mapOf(
                "code" to 0, "latitude" to point.latitude, "longitude" to point.longitude
            )
        } catch (e: Exception) {
            return mapOf(
                "code" to 1, "message" to e.message
            )
        }

    }

    private fun buildNotification(args: Map<*, *>): Notification {
        val builder: Notification.Builder
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelId = args["channelId"] as String?
            val channel = NotificationChannel(
                channelId, args["channelName"] as String, args["importance"] as Int
            )
            channel.description = args["description"] as String?
            channel.lockscreenVisibility = args["lockscreenVisibility"] as Int
            channel.enableLights(args["enableLights"] as Boolean) //是否在桌面icon右上角展示小圆点
            channel.lightColor = Color.parseColor(args["lightColor"] as String) //小圆点颜色
            channel.setShowBadge(args["showBadge"] as Boolean) //是否在久按桌面图标时显示此渠道的通知
            notificationManager.createNotificationChannel(channel)
            builder = Notification.Builder(context, channelId)
        } else {
            builder = Notification.Builder(context)
        }
        builder.setSmallIcon(R.mipmap.ic_launcher).setContentTitle(args["title"] as String)
            .setContentText(args["content"] as String).setWhen(System.currentTimeMillis())
//        builder.setLargeIcon(
//            BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)
//        )
        return builder.build()
    }

    private fun setLocationOption(arguments: Map<*, *>) {
        println(arguments)
        option.locationMode =
            AMapLocationClientOption.AMapLocationMode.entries[arguments["locationMode"] as Int]
        val protocol =
            AMapLocationClientOption.AMapLocationProtocol.entries[arguments["locationProtocol"] as Int]
        AMapLocationClientOption.setLocationProtocol(protocol)
        val locationPurpose = arguments["locationPurpose"] as Int?
        option.locationPurpose =
            if (locationPurpose == null) null else AMapLocationClientOption.AMapLocationPurpose.entries[locationPurpose]
        option.geoLanguage =
            com.amap.api.location.AMapLocationClientOption.GeoLanguage.entries[(arguments["geoLanguage"] as Int)]
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
