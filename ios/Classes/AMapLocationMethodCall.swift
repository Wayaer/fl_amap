import Foundation
import AMapLocationKit
import Flutter

class AMapLocationMethodCall: NSObject {
    private var channel: FlutterMethodChannel
    private var locationManager: AMapLocationManager?
    private var geoFenceManager: AMapGeoFenceManager?
    private var locationManagerDelegate: LocationManagerDelegate?
    private var geoFenceManagerDelegate: GeoFenceManagerDelegate?

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        geoFenceManagerDelegate?.result = result
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
        case "initLocation":
            if locationManager == nil {
                locationManager = AMapLocationManager()
            }
            result(initLocationOption(call))
        case "disposeLocation":
            if locationManager != nil {
                locationManager!.stopUpdatingLocation()
                locationManagerDelegate = nil
                locationManager!.delegate = nil
                locationManager = nil
            }
            result(locationManager == nil)
        case "getLocation":
            getLocation(call.arguments as! Bool, result)
        case "startLocation":
            if locationManager != nil {
                if locationManagerDelegate == nil {
                    locationManagerDelegate = LocationManagerDelegate(channel)
                    locationManager!.delegate = locationManagerDelegate
                }
                locationManager!.startUpdatingLocation()
            }
            result(locationManager != nil)
        case "stopLocation":
            if locationManager != nil {
                locationManagerDelegate = nil
                locationManager!.stopUpdatingLocation()
            }
            result(locationManager == nil)
        case "initGeoFence":
            if geoFenceManager == nil {
                geoFenceManager = AMapGeoFenceManager()
                if geoFenceManagerDelegate == nil {
                    geoFenceManagerDelegate = GeoFenceManagerDelegate(channel)
                    geoFenceManager!.delegate = geoFenceManagerDelegate
                }
            }
            result(initGeoFenceOption(call))
        case "disposeGeoFence":
            if geoFenceManager != nil {
                geoFenceManager!.removeAllGeoFenceRegions()
                geoFenceManagerDelegate = nil
                geoFenceManager!.delegate = nil
                geoFenceManager = nil
            }
            result(geoFenceManager == nil)
        case "getAllGeoFence":
            var list = [[String: Any?]]()
            if geoFenceManager != nil {
                let fences = geoFenceManager!.geoFenceRegions(withCustomID: call.arguments as? String)
                if fences != nil {
                    for item in fences! {
                        let region = item as? AMapGeoFenceRegion
                        if region != nil {
                            list.append(region!.data)
                        }
                    }
                }
            }
            result(list)
        case "addGeoFenceWithPOI":
            let args = call.arguments as! [String: Any?]
            geoFenceManager?.addKeywordPOIRegionForMonitoring(withKeyword: args["keyword"] as? String, poiType: args["type"] as? String, city: args["city"] as? String, size: args["size"] as! Int, customID: args["customID"] as? String)
        case "addAMapGeoFenceWithLatLong":
            let args = call.arguments as! [String: Any?]
            let coordinate = CLLocationCoordinate2DMake(args["latitude"] as! Double, args["longitude"] as! Double)
            geoFenceManager?.addAroundPOIRegionForMonitoring(withLocationPoint: coordinate, aroundRadius: Int(args["aroundRadius"] as! Double), keyword: args["keyword"] as? String, poiType: args["type"] as? String, size: args["size"] as! Int, customID: args["customID"] as? String)
        case "addGeoFenceWithDistrict":
            let args = call.arguments as! [String: Any?]
            geoFenceManager?.addDistrictRegionForMonitoring(withDistrictName: args["keyword"] as? String, customID: args["customID"] as? String)
        case "addCircleGeoFence":
            let args = call.arguments as! [String: Any?]
            let coordinate = CLLocationCoordinate2DMake(args["latitude"] as! Double, args["longitude"] as! Double)
            geoFenceManager?.addCircleRegionForMonitoring(withCenter: coordinate, radius: args["radius"] as! Double, customID: args["customID"] as? String)
        case "addCustomGeoFence":
            let args = call.arguments as! [String: Any?]
            let latLongs = args["latLong"] as! [[String: Double]]
            var coordinates = [CLLocationCoordinate2D]()
            for latLong in latLongs {
                coordinates.append(CLLocationCoordinate2D(
                        latitude: latLong["latitude"]!, longitude: latLong["longitude"]!
                ))
            }
            geoFenceManager?.addPolygonRegionForMonitoring(withCoordinates: &coordinates, count: latLongs.count, customID: args["customID"] as? String)
        case "removeGeoFence":
            let customID = call.arguments as? String
            if customID != nil {
                geoFenceManager?.removeGeoFenceRegions(withCustomID: customID)
            } else {
                geoFenceManager?.removeAllGeoFenceRegions()
            }
            result(geoFenceManager != nil)
        case "startGeoFence":
            geoFenceManager?.startGeoFenceRegions(withCustomID: call.arguments as? String)
            result(true)
        case "pauseGeoFence":
            geoFenceManager?.pauseGeoFenceRegions(withCustomID: call.arguments as? String)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func getLocation(_ withReGeocode: Bool, _ result: @escaping FlutterResult) {
        locationManager!.requestLocation(withReGeocode: withReGeocode, completionBlock: { location, reGeocode, error in
            if error != nil {
                result([
                    "code": (error! as NSError).code,
                    "description": error!.localizedDescription,
                    "success": false,
                ])
            } else {
                var md = location!.data
                if reGeocode != nil {
                    md.merge(reGeocode!.data)
                    md["code"] = 0
                    md["success"] = true
                } else {
                    md["code"] = (error! as NSError).code
                    md["description"] = error!.localizedDescription
                    md["success"] = true
                }
                result(md)
            }
        })
    }

    func initLocationOption(_ call: FlutterMethodCall) -> Bool {
        if locationManager == nil {
            return false
        }

        let args = call.arguments as! [AnyHashable: Any]
        locationManager!.desiredAccuracy = getDesiredAccuracy(args["desiredAccuracy"] as! String)
        locationManager!.pausesLocationUpdatesAutomatically = args["pausesLocationUpdatesAutomatically"] as! Bool
        locationManager!.distanceFilter = args["distanceFilter"] as! Double
        /// 设置在能不能再后台定位
        locationManager!.allowsBackgroundLocationUpdates = args["allowsBackgroundLocationUpdates"] as! Bool
        /// 设置定位超时时间
        locationManager!.locationTimeout = args["locationTimeout"] as! Int
        /// 设置逆地理超时时间
        locationManager!.reGeocodeTimeout = args["reGeocodeTimeout"] as! Int
        /// 定位是否需要逆地理信息
        locationManager!.locatingWithReGeocode = args["locatingWithReGeocode"] as! Bool
        /// 检测是否存在虚拟定位风险，默认为NO，不检测。
        /// 注意:设置为YES时，单次定位通过 AMapLocatingCompletionBlock 的error给出虚拟定位风险提示；连续定位通过 amapLocationManager:didFailWithError: 方法的error给出虚拟定位风险提示。error格式为error.domain==AMapLocationErrorDomain; error.code==AMapLocationErrorRiskOfFakeLocation;
        locationManager!.detectRiskOfFakeLocation = args["detectRiskOfFakeLocation"] as! Bool
        return true
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
        default:
            return kCLLocationAccuracyThreeKilometers
        }
    }

    func initGeoFenceOption(_ call: FlutterMethodCall) -> Bool {
        if geoFenceManager == nil {
            return false
        }
        let args = call.arguments as! [AnyHashable: Any]
        switch args["action"] as! Int {
        case 0:
            geoFenceManager!.activeAction = .inside
        case 1:
            geoFenceManager!.activeAction = .outside
        case 2:
            geoFenceManager!.activeAction = [.inside, .outside]
        case 3:
            geoFenceManager!.activeAction = [.inside, .outside, .stayed]
        default:
            geoFenceManager!.activeAction = [.inside, .outside, .stayed]
        }
        return true
    }

}

extension Dictionary {
    mutating func merge<S>(_ other: S)
            where S: Sequence, S.Iterator.Element == (key: Key, value: Value) {
        for (k, v) in other {
            self[k] = v
        }
    }
}

extension AMapGeoFenceRegion {
    var data: [String: Any?] {
        [
            "customID": customID,
            "status": fenceStatus.rawValue,
            "type": regionType.rawValue,
            "center": [
                "latitude": currentLocation.coordinate.latitude,
                "longitude": currentLocation.coordinate.longitude,
            ],
            "fenceID": identifier,
        ]
    }
}

class LocationManagerDelegate: NSObject, AMapLocationManagerDelegate {
    var channel: FlutterMethodChannel

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    /**
     *  @brief 连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
     *  @param manager 定位 AMapLocationManager 类。
     *  @param location 定位结果。
     *  @param reGeocode 逆地理信息。
     */
    public func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode?) {
        var locationMap = location.data
        let reGeocodeMap = reGeocode?.data
        if reGeocodeMap != nil {
            locationMap.merge(reGeocodeMap!)
        }
        locationMap["success"] = true
        channel.invokeMethod("updateLocation", arguments: locationMap)
    }

    /**
     *  @brief 定位权限状态改变时回调函数
     *  @param manager 定位 AMapLocationManager 类。
     *  @param status 定位权限状态。
     */
    public func amapLocationManager(_ manager: AMapLocationManager!, locationManagerDidChangeAuthorization locationManager: CLLocationManager!) {
    }

    /**
     *  @brief 当定位发生错误时，会调用代理的此方法。
     *  @param manager 定位 AMapLocationManager 类。
     *  @param error 返回的错误，参考 CLError 。
     */
    public func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        channel.invokeMethod("updateLocation", arguments: [
            "description": error!.localizedDescription,
            "success": false,
            "code": (error! as NSError).code,
        ])
    }
}

class GeoFenceManagerDelegate: NSObject, AMapGeoFenceManagerDelegate {
    private var channel: FlutterMethodChannel
    var result: FlutterResult?

    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    /// 地理围栏定位回调
    func amapLocationManager(_ manager: AMapGeoFenceManager!, doRequireTemporaryFullAccuracyAuth locationManager: CLLocationManager!, completion: ((Error?) -> Void)!) {
    }

    /// 获取围栏创建后的回调
    /// 在如下回调中知道创建的围栏是否成功，以及查看所创建围栏的具体内容
    public func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didAddRegionForMonitoringFinished regions: [AMapGeoFenceRegion]!, customID: String!, error: Error!) {
        result?(error == nil)
    }

    ///  围栏状态改变时的回调
    public func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didGeoFencesStatusChangedFor region: AMapGeoFenceRegion!, customID: String!, error: Error!) {
        channel.invokeMethod("updateGeoFence", arguments: region.data)
    }
}

extension CLLocation {
    var data: [String: Any?] {
        ["latitude": coordinate.latitude,
         "longitude": coordinate.longitude,
         "accuracy": (horizontalAccuracy + verticalAccuracy) / 2,
         "altitude": altitude,
         "speed": speed,
         "timestamp": timestamp.timeIntervalSince1970]
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
