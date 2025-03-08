import fl_channel
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

    public func mapViewRegionChanged(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "mapViewRegionChanged"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, regionWillChangeAnimated animated: Bool) {
        var map = getIdMap()
        map["method"] = "regionWillChangeAnimated"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        var map = getIdMap()
        map["method"] = "regionDidChangeAnimated"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool, wasUserAction: Bool) {
        var map = getIdMap()
        map["method"] = "regionDidChangeAnimatedWasUserAction"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, regionWillChangeAnimated animated: Bool, wasUserAction: Bool) {
        var map = getIdMap()
        map["method"] = "regionWillChangeAnimatedWasUserAction"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, mapWillMoveByUser wasUserAction: Bool) {
        var map = getIdMap()
        map["method"] = "mapWillMoveByUser"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        var map = getIdMap()
        map["method"] = "mapDidMoveByUser"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, mapWillZoomByUser wasUserAction: Bool) {
        var map = getIdMap()
        map["method"] = "mapWillZoomByUser"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, mapDidZoomByUser wasUserAction: Bool) {
        var map = getIdMap()
        map["method"] = "mapDidZoomByUser"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapViewWillStartLoadingMap(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "mapViewWillStartLoadingMap"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "mapViewDidFinishLoadingMap"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapViewDidFailLoadingMap(_ mapView: MAMapView!, withError error: (any Error)!) {
        var map = getIdMap()
        map["method"] = "mapViewDidFailLoadingMap"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didFailLoadTerrainWithError error: (any Error)!) {
        var map = getIdMap()
        map["method"] = "didFailLoadTerrainWithError"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didAddAnnotationViews views: [Any]!) {
        var map = getIdMap()
        map["method"] = "didAddAnnotationViews"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        var map = getIdMap()
        map["method"] = "didSelectAnnotationView"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didDeselect view: MAAnnotationView!) {
        var map = getIdMap()
        map["method"] = "didDeselectAnnotationView"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapViewWillStartLocatingUser(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "mapViewWillStartLocatingUser"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapViewDidStopLocatingUser(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "mapViewDidStopLocatingUser"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didUpdate location: MAUserLocation, updatingLocation: Bool) {
        var map = getIdMap()
        map["method"] = "didUpdateUserLocation"
        map.merge(location.location?.data ?? [:])
        map["heading"] = location.heading?.data
        map["isUpdating"] = location.isUpdating
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapViewRequireLocationAuth(_ locationManager: CLLocationManager!) {
        var map = getIdMap()
        map["method"] = "mapViewRequireLocationAuth"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didFailToLocateUserWithError error: Error!) {
        var map = getIdMap()
        map["method"] = "didFailToLocateUserWithError"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, didChange newState: MAAnnotationViewDragState, fromOldState oldState: MAAnnotationViewDragState) {
        var map = getIdMap()
        map["method"] = "annotationViewDidChangeDragState"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer? {
        var map = getIdMap()
        map["method"] = "rendererForOverlay"
        _ = AMapMapPlugin.flEventChannel?.send(map)
        return nil
    }

    func mapView(_ mapView: MAMapView!, didAddOverlayRenderers overlayRenderers: [Any]!) {
        var map = getIdMap()
        map["method"] = "didAddOverlayRenderers"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        var map = getIdMap()
        map["method"] = "annotationViewCalloutAccessoryControlTapped"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didAnnotationViewCalloutTapped view: MAAnnotationView!) {
        var map = getIdMap()
        map["method"] = "didAnnotationViewCalloutTapped"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didAnnotationViewTapped view: MAAnnotationView!) {
        var map = getIdMap()
        map["method"] = "didAnnotationViewTapped"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didChange mode: MAUserTrackingMode, animated: Bool) {
        var map = getIdMap()
        map["method"] = "didChangeUserTrackingMode"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didChangeOpenGLESDisabled openGLESDisabled: Bool) {
        var map = getIdMap()
        map["method"] = "didChangeOpenGLESDisabled"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        var map = getIdMap()
        map["method"] = "didTouchPois"
        map["poi"] = (pois as! [MATouchPoi]).map {
            $0.data
        }
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        var map = getIdMap()
        map["method"] = "didSingleTappedAtCoordinate"
        map.merge(coordinate.data)
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapView(_ mapView: MAMapView!, didLongPressedAt coordinate: CLLocationCoordinate2D) {
        var map = getIdMap()
        map["method"] = "didLongPressedAtCoordinate"
        map.merge(coordinate.data)
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func mapInitComplete(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "mapInitComplete"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didIndoorMapShowed indoorInfo: MAIndoorInfo!) {
        var map = getIdMap()
        map["method"] = "didIndoorMapShowed"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didIndoorMapFloorIndexChanged indoorInfo: MAIndoorInfo!) {
        var map = getIdMap()
        map["method"] = "didIndoorMapFloorIndexChanged"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func mapView(_ mapView: MAMapView!, didIndoorMapHidden indoorInfo: MAIndoorInfo!) {
        var map = getIdMap()
        map["method"] = "didIndoorMapHidden"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func offlineDataDidReload(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "offlineDataDidReload"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    func offlineDataWillReload(_ mapView: MAMapView!) {
        var map = getIdMap()
        map["method"] = "offlineDataWillReload"
        _ = AMapMapPlugin.flEventChannel?.send(map)
    }

    public func getIdMap() -> [String: Any?] {
        ["id": viewId]
    }
}
