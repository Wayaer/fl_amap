import Flutter

public class AMapPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var methodCall: AMapLocationMethodCall?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "fl_amap", binaryMessenger:
        registrar.messenger())
        let instance = AMapPlugin(channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        methodCall = AMapLocationMethodCall(channel)
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        methodCall?.handle(call, result)
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        channel?.setMethodCallHandler(nil)
    }

    deinit {
        methodCall = nil
        channel = nil
    }
}

