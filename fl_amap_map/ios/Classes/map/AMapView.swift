import AMapFoundationKit
import Flutter
import MAMapKit

public class AMapView: NSObject, FlutterPlatformView {
    private var channel: FlutterMethodChannel?
    private var mapview: MAMapView?
    private var viewId: Int64
    private var mapviewDelegate: AMapViewDelegate?

    init(channel: FlutterMethodChannel, frame: CGRect, viewId: Int64, options: [String: Any]) {
        self.channel = channel
        self.viewId = viewId
        mapview = MAMapView(frame: frame)
        super.init()
        channel.setMethodCallHandler(handle)
        mapview!.accessibilityElementsHidden = false
        setOptions(args: options)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setOptions":
            let options = call.arguments as! [String: Any]
            setOptions(args: options)
        case "reloadMap":
            mapview?.reloadMap()
            result(true)
        case "setRenderFps":
            mapview?.maxRenderFrame = UInt(call.arguments as! Int)
            result(true)
        case "setCenter":
            let args = call.arguments as! [String: Any]
            mapview?.setCenter(CLLocationCoordinate2D(latitude: args["latitude"] as! Double, longitude: args["longitude"] as! Double), animated: args["animated"] as! Bool)
            result(true)
        case "setTrackingMode":
            let args = call.arguments as! [String: Any]
            let mode = args["mode"] as! Int
            var trackingMode = MAUserTrackingMode.follow
            if mode == 0 {
                trackingMode = MAUserTrackingMode.none
            } else if mode == 7 {
                trackingMode = MAUserTrackingMode.followWithHeading
            }
            mapview?.setUserTrackingMode(trackingMode, animated: args["animated"] as! Bool)
            result(true)
        case "addListener":
            if (mapviewDelegate == nil && mapview != nil) {
                mapviewDelegate = AMapViewDelegate(viewId)
                mapview!.delegate = mapviewDelegate
            }
            result(mapviewDelegate != nil)
        case "addMarker":
            let point = MAPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: 39.979590, longitude: 116.352792)
//            mapview?.addAnnotation(pointAnnotation)
        case "removeListener":
            mapviewDelegate = nil
            mapview?.delegate = nil
            result(mapviewDelegate == nil)
        case "dispose":
            mapview = nil
            mapview?.removeObserver(self, forKeyPath: "frame")
            channel?.setMethodCallHandler(nil)
            channel = nil
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func setOptions(args: [String: Any?]) {
        let animated = args["animated"] as! Bool
        mapview?.rotationDegree = CGFloat(args["tilt"] as! Double)
        mapview?.isRotateEnabled = args["isTiltGesturesEnabled"] as! Bool
        mapview?.cameraDegree = CGFloat(args["bearing"] as! Double)
        mapview?.mapType = MAMapType(rawValue: args["mapType"] as! Int) ?? MAMapType.standard
        mapview?.setZoomLevel(CGFloat(args["zoom"] as! Double), animated: animated)
        mapview?.maxZoomLevel = args["maxZoom"] as! Double
        mapview?.minZoomLevel = args["minZoom"] as! Double
        mapview?.isZoomEnabled = args["isZoomGesturesEnabled"] as! Bool
        mapview?.zoomingInPivotsAroundAnchorPoint = args["zoomingInPivotsAroundAnchorPoint"] as! Bool
        mapview?.isRotateCameraEnabled = args["isRotateGesturesEnabled"] as! Bool
        mapview?.showsUserLocation = args["showUserLocation"] as! Bool
        mapview?.allowsBackgroundLocationUpdates = args["allowsBackgroundLocationUpdates"] as! Bool
        mapview?.showsCompass = args["showCompass"] as! Bool
        mapview?.showsScale = args["showScale"] as! Bool
        mapview?.isScrollEnabled = args["isScrollGesturesEnabled"] as! Bool
        mapview?.touchPOIEnabled = args["isTouchPoiEnable"] as! Bool
        mapview?.isShowTraffic = args["showTraffic"] as! Bool
        mapview?.isShowsIndoorMap = args["showIndoorMap"] as! Bool
        mapview?.isShowsLabels = args["showMapText"] as! Bool
        mapview?.isShowsBuildings = args["showBuildings"] as! Bool
        mapview?.mapLanguage = NSNumber(value: args["language"] as! Int)
        mapview?.centerCoordinate = CLLocationCoordinate2D(latitude: args["latitude"] as! Double, longitude: args["longitude"] as! Double)

    }

    public func view() -> UIView {
        mapview!
    }

}
