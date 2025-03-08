part of '../fl_amap_map.dart';

typedef AMapLocationChangeListener = void Function(Location location);
typedef AMapLoadedListener = void Function();
typedef AMapLatLngListener = void Function(LatLng latLng);
typedef AMapPOIPressedListener = void Function(List<Poi> poi);
typedef AMapMarkerPressedListener = void Function(Marker marker);

class AMapControllerForAndroid {
  AMapControllerForAndroid(this._channel, this._id);

  final MethodChannel _channel;
  final int _id;

  /// 添加回调监听
  Future<bool> addListener({
    /// 定位改变回调
    AMapLocationChangeListener? onLocationChange,

    /// 地图加载完成回调
    AMapLoadedListener? onMapLoaded,

    /// 单击地图回调
    AMapLatLngListener? onMapPressed,

    /// 长按地图回调
    AMapLatLngListener? onMapLongPressed,

    /// poi 点击回调
    AMapPOIPressedListener? onPOIPressed,

    /// marker 点击回调
    AMapMarkerPressedListener? onMarkerPressed,
  }) async {
    /// 初始化原生sdk listener
    final result = await _channel.invokeMethod('addListener');

    /// 添加消息监听通道
    FlAMapMap()._flEventChannel?.listen((data) {
      if (data is! Map || data['id'] != _id) return;
      final method = data['method'];
      debugPrint('消息回调==$method===$data');
      switch (method) {
        case 'Loaded':
          onMapLoaded?.call();
          break;
        case 'LocationChange':
          onLocationChange?.call(Location.fromMap(data));
          break;
        case 'Pressed':
          onMapPressed?.call(LatLng.fromMap(data));
          break;
        case 'LongPressed':
          onMapLongPressed?.call(LatLng.fromMap(data));
          break;
        case 'MarkerPressed':
          onMarkerPressed?.call(Marker.formMap(data));
          break;
        case 'POIPressed':
          onPOIPressed?.call(getPoiList(data['poi']));
          break;
      }
    });
    return result == true;
  }

  /// 重新加载地图
  Future<Marker?> addMarker() async {
    final marker = await _channel.invokeMapMethod('addMarker');
    return marker == null ? null : Marker.formMap(marker);
  }
}

class MarkerOptions {}

class Marker {
  Marker.formMap(Map<dynamic, dynamic> map)
      : title = map['title'] as String?,
        snippet = map['snippet'] as String?,
        draggable = map['draggable'] as bool?,
        visible = map['visible'] as bool?,
        alpha = map['alpha'] as Double?,
        latLng = LatLng.fromMap(map['latLng']);

  /// 在地图上标记位置的经纬度值
  final LatLng? latLng;

  /// 点标记的标题
  final String? title;

  /// 点标记的内容
  final String? snippet;

  /// 点标记是否可拖拽
  final bool? draggable;

  /// 点标记是否可见
  final bool? visible;

  /// 点的透明度
  final Double? alpha;
}
