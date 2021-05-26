library fl_amap;

import 'package:flutter/services.dart';

export 'amap_geo_fence.dart';
export 'amap_location.dart';

const MethodChannel channel = MethodChannel('fl_amap');

///  设置ios&android的key
Future<bool> setAMapKey(
    {required String iosKey, required String androidKey}) async {
  final bool? state = await channel.invokeMethod('setApiKey', iosKey);
  return state ?? false;
}

class LatLong {
  LatLong(this.latitude, this.longitude);

  LatLong.fromMap(Map<String, dynamic> map) {
    final double? lat = map['latitude'] as double?;
    final double? long = map['longitude'] as double?;

    if (lat != null && long != null) {
      latitude = lat;
      latitude = long;
    }
  }

  late double latitude;
  late double longitude;

  Map<String, double> toMap() => <String, double>{
        'latitude': latitude,
        'longitude': longitude,
      };
}
