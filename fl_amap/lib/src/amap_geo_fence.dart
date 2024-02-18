part of '../fl_amap.dart';

typedef EventHandlerAMapGeoFenceStatus = void Function(
    AMapGeoFenceStatusModel? geoFence);

class FlAMapGeoFence {
  factory FlAMapGeoFence() => _singleton ??= FlAMapGeoFence._();

  FlAMapGeoFence._();

  final MethodChannel _channel = const MethodChannel('fl.amap.GeoFence');

  static FlAMapGeoFence? _singleton;

  bool _isInitialize = false;

  bool _hasListener = false;

  ///  初始化地理围栏
  ///  allowsBackgroundLocationUpdates 仅支持 ios 在iOS9及之后版本的系统中，
  ///  如果您希望程序在后台持续检测围栏触发行为，需要保证manager 的 allowsBackgroundLocationUpdates 为YES，
  ///  设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
  ///  ios 添加代理
  Future<bool> initialize(GeoFenceActivateAction action,
      [bool allowsBackgroundLocationUpdates = false]) async {
    if (!_supportPlatform) return false;
    final bool? isInit =
        await _channel.invokeMethod('initialize', <String, dynamic>{
      'action': GeoFenceActivateAction.values.indexOf(action),
      'allowsBackgroundLocationUpdates': allowsBackgroundLocationUpdates
    });
    if (isInit == true) _isInitialize = isInit!;
    return isInit ?? false;
  }

  /// 销毁地理围栏
  /// ios 关闭代理,移出所有的GeoFence
  /// android 关闭广播,移出所有的GeoFence
  Future<bool> dispose() async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod<bool?>('dispose');
    if (state == true) _isInitialize = !state!;
    _hasListener = false;
    return state == true;
  }

  /// 删除地理围栏
  /// customID !=null 删除指定围栏 否则删除所有围栏
  Future<bool> remove({String? customID}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('remove', customID);
    return state == true;
  }

  /// 获取所有围栏信息
  /// 在ios  customID !=null 获取指定围栏信息
  Future<List<AMapGeoFenceModel>> getAll({String? customID}) async {
    if (!_supportPlatform || !_isInitialize) return [];
    final List<dynamic>? list = await _channel.invokeMethod('getAll', customID);
    if (list != null) {
      return list
          .map((dynamic e) =>
              AMapGeoFenceModel.fromMap(e as Map<dynamic, dynamic>))
          .toList();
    }
    return [];
  }

  /// 添加高德POI地理围栏
  Future<bool> addPOI(AMapPoiModel model) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('addPOI', model.toMap());
    return state == true;
  }

  /// 添加高德经纬度地理围栏
  Future<bool> addLatLng(AMapGeoFenceLatLngModel model) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('addLatLng', model.toMap());
    return state == true;
  }

  /// 创建行政区划围栏  根据关键字创建围栏
  /// keyword 行政区划关键字  例如：朝阳区
  /// customID 与围栏关联的自有业务Id
  Future<bool> addDistrict(
      {required String keyword, required String customID}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod(
        'addDistrict', {'keyword': keyword, 'customID': customID});
    return state == true;
  }

  /// 创建圆形围栏
  /// latLng 经纬度 围栏中心点
  /// radius 要创建的围栏半径 ，半径无限制，单位米
  /// customID 与围栏关联的自有业务Id
  Future<bool> addCircle(
      {required LatLng latLng,
      required double radius,
      required String customID}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('addCircle', {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'radius': radius,
      'customID': customID
    });
    return state == true;
  }

  /// 创建多边形围栏
  /// latLngs 多个经纬度点 最少3个点
  /// radius 要创建的围栏半径 ，半径无限制，单位米
  /// customID 与围栏关联的自有业务Id
  Future<bool> addCustom(
      {required List<LatLng> latLng, required String customID}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    if (latLng.length < 3) return false;
    final bool? state = await _channel.invokeMethod('addCustom', {
      'latLng': latLng.map((LatLng e) => e.toMap()).toList(),
      'customID': customID
    });
    return state == true;
  }

  /// 暂停监听围栏
  /// customID !=null 暂停监听指定customID 的围栏 仅支持ios
  /// android 不会关闭广播
  /// ios 不会关闭代理
  Future<bool> pause({String? customID}) async {
    if (!_supportPlatform || !_isInitialize || !_hasListener) return false;
    if (_isIOS) assert(customID != null, 'ios 平台 customID 必须不为null');
    final bool? state = await _channel.invokeMethod('pauseGeoFence', customID);
    if (state == true) _channel.setMethodCallHandler(null);
    _hasListener = false;
    return state == true;
  }

  /// 开启围栏状态监听
  ///  customID !=null 监听指定customID 的围栏 仅支持ios
  ///  android 第一次 调用 开启广播监听
  Future<bool> start(
      {String? customID,
      EventHandlerAMapGeoFenceStatus? onGeoFenceChanged}) async {
    if (!_supportPlatform || !_isInitialize || _hasListener) return false;
    if (_isIOS) assert(customID != null, 'ios 平台 customID 必须不为null');
    final bool? state = await _channel.invokeMethod('startGeoFence', customID);
    if (state == true) {
      _hasListener = true;
      _channel.setMethodCallHandler((MethodCall call) async {
        switch (call.method) {
          case 'updateGeoFence':
            onGeoFenceChanged?.call(call.arguments == null
                ? null
                : AMapGeoFenceStatusModel.fromMap(
                    call.arguments as Map<dynamic, dynamic>));
        }
      });
    }
    return state == true;
  }
}

class AMapGeoFenceStatusModel {
  AMapGeoFenceStatusModel.fromMap(Map<dynamic, dynamic> json) {
    customID = json['customID'] as String?;
    fenceID = json['fenceID'] as String?;
    final statusInt = json['status'] as int?;
    if (statusInt != null && statusInt < 4) {
      status = GenFenceStatus.values[statusInt];
    }
    final typeInt = json['type'] as int?;
    if (typeInt != null && typeInt < 4) type = GenFenceType.values[typeInt];
    fence = json['fence'] == null
        ? null
        : AMapGeoFenceModel.fromMap(json['fence'] as Map<dynamic, dynamic>);
  }

  /// 自定义id
  String? customID;

  /// 当前围栏状态
  late GenFenceStatus status = GenFenceStatus.none;

  /// 围栏类型
  GenFenceType? type;

  /// 围栏唯一id
  String? fenceID;

  /// 仅 Android 有数据
  AMapGeoFenceModel? fence;

  Map<String, dynamic> toMap() => {
        'customID': customID,
        'status': status,
        'type': type,
        'fenceID': fenceID,
        'fence': fence?.toMap()
      };
}

/// 围栏数据
class AMapGeoFenceModel {
  AMapGeoFenceModel.fromMap(Map<dynamic, dynamic> json) {
    pointList = <List<LatLng>>[];
    final points = json['pointList'];
    if (points is List) {
      for (var v in points) {
        final points = v as List<dynamic>;
        pointList!.add(points
            .map((dynamic e) => LatLng.fromMap(e as Map<dynamic, dynamic>))
            .toList());
      }
    }
    center = json['center'] != null
        ? LatLng.fromMap(json['center'] as Map<dynamic, dynamic>)
        : null;
    poiItem = json['poiItem'] != null
        ? AMapPoiItemModel.fromMap(json['poiItem'] as Map<dynamic, dynamic>)
        : null;
    radius = json['radius'] as double?;
    customID = json['customID'] as String?;
    fenceID = json['fenceID'] as String?;
    final statusInt = json['status'] as int?;
    if (statusInt != null && statusInt < 4) {
      status = GenFenceStatus.values[statusInt];
    }
    final typeInt = json['type'] as int?;
    if (typeInt != null && typeInt < 4) type = GenFenceType.values[typeInt];
  }

  /// 中心点
  LatLng? center;

  /// 自定义id
  String? customID;

  /// 围栏唯一id
  String? fenceID;

  /// 围栏状态
  late GenFenceStatus status = GenFenceStatus.none;

  /// 围栏类型
  GenFenceType? type;

  /// 围栏半径
  /// 仅android 有数据
  double? radius;

  /// 仅android 有数据
  List<List<LatLng>>? pointList;

  /// 仅android 有数据
  AMapPoiItemModel? poiItem;

  Map<String, dynamic> toMap() => {
        'pointList': pointList
            ?.map((List<LatLng> v) => v.map((LatLng e) => e.toMap()).toList())
            .toList(),
        'center': center?.toMap(),
        'poiItem': poiItem?.toMap(),
        'type': type,
        'radius': radius,
        'customID': customID,
        'fenceID': fenceID,
        'status': status
      };
}

class AMapPoiItemModel {
  AMapPoiItemModel.fromMap(Map<dynamic, dynamic> json) {
    adName = json['adName'] as String?;
    address = json['address'] as String?;
    poiName = json['poiName'] as String?;
    city = json['city'] as String?;
    poiType = json['poiType'] as String?;
    poiId = json['poiId'] as String?;
    final latitude = json['latitude'] as double?;
    final longitude = json['longitude'] as double?;
    if (latitude != null && longitude != null) {
      latLng = LatLng(latitude, longitude);
    }
  }

  String? adName;
  String? address;
  String? poiName;
  String? city;
  String? poiType;
  LatLng? latLng;
  String? poiId;

  Map<String, dynamic> toMap() => {
        'adName': adName,
        'address': address,
        'poiName': poiName,
        'city': city,
        'poiType': poiType,
        'latLng': latLng?.toMap(),
        'poiId': poiId
      };
}

class AMapPoiModel {
  AMapPoiModel({
    required this.keyword,
    required this.poiType,
    required this.city,
    required this.size,
    required this.customID,
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
  late String customID;

  Map<String, dynamic> toMap() => {
        'keyword': keyword,
        'poiType': poiType,
        'city': city,
        'size': size,
        'customID': customID
      };
}

class AMapGeoFenceLatLngModel {
  AMapGeoFenceLatLngModel({
    required this.keyword,
    required this.poiType,
    required this.aroundRadius,
    required this.size,
    required this.latLng,
    required this.customID,
  });

  /// POI关键字  (北京大学)
  late String keyword;

  /// POI类型  (高等院校)
  late String poiType;

  /// 经纬度
  late LatLng latLng;

  /// 周边半径
  late double aroundRadius;

  /// 范围大小
  late int size;

  /// 与围栏关联的自有业务ID
  late String customID;

  Map<String, dynamic> toMap() => {
        'keyword': keyword,
        'poiType': poiType,
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
        'aroundRadius': aroundRadius,
        'size': size,
        'customID': customID
      };
}
