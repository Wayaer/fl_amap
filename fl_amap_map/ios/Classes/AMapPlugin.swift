import fl_channel
import Flutter
import MAMapKit

public class AMapMapPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var binaryMessenger: FlutterBinaryMessenger
    public static var flEventChannel: FlEventChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl_amap_map", binaryMessenger:
            registrar.messenger())
        let instance = AMapMapPlugin(channel, registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.register(AMapPlatformViewFactory(registrar), withId: "fl_amap_map", gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicyWaitUntilTouchesEnded)
    }

    init(_ channel: FlutterMethodChannel, _ binaryMessenger: FlutterBinaryMessenger) {
        self.channel = channel
        self.binaryMessenger = binaryMessenger
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
            MAMapView.updatePrivacyAgree(isAgree ? .didAgree : .notAgree)
            MAMapView.updatePrivacyShow(isShow ? .didShow : .notShow, privacyInfo: isContains ? .didContain : .notContain)
            AMapMapPlugin.flEventChannel = FlChannelPlugin.getEventChannel("fl_amap_map_event")
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel?.setMethodCallHandler(nil)
    }
}
