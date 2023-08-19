import AMapLocationKit
import Foundation
import MAMapKit

extension Dictionary {
    mutating func merge<S>(_ other: S)
            where S: Sequence, S.Iterator.Element == (key: Key, value: Value) {
        for (k, v) in other {
            self[k] = v
        }
    }
}

extension CLLocationCoordinate2D {
    var data: [String: Any?] {
        [
            "longitude": longitude,
            "latitude": latitude,
        ]
    }
}

extension MATouchPoi {
    var data: [String: Any?] {
        [
            "latLng": coordinate.data,
            "name": name,
            "poiId": uid,
        ]
    }
}

extension CLHeading {
    var data: [String: Any?] {
        [
            "x": x,
            "y": y,
            "z": z,
            "timestamp": timestamp.timeIntervalSince1970,
            "magneticHeading": magneticHeading,
            "trueHeading": trueHeading,
            "headingAccuracy": headingAccuracy,
        ]
    }
}


extension AMapGeoFenceRegion {
    var data: [String: Any?] {
        [
            "customID": customID,
            "status": fenceStatus.rawValue,
            "type": regionType.rawValue,
            "center": currentLocation.coordinate.data,
            "fenceID": identifier,
        ]
    }
}

extension CLLocation {
    var data: [String: Any?] {
        [
            "latLng": coordinate.data,
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
