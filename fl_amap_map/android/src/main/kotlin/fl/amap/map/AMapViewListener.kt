package fl.amap.map

import android.location.Location
import com.amap.api.maps.AMap
import com.amap.api.maps.LocationSource
import com.amap.api.maps.model.*
import fl.amap.AMapMapPlugin.Companion.mapEvent
import fl.amap.data

class AMapViewListener(
    private var viewId: Int, private var map: AMap
) : AMap.OnMapLoadedListener, AMap.OnMyLocationChangeListener, AMap.OnCameraChangeListener,
    AMap.OnMarkerClickListener, AMap.OnMarkerDragListener, AMap.OnMapClickListener,
    AMap.OnMapLongClickListener, AMap.OnPOIClickListener, LocationSource.OnLocationChangedListener {


    init {
        map.addOnMapLoadedListener(this)
        map.addOnMyLocationChangeListener(this)
        map.addOnCameraChangeListener(this)
        map.addOnMapLongClickListener(this)
        map.addOnMapClickListener(this)
        map.addOnPOIClickListener(this)
    }

    override fun onMapLoaded() {
        // 地图加载完成监听接口
        val map = getIdMap()
        map["method"] = "Loaded"
        mapEvent?.sendEvent(map)
    }

    override fun onMyLocationChange(location: Location?) {
        // 用户定位信息监听接口。
        val map = getIdMap()
        map["method"] = "LocationChange"
        location?.data?.let { map.putAll(it) }
        mapEvent?.sendEvent(map)
    }

    override fun onCameraChange(position: CameraPosition?) {
        // 地图状态发生变化的监听接口
    }

    override fun onCameraChangeFinish(position: CameraPosition?) {
        // 地图状态发生变化完成的监听接口
    }

    override fun onMapClick(latlng: LatLng?) {
        // 地图点击事件监听接口。
        val map = getIdMap()
        map["method"] = "Pressed"
        latlng?.let { map.putAll(it.data) }
        mapEvent?.sendEvent(map)
    }

    override fun onMapLongClick(latlng: LatLng?) {
        // 地图长按事件监听接口。
        val map = getIdMap()
        map["method"] = "LongPressed"
        latlng?.let { map.putAll(it.data) }
        mapEvent?.sendEvent(map)
    }

    override fun onPOIClick(poi: Poi?) {
        // 地图poi点击事件监听接口。
        val map = getIdMap()
        map["method"] = "POIPressed"
        poi?.let { map["poi"] = listOf(it.data) }
        mapEvent?.sendEvent(map)
    }

    override fun onMarkerClick(marker: Marker?): Boolean {
        // marker点击事件监听接口。
        val map = getIdMap()
        map["method"] = "MarkerPressed"
        marker?.let { map.putAll(marker.data) }
        mapEvent?.sendEvent(map)
        return true
    }

    override fun onMarkerDragStart(marker: Marker?) {
        // marker开始拖拽事件监听接口。
    }

    override fun onMarkerDrag(marker: Marker?) {
        // marker拖拽事件监听接口。
    }

    override fun onMarkerDragEnd(marker: Marker?) {
        // marker结束拖拽事件监听接口。
    }

    override fun onLocationChanged(location: Location?) {
        // 当定位源获取的位置信息发生变化时回调此接口。
    }


    private fun getIdMap(): MutableMap<String, Any?> {
        return mutableMapOf("id" to viewId)
    }

    fun removeListener() {
        map.removeOnMapLoadedListener(this)
        map.removeOnMyLocationChangeListener(this)
        map.removeOnCameraChangeListener(this)
        map.removeOnMapLongClickListener(this)
        map.removeOnMapClickListener(this)
        map.removeOnPOIClickListener(this)
    }


}