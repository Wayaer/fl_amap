part of 'fl_amap.dart';

enum GeoFenceActivateAction {
  /// 进入地理围栏
  onlyInside,

  /// 退出地理围栏
  onlyOutside,

  /// 监听进入并退出
  insideAndOutside,

  /// 停留在地理围栏内10分钟
  stayed,
}

///  初始化地理围栏
///  allowsBackgroundLocationUpdates 仅支持 ios 在iOS9及之后版本的系统中，
///  如果您希望程序在后台持续检测围栏触发行为，需要保证manager 的 allowsBackgroundLocationUpdates 为YES，
///  设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
Future<bool> initAMapGeoFence(GeoFenceActivateAction action,
    [bool allowsBackgroundLocationUpdates = false]) async {
  final bool? isInit =
      await _channel.invokeMethod('initGeoFence', <String, dynamic>{
    'action': GeoFenceActivateAction.values.indexOf(action),
    'allowsBackgroundLocationUpdates': allowsBackgroundLocationUpdates
  });
  return isInit ?? false;
}

/// 销毁地理围栏
Future<bool> disposeAMapGeoFence() async {
  final bool? state = await _channel.invokeMethod('disposeGeoFence');
  return state ?? false;
}

/// 删除指定地理围栏
Future<bool> removeGeoFenceWithCustomID(String customID) async {
  final bool? state =
      await _channel.invokeMethod('removeGeoFenceWithCustomID', customID);
  return state ?? false;
}

/// 删除所有地理围栏
Future<bool> removeAllGeoFence() async {
  final bool? state = await _channel.invokeMethod('removeAllGeoFence');
  return state ?? false;
}

class AMapPoiModel {
  AMapPoiModel({
    required this.keyword,
    required this.poiType,
    required this.city,
    required this.size,
    required this.customId,
  });

  /// POI关键字  (北京大学)
  late String keyword;

  /// POI类型  (高等院校)
  late String poiType;

  /// POI所在的城市名称  (北京)
  late String city;

  /// 范围大小
  late int size;

  /// 与围栏关联的自有业务ID
  late String customId;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'keyword': keyword,
        'poiType': poiType,
        'city': city,
        'size': size,
        'customId': customId
      };
}

/// 添加高德POI地理围栏
Future<bool> addGeoFenceWithPOI(AMapPoiModel aMapPoiModel) async {
  final bool? state =
      await _channel.invokeMethod('addGeoFenceWithPOI', aMapPoiModel.toMap());
  return state ?? false;
}

class AMapLatLongModel {
  AMapLatLongModel({
    required this.keyword,
    required this.poiType,
    required this.aroundRadius,
    required this.size,
    required this.customId,
  });

  /// POI关键字  (北京大学)
  late String keyword;

  /// POI类型  (高等院校)
  late String poiType;

  /// 经纬度
  late LatLong latLong;

  /// 周边半径
  late double aroundRadius;

  /// 范围大小
  late int size;

  /// 与围栏关联的自有业务ID
  late String customId;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'keyword': keyword,
        'poiType': poiType,
        'latitude': latLong.latitude,
        'longitude': latLong.longitude,
        'aroundRadius': aroundRadius,
        'size': size,
        'customId': customId
      };
}

/// 添加高德经纬度地理围栏
Future<bool> addAMapGeoFenceWithLatLong(
    AMapLatLongModel aMapLatLongModel) async {
  final bool? state = await _channel.invokeMethod(
      'addAMapGeoFenceWithLatLong', aMapLatLongModel.toMap());
  return state ?? false;
}

/// 创建行政区划围栏  根据关键字创建围栏
///  keyword 行政区划关键字  例如：朝阳区
///  customId 与围栏关联的自有业务Id
Future<bool> addGeoFenceWithDistrict(String keyword, String customId) async {
  final bool? state = await _channel.invokeMethod('addGeoFenceWithDistrict',
      <String, String>{'keyword': keyword, 'customId': customId});
  return state ?? false;
}

/// 创建圆形围栏
///  latLong 经纬度 围栏中心点
///  radius 要创建的围栏半径 ，半径无限制，单位米
///  customId 与围栏关联的自有业务Id
Future<bool> addCircleGeoFence(
    LatLong latLong, double radius, String customId) async {
  final bool? state =
      await _channel.invokeMethod('addCircleGeoFence', <String, dynamic>{
    'latitude': latLong.latitude,
    'longitude': latLong.longitude,
    'radius': radius,
    'customId': customId
  });
  return state ?? false;
}

/// 创建多边形围栏
///  latLongs 多个经纬度点 最少3个点
///  radius 要创建的围栏半径 ，半径无限制，单位米
///  customId 与围栏关联的自有业务Id
Future<bool> addCustomGeoFence(List<LatLong> latLongs, String customId) async {
  if (latLongs.length < 3) return false;
  final bool? state = await _channel.invokeMethod(
      'addCustomGeoFence', <String, dynamic>{
    'latLong': latLongs.map((LatLong e) => e.toMap()).toList(),
    'customId': customId
  });
  return state ?? false;
}

class AMapGeoFenceModel {
  AMapGeoFenceModel.fromMap(Map<dynamic, dynamic> json) {
    customID = json['customID'] as String?;
    fenceId = json['fenceId'] as String?;
    status = json['status'] as int?;
    type = json['type'] as int?;
    radius = json['radius'] as double?;
    fence = json['radius'] == null
        ? null
        : AMapGeoFenceModel.fromMap(json['radius'] as Map<dynamic, dynamic>);
  }

  /// 自定义id
  String? customID;

  /// 在ios
  /// status  = 0,       ///< 未知
  /// status  = 1,       ///< 在范围内
  /// status  = 2,       ///< 在范围外
  /// status  = 3,       ///< 停留(在范围内超过10分钟)
  int? status;

  /// 在ios
  ///    type   = 0,       /// 圆形地理围栏
  ///    type   = 1,       /// 多边形地理围栏
  ///    type   = 2,       /// 兴趣点（POI）地理围栏
  ///    type   = 3,       /// 行政区划地理围栏
  int? type;

  /// 围栏唯一id
  String? fenceId;

  /// 仅 Android 有数据
  AMapGeoFenceModel? fence;

  /// 仅 Android 有数据
  double? radius;
}

typedef EventHandlerAMapGeoFence = void Function(AMapGeoFenceModel location);

/// 开启围栏状态监听
/// 不需要使用时 一定要调用 [stopGeoFenceChange] 避免内存移出
Future<bool> startGeoFenceChange(
    {EventHandlerAMapGeoFence? onGeoFenceChange}) async {
  final bool? state = await _channel.invokeMethod('startGeoFence');
  if (state != null && state) {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'updateGeoFence':
          if (onGeoFenceChange == null) return;
          if (call.arguments == null) return;
          final Map<dynamic, dynamic> argument =
              call.arguments as Map<dynamic, dynamic>;
          return onGeoFenceChange(AMapGeoFenceModel.fromMap(argument));
      }
    });
  }
  return false;
}

/// 关闭围栏状态监听
Future<bool> stopGeoFenceChange() async {
  final bool? state = await _channel.invokeMethod('startGeoFence');
  return state ?? false;
}
