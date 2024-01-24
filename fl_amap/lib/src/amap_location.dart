part of '../fl_amap.dart';

typedef FlAMapLocationChanged = void Function(AMapLocation? location);

class FlAMapLocation {
  factory FlAMapLocation() => _singleton ??= FlAMapLocation._();

  FlAMapLocation._();

  final MethodChannel _channel = const MethodChannel('fl.amap.Location');

  static FlAMapLocation? _singleton;

  bool _isInitialize = false;

  ///  初始化定位
  ///  @param options 启动系统所需选项
  Future<bool> initialize(
      {AMapLocationOptionForIOS? optionForIOS,
      AMapLocationOptionForAndroid? optionForAndroid}) async {
    if (!_supportPlatform) return false;
    final bool? isInit = await _channel.invokeMethod(
        'initialize', _optionToMap(optionForIOS, optionForAndroid));
    if (isInit == true) _isInitialize = isInit!;
    return isInit ?? false;
  }

  /// 直接获取定位
  Future<AMapLocation?> getLocation(
      {AMapLocationOptionForIOS? optionForIOS,
      AMapLocationOptionForAndroid? optionForAndroid}) async {
    if (!_supportPlatform || !_isInitialize) return null;
    final Map<dynamic, dynamic>? location = await _channel.invokeMethod(
        'getLocation', _optionToMap(optionForIOS, optionForAndroid));
    if (location == null) return null;
    return AMapLocation.fromMap(location);
  }

  /// dispose
  Future<bool> dispose() async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('dispose');
    return state ?? false;
  }

  /// 启动监听位置改变
  Future<bool> startLocation(
      {AMapLocationOptionForIOS? optionForIOS,
      AMapLocationOptionForAndroid? optionForAndroid}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod<bool?>(
        'startLocation', _optionToMap(optionForIOS, optionForAndroid));
    return state ?? false;
  }

  void addMethodCallHandler({FlAMapLocationChanged? onLocationChanged}) {
    _channel.setMethodCallHandler((MethodCall call) async {
      final args = call.arguments;
      print("addMethodCallHandler===\n"
          "${call.method}:${call.arguments}\n"
          "===\n");
      switch (call.method) {
        case 'onAuthorizationChanged':
          break;
        case 'onLocationFailed':
          break;
        case 'onLocationChanged':
          onLocationChanged
              ?.call(args is Map ? AMapLocation.fromMap(args) : null);
          break;
      }
    });
  }

  ///  停止监听位置改变
  Future<bool> stopLocation() async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('stopLocation');
    if (state == true) {
      _isInitialize = false;
      _channel.setMethodCallHandler(null);
    }
    return state ?? false;
  }

  Map<String, dynamic>? _optionToMap(AMapLocationOptionForIOS? optionForIOS,
      AMapLocationOptionForAndroid? optionForAndroid) {
    if (optionForIOS != null) return optionForIOS.toMap();
    if (optionForAndroid != null) return optionForAndroid.toMap();
    return null;
  }
}

class AMapLocationQualityReport {
  static const int ok = 0;
  static const int noGpsProvider = 1;
  static const int off = 2;
  static const int modeSaving = 3;
  static const int noGpsPermission = 4;

  AMapLocationQualityReport.fromMap(Map<dynamic, dynamic> map)
      : adviseMessage = map['adviseMessage'] as String?,
        gpsSatellites = map['gpsSatellites'] as int?,
        gpsStatus = map['gpsStatus'] as int?,
        netUseTime = map['netUseTime'] as int?,
        networkType = map['networkType'] as String?,
        isWifiAble = map['isWifiAble'] as bool?,
        isInstalledHighDangerMockApp =
            map['isInstalledHighDangerMockApp'] as bool?;

  /// 提示语义,状态良好时，返回的是内容为空 根据当前的质量报告，给出相应的建议
  final String? adviseMessage;

  /// 当前的卫星数， 只有在非低功耗模式下此值才有效
  final int? gpsSatellites;

  /// 卫星状态信息，只有在非低功耗模式下此值才有效
  final int? gpsStatus;

  /// 网络定位时的网络耗时 单位：毫秒
  final int? netUseTime;

  /// 网络连接类型（2G、3G、4G、WIFI)
  final String? networkType;

  /// wifi开关是否打开 如果wifi关闭建议打开wifi开关，提高定位质量
  final bool? isWifiAble;

  /// 是否安装了高危位置模拟软件 首次定位可能没有结果
  final bool? isInstalledHighDangerMockApp;

  Map<String, dynamic> toMap() => {
        "adviseMessage": adviseMessage,
        "gpsSatellites": gpsSatellites,
        "gpsStatus": gpsStatus,
        "netUseTime": netUseTime,
        "networkType": networkType,
        "isWifiAble": isWifiAble,
        "isInstalledHighDangerMockApp": isInstalledHighDangerMockApp,
      };
}

class AMapLocation {
  AMapLocation.fromMap(Map<dynamic, dynamic> map)
      : description = map['description'] as String?,
        speed = map['speed'] as double?,
        altitude = map['altitude'] as double?,
        accuracy = map['accuracy'] as double?,
        adCode = map['adCode'] as String?,
        aoiName = map['aoiName'] as String?,
        city = map['city'] as String?,
        cityCode = map['cityCode'] as String?,
        country = map['country'] as String?,
        district = map['district'] as String?,
        poiName = map['poiName'] as String?,
        provider = map['provider'] as String?,
        province = map['province'] as String?,
        street = map['street'] as String?,
        locationType = map['locationType'] as int?,
        address = map['street'] as String?,
        bearing = map['bearing'] as double?,
        buildingId = map['buildingId'] as String?,
        streetNum = map['streetNum'] as String?,
        conScenario = map['conScenario'] as int?,
        coordinateType = map['coordinateType'] as String?,
        floor = map['floor'] as String?,
        errorCode = map['errorCode'] as int?,
        gpsAccuracyStatus =
            GPSAccuracyStatus.values[map['gpsAccuracyStatus'] as int],
        locationDetail = map['locationDetail'] as String?,
        locationQualityReport = map['locationQualityReport'] == null
            ? null
            : AMapLocationQualityReport.fromMap(
                map['locationQualityReport'] as Map),
        latitude = map['latitude'] as double?,
        longitude = map['longitude'] as double?,
        satellites = map['satellites'] as int?;

  /// 定位精度 单位:米
  final double? accuracy;

  /// 区域编码
  final String? adCode;

  /// 地址信息
  final String? address;

  /// 海拔高度(单位：米)
  final double? altitude;

  /// 兴趣面名称
  final String? aoiName;

  /// 方向角(单位：度） 默认值：0.0
  /// 取值范围：【0，360】，其中0度表示正北方向，90度表示正东，180度表示正南，270度表示正西
  final double? bearing;

  /// 室内定位的建筑物ID信息
  final String? buildingId;

  /// 国家名称
  final String? country;

  /// 省的名称
  final String? province;

  /// 城市名称
  final String? city;

  /// 城市编码
  final String? cityCode;

  /// 区的名称
  final String? district;

  /// 街道名称
  final String? street;

  /// 门牌号
  final String? streetNum;

  /// 室内外置信度 室内：且置信度取值在[1 ～ 100]，值越大在室内的可能性越大 室外：且置信度取值在[-100 ～ -1] ,值越小在室外的可能性越大 无法识别室内外：置信度返回值为 0
  final int? conScenario;

  /// 坐标系类型 高德定位sdk会返回两种坐标系 AMapLocation.COORD_TYPE_GCJ02 -- GCJ02坐标系 AMapLocation.COORD_TYPE_WGS84 -- WGS84坐标系,国外定位时返回的是WGS84坐标系
  final String? coordinateType;

  /// 室内定位的楼层信息
  final String? floor;

  /// 位置语义信息
  final String? description;

  /// 错误码
  final int? errorCode;

  /// 获取卫星信号强度，仅在卫星定位时有效,
  final GPSAccuracyStatus? gpsAccuracyStatus;

  /// 定位信息描述
  final String? locationDetail;

  /// 定位质量
  final AMapLocationQualityReport? locationQualityReport;

  /// 定位结果来源
  final int? locationType;

  /// 兴趣点名称
  final String? poiName;

  /// 定位提供者
  final String? provider;

  /// 纬度
  final double? latitude;

  /// 经度
  final double? longitude;

  /// 当前可用卫星数量, 仅在卫星定位时有效,
  final int? satellites;

  /// 获取当前速度(单位：米/秒)
  final double? speed;

  /////////////////////////

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
  // final int? code;
  //
  // /// 这个字段用来判断有没有定位成功，在ios下，有可能获取到了经纬度，但是详细地址没有获取到，
  // /// 这个情况下，值也为true
  // final bool? success;
  //
  // ///  是否成功，单纯从经纬度来判断
  // ///  code > 0 ,有可能是逆地理位置有错误，那么这个时候仍然是成功的
  // bool? get isSuccess => success;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'accuracy': accuracy,
        'description': description,
        'speed': speed,
        'altitude': altitude,
        'adCode': adCode,
        'aoiName': aoiName,
        'poiName': poiName,
        'city': city,
        'cityCode': cityCode,
        'country': country,
        'district': district,
        'provider': provider,
        'province': province,
        'street': street,
        'locationType': locationType,
      };
}

class AMapLocationOptionForAndroid {
  AMapLocationOptionForAndroid({
    this.locationMode = AMapLocationMode.batterySaving,
    this.locationProtocol = AMapLocationProtocol.http,
    this.locationPurpose,
    this.geoLanguage = GeoLanguage.none,
    this.gpsFirst = false,
    this.gpsFirstTimeout = 50000,
    this.mockEnable = false,
    this.needAddress = true,
    this.wifiScan = true,
    this.beiDouFirst = false,
    this.deviceModeDistanceFilter = 0,
    this.httpTimeOut = 30000,
    this.interval = 2000,
    this.locationCacheEnable = true,
    this.onceLocationLatest = false,
    this.selfStartServiceEnable = false,
    this.sensorEnable = false,
  })  : assert(gpsFirstTimeout >= 1),
        assert(deviceModeDistanceFilter >= 0);

  /// 设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
  /// 默认 [AMapLocationMode.batterySaving]
  final AMapLocationMode locationMode;

  /// 设置网络请求的协议。可选HTTP或者HTTPS
  /// 默认 [AMapLocationProtocol.http]
  final AMapLocationProtocol locationProtocol;

  /// 设置定位场景，根据场景快速修改option，不支持动态改变
  final AMapLocationPurpose? locationPurpose;

  /// 设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言)
  final GeoLanguage geoLanguage;

  /// 获取高精度模式下单次定位是否优先返回卫星定位信息
  /// 默认值：false
  /// 只有在单次定位高精度定位模式下有效
  /// 为true时，会等待卫星定位结果返回，最多等待30秒，若30秒后仍无卫星定位结果返回，返回网络定位结果
  final bool gpsFirst;

  /// 设置优先返回卫星定位信息时等待卫星定位结果的超时时间，
  /// 单位：毫秒 只有在[gpsFirst]设置为true时才有效。
  final int gpsFirstTimeout;

  /// 设置是否允许模拟位置
  /// 默认为true
  final bool mockEnable;

  /// 设置是否返回地址信息，默认返回地址信息
  /// 当类型为[gpsFirst]true时也可以返回地址信息(需要网络通畅，第一次有可能没有地址信息返回）
  final bool needAddress;

  /// 设置是否允许调用WIFI刷新 默认值为true，
  /// 当设置为false时会停止主动调用WIFI刷新，将会极大程度影响定位精度，但可以有效的降低定位耗电
  final bool wifiScan;

  /// 优先使用北斗
  /// 默认为false
  final bool beiDouFirst;

  /// 获取仅设备模式/高精度模式的系统定位自动回调最少间隔距离值
  /// 默认值：0米
  /// 只有当定位模式为[AMapLocationMode.deviceSensors]（仅设备模式）或 [AMapLocationMode.heightAccuracy]（高精度模式）有效，值小于0时无效
  final double deviceModeDistanceFilter;

  /// 获取联网超时时间  单位：毫秒
  /// 默认值：30000毫秒
  final int httpTimeOut;

  /// 获取发起定位请求的时间间隔  单位：毫秒
  /// 默认值：2000毫秒
  final int interval;

  /// 设置是否使用缓存策略, 默认为true 使用缓存策略
  final bool locationCacheEnable;

  /// 设置定位是否等待WIFI列表刷新 定位精度会更高，但是定位速度会变慢1-3秒
  /// 默认false
  final bool onceLocationLatest;

  /// 设置是否允许定位服务自启动，用于连续定位场景下定位服务被系统异常杀死时重新启动
  final bool selfStartServiceEnable;

  /// 设置是否使用设备传感器
  /// 默认值：false 不使用设备传感器
  final bool sensorEnable;

  Map<String, dynamic> toMap() => {
        'locationMode': locationMode.index,
        'locationProtocol': locationProtocol.index,
        'locationPurpose': locationPurpose?.index,
        'geoLanguage': geoLanguage.index,
        'psFirst': gpsFirst,
        'gpsFirstTimeout': gpsFirstTimeout,
        'mockEnable': mockEnable,
        'needAddress': needAddress,
        'wifiScan': wifiScan,
        'beiDouFirst': beiDouFirst,
        'deviceModeDistanceFilter': deviceModeDistanceFilter,
        'httpTimeOut': httpTimeOut,
        'interval': interval,
        'locationCacheEnable': locationCacheEnable,
        'onceLocationLatest': onceLocationLatest,
        'selfStartServiceEnable': selfStartServiceEnable,
        'sensorEnable': sensorEnable,
      };
}

class AMapLocationOptionForIOS {
  AMapLocationOptionForIOS({
    this.locationAccuracyMode = AMapLocationAccuracyMode.fullAndReduceAccuracy,
    this.distanceFilter,
    this.desiredAccuracy = CLLocationAccuracy.kCLLocationAccuracyBest,
    this.pausesLocationUpdatesAutomatically = false,
    this.allowsBackgroundLocationUpdates = false,
    this.locationTimeout = 2,
    this.reGeocodeTimeout = 2,
    this.locatingWithReGeocode = false,
    this.reGeocodeLanguage = GeoLanguage.none,
    this.detectRiskOfFakeLocation = false,
  })  : assert(locationTimeout >= 2),
        assert(reGeocodeTimeout >= 2);

  /// 设置定位数据回调精度模式，默认为[AMapLocationAccuracyMode.fullAndReduceAccuracy]
  /// 注意：如果定位时未获得定位权限，则首先会调用申请定位权限API，实际定位精度权限取决于用户的权限设置。
  /// ios14+
  final AMapLocationAccuracyMode locationAccuracyMode;

  /// 设定定位的最小更新距离。单位米，默认为0米，表示只要检测到设备位置发生变化就会更新位置信息。
  final double? distanceFilter;

  /// 设定期望的定位精度。单位米，默认为 [CLLocationAccuracy.kCLLocationAccuracyBest]。
  /// 定位服务会尽可能去获取满足desiredAccuracy的定位结果，但不保证一定会得到满足期望的结果。
  /// 注意：设置为kCLLocationAccuracyBest或kCLLocationAccuracyBestForNavigation时，
  /// 单次定位会在达到locationTimeout设定的时间后，将时间内获取到的最高精度的定位结果返回。
  /// ⚠️ 当iOS14及以上版本，模糊定位权限下可能拿不到设置精度的经纬度
  final CLLocationAccuracy desiredAccuracy;

  /// 指定定位是否会被系统自动暂停。默认为NO。
  final bool pausesLocationUpdatesAutomatically;

  /// 是否允许后台定位。默认为NO。只在iOS 9.0及之后起作用。设置为YES的时候必须保证
  /// Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
  /// 由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
  final bool allowsBackgroundLocationUpdates;

  /// 指定单次定位超时时间,默认为2s。最小值是2s。 单位为秒
  /// 注意单次定位请求前设置。
  /// 注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)后开始计算。
  final int locationTimeout;

  /// 指定单次定位逆地理超时时间,默认为2s。最小值是2s。注意单次定位请求前设置。
  final int reGeocodeTimeout;

  /// 连续定位是否返回逆地理信息，默认false。
  final bool locatingWithReGeocode;

  /// 逆地址语言类型，默认是[GeoLanguage.none]
  final GeoLanguage reGeocodeLanguage;

  /// 检测是否存在虚拟定位风险，默认为NO，不检测。
  ///  注意:设置为YES时，单次定位通过 AMapLocatingCompletionBlock 的
  ///  error给出虚拟定位风险提示；
  ///  连续定位通过 amapLocationManager:didFailWithError: 方法的
  ///  error给出虚拟定位风险提示。
  ///  error格式为error.domain==AMapLocationErrorDomain;
  ///  error.code==AMapLocationErrorRiskOfFakeLocation;
  final bool detectRiskOfFakeLocation;

  Map<String, dynamic> toMap() => {
        'locationAccuracyMode': locationAccuracyMode.index,
        'desiredAccuracy': desiredAccuracy.name,
        'distanceFilter': distanceFilter,
        'pausesLocationUpdatesAutomatically':
            pausesLocationUpdatesAutomatically,
        'allowsBackgroundLocationUpdates': allowsBackgroundLocationUpdates,
        'locationTimeout': locationTimeout,
        'reGeocodeTimeout': reGeocodeTimeout,
        'locatingWithReGeocode': locatingWithReGeocode,
        'geoLanguage': reGeocodeLanguage.index,
        'detectRiskOfFakeLocation': detectRiskOfFakeLocation,
      };
}

enum AMapLocationAccuracyMode {
  /// 默认模式，该模式下会申请临时精确定位权限，如果用户拒绝，则依然开启定位，回调模糊定位数据；
  fullAndReduceAccuracy,

  /// 高精度模式，该模式下会申请临时精确定位权限，如果用户拒绝，则回调error；
  fullAccuracy,

  /// 低精度模式，该模式下不会申请临时精确定位权限，根据当前定位权限回调定位数据；
  reduceAccuracy,
}

/// android
/// 定位协议，目前支持二种定位协议
/// http协议： 在这种定位协议下，会使用http请求定位 https协议： 在这种定位协议下，会使用https请求定位
enum AMapLocationProtocol { http, https }

/// android 设置定位场景，根据场景快速修改option，不支持动态改变，修改后需要调用AMapLocationClient.startLocation()使其生效
enum AMapLocationPurpose {
  /// 签到场景 只进行一次定位返回最接近真实位置的定位结果（定位速度可能会延迟1-3s）
  signIn,

  /// 出行场景 高精度连续定位，适用于有户内外切换的场景，卫星定位和网络定位相互切换，卫星定位成功之后网络定位不再返回，卫星信号断开之后一段时间才会返回网络结果
  transport,

  /// 运动场景 高精度连续定位，适用于有户内外切换的场景，卫星定位和网络定位相互切换，卫星定位成功之后网络定位不再返回，卫星信号断开之后一段时间才会返回网络结果
  sport
}

/// android ios 逆地理位置信息的语言
enum GeoLanguage {
  /// 选择这种模式，会根据位置按照相应的语言返回逆地理信息，在国外按英语返回，在国内按中文返回
  none,

  /// 设置只中文后，无论在国外还是国内都为返回中文的逆地理信息
  zh,

  /// 设置英文后，无论在国外还是国内都为返回英文的逆地理信息
  en,
}

/// android 获取卫星信号强度
enum GPSAccuracyStatus { bad, good, unknown }

/// android
/// 定位模式，目前支持三种定位模式
enum AMapLocationMode {
  /// 低功耗定位模式： 在这种模式下，将只使用高德网络定位
  batterySaving,

  /// 仅设备定位模式： 在这种模式下，将只使用卫星定位。
  deviceSensors,

  /// 高精度定位模式： 在这种定位模式下，将同时使用高德网络定位和卫星定位,优先返回精度高的定位
  heightAccuracy
}
