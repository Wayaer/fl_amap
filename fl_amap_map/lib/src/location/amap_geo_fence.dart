part of '../../fl_amap_map.dart';

typedef EventHandlerAMapGeoFenceStatus = void Function(
    AMapGeoFenceStatusModel geoFence);

class FlAMapGeoFence {
  factory FlAMapGeoFence() => _singleton ??= FlAMapGeoFence._();

  FlAMapGeoFence._();

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
        await _channel.invokeMethod('initGeoFence', <String, dynamic>{
      'action': GeoFenceActivateAction.values.indexOf(action),
      'allowsBackgroundLocationUpdates': allowsBackgroundLocationUpdates
    });
    if (isInit == true) _isInitialize = isInit!;
    return isInit ?? false;
  }

  /// 销毁地理围栏
  /// ios 关闭代理,移出所有的GeoFence
  /// android  关闭广播,移出所有的GeoFence
  Future<bool> dispose() async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod<bool?>('disposeGeoFence');
    if (state == true) _isInitialize = !state!;
    _hasListener = false;
    return state == true;
  }

  /// 删除地理围栏
  /// customID !=null 删除指定围栏 否则删除所有围栏
  Future<bool> remove({String? customID}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('removeGeoFence', customID);
    return state == true;
  }

  /// 获取所有围栏信息
  /// 在ios  customID !=null 获取指定围栏信息
  Future<List<AMapGeoFenceModel>> getAll({String? customID}) async {
    if (!_supportPlatform || !_isInitialize) return <AMapGeoFenceModel>[];
    final List<dynamic>? list =
        await _channel.invokeMethod('getAllGeoFence', customID);
    if (list != null) {
      return list
          .map((dynamic e) =>
              AMapGeoFenceModel.fromMap(e as Map<dynamic, dynamic>))
          .toList();
    }
    return [];
  }

  /// 添加高德POI地理围栏
  Future<bool> addPOI(AMapPoiModel aMapPoiModel) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state =
        await _channel.invokeMethod('addGeoFenceWithPOI', aMapPoiModel.toMap());
    return state == true;
  }

  /// 添加高德经纬度地理围栏
  Future<bool> addLatLng(AMapLatLngModel aMapLatLngModel) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod(
        'addAMapGeoFenceWithLatLng', aMapLatLngModel.toMap());
    return state == true;
  }

  /// 创建行政区划围栏  根据关键字创建围栏
  ///  keyword 行政区划关键字  例如：朝阳区
  ///  customID 与围栏关联的自有业务Id
  Future<bool> addDistrict(
      {required String keyword, required String customID}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('addGeoFenceWithDistrict',
        <String, String>{'keyword': keyword, 'customID': customID});
    return state == true;
  }

  /// 创建圆形围栏
  ///  latLng 经纬度 围栏中心点
  ///  radius 要创建的围栏半径 ，半径无限制，单位米
  ///  customID 与围栏关联的自有业务Id
  Future<bool> addCircle(
      {required LatLng latLng,
      required double radius,
      required String customID}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('addCircleGeoFence', {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'radius': radius,
      'customID': customID
    });
    return state == true;
  }

  /// 创建多边形围栏
  ///  latLngs 多个经纬度点 最少3个点
  ///  radius 要创建的围栏半径 ，半径无限制，单位米
  ///  customID 与围栏关联的自有业务Id
  Future<bool> addCustom(
      {required List<LatLng> latLngs, required String customID}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    if (latLngs.length < 3) return false;
    final bool? state = await _channel.invokeMethod(
        'addCustomGeoFence', <String, dynamic>{
      'latLng': latLngs.map((LatLng e) => e.toMap()).toList(),
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
            if (onGeoFenceChanged == null) return;
            if (call.arguments == null) return;
            onGeoFenceChanged(AMapGeoFenceStatusModel.fromMap(
                call.arguments as Map<dynamic, dynamic>));
        }
      });
    }
    return state == true;
  }
}

class AMapGeoFenceModel {
  AMapGeoFenceModel({
    this.pointList,
    this.center,
    this.type,
    this.radius,
    this.customID,
    this.fenceID,
    this.status,
  });

  AMapGeoFenceModel.fromMap(Map<dynamic, dynamic> json) {
    pointList = <List<LatLng>>[];
    if (json['pointList'] != null) {
      json['pointList'].forEach((dynamic v) {
        final List<dynamic> points = v as List<dynamic>;
        pointList!.add(points
            .map((dynamic e) => LatLng.fromMap(e as Map<dynamic, dynamic>))
            .toList());
      });
    }
    center = json['center'] != null
        ? LatLng.fromMap(json['center'] as Map<dynamic, dynamic>)
        : null;
    poiItem = json['poiItem'] != null
        ? AMapPoiDetailModel.fromMap(json['poiItem'] as Map<dynamic, dynamic>)
        : null;
    type = json['type'] as int?;
    radius = json['radius'] as double?;
    customID = json['customID'] as String?;
    fenceID = json['fenceID'] as String?;
    status = json['status'] as int?;
  }

  List<List<LatLng>>? pointList;
  LatLng? center;
  int? type;
  double? radius;
  String? customID;
  String? fenceID;
  int? status;
  AMapPoiDetailModel? poiItem;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pointList'] = pointList
        ?.map((List<LatLng> v) => v.map((LatLng e) => e.toMap()).toList())
        .toList();
    data['center'] = center?.toMap();
    data['poiItem'] = poiItem?.toMap();
    data['type'] = type;
    data['radius'] = radius;
    data['customID'] = customID;
    data['fenceID'] = fenceID;
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
      this.latLng,
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

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['adName'] = adName;
    data['address'] = address;
    data['poiName'] = poiName;
    data['city'] = city;
    data['poiType'] = poiType;
    data['latLng'] = latLng?.toMap();
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

  Map<String, dynamic> toMap() => <String, dynamic>{
        'keyword': keyword,
        'poiType': poiType,
        'city': city,
        'size': size,
        'customID': customID
      };
}

class AMapLatLngModel {
  AMapLatLngModel({
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

  Map<String, dynamic> toMap() => <String, dynamic>{
        'keyword': keyword,
        'poiType': poiType,
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
        'aroundRadius': aroundRadius,
        'size': size,
        'customID': customID
      };
}

class AMapGeoFenceStatusModel {
  AMapGeoFenceStatusModel({
    this.status = GenFenceStatus.none,
    this.customID,
    this.type,
    this.radius,
    this.fence,
    this.fenceID,
  });

  AMapGeoFenceStatusModel.fromMap(Map<dynamic, dynamic> json) {
    customID = json['customID'] as String?;
    fenceID = json['fenceID'] as String?;
    status = GenFenceStatus.values[(json['status'] as int?) ?? 0];
    final int? t = json['type'] as int?;
    if (t != null) type = GenFenceType.values[t];
    radius = json['radius'] as double?;
    fence = json['fence'] == null
        ? null
        : AMapGeoFenceStatusModel.fromMap(
            json['fence'] as Map<dynamic, dynamic>);
  }

  /// 自定义id
  String? customID;

  late GenFenceStatus status;

  /// 在ios
  ///    type   = 0,       /// 圆形地理围栏
  ///    type   = 1,       /// 多边形地理围栏
  ///    type   = 2,       /// 兴趣点（POI）地理围栏
  ///    type   = 3,       /// 行政区划地理围栏
  GenFenceType? type;

  /// 围栏唯一id
  String? fenceID;

  /// 仅 Android 有数据
  AMapGeoFenceStatusModel? fence;

  /// 仅 Android 有数据
  double? radius;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'customID': customID,
        'status': status,
        'type': type,
        'fenceID': fenceID,
        'radius': radius,
        'fence': fence?.toMap()
      };
}
