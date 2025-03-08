package fl.amap

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import com.amap.api.fence.DistrictItem
import com.amap.api.fence.GeoFence
import com.amap.api.fence.GeoFenceClient
import com.amap.api.fence.GeoFenceListener
import com.amap.api.fence.PoiItem
import com.amap.api.location.DPoint
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AMapGeoFence(plugin: FlutterPlugin.FlutterPluginBinding) : MethodChannel.MethodCallHandler {

    private var channel: MethodChannel = MethodChannel(plugin.binaryMessenger, "fl.amap.GeoFence")

    private val context = plugin.applicationContext

    init {
        channel.setMethodCallHandler(this)
    }

    private lateinit var result: MethodChannel.Result

    private var handler: Handler = Handler(context.mainLooper)

    private val geoFenceBroadcastAction = "com.location.apis.geofence.broadcast"

    private var client: GeoFenceClient? = null


    private var isRegisterReceiver = false

    private val onGeoFenceListener =
        GeoFenceListener { geoFenceList: MutableList<GeoFence>?, errorCode: Int, customId: String? ->
            result.success(
                mapOf(
                    "customId" to customId,
                    "errorCode" to errorCode,
                    "geoFenceList" to geoFenceList?.map { it.data },
                )
            )
        }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        this.result = result
        when (call.method) {
            "initialize" -> {
                client ?: GeoFenceClient(context)
                val type = call.argument<Int>("action")!!
                if (type == 0) client!!.setActivateAction(
                    GeoFenceClient.GEOFENCE_IN
                )
                if (type == 1) client!!.setActivateAction(
                    GeoFenceClient.GEOFENCE_OUT
                )
                if (type == 2) client!!.setActivateAction(
                    GeoFenceClient.GEOFENCE_IN or GeoFenceClient.GEOFENCE_OUT
                )
                if (type == 3) client!!.setActivateAction(
                    GeoFenceClient.GEOFENCE_IN or GeoFenceClient.GEOFENCE_OUT or GeoFenceClient.GEOFENCE_STAYED
                )
                client!!.setGeoFenceListener(onGeoFenceListener)
                client!!.createPendingIntent(geoFenceBroadcastAction)
                val filter = IntentFilter()
                filter.addAction(geoFenceBroadcastAction)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    context.registerReceiver(
                        mGeoFenceReceiver, filter, Context.RECEIVER_NOT_EXPORTED
                    )
                } else {
                    context.registerReceiver(mGeoFenceReceiver, filter)
                }
                client!!.pauseGeoFence()
                isRegisterReceiver = true
                result.success(true)
            }

            "dispose" -> {
                if (resultFalse()) return
                if (isRegisterReceiver) context.unregisterReceiver(mGeoFenceReceiver)
                isRegisterReceiver = false
                client?.removeGeoFence()
                client = null
                result.success(true)
            }

            "getAll" -> {
                if (resultFalse()) return
                val geoFences = client!!.allGeoFence
                result.success(geoFences.map { geoFence -> geoFence.data })
            }

            "addPOI" -> {
                if (resultFalse()) return
                client!!.addGeoFence(
                    call.argument("keyword"),
                    call.argument("poiType"),
                    call.argument("city"),
                    call.argument<Int>("size")!!,
                    call.argument("customID")
                )
            }

            "addLatLng" -> {
                if (resultFalse()) return
                val centerPoint = DPoint()
                centerPoint.latitude = call.argument("latitude")!!
                centerPoint.longitude = call.argument("longitude")!!
                val aroundRadius = call.argument<Double>("aroundRadius")!!
                client!!.addGeoFence(
                    call.argument("keyword"),
                    call.argument("poiType"),
                    centerPoint,
                    aroundRadius.toFloat(),
                    call.argument<Int>("size")!!,
                    call.argument("customID")
                )
            }

            "addDistrict" -> {
                if (resultFalse()) return
                val keyword = call.argument<String>("keyword")!!
                val customId = call.argument<String>("customID")!!
                client!!.addGeoFence(keyword, customId)
            }

            "addCircle" -> {
                if (resultFalse()) return
                val centerPoint = DPoint()
                centerPoint.latitude = call.argument("latitude")!!
                centerPoint.longitude = call.argument("longitude")!!
                val radius = call.argument<Double>("radius")!!
                client!!.addGeoFence(
                    centerPoint, radius.toFloat(), call.argument("customID")
                )
            }

            "addCustom" -> {
                if (resultFalse()) return
                val points: MutableList<DPoint> = ArrayList()
                val latLngs = call.argument<MutableList<MutableMap<String, Double>>>(
                    "latLng"
                )!!
                latLngs.forEach { latLng ->
                    val dPoint = DPoint()
                    dPoint.latitude = latLng["latitude"]!!
                    dPoint.longitude = latLng["longitude"]!!
                    points.add(dPoint)
                }
                client!!.addGeoFence(
                    points, call.argument("customID")
                )
            }

            "remove" -> {
                client?.let {
                    val customId = call.arguments as String?
                    if (customId == null) {
                        it.removeGeoFence()
                    } else {
                        val geoFence = GeoFence()
                        geoFence.customId = customId
                        it.removeGeoFence(geoFence)
                    }
                }
                result.success(client != null)
            }

            "pause" -> {
                client?.pauseGeoFence()
                result.success(client != null)
            }

            "resume" -> {
                client?.resumeGeoFence()
                result.success(client != null)
            }

            else -> result.notImplemented()
        }
    }

    private fun resultFalse(): Boolean {
        if (client == null) {
            result.success(false)
            return true
        }
        return false
    }


    private val mGeoFenceReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent) {
            if (intent.action.equals(geoFenceBroadcastAction)) {
                //解析广播内容
                val bundle = intent.extras
                if (bundle != null) {
                    val map: MutableMap<String, Any?> = HashMap()
                    //获取围栏行为：
                    map["status"] = bundle.getInt(GeoFence.BUNDLE_KEY_FENCESTATUS)
                    //获取自定义的围栏标识：
                    map["customID"] = bundle.getString(GeoFence.BUNDLE_KEY_CUSTOMID)
                    //获取围栏ID:
                    map["fenceID"] = bundle.getString(GeoFence.BUNDLE_KEY_FENCEID)
                    //获取当前有触发的围栏对象：
                    val fence: GeoFence? =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            bundle.getParcelable(GeoFence.BUNDLE_KEY_FENCE, GeoFence::class.java)
                        } else {
                            bundle.getParcelable(GeoFence.BUNDLE_KEY_FENCE)
                        }
                    map["fence"] = fence?.data
                    map["type"] = fence?.type
                    handler.post {
                        channel.invokeMethod("onGeoFencesStatus", map)
                    }
                }
            }
        }
    }


    val GeoFence.data: Map<String, Any>
        get() = mapOf(
            "customID" to customId,
            "fenceID" to fenceId,
            "type" to type,
            "radius" to radius.toDouble(),
            "status" to status,
            "pointList" to pointList.map { points -> points.map { point -> point.data } },
            "center" to center.data,
            "poiItem" to poiItem.data,
        )

    val DistrictItem.data: Map<String, Any>
        get() = mapOf(
            "adCode" to adcode,
            "cityCode" to citycode,
            "districtName" to districtName,
            "pointList" to polyline.map { point -> point.data },
        )
    private val DPoint.data: Map<String, Any>
        get() = mapOf(
            "latitude" to latitude,
            "longitude" to longitude,
        )

    private val PoiItem.data: Map<String, Any>
        get() = mapOf(
            "latLng" to mapOf(
                "latitude" to latitude,
                "longitude" to longitude,
            ),
            "address" to address,
            "poiName" to poiName,
            "adName" to adname,
            "city" to city,
            "poiId" to poiId,
            "poiType" to poiType
        )

    fun detached() {
        channel.setMethodCallHandler(null)
    }

}
