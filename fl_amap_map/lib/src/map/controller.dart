part of '../../fl_amap_map.dart';

typedef AMapLocationChangeListener = void Function(Location location);
typedef AMapLoadedListener = void Function();
typedef AMapLatLngListener = void Function(LatLng latLng);
typedef AMapPOIPressedListener = void Function(List<Poi> poi);
typedef AMapMarkerPressedListener = void Function(Marker marker);

class AMapController {
  AMapController({required this.id}) {
    _channel = MethodChannel('fl_amap_map_$id');
  }

  final int id;

  late MethodChannel _channel;

  /// 设置地图配置信息
  Future<bool> setOptions(AMapOptions options) async {
    final result = await _channel.invokeMethod<bool>('setOptions', options.toMap());
    return result ?? false;
  }

  /// 最大帧数，有效的帧数为：60、30、20、10等能被60整除的数。默认为60
  Future<bool> setRenderFps(int fps) async {
    final result = await _channel.invokeMethod<bool>('setRenderFps', fps);
    return result ?? false;
  }

  /// 重新加载地图
  Future<bool> reloadMap() async {
    final result = await _channel.invokeMethod<bool>('reloadMap');
    return result ?? false;
  }

  /// 设置地图定位跟随模式
  Future<bool> setTrackingMode(TrackingMode mode, {bool animated = true}) async {
    int modeIndex = mode.index;
    if (modeIndex > 2 && _isIOS) modeIndex = 1;
    final result = await _channel.invokeMethod<bool>('setTrackingMode', {
      'mode': modeIndex,
      'animated': animated,
    });
    return result ?? false;
  }

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
      if (data is! Map) return;
      debugPrint('消息回调==${data['method']}===$data');
      final id = data['id'];
      if (id != this.id) return;
      final method = data['method'];
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

  /// 销毁地图
  /// 当只存在一个地图且被销毁时 需要关系消息通道
  /// [controller.mapEvent.dispose()]
  Future<bool> dispose() async {
    final result = await _channel.invokeMethod('dispose');
    return result ?? false;
  }
}
