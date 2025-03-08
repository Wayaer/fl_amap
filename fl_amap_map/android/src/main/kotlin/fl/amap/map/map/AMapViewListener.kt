package fl.amap.map.map

import android.graphics.Bitmap
import android.graphics.Rect
import android.location.Location
import android.view.MotionEvent
import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.CustomRenderer
import com.amap.api.maps.LocationSource
import com.amap.api.maps.SwipeDismissTouchListener
import com.amap.api.maps.WearMapView
import com.amap.api.maps.model.*
import com.autonavi.base.ae.gmap.AMapAppRequestParam
import fl.amap.map.AMapMapPlugin.Companion.flEventChannel
import fl.amap.map.data
import fl.channel.FlChannelPlugin
import fl.channel.FlEventChannel
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

// AMap.CancelableCallback, AMap.ImageInfoWindowAdapter,AMap.OnCacheRemoveListener,AMap.InfoWindowAdapter, AMap.OnMapScreenShotListener, AMap.OnMapSnapshotListener, AMap.OnPolylineClickListener, CustomRenderer, LocationSource, LocationSource.OnLocationChangedListener, AMap.OnMultiPointClickListener,  SwipeDismissTouchListener.DismissCallbacks, WearMapView.OnDismissCallback
class AMapViewListener(private var viewId: Int, private var map: AMap) : AMap.AMapAppResourceRequestListener,

    AMap.OnCameraChangeListener, AMap.OnIndoorBuildingActiveListener, AMap.OnInfoWindowClickListener,
    AMap.OnMapClickListener, AMap.OnMapLoadedListener, AMap.OnMapLongClickListener, AMap.OnMapTouchListener,
    AMap.OnMarkerClickListener, AMap.OnMarkerDragListener, AMap.OnMyLocationChangeListener, AMap.OnPOIClickListener {

    init {
        map.addAMapAppResourceListener(this)
        map.addOnCameraChangeListener(this)
        map.addOnIndoorBuildingActiveListener(this)
        map.addOnInfoWindowClickListener(this)
        map.addOnMapClickListener(this)
        map.addOnMapLoadedListener(this)
        map.addOnMapLongClickListener(this)
        map.addOnMapTouchListener(this)
        map.addOnMarkerClickListener(this)
        map.addOnMarkerDragListener(this)
        map.addOnMyLocationChangeListener(this)
        map.addOnPOIClickListener(this)
    }

    override fun onMapLoaded() {
        val map = getIdMap()
        map["method"] = "onMapLoaded"
        flEventChannel?.send(map)
    }

    override fun onMyLocationChange(location: Location?) {
        val map = getIdMap()
        map["method"] = "onMyLocationChange"
        location?.data?.let { map.putAll(it) }
        flEventChannel?.send(map)
    }

    override fun onCameraChange(position: CameraPosition?) {
        val map = getIdMap()
        map["method"] = "onCameraChange"
        position?.data?.let { map.putAll(it) }
        flEventChannel?.send(map)
    }

    override fun onCameraChangeFinish(position: CameraPosition?) {
        val map = getIdMap()
        map["method"] = "onCameraChangeFinish"
        position?.data?.let { map.putAll(it) }
        flEventChannel?.send(map)
    }

    override fun onMapClick(latlng: LatLng?) {
        val map = getIdMap()
        map["method"] = "onMapClick"
        latlng?.let { map.putAll(it.data) }
        flEventChannel?.send(map)
    }

    override fun onMapLongClick(latlng: LatLng?) {
        val map = getIdMap()
        map["method"] = "onMapLongClick"
        latlng?.let { map.putAll(it.data) }
        flEventChannel?.send(map)
    }

    override fun onPOIClick(poi: Poi?) {
        val map = getIdMap()
        map["method"] = "onPOIClick"
        poi?.let { map["poi"] = listOf(it.data) }
        flEventChannel?.send(map)
    }

    override fun onMarkerClick(marker: Marker?): Boolean {
        val map = getIdMap()
        map["method"] = "onMarkerClick"
        marker?.let { map.putAll(it.data) }
        flEventChannel?.send(map)
        return true
    }

    override fun onMarkerDragStart(marker: Marker?) {
        val map = getIdMap()
        map["method"] = "onMarkerDragStart"
        marker?.let { map.putAll(it.data) }
        flEventChannel?.send(map)
    }

    override fun onMarkerDrag(marker: Marker?) {
        val map = getIdMap()
        map["method"] = "onMarkerDrag"
        marker?.let { map.putAll(it.data) }
        flEventChannel?.send(map)
    }

    override fun onMarkerDragEnd(marker: Marker?) {
        val map = getIdMap()
        map["method"] = "onMarkerDragEnd"
        marker?.let { map.putAll(it.data) }
        flEventChannel?.send(map)
    }


    override fun onRequest(param: AMapAppRequestParam?) {
        val map = getIdMap()
        map["method"] = "onRequest"
        flEventChannel?.send(map)
    }


    override fun OnIndoorBuilding(info: IndoorBuildingInfo?) {
        val map = getIdMap()
        map["method"] = "onIndoorBuilding"
        flEventChannel?.send(map)
    }

    override fun onInfoWindowClick(marker: Marker?) {
        val map = getIdMap()
        map["method"] = "onInfoWindowClick"
        marker?.let { map.putAll(it.data) }
        flEventChannel?.send(map)
    }


    override fun onTouch(event: MotionEvent?) {
        val map = getIdMap()
        map["method"] = "onTouch"
        flEventChannel?.send(map)
    }


    private fun getIdMap(): MutableMap<String, Any?> {
        return mutableMapOf("id" to viewId)
    }

    fun removeListener() {
        map.removeAMapAppResourceListener(this)
        map.removeOnCameraChangeListener(this)
        map.removeOnIndoorBuildingActiveListener(this)
        map.removeOnInfoWindowClickListener(this)
        map.removeOnMapClickListener(this)
        map.removeOnMapLoadedListener(this)
        map.removeOnMapLongClickListener(this)
        map.removeOnMapTouchListener(this)
        map.removeOnMarkerClickListener(this)
        map.removeOnMarkerDragListener(this)
        map.removeOnMyLocationChangeListener(this)
        map.removeOnPOIClickListener(this)
    }

}