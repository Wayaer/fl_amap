import Flutter

public class AMapPlugin: NSObject, FlutterPlugin {
    private var location: AMapLocation
    private var geoFence: AMapGeoFence

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AMapPlugin(registrar)
        registrar.addMethodCallDelegate(instance, channel: instance.geoFence.channel)
        registrar.addMethodCallDelegate(instance, channel: instance.location.channel)
    }

    init(_ registrar: FlutterPluginRegistrar) {
        location = AMapLocation(registrar)
        geoFence = AMapGeoFence(registrar)
        super.init()
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        location.detach()
        geoFence.detach()
    }
}
