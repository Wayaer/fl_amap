package fl.amap.map

import android.location.Location
import com.amap.api.fence.GeoFence
import com.amap.api.fence.PoiItem
import com.amap.api.location.AMapLocation
import com.amap.api.location.DPoint
import com.amap.api.maps.model.CameraPosition
import com.amap.api.maps.model.LatLng
import com.amap.api.maps.model.Marker
import com.amap.api.maps.model.Poi

val Location.data: Map<String, Any?>
    get() = mapOf(
        "accuracy" to accuracy,
        "altitude" to altitude,
        "speed" to speed,
        "timestamp" to (time.toDouble() / 1000),
        "latLng" to mapOf(
            "latitude" to latitude,
            "longitude" to longitude,
        ),
        "provider" to provider,
        "bearing" to bearing,
    )

val LatLng.data: Map<String, Any>
    get() = mapOf(
        "latitude" to latitude,
        "longitude" to longitude,
    )
val CameraPosition.data: Map<String, Any>
    get() = mapOf(
        "target" to target.data,
        "zoom" to zoom,
        "tilt" to tilt,
        "bearing" to bearing,
        "isAbroad" to isAbroad,
    )

val Marker.data: Map<String, Any>
    get() = mapOf(
        "title" to options.title,
        "latLng" to options.position.data,
        "snippet" to snippet,
        "draggable" to isDraggable,
        "visible" to isVisible,
        "alpha" to alpha,
    )

val Poi.data: Map<String, Any>
    get() = mapOf(
        "latLng" to coordinate.data,
        "name" to name,
        "poiId" to poiId,
    )
