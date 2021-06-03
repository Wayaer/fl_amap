package fl.amap

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import com.amap.api.fence.GeoFence
import com.amap.api.fence.GeoFenceClient
import com.amap.api.fence.GeoFenceClient.*
import com.amap.api.fence.GeoFenceListener
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.DPoint
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.ArrayList


class AMapPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var result: MethodChannel.Result
    private var channel: MethodChannel? = null

    //定义接收广播的action字符串
    private val geoFenceBroadcastAction = "com.location.apis.geofencedemo.broadcast"

    private var option: AMapLocationClientOption? = null
    private var locationClient: AMapLocationClient? = null
    private var geoFenceClient: GeoFenceClient? = null
    private var onceLocation = false

    // 是否在定位
    private var isLocation = false

    // 是否开启围栏
    private var isGeoFence = false


    override fun onAttachedToEngine(plugin: FlutterPlugin.FlutterPluginBinding) {
        context = plugin.applicationContext
        channel = MethodChannel(plugin.binaryMessenger, "fl_amap")
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, _result: MethodChannel.Result) {
        result = _result
        //显然下面的任何方法都应该放在同步块处理
        when (call.method) {
            "setApiKey" -> {
                val key = call.arguments as String
                AMapLocationClient.setApiKey(key)
                result.success(true)
            }
            "initLocation" -> {
                //初始化client
                if (locationClient == null) locationClient =
                    AMapLocationClient(context)
                //设置定位参数
                if (option == null) option = AMapLocationClientOption()
                parseOptions(option, call.arguments as Map<*, *>)
                locationClient!!.setLocationOption(option)
                result.success(true)
            }
            "disposeLocation" -> {
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
                    try {
                        locationClient?.setLocationListener { location ->
                            locationClient?.stopLocation()
                            result.success(resultToMap(location))
                        }
                        locationClient?.startLocation()
                    } catch (e: Exception) {
                        result.success(null)
                        locationClient?.stopLocation()
                    }
                }
            }
            "startLocation" -> {
                if (locationClient == null || option == null) {
                    result.success(false)
                } else {
                    option!!.isOnceLocation = false
                    locationClient?.setLocationOption(option)
                    locationClient!!.setLocationListener { location ->
                        channel!!.invokeMethod(
                            "updateLocation",
                            resultToMap(location)
                        )
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
            "initGeoFence" -> {
                geoFenceClient = GeoFenceClient(context)
                val type = call.argument<Int>("action")!!
                if (type == 0) geoFenceClient!!.setActivateAction(
                    GEOFENCE_IN
                )
                if (type == 1) geoFenceClient!!.setActivateAction(
                    GEOFENCE_OUT
                )
                if (type == 2) geoFenceClient!!.setActivateAction(
                    GEOFENCE_IN or GEOFENCE_OUT
                )
                if (type == 3) geoFenceClient!!.setActivateAction(
                    GEOFENCE_IN or GEOFENCE_OUT or GEOFENCE_STAYED
                )
                geoFenceClient!!.setGeoFenceListener(onGeoFenceCreateFinished)
                result.success(true)
            }
            "disposeGeoFence" -> {
                if (resultFalse()) return
                geoFenceClient?.removeGeoFence()
                geoFenceClient = null
                result.success(true)
            }
            "getAllGeoFence" -> {
                if (resultFalse()) return
                val geoFences = geoFenceClient!!.allGeoFence
                result.success(getAllGeoFence(geoFences))
            }
            "pauseGeoFence" -> {
                if (resultFalse()) return
                geoFenceClient!!.pauseGeoFence()
                result.success(true)
            }
            "resumeGeoFence" -> {
                if (resultFalse()) return
                geoFenceClient!!.resumeGeoFence()
                result.success(true)
            }
            "addGeoFenceWithPOI" -> {
                if (resultFalse()) return
                geoFenceClient!!.addGeoFence(
                    call.argument("keyword"),
                    call.argument("poiType"),
                    call.argument("city"),
                    call.argument<Int>("size")!!,
                    call.argument("customID")
                )
            }
            "addAMapGeoFenceWithLatLong" -> {
                if (resultFalse()) return
                val centerPoint = DPoint()
                centerPoint.latitude = call.argument("latitude")!!
                centerPoint.longitude = call.argument("longitude")!!
                val aroundRadius =
                    call.argument<Double>("aroundRadius")!!
                geoFenceClient!!.addGeoFence(
                    call.argument("keyword"),
                    call.argument("poiType"),
                    centerPoint,
                    aroundRadius.toFloat(),
                    call.argument<Int>("size")!!,
                    call.argument("customID")
                )
            }
            "addGeoFenceWithDistrict" -> {
                if (resultFalse()) return
                val keyword = call.argument<String>("keyword")!!
                val customId = call.argument<String>("customID")!!
                geoFenceClient!!.addGeoFence(keyword, customId)
            }
            "addCircleGeoFence" -> {
                if (resultFalse()) return
                val centerPoint = DPoint()
                centerPoint.latitude = call.argument("latitude")!!
                centerPoint.longitude = call.argument("longitude")!!
                val radius =
                    call.argument<Double>("radius")!!
                geoFenceClient!!.addGeoFence(
                    centerPoint, radius.toFloat(),
                    call.argument("customID")
                )
            }
            "addCustomGeoFence" -> {
                if (resultFalse()) return
                val points: MutableList<DPoint> = ArrayList()
                val latLongs =
                    call.argument<MutableList<MutableMap<String, Double>>>(
                        "latLong"
                    )!!
                latLongs.forEach { latLong ->
                    val dPoint = DPoint()
                    dPoint.latitude = latLong["latitude"]!!
                    dPoint.longitude = latLong["longitude"]!!
                    points.add(dPoint)
                }

                geoFenceClient!!.addGeoFence(
                    points,
                    call.argument("customID")
                )
            }
            "startGeoFence" -> {
                if (resultFalse()) return
                if (!isGeoFence) {
                    geoFenceClient!!.createPendingIntent(geoFenceBroadcastAction)
                    val filter = IntentFilter()
                    filter.addAction(geoFenceBroadcastAction)
                    context.registerReceiver(mGeoFenceReceiver, filter)
                    isGeoFence = true
                    result.success(true)
                }
                result.success(false)
            }
            "registerGeoFenceService" -> {
                if (resultFalse()) return
                if (isGeoFence) {
                    context.unregisterReceiver(mGeoFenceReceiver)
                    isGeoFence = false
                    result.success(true)
                }
                result.success(false)

            }
            "unregisterGeoFenceService" -> {
                if (resultFalse()) return
                val customId = call.arguments as String?
                if (customId == null) {
                    geoFenceClient?.removeGeoFence()
                } else {
                    val geoFence = GeoFence()
                    geoFence.customId = customId
                    geoFenceClient?.removeGeoFence(geoFence)
                }
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun resultFalse(): Boolean {
        if (geoFenceClient == null) {
            result.success(false)
            return true
        }
        return false
    }

    private fun getAllGeoFence(geoFences: List<GeoFence>): MutableList<MutableMap<String, Any?>> {
        val list: MutableList<MutableMap<String, Any?>> = ArrayList()
        geoFences.forEach { geoFence: GeoFence? ->
            if (geoFence != null) {
                val map: MutableMap<String, Any?> = HashMap()
                map["customID"] = geoFence.customId
                map["fenceID"] = geoFence.fenceId
                map["type"] = geoFence.type
                map["radius"] = geoFence.radius.toDouble()
                map["status"] = geoFence.status

                val dPoint = geoFence.center
                val center: MutableMap<String, Any?> = HashMap()
                center["latitude"] = dPoint.latitude
                center["longitude"] = dPoint.longitude

                map["center"] = center

                val poi: MutableMap<String, Any?> = HashMap()
                val poiItem = geoFence.poiItem
                poi["address"] = poiItem?.address
                poi["poiName"] = poiItem?.poiName
                poi["adName"] = poiItem?.adname
                poi["city"] = poiItem?.city
                poi["poiId"] = poiItem?.poiId
                poi["poiType"] = poiItem?.poiType
                poi["latitude"] = poiItem?.latitude
                poi["longitude"] = poiItem?.longitude
                map["poiItem"] = poi

                val pointList = geoFence.pointList
                val pointListMap: MutableList<MutableList<MutableMap<String, Any?>>> = ArrayList()
                pointList.forEach { points ->
                    val pointsMap: MutableList<MutableMap<String, Any?>> = ArrayList()
                    points.forEach { point ->
                        val pointMap: MutableMap<String, Any?> = HashMap()
                        pointMap["latitude"] = point.latitude
                        pointMap["longitude"] = point.longitude
                        pointsMap.add(pointMap)
                    }
                    pointListMap.add(pointsMap)
                }

                map["pointList"] = pointListMap
                list.add(map)
            }
        }
        return list
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
    private fun parseOptions(
        option: AMapLocationClientOption?,
        arguments: Map<*, *>
    ) {
        onceLocation = (arguments["onceLocation"] as Boolean?)!!
        //可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
        option!!.locationMode =
            AMapLocationClientOption.AMapLocationMode.valueOf((arguments["locationMode"] as String?)!!)
        //可选，设置是否gps优先，只在高精度模式下有效。默认关闭
        option.isGpsFirst = (arguments["gpsFirst"] as Boolean?)!!
        //可选，设置网络请求超时时间。默认为30秒。在仅设备模式下无效
        option.httpTimeOut = (arguments["httpTimeOut"] as Int).toLong()
        //可选，设置定位间隔。默认为2秒
        option.interval = (arguments["interval"] as Int).toLong()
        //可选，设置是否返回逆地理地址信息。默认是true
        option.isNeedAddress = (arguments["needsAddress"] as Boolean?)!!
        option.isOnceLocation = onceLocation //可选，设置是否单次定位。默认是false
        option.isOnceLocationLatest =
            (arguments["onceLocationLatest"] as Boolean?)!!
        //可选，设置是否等待wifi刷新，默认为false.如果设置为true,会自动变为单次定位，持续定位时不要使用
        AMapLocationClientOption.setLocationProtocol(
            AMapLocationClientOption.AMapLocationProtocol.valueOf(
                (arguments["locationProtocol"] as String?)!!
            )
        ) //可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
        //可选，设置是否使用传感器。默认是false
        option.isSensorEnable = (arguments["sensorEnable"] as Boolean?)!!
        //可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
        option.isWifiScan = (arguments["wifiScan"] as Boolean?)!!
        //可选，设置是否使用缓存定位，默认为true
        option.isLocationCacheEnable =
            (arguments["locationCacheEnable"] as Boolean?)!!
        //可选，设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言）
        option.geoLanguage =
            AMapLocationClientOption.GeoLanguage.valueOf((arguments["geoLanguage"] as String?)!!)
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


    private val onGeoFenceCreateFinished =
        GeoFenceListener { _: MutableList<GeoFence>?, errorCode: Int, _: String? ->
            //geoFenceList是已经添加的围栏列表，可据此查看创建的围栏
            //判断围栏是否创建成功
            if (errorCode == GeoFence.ADDGEOFENCE_SUCCESS) {
                // 添加围栏成功
                result.success(true)
            } else {
                // 添加围栏失败
                result.success(false)
            }

        }


    private val mGeoFenceReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent) {
            if (intent.action.equals(geoFenceBroadcastAction)) {
                //解析广播内容
                val bundle: Bundle? = intent.extras
                if (bundle != null) {
                    //获取围栏行为：
                    val status: Int = bundle.getInt(GeoFence.BUNDLE_KEY_FENCESTATUS)
                    //获取自定义的围栏标识：
                    val customId: String? = bundle.getString(GeoFence.BUNDLE_KEY_CUSTOMID)
                    //获取围栏ID:
                    val fenceId: String? = bundle.getString(GeoFence.BUNDLE_KEY_FENCEID)
                    //获取当前有触发的围栏对象：
                    val fence: GeoFence? = bundle.getParcelable(GeoFence.BUNDLE_KEY_FENCE)
                    val map: MutableMap<String, Any?> = HashMap()
                    map["status"] = status
                    map["customID"] = customId
                    map["fenceID"] = fenceId
                    if (fence != null) {
                        val fenceMap: MutableMap<String, Any?> = HashMap()
                        fenceMap["type"] = fence.type
                        fenceMap["customID"] = fence.customId
                        fenceMap["fenceID"] = fence.fenceId
                        fenceMap["radius"] = fence.radius.toDouble()

                        map["fence"] = fenceMap
                    }
                    channel?.invokeMethod("updateGeoFence", map)
                }
            }
        }
    }
}
