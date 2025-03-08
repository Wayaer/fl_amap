part of '../fl_amap_map.dart';

class AMapControllerForIOS {
  const AMapControllerForIOS(this._channel, this._id);

  final MethodChannel _channel;
  final int _id;

  /// 添加回调监听
  Future<bool> addListener() async {
    /// 初始化原生sdk listener
    final result = await _channel.invokeMethod('addListener');

    /// 添加消息监听通道
    FlAMapMap()._flEventChannel?.listen((data) {
      if (data is! Map || data['id'] != _id) return;
      final method = data['method'];
      debugPrint('消息回调==$method===$data');
      switch (method) {}
    });
    return result == true;
  }
}
