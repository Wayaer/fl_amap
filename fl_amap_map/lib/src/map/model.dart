part of '../../fl_amap_map.dart';

class AMapOptions {
  const AMapOptions(
      {required this.latLng,
      this.mapType = MapType.standard,
      this.language = MapLanguage.chinese,
      this.zoom = 13,
      this.maxZoom = 19,
      this.minZoom = 3,
      this.animated = false,
      this.zoomingInPivotsAroundAnchorPoint = true,
      this.allowsBackgroundLocationUpdates = false,
      this.showUserLocation = true,
      this.showUserLocationButton = false,
      this.isZoomGesturesEnabled = true,
      this.isTouchPoiEnable = true,
      this.isRotateGesturesEnabled = true,
      this.isScrollGesturesEnabled = true,
      this.showCompass = true,
      this.showScale = true,
      this.showTraffic = true,
      this.showMapText = true,
      this.showBuildings = true,
      this.showIndoorMap = true,
      this.tilt = 0.0,
      this.isTiltGesturesEnabled = true,
      this.bearing = 0.0});

  /// 地图类型
  final MapType mapType;

  /// 显示语言
  final MapLanguage language;

  /// 中心点
  final LatLng latLng;

  /// 目标可视区域的缩放级别。
  /// IOS（默认3-19，有室内地图时为3-20）
  /// Android 缩放级别范围为[3, 20]
  final double zoom;

  /// 最大缩放级别（有室内地图时最大为20，否则为19）
  final double maxZoom;

  /// 最小缩放级别
  final double minZoom;

  /// 是否显示动画
  final bool animated;

  /// 是否允许可用。
  final bool isZoomGesturesEnabled;

  /// 是否以screenAnchor点作为锚点进行缩放，默认为YES。如果为NO，则以手势中心点作为锚点
  final bool zoomingInPivotsAroundAnchorPoint;

  /// 是否支持平移, 默认YES
  final bool isScrollGesturesEnabled;

  /// 是否可点击POI
  final bool isTouchPoiEnable;

  /// 地图是否显示了定位按钮
  final bool showUserLocation;

  /// 仅android
  final bool showUserLocationButton;

  /// 是否显示指南针, 默认YES
  final bool showCompass;

  /// 是否显示交通路况图层, 默认为NO
  final bool showTraffic;

  /// 是否显示比例尺, 默认YES
  final bool showScale;

  /// 显示底图文字标注，默认显示
  final bool showMapText;

  /// 是否显示室内地图
  final bool showIndoorMap;

  /// 是否显示楼块，默认为YES
  final bool showBuildings;

  /// 地图旋转手势是否可用。
  final bool isRotateGesturesEnabled;

  /// 目标可视区域的倾斜度，以角度为单位
  /// 范围[0, 45]
  final double tilt;
  final bool isTiltGesturesEnabled;

  /// 可视区域指向的方向，以角度为单位，从正北向逆时针方向计算，从0 度到360 度。
  /// 范围[0, 360)
  final double bearing;

  /// 是否允许后台定位。默认为NO。仅支持IOS
  final bool allowsBackgroundLocationUpdates;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'mapType': mapType.index,
      'language': language.index,
      'latLng': latLng.toMap(),
      'zoom': zoom,
      'maxZoom': maxZoom,
      'minZoom': minZoom,
      'animated': animated,
      'isZoomGesturesEnabled': isZoomGesturesEnabled,
      'isScrollGesturesEnabled': isScrollGesturesEnabled,
      'isTouchPoiEnable': isTouchPoiEnable,
      'zoomingInPivotsAroundAnchorPoint': zoomingInPivotsAroundAnchorPoint,
      'showUserLocation': showUserLocation,
      'showUserLocationButton': showUserLocationButton,
      'showCompass': showCompass,
      'showScale': showScale,
      'showTraffic': showTraffic,
      'showMapText': showMapText,
      'showBuildings': showBuildings,
      'showIndoorMap': showIndoorMap,
      'isRotateGesturesEnabled': isRotateGesturesEnabled,
      'tilt': tilt,
      'isTiltGesturesEnabled': isTiltGesturesEnabled,
      'bearing': bearing,
      'allowsBackgroundLocationUpdates': allowsBackgroundLocationUpdates,
    };
    map.addAll(latLng.toMap());
    return map;
  }
}

class Marker {
  Marker.formMap(Map<dynamic, dynamic> map)
      : title = map['title'] as String?,
        snippet = map['snippet'] as String?,
        draggable = map['draggable'] as bool?,
        visible = map['visible'] as bool?,
        alpha = map['alpha'] as Double?,
        latLng = LatLng.fromMap(map['latLng']);

  /// 在地图上标记位置的经纬度值
  final LatLng? latLng;

  /// 点标记的标题
  final String? title;

  /// 点标记的内容
  final String? snippet;

  /// 点标记是否可拖拽
  final bool? draggable;

  /// 点标记是否可见
  final bool? visible;

  /// 点的透明度
  final Double? alpha;
}

List<Poi> getPoiList(List<dynamic> list) {
  List<Poi> result = [];
  for (var item in list) {
    result.add(Poi.formMap(item));
  }
  return result;
}

class Poi {
  Poi.formMap(Map<dynamic, dynamic> map)
      : name = map['name'] as String?,
        poiId = map['poiId'] as String?,
        latLng = LatLng.fromMap(map['latLng']);

  /// name
  final String? name;

  /// poiId
  final String? poiId;

  /// latLng
  final LatLng? latLng;
}

class Heading {
  Heading.formMap(Map<dynamic, dynamic> map)
      : x = map['x'] as double?,
        y = map['y'] as double?,
        z = map['z'] as double?,
        timestamp = map['timestamp'] as double?,
        magneticHeading = map['magneticHeading'] as double?,
        trueHeading = map['trueHeading'] as double?,
        headingAccuracy = map['headingAccuracy'] as double?;

  final double? x;
  final double? y;
  final double? z;
  final double? timestamp;
  final double? magneticHeading;
  final double? trueHeading;
  final double? headingAccuracy;

  Map<String, dynamic> toMap() => {
        'x': x,
        'y': y,
        'z': z,
        'timestamp': timestamp,
        'trueHeading': trueHeading,
        'magneticHeading': magneticHeading,
        'headingAccuracy': headingAccuracy,
      };
}

class Location {
  Location(
      {this.latLng,
      this.accuracy,
      this.altitude,
      this.speed,
      this.timestamp,
      this.isUpdating,
      this.heading,
      this.provider,
      this.bearing});

  factory Location.fromMap(Map<dynamic, dynamic> map) {
    return Location(
        latLng: LatLng.fromMap(map['latLng']),
        timestamp: map['timestamp'] as double?,
        speed: map['speed'] as double?,
        altitude: map['altitude'] as double?,
        accuracy: map['accuracy'] as double?);
  }

  final LatLng? latLng;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? timestamp;

  /// 仅 IOS
  /// 位置更新状态，如果正在更新位置信息，则该值为YES
  final bool? isUpdating;
  final Heading? heading;

  /// 仅 Android
  final String? provider;
  final double? bearing;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'latLng': latLng?.toMap(),
        'accuracy': accuracy,
        'timestamp': timestamp,
        'speed': speed,
        'altitude': altitude,
        'provider': provider,
        'isUpdating': isUpdating,
        'heading': heading?.toMap(),
      };
}

/// 用于定位
class AMapLocation extends Location {
  AMapLocation({
    this.description,
    this.code,
    this.adCode,
    this.aoiName,
    this.city,
    this.cityCode,
    this.country,
    this.district,
    this.formattedAddress,
    this.number,
    this.poiName,
    this.province,
    this.street,
    this.locationType,
    super.timestamp,
    super.speed,
    super.altitude,
    super.latLng,
    super.accuracy,
    super.provider,
  });

  factory AMapLocation.fromMap(Map<dynamic, dynamic> map) {
    return AMapLocation(
        description: map['description'] as String?,
        code: map['code'] as int?,
        latLng: LatLng.fromMap(map['latLng']),
        timestamp: map['timestamp'] as double?,
        speed: map['speed'] as double?,
        altitude: map['altitude'] as double?,
        accuracy: map['accuracy'] as double?,
        adCode: map['adCode'] as String?,
        aoiName: map['aoiName'] as String?,
        city: map['city'] as String?,
        cityCode: map['cityCode'] as String?,
        country: map['country'] as String?,
        district: map['district'] as String?,
        formattedAddress: map['formattedAddress'] as String?,
        number: map['number'] as String?,
        poiName: map['poiName'] as String?,
        provider: map['provider'] as String?,
        province: map['province'] as String?,
        street: map['street'] as String?,
        locationType: map['locationType'] as int?);
  }

  final String? formattedAddress;
  final String? country;
  final String? province;
  final String? city;
  final String? district;
  final String? cityCode;
  final String? adCode;
  final String? street;
  final String? number;
  final String? poiName;
  final String? aoiName;

  ///    这个参数很重要，在android和ios下的判断标准不一样
  ///    android下: 0  定位成功。
  ///       1  一些重要参数为空，如context；请对定位传递的参数进行非空判断。
  ///       2  定位失败，由于仅扫描到单个wifi，且没有基站信息。
  ///       3  获取到的请求参数为空，可能获取过程中出现异常。
  ///       4  请求服务器过程中的异常，多为网络情况差，链路不通导致，请检查设备网络是否通畅。
  ///       5  返回的XML格式错误，解析失败。
  ///       6  定位服务返回定位失败，如果出现该异常，请将errorDetail信息通过API@autonavi.com反馈给我们。
  ///       7  KEY建权失败，请仔细检查key绑定的sha1值与apk签名sha1值是否对应。
  ///       8  Android exception通用错误，请将errordetail信息通过API@autonavi.com反馈给我们。
  ///       9  定位初始化时出现异常，请重新启动定位。
  ///       10 定位客户端启动失败，请检查AndroidManifest.xml文件是否配置了APSService定位服务
  ///       11 定位时的基站信息错误，请检查是否安装SIM卡，设备很有可能连入了伪基站网络。
  ///       12 缺少定位权限，请在设备的设置中开启app的定位权限。
  ///
  ///    ios下:
  ///    typedef NS_ENUM(NSInteger, AMapLocationErrorCode)
  ///       {
  ///       AMapLocationErrorUnknown = 1,               /// <未知错误
  ///       AMapLocationErrorLocateFailed = 2,          /// <定位错误
  ///       AMapLocationErrorReGeocodeFailed  = 3,      /// <逆地理错误
  ///       AMapLocationErrorTimeOut = 4,               /// <超时
  ///       AMapLocationErrorCanceled = 5,              /// <取消
  ///       AMapLocationErrorCannotFindHost = 6,        /// <找不到主机
  ///       AMapLocationErrorBadURL = 7,                /// <URL异常
  ///       AMapLocationErrorNotConnectedToInternet = 8,/// <连接异常
  ///       AMapLocationErrorCannotConnectToHost = 9,   /// <服务器连接失败
  ///       AMapLocationErrorRegionMonitoringFailure=10,/// <地理围栏错误
  ///       AMapLocationErrorRiskOfFakeLocation = 11,   /// <存在虚拟定位风险
  ///       };
  ///
  ///
  /// 这个字段用来判断有没有定位成功，在ios下，有可能获取到了经纬度，但是详细地址没有获取到，
  /// 这个情况下，值也为true
  final int? code;

  ///  是否成功，单纯从经纬度来判断
  ///  code > 0 ,有可能是逆地理位置有错误，那么这个时候仍然是成功的
  bool? get isSuccess => code == 0;

  ///  描述
  final String? description;

  final int? locationType;

  ///  是否有详细地址
  bool? get hasAddress => formattedAddress != null;

  @override
  Map<String, dynamic> toMap() => super.toMap()
    ..addAll({
      'description': description,
      'code': code,
      'adCode': adCode,
      'aoiName': aoiName,
      'poiName': poiName,
      'city': city,
      'cityCode': cityCode,
      'country': country,
      'district': district,
      'formattedAddress': formattedAddress,
      'number': number,
      'province': province,
      'street': street,
      'locationType': locationType,
    });
}
