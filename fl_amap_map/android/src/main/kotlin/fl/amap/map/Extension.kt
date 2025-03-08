package fl.amap.map

import android.location.Location
import com.amap.api.maps.model.*
import com.autonavi.amap.mapcore.DPoint
import com.autonavi.amap.mapcore.IPoint

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
val IPoint.data: Map<String, Any>
    get() = mapOf(
        "x" to x,
        "y" to y,
    )
val DPoint.data: Map<String, Any>
    get() = mapOf(
        "x" to x,
        "y" to y,
    )
val CameraPosition.data: Map<String, Any>
    get() = mapOf(
        "target" to target.data,
        "zoom" to zoom,
        "tilt" to tilt,
        "bearing" to bearing,
        "isAbroad" to isAbroad,
    )


val MarkerOptions.data: Map<String, Any?>
    get() = mapOf(
        "anchorU" to anchorU,
        "anchorV" to anchorV,
        "infoWindowOffsetX" to infoWindowOffsetX,
        "infoWindowOffsetY" to infoWindowOffsetY,
        "alpha" to alpha,
        "altitude" to altitude,
        "period" to period,
        "position" to position,
        "rotateAngle" to rotateAngle,
        "snippet" to snippet,
        "title" to title,
        "zIndex" to zIndex,
        "isDraggable" to isDraggable,
        "isVisible" to isVisible,
        "isFlat" to isFlat,
        "isInfoWindowAutoOverturn" to isInfoWindowAutoOverturn,
        "isInfoWindowEnable" to isInfoWindowEnable,
    )
val Marker.data: Map<String, Any?>
    get() = mapOf(
        "options" to options.data,
        "alpha" to alpha,
        "altitude" to altitude,
        "id" to id,
        "period" to period,
        "position" to position,
        "rotateAngle" to rotateAngle,
        "snippet" to snippet,
        "title" to title,
        "zIndex" to zIndex,
        "geoPoint" to geoPoint.data,
        "isRemoved" to isRemoved,
        "isClickable" to isClickable,
        "isDraggable" to isDraggable,
        "isVisible" to isVisible,
        "isFlat" to isFlat,
        "isViewMode" to isViewMode,
        "isInfoWindowAutoOverturn" to isInfoWindowAutoOverturn,
        "isInfoWindowEnable" to isInfoWindowEnable,
    )


val Poi.data: Map<String, Any>
    get() = mapOf(
        "latLng" to coordinate.data,
        "name" to name,
        "poiId" to poiId,
    )
