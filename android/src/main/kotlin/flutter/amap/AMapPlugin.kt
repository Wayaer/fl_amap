package flutter.amap

import android.content.Context
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import java.util.*


class AMapPlugin : FlutterPlugin {
    private lateinit var context: Context
    private var channel: MethodChannel? = null

    private var option: AMapLocationClientOption? = null
    private var locationClient: AMapLocationClient? = null

    private var isLocation = false
    private var onceLocation = false

    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        context = plugin.applicationContext
        channel = MethodChannel(plugin.binaryMessenger, "fl_amap")
        channel?.setMethodCallHandler { call, result ->
            //显然下面的任何方法都应该放在同步块处理
            when (call.method) {
                "setApiKey" -> {
                    val key = call.argument<String>("key")
                    if (key != null) {
                        AMapLocationClient.setApiKey(key)
                        result.success(true)
                    }
                }
                "init" -> {
                    //初始化client
                    if (locationClient == null) locationClient = AMapLocationClient(context)
                    //设置定位参数
                    if (option == null) option = AMapLocationClientOption()
                    parseOptions(option, call.arguments as Map<*, *>)
                    locationClient!!.setLocationOption(option)
                    result.success(true)
                }
                "dispose" -> {
                    if (locationClient != null) {
                        locationClient!!.stopLocation()
                        locationClient = null
                        option = null
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "getLocation" -> {
                    if (isLocation) {
                        result.success(false)
                    } else {
                        if (locationClient == null) result.success(null)
                        val needsAddress = call.arguments as Boolean
                        if (needsAddress != option!!.isNeedAddress) {
                            option!!.isNeedAddress = needsAddress
                            locationClient!!.setLocationOption(option)
                        }
                        option!!.isOnceLocation = true
                        locationClient?.setLocationListener { location ->
                            locationClient?.stopLocation()
                            result.success(resultToMap(location))
                        }
                        locationClient?.startLocation()
                    }
                }
                "startLocation" -> {
                    if (locationClient == null || option == null) {
                        result.success(false)
                    } else {
                        option!!.isOnceLocation = false
                        locationClient?.setLocationOption(option)
                        locationClient!!.setLocationListener { location ->
                            channel!!.invokeMethod("updateLocation", resultToMap(location))
                        }
                        locationClient?.startLocation()
                        isLocation = true
                        result.success(true)
                    }

                }
                "stopLocation" -> {
                    //停止定位
                    if (locationClient == null) {
                        result.success(false)
                    } else {
                        locationClient!!.stopLocation()
                        isLocation = false
                        result.success(true)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    /**
     * this.locationMode : AMapLocationMode.Hight_Accuracy,
     * this.gpsFirst:false,
     * this.httpTimeOut:10000,             //30有点长，特殊情况才需要这么长，改成10
     * this.interval:2000,
     * this.needsAddress : true,
     * this.onceLocation : false,
     * this.onceLocationLatest : false,
     * this.locationProtocol : AMapLocationProtocol.HTTP,
     * this.sensorEnable : false,
     * this.wifiScan : true,
     * this.locationCacheEnable : true,
     *
     *
     * this.allowsBackgroundLocationUpdates : false,
     * this.desiredAccuracy : CLLocationAccuracy.kCLLocationAccuracyBest,
     * this.locatingWithReGeocode : false,
     * this.locationTimeout : 10000,     //30有点长，特殊情况才需要这么长，改成10
     * this.pausesLocationUpdatesAutomatically : false,
     * this.reGeocodeTimeout : 5000,
     *
     * this.geoLanguage : GeoLanguage.DEFAULT,
     *
     * @param arguments
     * @return
     */
    private fun parseOptions(option: AMapLocationClientOption?, arguments: Map<*, *>) {
        onceLocation = (arguments["onceLocation"] as Boolean?)!!
        //可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
        option!!.locationMode = AMapLocationClientOption.AMapLocationMode.valueOf((arguments["locationMode"] as String?)!!)
        //可选，设置是否gps优先，只在高精度模式下有效。默认关闭
        option.isGpsFirst = (arguments["gpsFirst"] as Boolean?)!!
        //可选，设置网络请求超时时间。默认为30秒。在仅设备模式下无效
        option.httpTimeOut = (arguments["httpTimeOut"] as Int).toLong()
        //可选，设置定位间隔。默认为2秒
        option.interval = (arguments["interval"] as Int).toLong()
        //可选，设置是否返回逆地理地址信息。默认是true
        option.isNeedAddress = (arguments["needsAddress"] as Boolean?)!!
        option.isOnceLocation = onceLocation //可选，设置是否单次定位。默认是false
        option.isOnceLocationLatest = (arguments["onceLocationLatest"] as Boolean?)!!
        //可选，设置是否等待wifi刷新，默认为false.如果设置为true,会自动变为单次定位，持续定位时不要使用
        AMapLocationClientOption.setLocationProtocol(AMapLocationClientOption.AMapLocationProtocol.valueOf((arguments["locationProtocol"] as String?)!!)) //可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
        //可选，设置是否使用传感器。默认是false
        option.isSensorEnable = (arguments["sensorEnable"] as Boolean?)!!
        //可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
        option.isWifiScan = (arguments["wifiScan"] as Boolean?)!!
        //可选，设置是否使用缓存定位，默认为true
        option.isLocationCacheEnable = (arguments["locationCacheEnable"] as Boolean?)!!
        //可选，设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言）
        option.geoLanguage = AMapLocationClientOption.GeoLanguage.valueOf((arguments["geoLanguage"] as String?)!!)
    }


    private fun resultToMap(a: AMapLocation?): Map<*, *> {
        val map: MutableMap<String, Any> = HashMap()
        if (a != null) {
            if (a.errorCode != 0) {
                //错误信息
                map["description"] = a.errorInfo
                map["success"] = false
            } else {
                map["success"] = true
                map["accuracy"] = a.accuracy
                map["altitude"] = a.altitude
                map["speed"] = a.speed
                map["timestamp"] = a.time.toDouble() / 1000
                map["latitude"] = a.latitude
                map["longitude"] = a.longitude
                map["locationType"] = a.locationType
                map["provider"] = a.provider
                map["formattedAddress"] = a.address
                map["country"] = a.country
                map["province"] = a.province
                map["city"] = a.city
                map["district"] = a.district
                map["cityCode"] = a.cityCode
                map["adCode"] = a.adCode
                map["street"] = a.street
                map["number"] = a.streetNum
                map["poiName"] = a.poiName
                map["aoiName"] = a.aoiName
            }
            map["code"] = a.errorCode
        }
        return map
    }


}

