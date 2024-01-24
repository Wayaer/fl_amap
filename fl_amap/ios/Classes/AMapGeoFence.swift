import AMapLocationKit
import Flutter
import Foundation

class AMapGeoFence: NSObject, AMapGeoFenceManagerDelegate {
    var channel: FlutterMethodChannel
    private var manager: AMapGeoFenceManager?
    private var result: FlutterResult?

    init(_ binaryMessenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "fl.amap.GeoFence", binaryMessenger:
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
        case "initialize":
            manager = manager ?? AMapGeoFenceManager()
            manager?.delegate = self
            result(initGeoFenceOption(call))
        case "dispose":
            manager?.removeAllGeoFenceRegions()
            manager?.delegate = nil
            manager = nil
            result(manager == nil)
        case "getAll":
            result(getAllGeoFence(call.arguments as? String))
        case "addPOI":
            let args = call.arguments as! [String: Any?]
            manager?.addKeywordPOIRegionForMonitoring(withKeyword: args["keyword"] as? String, poiType: args["type"] as? String, city: args["city"] as? String, size: args["size"] as! Int, customID: args["customID"] as? String)
        case "addLatLng":
            let args = call.arguments as! [String: Any?]
            let coordinate = CLLocationCoordinate2DMake(args["latitude"] as! Double, args["longitude"] as! Double)
            manager?.addAroundPOIRegionForMonitoring(withLocationPoint: coordinate, aroundRadius: Int(args["aroundRadius"] as! Double), keyword: args["keyword"] as? String, poiType: args["type"] as? String, size: args["size"] as! Int, customID: args["customID"] as? String)
        case "addDistrict":
            let args = call.arguments as! [String: Any?]
            manager?.addDistrictRegionForMonitoring(withDistrictName: args["keyword"] as? String, customID: args["customID"] as? String)
        case "addCircle":
            let args = call.arguments as! [String: Any?]
            let coordinate = CLLocationCoordinate2DMake(args["latitude"] as! Double, args["longitude"] as! Double)
            manager?.addCircleRegionForMonitoring(withCenter: coordinate, radius: args["radius"] as! Double, customID: args["customID"] as? String)
        case "addCustom":
            let args = call.arguments as! [String: Any?]
            let latLngs = args["latLng"] as! [[String: Double]]
            var coordinates = [CLLocationCoordinate2D]()
            for latLng in latLngs {
                coordinates.append(CLLocationCoordinate2D(
                    latitude: latLng["latitude"]!, longitude: latLng["longitude"]!
                ))
            }
            manager?.addPolygonRegionForMonitoring(withCoordinates: &coordinates, count: latLngs.count, customID: args["customID"] as? String)
        case "remove":
            let customID = call.arguments as? String
            if customID != nil {
                manager?.removeGeoFenceRegions(withCustomID: customID)
            } else {
                manager?.removeAllGeoFenceRegions()
            }
            result(manager != nil)
        case "start":
            manager?.startGeoFenceRegions(withCustomID: call.arguments as? String)
            result(true)
        case "pause":
            manager?.pauseGeoFenceRegions(withCustomID: call.arguments as? String)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func getAllGeoFence(_ customId: String?) -> [[String: Any?]] {
        var list = [[String: Any?]]()
        let fences = manager?.geoFenceRegions(withCustomID: customId)
        if fences == nil {
            return list
        }
        for region in fences! {
            if region is AMapGeoFenceRegion {
                let map = regionToMap(region as! AMapGeoFenceRegion)
                if map != nil {
                    list.append(map!)
                }
            }
        }
        return list
    }

    func initGeoFenceOption(_ call: FlutterMethodCall) -> Bool {
        if manager == nil {
            return false
        }
        let args = call.arguments as! [AnyHashable: Any]
        switch args["action"] as! Int {
        case 0:
            manager!.activeAction = .inside
        case 1:
            manager!.activeAction = .outside
        case 2:
            manager!.activeAction = [.inside, .outside]
        case 3:
            manager!.activeAction = [.inside, .outside, .stayed]
        default:
            manager!.activeAction = [.inside, .outside, .stayed]
        }
        return true
    }

    /// 获取围栏创建后的回调
    /// 在如下回调中知道创建的围栏是否成功，以及查看所创建围栏的具体内容
    func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didAddRegionForMonitoringFinished regions: [AMapGeoFenceRegion]!, customID: String!, error: Error?) {
        result?([
            "customId": customID as Any,
            "errorCode": (error as? NSError)?.code as Any,
        ])
    }

    ///  围栏状态改变时的回调
    func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, didGeoFencesStatusChangedFor region: AMapGeoFenceRegion!, customID: String?, error: Error?) {
        channel.invokeMethod("onGeoFencesStatus", arguments: [
            "region": region.data,
            "customId": customID as Any,
            "errorCode": (error as? NSError)?.code as Any,
        ])
    }

    func amapLocationManager(_ manager: AMapGeoFenceManager!, doRequireTemporaryFullAccuracyAuth locationManager: CLLocationManager!, completion: ((Error?) -> Void)!) {}

    func amapGeoFenceManager(_ manager: AMapGeoFenceManager!, doRequireLocationAuth locationManager: CLLocationManager!) {}

    func regionToMap(_ region: AMapGeoFenceRegion) -> [String: Any?]? {
        if region is AMapGeoFenceCircleRegion {
            return (region as! AMapGeoFenceCircleRegion).circleData
        } else if region is AMapGeoFencePOIRegion {
            return (region as! AMapGeoFencePOIRegion).poiData
        } else if region is AMapGeoFencePolygonRegion {
            return (region as! AMapGeoFencePolygonRegion).polygonData
        } else if region is AMapGeoFenceDistrictRegion {
            return (region as! AMapGeoFenceDistrictRegion).districtData
        }
        return nil
    }
}

extension AMapGeoFenceRegion {
    var data: [String: Any?] {
        [
            "customID": customID,
            "status": fenceStatus.rawValue,
            "type": regionType.rawValue,
            "location": currentLocation?.data,
            "fenceID": identifier,
        ]
    }
}

extension AMapGeoFenceCircleRegion {
    var circleData: [String: Any?] {
        var map = [:] as [String: Any?]
        for (key, value) in data {
            map[key] = value
        }
        map["center"] = center.data
        map["radius"] = radius
        return map
    }
}

extension AMapGeoFencePOIRegion {
    var poiData: [String: Any?] {
        var map = [:] as [String: Any?]
        for (key, value) in circleData {
            map[key] = value
        }
        map["poiItem"] = poiItem.data
        return map
    }
}

extension AMapGeoFencePolygonRegion {
    var polygonData: [String: Any?] {
        var map = [:] as [String: Any?]
        for (key, value) in data {
            map[key] = value
        }
        map["count"] = count
        map["point"] = coordinates.pointee.data
        return map
    }
}

extension AMapGeoFenceDistrictRegion {
    var districtData: [String: Any?] {
        var map = [:] as [String: Any?]
        for (key, value) in data {
            map[key] = value
        }
        map["districtItem"] = districtItem.data
        map["pointList"] = polylinePoints.map { points in
            points.map { point in
                point.data
            }
        }
        return map
    }
}

extension AMapLocationDistrictItem {
    var data: [String: Any?] {
        [
            "cityCode": cityCode,
            "district": district,
            "districtCode": districtCode,
            "pointList": polylinePoints.map { points in
                points.map { point in
                    point.data
                }
            },
        ]
    }
}

extension AMapLocationPOIItem {
    var data: [String: Any?] {
        [
            "pId": pId,
            "name": name,
            "type": type,
            "typeCode": typeCode,
            "address": address,
            "location": location.data,
            "tel": tel,
            "province": province,
            "city": city,
            "district": district,
        ]
    }
}

extension CLLocationCoordinate2D {
    var data: [String: Any?] {
        [
            "latitude": latitude,
            "longitude": longitude,
        ]
    }
}

extension AMapLocationPoint {
    var data: [String: Any?] {
        [
            "latitude": latitude,
            "longitude": longitude,
        ]
    }
}
