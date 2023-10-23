part of '../../fl_amap_map.dart';

typedef OnAMapControllerCreated = void Function(AMapController controller);

class AMapView extends StatefulWidget {
  const AMapView(
      {super.key,
      this.gestureRecognizers,
      this.onCreateController,
      this.options = const AMapOptions(latLng: LatLng(30.651411, 103.998638))});

  /// 需要应用到地图上的手势集合
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// AMapController 回调
  final OnAMapControllerCreated? onCreateController;

  /// 初始配置信息
  final AMapOptions options;

  @override
  State<AMapView> createState() => _AMapViewState();
}

class _AMapViewState extends State<AMapView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
          viewType: 'fl_amap_map',
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          creationParams: widget.options.toMap(),
          creationParamsCodec: const StandardMessageCodec());
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
          viewType: 'fl_amap_map',
          onPlatformViewCreated: onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          creationParams: widget.options.toMap(),
          creationParamsCodec: const StandardMessageCodec());
    }
    return Text('当前平台:$defaultTargetPlatform, 不支持使用高德地图插件');
  }

  Future<void> onPlatformViewCreated(int id) async {
    final AMapController controller = AMapController(id: id);
    widget.onCreateController?.call(controller);
  }
}
