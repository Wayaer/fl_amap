part of '../fl_amap_map.dart';

class AMapController {
  AMapController({required this.id}) {
    _channel = MethodChannel('fl_amap_map_$id');
    if (_isAndroid) _android = AMapControllerForAndroid(_channel, id);
    if (_isIOS) _ios = AMapControllerForIOS(_channel, id);
  }

  final int id;

  late MethodChannel _channel;

  /// 仅 android 可用
  AMapControllerForAndroid? _android;

  AMapControllerForAndroid? get android => _android;

  /// 仅 ios 可用
  AMapControllerForIOS? _ios;

  AMapControllerForIOS? get ios => _ios;

  /// 设置地图配置信息
  Future<bool> setOptions(AMapOptions options) async {
    final result = await _channel.invokeMethod<bool>('setOptions', options.toMap());
    return result ?? false;
  }

  /// 销毁地图
  Future<bool> dispose() async {
    final result = await _channel.invokeMethod('dispose');
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
}

