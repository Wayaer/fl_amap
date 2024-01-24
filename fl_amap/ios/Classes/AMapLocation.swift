import AMapLocationKit
import Flutter
import Foundation

class AMapLocation: NSObject, AMapLocationManagerDelegate {
    var channel: FlutterMethodChannel
    private var manager: AMapLocationManager?
    private var result: FlutterResult?
    private var isLocation: Bool = false

    init(_ binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "fl.amap.Location", binaryMessenger:
            binaryMessenger)
        super.init()
    }

    public func setMethodCallHandler() {
        channel.setMethodCallHandler(handle)
    }

    public func detach() {
        channel.setMethodCallHandler(nil)
    }

    func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        self.result = result
        switch call.method {
        case "setApiKey":
            let args = call.arguments as! [String: Any?]
            let key = args["key"] as! String
            let isAgree = args["isAgree"] as! Bool
            let isContains = args["isContains"] as! Bool
            let isShow = args["isShow"] as! Bool
            AMapLocationManager.updatePrivacyAgree(isAgree ? .didAgree : .notAgree)
            AMapLocationManager.updatePrivacyShow(isShow ? .didShow : .notShow, privacyInfo: isContains ? .didContain : .notContain)
            AMapServices.shared().apiKey = key
            result(true)
        case "initialize":
            manager = manager ?? AMapLocationManager()
            setLocationOption(call)
            result(true)
        case "dispose":
            isLocation = false
            manager?.stopUpdatingLocation()
            manager?.delegate = nil
            manager = nil
            result(true)
        case "getLocation":
            if manager == nil {
                result(nil)
                return
            }
            setLocationOption(call)
            let args = call.arguments as? [AnyHashable: Any]
            let withReGeocode = args?["locatingWithReGeocode"] as? Bool ?? false
            manager!.requestLocation(withReGeocode: withReGeocode, completionBlock: { (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in
                if location != nil {
                    var map = location!.data
                    if reGeocode != nil {
                        map.merge(reGeocode!.data)
                    }
                    result(map)
                } else if error != nil {
                    result([
                        "description": error!.localizedDescription,
                        "errorCode": (error! as NSError).code,
                    ])
                }
            })
        case "startLocation":
            if isLocation || manager == nil {
                result(false)
                return
            }
            isLocation = true
            setLocationOption(call)
            manager!.delegate = self
            manager!.startUpdatingLocation()
            result(true)
        case "stopLocation":
            isLocation = false
            manager?.stopUpdatingLocation()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func setLocationOption(_ call: FlutterMethodCall) {
        let args = call.arguments as? [AnyHashable: Any]
        if args != nil, manager != nil {
            if #available(iOS 14.0, *) {
                manager!.locationAccuracyMode = AMapLocationAccuracyMode(rawValue: args!["locationAccuracyMode"] as! Int)!
            }
            let distanceFilter = args!["distanceFilter"] as? Double
            manager!.distanceFilter = (distanceFilter == nil ? kCLDistanceFilterNone : distanceFilter!)

            manager!.desiredAccuracy = getDesiredAccuracy(args!["desiredAccuracy"] as! String)

            manager!.pausesLocationUpdatesAutomatically = args!["pausesLocationUpdatesAutomatically"] as! Bool

            /// 设置在能不能再后台定位
            manager!.allowsBackgroundLocationUpdates = args!["allowsBackgroundLocationUpdates"] as! Bool
            /// 设置定位超时时间
            manager!.locationTimeout = args!["locationTimeout"] as! Int
            /// 设置逆地理超时时间
            manager!.reGeocodeTimeout = args!["reGeocodeTimeout"] as! Int

            /// 定位是否需要逆地理信息
            manager!.locatingWithReGeocode = args!["locatingWithReGeocode"] as! Bool
            /// 逆地理信息语言设置
            manager!.reGeocodeLanguage = AMapLocationReGeocodeLanguage(rawValue: args!["reGeocodeLanguage"] as! Int)!
            /// 检测是否存在虚拟定位风险，默认为NO，不检测。
            /// 注意:设置为YES时，单次定位通过 AMapLocatingCompletionBlock 的error给出虚拟定位风险提示；连续定位通过 amapLocationManager:didFailWithError: 方法的error给出虚拟定位风险提示。error格式为error.domain==AMapLocationErrorDomain; error.code==AMapLocationErrorRiskOfFakeLocation;
            manager!.detectRiskOfFakeLocation = args!["detectRiskOfFakeLocation"] as! Bool
        }
    }

    func getDesiredAccuracy(_ str: String) -> CLLocationAccuracy {
        switch str {
        case "kCLLocationAccuracyBest":
            return kCLLocationAccuracyBest
        case "kCLLocationAccuracyNearestTenMeters":
            return kCLLocationAccuracyNearestTenMeters
        case "kCLLocationAccuracyHundredMeters":
            return kCLLocationAccuracyHundredMeters
        case "kCLLocationAccuracyKilometer":
            return kCLLocationAccuracyKilometer
        case "kCLLocationAccuracyThreeKilometers":
            return kCLLocationAccuracyThreeKilometers
        default:
            return kCLLocationAccuracyThreeKilometers
        }
    }

    // 连续定位回调函数
    // 注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {
        var locationMap = location.data
        let reGeocodeMap = reGeocode?.data
        if reGeocodeMap != nil {
            locationMap.merge(reGeocodeMap!)
        }
        channel.invokeMethod("onLocationChanged", arguments: locationMap)
    }

    // 定位权限状态改变时回调函数 ios14及之后
    func amapLocationManager(_ manager: AMapLocationManager!, locationManagerDidChangeAuthorization locationManager: CLLocationManager!) {
        if #available(iOS 14.0, *) {
            channel.invokeMethod("onAuthorizationChanged", arguments: locationManager.authorizationStatus.rawValue)
        }
    }

    // 定位权限状态改变时回调函数 ios13及之前
    func amapLocationManager(_ manager: AMapLocationManager!, didChange status: CLAuthorizationStatus) {
        channel.invokeMethod("onAuthorizationChanged", arguments: status.rawValue)
    }

    // 当定位发生错误时，会调用代理的此方法。
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error?) {
        channel.invokeMethod("onFailed", arguments: [
            "errorCode": (error as? NSError)?.code as Any,
        ])
    }
}

extension Dictionary {
    mutating func merge<S>(_ other: S)
        where S: Sequence, S.Iterator.Element == (key: Key, value: Value)
    {
        for (k, v) in other {
            self[k] = v
        }
    }
}

extension CLLocation {
    var data: [String: Any?] {
        var map = ["latitude": coordinate.latitude,
                   "longitude": coordinate.longitude,
                   "horizontalAccuracy": horizontalAccuracy,
                   "verticalAccuracy": verticalAccuracy,
                   "altitude": altitude,
                   "speed": speed,
                   "speedAccuracy": speedAccuracy,
                   "course": course,
                   "distance": distance,
                   "floor": floor?.level,
                   "timestamp": timestamp.timeIntervalSince1970] as [String: Any?]
        if #available(iOS 13.4, *) {
            map["courseAccuracy"] = courseAccuracy
        }
        if #available(iOS 15.0, *) {
            map["isSimulatedBySoftware"] = sourceInformation?.isSimulatedBySoftware
            map["isProducedByAccessory"] = sourceInformation?.isProducedByAccessory
        }

        return map
    }
}

extension AMapLocationReGeocode {
    var data: [String: Any?] {
        ["formattedAddress": formattedAddress,
         "country": country,
         "province": province,
         "city": city,
         "district": district,
         "cityCode": city,
         "adCode": adcode,
         "street": street,
         "number": number,
         "poiName": poiName,
         "aoiName": aoiName]
    }
}
