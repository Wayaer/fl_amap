part of '../../fl_amap_map.dart';

typedef EventListen = void Function(dynamic data);

class AMapEvent {
  factory AMapEvent() => _singleton ??= AMapEvent._();

  AMapEvent._();

  static AMapEvent? _singleton;

  /// 订阅流
  StreamSubscription<dynamic>? _streamSubscription;

  /// 创建流
  Stream<dynamic>? _stream;

  /// 消息通道
  EventChannel? _eventChannel;

  bool get isPaused =>
      _streamSubscription != null && _streamSubscription!.isPaused;

  /// 初始化消息通道
  Future<bool> initialize() async {
    if (!_supportPlatform) return false;
    final bool? event = await _channel.invokeMethod("startEvent");
    _eventChannel = const EventChannel('fl_amap/event');
    _stream = _eventChannel?.receiveBroadcastStream(<dynamic, dynamic>{});
    return event == true && _eventChannel != null && _stream != null;
  }

  /// 添加消息流监听
  bool addListener(EventListen eventListen) {
    if (!_supportPlatform) return false;
    if (_eventChannel != null && _stream != null) {
      if (_streamSubscription != null) return false;
      try {
        _streamSubscription = _stream!.listen(eventListen);
        return true;
      } catch (e) {
        debugPrint(e.toString());
        return false;
      }
    }
    return false;
  }

  /// 暂停消息流监听
  bool pause() {
    if (!_supportPlatform) return false;
    if (_streamSubscription != null && !_streamSubscription!.isPaused) {
      _streamSubscription!.pause();
      return true;
    }
    return false;
  }

  /// 重新开始监听
  bool resume() {
    if (!_supportPlatform) return false;
    if (_streamSubscription != null && _streamSubscription!.isPaused) {
      _streamSubscription!.resume();
      return true;
    }
    return false;
  }

  /// 关闭并销毁消息通道
  Future<bool> dispose() async {
    if (!_supportPlatform) return false;
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    _stream = null;
    _eventChannel = null;
    final bool? state = await _channel.invokeMethod<bool>('stopEvent');
    return state == true;
  }
}
