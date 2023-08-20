package fl.amap.map

import android.location.Location
import com.amap.api.fence.GeoFence
import com.amap.api.fence.PoiItem
import com.amap.api.location.AMapLocation
import com.amap.api.location.DPoint
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
val AMapLocation.data: Map<String, Any?>
    get() = mapOf(
            "code" to errorCode,
            "description" to errorInfo,
            "accuracy" to accuracy,
            "altitude" to altitude,
            "speed" to speed,
            "timestamp" to (time.toDouble() / 1000),
            "latLng" to mapOf(
                    "latitude" to latitude,
                    "longitude" to longitude,
            ),
            "locationType" to locationType,
            "provider" to provider,
            "formattedAddress" to address,
            "country" to country,
            "province" to province,
            "city" to city,
            "district" to district,
            "cityCode" to cityCode,
            "adCode" to adCode,
            "street" to street,
            "number" to streetNum,
            "poiName" to poiName,
            "aoiName" to aoiName
    )
val DPoint.data: Map<String, Any>
    get() = mapOf(
            "latitude" to latitude,
            "longitude" to longitude,
    )

val LatLng.data: Map<String, Any>
    get() = mapOf(
            "latitude" to latitude,
            "longitude" to longitude,
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

val PoiItem.data: Map<String, Any>
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

