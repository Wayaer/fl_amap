package fl.amap.map.map

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.TextureMapView
import com.amap.api.maps.model.*
import fl.amap.map.AMapMapPlugin.Companion.lifecycle
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding.OnSaveInstanceStateListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView


class AMapView(
    context: Context?, private var channel: MethodChannel, private var viewId: Int, args: Map<*, *>
) : DefaultLifecycleObserver, OnSaveInstanceStateListener, MethodCallHandler, PlatformView {
    private var mapview: TextureMapView
    private var mapViewListener: AMapViewListener? = null

    init {
        channel.setMethodCallHandler(this)
        mapview = TextureMapView(context)
        setOptions(args)
        mapViewListener = AMapViewListener(viewId, mapview.map)
        lifecycle?.addObserver(this)
    }

    override fun onCreate(owner: LifecycleOwner) {
        mapview.onCreate(null)
    }

    override fun onResume(owner: LifecycleOwner) {
        mapview.onResume()
    }

    override fun onPause(owner: LifecycleOwner) {
        mapview.onPause()
    }

    override fun onDestroy(owner: LifecycleOwner) {
        mapview.onDestroy()
        lifecycle?.removeObserver(this)
    }

    override fun onSaveInstanceState(bundle: Bundle) {
        mapview.onSaveInstanceState(bundle)
    }

    override fun onRestoreInstanceState(bundle: Bundle?) {
        mapview.onCreate(bundle)
    }

    override fun getView(): View {
        return mapview
    }

    override fun dispose() {

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setOptions" -> setOptions(call.arguments as Map<*, *>)
            "dispose" -> {
                mapViewListener?.removeListener()
                mapViewListener = null
                channel.setMethodCallHandler(null)
                mapview.onDestroy()
                lifecycle?.removeObserver(this)
            }

            "setCenter" -> {
                val animated = call.argument<Boolean>("animated")!!
                val cameraUpdate = CameraUpdateFactory.newCameraPosition(
                    CameraPosition(
                        LatLng(
                            call.argument<Double>("latitude")!!,
                            call.argument<Double>("longitude")!!
                        ),
                        call.argument<Double>("zoom")!!.toFloat(),
                        call.argument<Double>("tilt")!!.toFloat(),
                        call.argument<Double>("bearing")!!.toFloat()
                    )
                )
                if (animated) {
                    mapview.map.animateCamera(cameraUpdate)
                } else {
                    mapview.map.moveCamera(cameraUpdate)
                }
                result.success(true)
            }

            "reloadMap" -> {
                mapview.map.reloadMap()
                result.success(true)
            }

            "setRenderFps" -> {
                mapview.map.setRenderFps(call.arguments as Int)
                result.success(true)
            }

            "setTrackingMode" -> {
                val mode = call.argument<Int>("mode") ?: 0
                val locationStyle = MyLocationStyle()
                locationStyle.myLocationType(mode)
                mapview.map.myLocationStyle = locationStyle
                result.success(true)
            }

            "addMarker" -> {
                val markerOptions = MarkerOptions()
                val marker = mapview.map.addMarker(markerOptions)
                result.success(marker.id)
            }

            else -> result.notImplemented()
        }
    }

    private fun setOptions(args: Map<*, *>) {
        val map = mapview.map
        val options = map.uiSettings
        options.isZoomControlsEnabled = false
        val latitude = args["latitude"] as Double
        val longitude = args["longitude"] as Double
        val zoom = (args["zoom"] as Double).toFloat()
        val tilt = (args["tilt"] as Double).toFloat()
        val bearing = (args["bearing"] as Double).toFloat()
        map.moveCamera(
            CameraUpdateFactory.newCameraPosition(
                CameraPosition(LatLng(latitude, longitude), zoom, tilt, bearing)
            )
        )
        options.isRotateGesturesEnabled = args["isRotateGesturesEnabled"] as Boolean
        options.isCompassEnabled = args["showCompass"] as Boolean
        options.isScaleControlsEnabled = args["showScale"] as Boolean
        options.isScrollGesturesEnabled = args["isScrollGesturesEnabled"] as Boolean
        options.isZoomGesturesEnabled = args["isZoomGesturesEnabled"] as Boolean
        options.isTiltGesturesEnabled = args["isTiltGesturesEnabled"] as Boolean
        options.isMyLocationButtonEnabled = args["showUserLocationButton"] as Boolean
        map.isMyLocationEnabled = args["showUserLocation"] as Boolean
        options.setZoomInByScreenCenter(args["zoomingInPivotsAroundAnchorPoint"] as Boolean)
        map.mapType = (args["mapType"] as Int) + 1
        map.isTouchPoiEnable = args["isTouchPoiEnable"] as Boolean
        map.isTrafficEnabled = args["showTraffic"] as Boolean
        map.showIndoorMap(args["showIndoorMap"] as Boolean)
        map.showMapText(args["showMapText"] as Boolean)
        map.showBuildings(args["showBuildings"] as Boolean)
        val language = args["language"] as Int
        map.setMapLanguage(if (language == 0) AMap.CHINESE else AMap.ENGLISH)
        map.maxZoomLevel = (args["maxZoom"] as Double).toFloat()
        map.minZoomLevel = (args["minZoom"] as Double).toFloat()
    }


}