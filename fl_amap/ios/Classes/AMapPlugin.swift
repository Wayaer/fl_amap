import Flutter

public class AMapPlugin: NSObject, FlutterPlugin {
    private var location: AMapLocation
    private var geoFence: AMapGeoFence

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AMapPlugin(registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: instance.location.channel)
        instance.location.setMethodCallHandler()
        registrar.addMethodCallDelegate(instance, channel: instance.geoFence.channel)
        instance.geoFence.setMethodCallHandler()
    }

    init(_ binaryMessenger: FlutterBinaryMessenger) {
        location = AMapLocation(binaryMessenger)
        geoFence = AMapGeoFence(binaryMessenger)
        super.init()
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        location.detach()
        geoFence.detach()
    }
}
