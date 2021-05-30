library fl_amap;

import 'dart:io';

import 'package:flutter/services.dart';

export 'amap_geo_fence.dart';
export 'amap_location.dart';

const MethodChannel channel = MethodChannel('fl_amap');

///  设置ios&android的key
Future<bool> setAMapKey(
    {required String iosKey, required String androidKey}) async {
  String? key;
  if (Platform.isAndroid) key = androidKey;
  if (Platform.isIOS) key = iosKey;
  if (key == null) return false;
  final bool? state = await channel.invokeMethod('setApiKey', key);
  return state ?? false;
}

class LatLong {
  LatLong(this.latitude, this.longitude);

  LatLong.fromMap(Map<dynamic, dynamic> map) {
    latitude = map['latitude'] as double?;
    longitude = map['longitude'] as double?;
  }

  double? latitude;
  double? longitude;

  Map<String, double?> toMap() => <String, double?>{
        'latitude': latitude,
        'longitude': longitude,
      };
}
