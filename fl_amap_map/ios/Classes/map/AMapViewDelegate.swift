import Flutter
import Foundation
import MAMapKit

class AMapViewDelegate: NSObject, MAMapViewDelegate {
    private var mapview: MAMapView?
    private var viewId: Int64

    init(_ viewId: Int64) {
        self.viewId = viewId
        super.init()
    }

    public func mapViewWillStartLocatingUser(_ mapView: MAMapView!) {
        // ("启动定位")
    }

    public func mapViewDidStopLocatingUser(_ mapView: MAMapView!) {
        // ("停止定位")
    }

    public func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        // ("请求定位")
    }

    public func mapView(_ mapView: MAMapView!, didFailToLocateUserWithError error: Error!) {
        // ("定位失败")
    }

    public func mapView(_ mapView: MAMapView!, didUpdate location: MAUserLocation, updatingLocation: Bool) {
        var map = getIdMap()
        map["method"] = "LocationChange"
        map.merge(location.location?.data ?? [:])
        map["heading"] = location.heading?.data
        map["isUpdating"] = location.isUpdating
        _ = AMapMapPlugin.flMapEvent?.send(map)
    }

    public func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        // 地图加载完成
    }

    public func mapInitComplete(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "Loaded"
        _ = AMapMapPlugin.flMapEvent?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        // ("地图AddAnnotation")
    }

    public func mapView(_ mapView: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
        // ("地图Annotation被点击")
    }

    public func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, didChange newState: MAAnnotationViewDragState, fromOldState oldState: MAAnnotationViewDragState) {
        // ("地图Annotation被拖转")
    }

    public func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        // ("地图MAOverlay生成renderer")
        nil
    }

    public func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        var map = getIdMap()
        map["method"] = "Pressed"
        map.merge(coordinate.data)
        _ = AMapMapPlugin.flMapEvent?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
        var map = getIdMap()
        map["method"] = "LongPressed"
        map.merge(coordinate.data)
        _ = AMapMapPlugin.flMapEvent?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        var map = getIdMap()
        map["method"] = "POIPressed"
        map["poi"] = (pois as! [MATouchPoi]).map {
            $0.data
        }
        _ = AMapMapPlugin.flMapEvent?.send(map)
    }

    public func mapViewRegionChanged(_ mapView: MAMapView!) {
        // 地图区域改变过程中会调用此接口 since 4.6.0
    }

    public func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        // 地图区域改变完成后会调用此接口
    }

    public func getIdMap() -> [String: Any?] {
        ["id": viewId]
    }
}
