import Flutter
import MAMapKit
import AMapLocationKit

public class AMapMapPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var methodCall: AMapLocationMethodCall?
    private var binaryMessenger: FlutterBinaryMessenger
    static var mapEvent: AMapEvent?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl_amap", binaryMessenger:
        registrar.messenger())
        let instance = AMapMapPlugin(channel, registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(AMapPlatformViewFactory(registrar), withId: "fl_amap_map", gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded)
    }

    init(_ channel: FlutterMethodChannel, _ binaryMessenger: FlutterBinaryMessenger) {
        self.channel = channel
        self.binaryMessenger = binaryMessenger
        methodCall = AMapLocationMethodCall(channel)
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setApiKey":
            let args = call.arguments as! [String: Any?]
            let key = args["key"] as! String
            let isAgree = args["isAgree"] as! Bool
            let isContains = args["isContains"] as! Bool
            let isShow = args["isShow"] as! Bool
            AMapServices.shared().apiKey = key
            AMapServices.shared().enableHTTPS = args["enableHTTPS"] as! Bool
            AMapLocationManager.updatePrivacyAgree(isAgree ? .didAgree : .notAgree)
            AMapLocationManager.updatePrivacyShow(isShow ? .didShow : .notShow, privacyInfo: isContains ? .didContain : .notContain)
            MAMapView.updatePrivacyAgree(isAgree ? .didAgree : .notAgree)
            MAMapView.updatePrivacyShow(isShow ? .didShow : .notShow, privacyInfo: isContains ? .didContain : .notContain)
            result(true)
        case "startEvent":
            if (AMapMapPlugin.mapEvent == nil) {
                AMapMapPlugin.mapEvent = AMapEvent(binaryMessenger)
            }
            result(true)
        case "stopEvent":
            AMapMapPlugin.mapEvent?.dispose()
            AMapMapPlugin.mapEvent = nil
            result(true)
        default:
            methodCall?.handle(call, result)
        }


    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel?.setMethodCallHandler(nil)
    }

    deinit {
        methodCall = nil
        channel = nil
    }
}
