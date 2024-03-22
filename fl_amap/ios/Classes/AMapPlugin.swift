import Flutter

public class AMapPlugin: NSObject, FlutterPlugin {
    private var location: AMapLocation
    private var geoFence: AMapGeoFence

    public static func register(with registrar: FlutterPluginRegistrar) {
        _ = AMapPlugin(registrar.messenger())
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
