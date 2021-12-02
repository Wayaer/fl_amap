import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'amap_geo_fence.dart';

part 'amap_location.dart';

const MethodChannel _channel = MethodChannel('fl_amap');

/// 设置ios&android的key
Future<bool> setAMapKey({
  required String iosKey,
  required String androidKey,

  /// 设置是否同意用户授权政策 设置为true才可以调用其他功能
  bool isAgree = true,

  /// 设置包含隐私政策 设置为true才可以调用其他功能
  bool isContains = true,

  /// 并展示用户授权弹窗 设置为true才可以调用其他功能
  bool isShow = true,
}) async {
  if (!_supportPlatform) return false;
  String? key;
  if (_isAndroid) key = androidKey;
  if (_isIOS) key = iosKey;
  if (key == null) return false;
  final bool? state = await _channel.invokeMethod('setApiKey', {
    'key': key,
    'isAgree': isAgree,
    'isContains': isContains,
    'isShow': isShow
  });
  return state ?? false;
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

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
