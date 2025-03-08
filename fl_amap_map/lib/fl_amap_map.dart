import 'dart:async';
import 'dart:ffi';

import 'package:fl_channel/fl_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'src/map/amap_view.dart';

part 'src/map/controller.dart';

part 'src/map/model.dart';

part 'src/enum.dart';

class FlAMapMap {
  final MethodChannel _channel = MethodChannel('fl_amap_map');

  factory FlAMapMap() => _singleton ??= FlAMapMap._();

  FlAMapMap._();

  static FlAMapMap? _singleton;

  FlEventChannel? _flEventChannel;

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
    bool enableHTTPS = true,
  }) async {
    if (!_supportPlatform) return false;
    String? key;
    if (_isAndroid) key = androidKey;
    if (_isIOS) key = iosKey;
    if (key == null) return false;
    _flEventChannel ??= await FlChannel().create('${_channel.name}_event');
    final state = await _channel.invokeMethod(
        'setApiKey', {'key': key, 'isAgree': isAgree, 'isContains': isContains, 'isShow': isShow, 'enableHTTPS': enableHTTPS});
    return state ?? false;
  }

  void dispose() {
    _flEventChannel?.dispose();
    _flEventChannel = null;
  }
}

bool get _supportPlatform {
  if (!kIsWeb && (_isAndroid || _isIOS)) return true;
  debugPrint('Not support platform for $defaultTargetPlatform');
  return false;
}

bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

class LatLng {
  const LatLng(this.latitude, this.longitude);

  LatLng.fromMap(Map<dynamic, dynamic> map)
      : latitude = map['latitude'] as double?,
        longitude = map['longitude'] as double?;

  final double? latitude;
  final double? longitude;

  Map<String, double?> toMap() => {'latitude': latitude, 'longitude': longitude};
}
