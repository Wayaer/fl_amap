import 'package:fl_amap/fl_amap.dart';
import 'package:flutter/services.dart';

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
      await channel.invokeMethod('initGeoFence', <String, dynamic>{
    'action': GeoFenceActivateAction.values.indexOf(action),
    'allowsBackgroundLocationUpdates': allowsBackgroundLocationUpdates
  });
  return isInit ?? false;
}

/// 销毁地理围栏
Future<bool> disposeAMapGeoFence() async {
  final bool? state = await channel.invokeMethod('disposeGeoFence');
  return state ?? false;
}

/// 暂停监听所有围栏
/// customID !=null 暂停监听指定customID 的围栏 仅支持ios
Future<bool> pauseAMapGeoFence({String? customID}) async {
  final bool? state = await channel.invokeMethod('pauseGeoFence', customID);
  return state ?? false;
}

/// 重新开始监听所有围栏
/// customID !=null 重新开始监听指定customID 的围栏 仅支持ios
Future<bool> resumeAMapGeoFence({String? customID}) async {
  final bool? state = await channel.invokeMethod('resumeGeoFence', customID);
  return state ?? false;
}

/// 删除地理围栏
/// customID !=null 删除指定围栏 否则删除所有围栏
Future<bool> removeAMapGeoFence({String? customID}) async {
  final bool? state = await channel.invokeMethod('removeGeoFence', customID);
  return state ?? false;
}

/// 获取所有围栏信息
/// 在ios  customID !=null 获取指定围栏信息
Future<List<AMapGeoFenceModel>> getAllAMapGeoFence({String? customID}) async {
  final List<dynamic>? list =
      await channel.invokeMethod('getAllGeoFence', customID);
  if (list != null)
    return list
        .map((dynamic e) =>
            AMapGeoFenceModel.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  return <AMapGeoFenceModel>[];
}

class AMapGeoFenceModel {
  AMapGeoFenceModel({
    this.pointList,
    this.center,
    this.type,
    this.radius,
    this.customId,
    this.fenceId,
    this.status,
  });

  AMapGeoFenceModel.fromMap(Map<dynamic, dynamic> json) {
    pointList = <List<LatLong>>[];
    if (json['pointList'] != null) {
      json['pointList'].forEach((dynamic v) {
        final List<dynamic> points = v as List<dynamic>;
        pointList!.add(points
            .map((dynamic e) => LatLong.fromMap(e as Map<dynamic, dynamic>))
            .toList());
      });
    }
    center = json['center'] != null
        ? LatLong.fromMap(json['center'] as Map<dynamic, dynamic>)
        : null;
    poiItem = json['poiItem'] != null
        ? AMapPoiDetailModel.fromMap(json['poiItem'] as Map<dynamic, dynamic>)
        : null;
    type = json['type'] as int?;
    radius = json['radius'] as double?;
    customId = json['customId'] as String?;
    fenceId = json['fenceId'] as String?;
    status = json['status'] as int?;
  }

  List<List<LatLong>>? pointList;
  LatLong? center;
  int? type;
  double? radius;
  String? customId;
  String? fenceId;
  int? status;
  AMapPoiDetailModel? poiItem;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pointList'] = pointList == null
        ? null
        : pointList!
            .map((List<LatLong> v) => v.map((LatLong e) => e.toMap()).toList())
            .toList();
    data['center'] = center == null ? null : center!.toMap();
    data['poiItem'] = poiItem == null ? null : poiItem!.toMap();
    data['type'] = type;
    data['radius'] = radius;
    data['customId'] = customId;
    data['fenceId'] = fenceId;
    data['status'] = status;
    return data;
  }
}

class AMapPoiDetailModel {
  AMapPoiDetailModel(
      {this.adName,
      this.address,
      this.poiName,
      this.city,
      this.poiType,
      this.latLong,
      this.poiId});

  AMapPoiDetailModel.fromMap(Map<dynamic, dynamic> json) {
    adName = json['adName'] as String?;
    address = json['address'] as String?;
    poiName = json['poiName'] as String?;
    city = json['city'] as String?;
    poiType = json['poiType'] as String?;
    poiId = json['poiId'] as String?;
    final double? latitude = json['latitude'] as double?;
    final double? longitude = json['longitude'] as double?;
    if (latitude != null && longitude != null)
      latLong = LatLong(latitude, longitude);
  }

  String? adName;
  String? address;
  String? poiName;
  String? city;
  String? poiType;
  LatLong? latLong;
  String? poiId;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adName'] = adName;
    data['address'] = address;
    data['poiName'] = poiName;
    data['city'] = city;
    data['poiType'] = poiType;
    data['latLong'] = latLong == null ? null : latLong!.toMap();
    data['poiId'] = poiId;
    return data;
  }
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
Future<bool> addAMapGeoFenceWithPOI(AMapPoiModel aMapPoiModel) async {
  final bool? state =
      await channel.invokeMethod('addGeoFenceWithPOI', aMapPoiModel.toMap());
  return state ?? false;
}

class AMapLatLongModel {
  AMapLatLongModel({
    required this.keyword,
    required this.poiType,
    required this.aroundRadius,
    required this.size,
    required this.latLong,
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
  final bool? state = await channel.invokeMethod(
      'addAMapGeoFenceWithLatLong', aMapLatLongModel.toMap());
  return state ?? false;
}

/// 创建行政区划围栏  根据关键字创建围栏
///  keyword 行政区划关键字  例如：朝阳区
///  customId 与围栏关联的自有业务Id
Future<bool> addAMapGeoFenceWithDistrict(
    {required String keyword, required String customId}) async {
  final bool? state = await channel.invokeMethod('addGeoFenceWithDistrict',
      <String, String>{'keyword': keyword, 'customId': customId});
  return state ?? false;
}

/// 创建圆形围栏
///  latLong 经纬度 围栏中心点
///  radius 要创建的围栏半径 ，半径无限制，单位米
///  customId 与围栏关联的自有业务Id
Future<bool> addAMapCircleGeoFence(
    {required LatLong latLong,
    required double radius,
    required String customId}) async {
  final bool? state =
      await channel.invokeMethod('addCircleGeoFence', <String, dynamic>{
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
Future<bool> addAMapCustomGeoFence(
    {required List<LatLong> latLongs, required String customId}) async {
  if (latLongs.length < 3) return false;
  final bool? state = await channel.invokeMethod(
      'addCustomGeoFence', <String, dynamic>{
    'latLong': latLongs.map((LatLong e) => e.toMap()).toList(),
    'customId': customId
  });
  return state ?? false;
}

class AMapGeoFenceStatusModel {
  AMapGeoFenceStatusModel({
    this.status,
    this.customID,
    this.type,
    this.radius,
    this.fence,
    this.fenceId,
  });

  AMapGeoFenceStatusModel.fromMap(Map<dynamic, dynamic> json) {
    customID = json['customID'] as String?;
    fenceId = json['fenceId'] as String?;
    status = json['status'] as int?;
    type = json['type'] as int?;
    radius = json['radius'] as double?;
    fence = json['fence'] == null
        ? null
        : AMapGeoFenceStatusModel.fromMap(
            json['fence'] as Map<dynamic, dynamic>);
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
  AMapGeoFenceStatusModel? fence;

  /// 仅 Android 有数据
  double? radius;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'customID': customID,
        'status': status,
        'type': type,
        'fenceId': fenceId,
        'radius': radius,
        'fence': fence == null ? null : fence!.toMap(),
      };
}

typedef EventHandlerAMapGeoFenceStatus = void Function(
    AMapGeoFenceStatusModel geoFence);

/// 开启围栏状态监听
/// 不需要使用时 一定要调用 [stopGeoFenceChange] 避免内存移出
Future<bool> startAMapGeoFenceChange(
    {EventHandlerAMapGeoFenceStatus? onGeoFenceChange}) async {
  final bool? state = await channel.invokeMethod('startGeoFence');
  if (state != null && state) {
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'updateGeoFence':
          if (onGeoFenceChange == null) return;
          if (call.arguments == null) return;
          final Map<dynamic, dynamic> argument =
              call.arguments as Map<dynamic, dynamic>;
          return onGeoFenceChange(AMapGeoFenceStatusModel.fromMap(argument));
      }
    });
  }
  return state ?? false;
}

/// 关闭围栏状态监听
Future<bool> stopAMapGeoFenceChange() async {
  final bool? state = await channel.invokeMethod('startGeoFence');
  return state ?? false;
}
