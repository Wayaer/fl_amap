import AMapLocationKit
import fl_channel
import Flutter
import MAMapKit

public class AMapMapPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var methodCall: AMapLocationMethodCall?
    private var binaryMessenger: FlutterBinaryMessenger

    public static var flMapEvent: FlEvent?

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
            AMapMapPlugin.flMapEvent = FlEvent("fl_amap_map/event", binaryMessenger)
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
        default:
            methodCall?.handle(call, result)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel?.setMethodCallHandler(nil)
        AMapMapPlugin.flMapEvent = nil
    }

    deinit {
        methodCall = nil
        channel = nil
    }
}
