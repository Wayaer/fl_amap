part of '../fl_amap_map.dart';

typedef FlMapEventListenCallback = void Function(dynamic data);

typedef FlMapEventListenCancel = void Function();

class FlMapEvent {
  factory FlMapEvent() => _singleton ??= FlMapEvent._();

  FlMapEvent._() {
    _flEvent = FlEvent("fl_amap_map/event");
    _flEvent.listen((data) {
      debugPrint('FlEvent==$data');
      _listen.value = data;
    });
  }

  static FlMapEvent? _singleton;

  late FlEvent _flEvent;

  final ValueNotifier<dynamic> _listen = ValueNotifier(null);

  FlMapEventListenCallback? callback;

  FlMapEventListenCancel listen(FlMapEventListenCallback callback) {
    handler() {
      callback(_listen.value);
    }

    _listen.addListener(handler);
    return () => _listen.removeListener(handler);
  }
}
