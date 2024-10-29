import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'src/amap_geo_fence.dart';

part 'src/amap_location.dart';

part 'src/enum.dart';

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
  final bool? state = await FlAMapLocation()._channel.invokeMethod(
      'setApiKey', {
    'key': key,
    'isAgree': isAgree,
    'isContains': isContains,
    'isShow': isShow
  });
  return state == true;
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

class LatLng {
  LatLng(this.latitude, this.longitude);

  LatLng.fromMap(Map<dynamic, dynamic> map)
      : latitude = map['latitude'] as double?,
        longitude = map['longitude'] as double?;

  /// 维度
  double? latitude;

  /// 经度
  double? longitude;

  Map<String, dynamic> toMap() =>
      {'latitude': latitude, 'longitude': longitude};
}
