part of '../fl_amap.dart';

typedef FlAMapLocationChanged = void Function(AMapLocation? location);
typedef FlAMapLocationFailed = void Function(AMapLocationError? error);
typedef FlAMapLocationHeadingChanged = void Function(
    AMapLocationHeading? heading);

/// User has not yet made a choice with regards to this application
/// case notDetermined = 0
///
/// This application is not authorized to use location services.  Due
/// to active restrictions on location services, the user cannot change
/// this status, and may not have personally denied authorization
/// case restricted = 1
///
/// User has explicitly denied authorization for this application, or
/// location services are disabled in Settings.
/// case denied = 2
///
/// User has granted authorization to use their location at any
/// time.  Your app may be launched into the background by
/// monitoring APIs such as visit monitoring, region monitoring,
/// and significant location change monitoring.
/// This value should be used on iOS, tvOS and watchOS.  It is available on
/// MacOS, but kCLAuthorizationStatusAuthorized is synonymous and preferred.
/// case authorizedAlways = 3
///
/// User has granted authorization to use their location only while
/// they are using your app.  Note: You can reflect the user's
/// continued engagement with your app using
/// -allowsBackgroundLocationUpdates.
/// This value is not available on MacOS.  It should be used on iOS, tvOS and
/// watchOS.
/// case authorizedWhenInUse = 4
typedef FlAMapLocationAuthorizationChanged = void Function(int? status);

class FlAMapLocation {
  factory FlAMapLocation() => _singleton ??= FlAMapLocation._();

  FlAMapLocation._();

  final MethodChannel _channel = const MethodChannel('fl.amap.Location');

  static FlAMapLocation? _singleton;

  bool _isInitialize = false;

  /// 初始化定位
  Future<bool> initialize(
      {AMapLocationOptionForIOS? optionForIOS,
      AMapLocationOptionForAndroid? optionForAndroid}) async {
    if (!_supportPlatform) return false;
    final bool? isInitialize = await _channel.invokeMethod(
        'initialize', _optionToMap(optionForIOS, optionForAndroid));
    return _isInitialize = isInitialize ?? false;
  }

  /// 添加回调监听
  void addListener({
    /// android & ios
    /// 连续定位回调
    FlAMapLocationChanged? onLocationChanged,

    /// 仅在ios中生效
    /// ios连续定位 错误监听
    FlAMapLocationFailed? onLocationFailed,

    /// 仅在ios中生效
    /// 监听设备朝向变化
    FlAMapLocationHeadingChanged? onHeadingChanged,

    /// 仅在ios中生效
    /// 监听权限状态变化
    FlAMapLocationAuthorizationChanged? onAuthorizationChanged,
  }) {
    _channel.setMethodCallHandler((MethodCall call) async {
      final args = call.arguments;
      switch (call.method) {
        case 'onAuthorizationChanged':
          onAuthorizationChanged?.call(args is int ? args : null);
          break;
        case 'onHeadingChanged':
          onHeadingChanged
              ?.call(args is Map ? AMapLocationHeading.fromMap(args) : null);
          break;
        case 'onLocationFailed':
          onLocationFailed
              ?.call(args is Map ? AMapLocationError.fromMap(args) : null);
          break;
        case 'onLocationChanged':
          onLocationChanged
              ?.call(args is Map ? AMapLocation.mapToLocation(args) : null);
          break;
      }
    });
  }

  /// dispose
  Future<bool> dispose() async {
    if (!_supportPlatform || !_isInitialize) return false;
    _channel.setMethodCallHandler(null);
    final bool? state = await _channel.invokeMethod('dispose');
    return state ?? false;
  }

  /// 直接获取定位
  Future<AMapLocation?> getLocation(
      {AMapLocationOptionForIOS? optionForIOS,
      AMapLocationOptionForAndroid? optionForAndroid}) async {
    if (!_supportPlatform || !_isInitialize) return null;
    final Map<dynamic, dynamic>? map = await _channel.invokeMethod(
        'getLocation', _optionToMap(optionForIOS, optionForAndroid));
    if (map == null) return null;
    return AMapLocation.mapToLocation(map);
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

  /// 停止监听位置改变
  Future<bool> stopLocation() async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('stopLocation');
    return state ?? false;
  }

  /// 仅支持ios
  /// 设备是否支持方向识别
  /// ture:设备支持方向识别 ; false:设备不支持支持方向识别
  Future<bool> headingAvailable() async {
    if (!_isIOS || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod<bool>('headingAvailable');
    return state ?? false;
  }

  /// 仅支持ios
  /// 开始获取设备朝向，如果设备支持方向识别，则会通过代理回调方法
  Future<bool> startUpdatingHeading() async {
    if (!_isIOS || !_isInitialize) return false;
    final bool? state =
        await _channel.invokeMethod<bool>('startUpdatingHeading');
    return state ?? false;
  }

  /// 仅支持ios
  /// 停止获取设备朝向
  Future<bool> stopUpdatingHeading() async {
    if (!_isIOS || !_isInitialize) return false;
    final bool? state =
        await _channel.invokeMethod<bool>('stopUpdatingHeading');
    return state ?? false;
  }

  /// 仅支持ios
  /// 停止设备朝向校准显示
  Future<bool> dismissHeadingCalibrationDisplay() async {
    if (!_isIOS || !_isInitialize) return false;
    final bool? state =
        await _channel.invokeMethod<bool>('dismissHeadingCalibrationDisplay');
    return state ?? false;
  }

  /// 仅支持android
  /// 开启后台定位功能 注意: 如果您设置了target>=28,需要增加[android.permission.FOREGROUND_SERVICE]权限,
  /// 如果您的app需要运行在Android Q版本的手机上，需要为ApsService增加android:foregroundServiceType="location"属性，
  /// 例：<service android:name="com.amap.api.location.APSService" android:foregroundServiceType="location"/>
  /// 主要是为了解决Android 8.0以上版本对后台定位的限制，开启后会显示通知栏,如果您的应用本身已经存在一个前台服务通知，则无需再开启此接口
  /// 注意:启动后台定位只是代表开启了后台定位的能力，并不代表已经开始定位，开始定位请调用
  Future<bool> enableBackgroundLocation() async {
    if (!_isAndroid || !_isInitialize) return false;
    final bool? state =
        await _channel.invokeMethod<bool>('enableBackgroundLocation');
    return state ?? false;
  }

  /// 仅支持android
  /// 关闭后台定位功能,关闭后台定位功能只是代表不再提供后台定位的能力，并不是停止定位，停止定位请调用
  /// [removeNotification] - 是否移除通知栏， true：移除通知栏，false：不移除通知栏，可以手动移除
  Future<bool> disableBackgroundLocation(
      {bool removeNotification = true}) async {
    if (!_isAndroid || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod<bool>(
        'disableBackgroundLocation', removeNotification);
    return state ?? false;
  }

  Map<String, dynamic>? _optionToMap(AMapLocationOptionForIOS? optionForIOS,
      AMapLocationOptionForAndroid? optionForAndroid) {
    if (optionForIOS != null && _isIOS) return optionForIOS.toMap();
    if (optionForAndroid != null && _isAndroid) return optionForAndroid.toMap();
    return null;
  }
}

class AMapLocationQualityReport {
  /// 卫星定位状态--正常
  static const int gpsStatusOk = 0;

  /// 卫星定位状态--手机中没有GPS Provider，无法进行卫星定位
  static const int gpsStatusNoGpsProvider = 1;

  /// 卫星定位状态--GPS开关关闭 建议开启GPS开关，提高定位质量
  static const int gpsStatusOff = 2;

  /// 卫星定位状态--选择的定位模式中不包含卫星定位 Android 4.4以上的手机设置中开启了定位（位置）服务，但是选择的模式为省电模式，不包含卫星定位
  /// 建议选择包含gps定位的模式（例如：高精度、仅设备
  static const int gpsStatusModeSaving = 3;

  /// 卫星定位状态--没有GPS定位权限 如果没有GPS定位权限无法进行卫星定位, 建议在安全软件中授予GPS定位权限
  static const int gpsStatusNoGpsPermission = 4;

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

class AMapLocationForAndroid extends AMapLocation {
  AMapLocationForAndroid.fromMap(super.map)
      : accuracy = map['accuracy'] as double?,
        provider = map['provider'] as String?,
        locationType = map['locationType'] as int?,
        buildingId = map['buildingId'] as String?,
        conScenario = map['conScenario'] as int?,
        coordType = map['coordType'] as String?,
        gpsAccuracyStatus =
            GPSAccuracyStatus.getStatus(map['gpsAccuracyStatus'] as int?),
        locationDetail = map['locationDetail'] as String?,
        locationQualityReport = map['locationQualityReport'] == null
            ? null
            : AMapLocationQualityReport.fromMap(
                map['locationQualityReport'] as Map),
        satellites = map['satellites'] as int?,
        trustedLevel = map['trustedLevel'] as int?,
        description = map['description'] as String?,
        super.fromMap();

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'accuracy': accuracy,
        'provider': provider,
        'locationType': locationType,
        'buildingId': buildingId,
        'conScenario': conScenario,
        'coordType': coordType,
        'gpsAccuracyStatus': gpsAccuracyStatus,
        'locationDetail': locationDetail,
        'locationQualityReport': locationQualityReport?.toMap(),
        'satellites': satellites,
        'trustedLevel': trustedLevel,
        'description': description,
      };

  /// 定位精度 单位:米
  final double? accuracy;

  /// 室内定位的建筑物ID信息
  final String? buildingId;

  /// 室内外置信度 室内：且置信度取值在[1 ～ 100]，值越大在室内的可能性越大 室外：且置信度取值在[-100 ～ -1] ,值越小在室外的可能性越大
  /// 无法识别室内外：置信度返回值为 0
  final int? conScenario;

  /// 定位结果的可信度-非常可信 周边信息的新鲜度在15s之内 实时GPS定位结果
  static const int trustedLevelHigh = 1;

  /// 定位结果的可信度-可信度一般 周边信息的新鲜度在15秒-2分钟之间 缓存、离线定位、最后位置
  static const int trustedLevelNormal = 2;

  /// 定位结果的可信度-可信度较低 周边信息的新鲜度在2-10分钟之间
  static const int trustedLevelLow = 3;

  /// 定位结果的可信度-非常不可信 周边信息的新鲜度超过10分钟 模拟定位结果
  static const int trustedLevelBad = 4;

  /// 获取定位结果的可信度 只有在定位成功时才有意义
  /// [trustedLevelHigh]、[trustedLevelNormal]、[trustedLevelLow]、[trustedLevelBad]
  final int? trustedLevel;

  /// AMapLocation.COORD_TYPE_WGS84 -- WGS84坐标系,国外定位时返回的是WGS84坐标系
  static const String coordinateTypeWGS84 = "WGS84";

  /// AMapLocation.COORD_TYPE_GCJ02 -- GCJ02坐标系
  static const String coordinateTypeGCJ02 = "GCJ02";

  /// 坐标系类型 高德定位sdk会返回两种坐标系  [AMapLocationForAndroid.coordinateTypeGCJ02]、[AMapLocationForAndroid.coordinateTypeWGS84]
  final String? coordType;

  /// 卫星信号弱
  static const int gpsAccuracyGood = 1;

  /// 卫星信号强
  static const int gpsAccuracyBad = 0;

  /// 卫星状态未知
  static const int gpsAccuracyUnknown = -1;

  /// 获取卫星信号强度，仅在卫星定位时有效,
  /// [gpsAccuracyGood]、[gpsAccuracyBad]、[gpsAccuracyUnknown]
  final GPSAccuracyStatus? gpsAccuracyStatus;

  /// 定位信息描述
  final String? locationDetail;

  /// 定位质量
  final AMapLocationQualityReport? locationQualityReport;

  /// 位置语义信息
  final String? description;

  /// 卫星定位结果 通过设备卫星定位模块返回的定位结果
  static const int locationTypeGPS = 1;

  /// 前次定位结果 网络定位请求低于1秒、或两次定位之间设备位置变化非常小时返回，设备位移通过传感器感知
  static const int locationTypeSameReq = 2;

  /// 已过时。已合并到AMapLocation.LOCATION_TYPE_SAME_REQ
  @Deprecated('已过时。已合并到[AMapLocationForAndroid.locationTypeSameReq]')
  static const int locationTypeFast = 3;

  /// 缓存定位结果 返回一段时间前设备在相同的环境中缓存下来的网络定位结果，节省无必要的设备定位消耗
  static const int locationTypeFixCache = 4;

  /// Wifi定位结果 属于网络定位，定位精度相对基站定位会更好
  static const int locationTypeWIFI = 5;

  /// 基站定位结果 属于网络定位
  static const int locationTypeCell = 6;

  ///
  static const int locationTypeAMAP = 7;

  /// 离线定位结果
  static const int locationTypeOffLine = 8;

  /// 最后位置缓存
  static const int locationTypeLastLocationCache = 9;

  static const int locationCompensation = 10;

  /// 模糊定位类型
  static const int locationTypeCoarseLocation = 11;

  /// 定位结果类型
  /// [locationTypeGPS]、 [locationTypeSameReq]、  [locationTypeFixCache]、 [locationTypeWIFI]、[locationTypeCell]、
  /// [locationTypeAMAP]、[locationTypeOffLine]、 [locationTypeLastLocationCache]、 [locationCompensation]、
  /// [locationTypeCoarseLocation]、
  final int? locationType;

  /// 定位提供者
  final String? provider;

  /// 当前可用卫星数量, 仅在卫星定位时有效,
  final int? satellites;
}

class AMapLocationForIOS extends AMapLocation {
  AMapLocationForIOS.fromMap(super.map)
      : horizontalAccuracy = map['horizontalAccuracy'] as double?,
        verticalAccuracy = map['verticalAccuracy'] as double?,
        speedAccuracy = map['speedAccuracy'] as double?,
        bearingAccuracy = map['courseAccuracy'] as double?,
        isSimulatedBySoftware = map['isSimulatedBySoftware'] as bool?,
        isProducedByAccessory = map['isProducedByAccessory'] as bool?,
        super.fromMap();

  @override
  Map<String, dynamic> toMap() => {
        ...super.toMap(),
        'horizontalAccuracy': horizontalAccuracy,
        'verticalAccuracy': verticalAccuracy,
        'speedAccuracy': speedAccuracy,
        'bearingAccuracy': bearingAccuracy,
        'isSimulatedBySoftware': isSimulatedBySoftware,
        'isProducedByAccessory': isProducedByAccessory
      };

  /// 定位水平精度 单位:米
  final double? horizontalAccuracy;

  /// 定位垂直精度 单位:米
  final double? verticalAccuracy;

  /// speed 精度
  final double? speedAccuracy;

  /// [bearing] 航向精度
  /// iOS 13.4+
  final double? bearingAccuracy;

  /// 如果这个位置是由软件模拟器(如Xcode)检测到的，设置为 true
  /// iOS 15+
  final bool? isSimulatedBySoftware;

  /// 如果此位置是由外部配件生成的，如CarPlay或MFi配件，则设置为 true
  /// iOS 15+
  final bool? isProducedByAccessory;
}

/// ios 设备朝向
class AMapLocationHeading {
  AMapLocationHeading.fromMap(Map<dynamic, dynamic> map)
      : x = map['x'] as double?,
        y = map['y'] as double?,
        z = map['z'] as double?,
        timestamp = map['timestamp'] as double?,
        headingAccuracy = map['headingAccuracy'] as double?,
        trueHeading = map['trueHeading'] as double?,
        magneticHeading = map['magneticHeading'] as double?;

  /// 返回在x轴上测量的地磁的原始值。
  final double? x;

  /// 返回在y轴上测量的地磁的原始值。
  final double? y;

  /// 返回在z轴上测量的地磁的原始值。
  final double? z;

  /// 返回确定磁航向的时间戳。
  final double? timestamp;

  /// 表示磁航向与实际地磁航向在度数上可能存在差异的最大偏差。负值表示无效
  final double? headingAccuracy;

  /// 以度数表示方向，其中0度为真北。方向是从设备的顶部引用的，而不考虑设备的方向以及用户界面的方向。
  /// 范围: 0.0 - 359.9度，0为正北
  final double? trueHeading;

  /// 表示方向，以度数表示，其中0度为磁北。方向是从设备的顶部引用的，而不考虑设备的方向以及用户界面的方向。
  /// 范围: 0.0 - 359.9度，0为正北
  final double? magneticHeading;

  Map<String, dynamic> toMap() => {
        "x": x,
        "y": y,
        "z": z,
        "timestamp": timestamp,
        "headingAccuracy": headingAccuracy,
        "trueHeading": trueHeading,
        "magneticHeading": magneticHeading
      };
}

class AMapLocationError {
  AMapLocationError.fromMap(Map<dynamic, dynamic> map)
      : errorInfo = map['errorInfo'] as String?,
        errorCode = map['errorCode'] as int?,
        userInfo = map['userInfo'] as Map<dynamic, dynamic>?;

  /// 错误码 这个参数很重要，在android和ios下的判断标准不一样
  /// android下:
  /// LOCATION_SUCCESS = 0                         <定位成功
  /// ERROR_CODE_INVALID_PARAMETER = 1             <一些重要参数为空，如context；请对定位传递的参数进行非空判断。
  /// ERROR_CODE_FAILURE_WIFI_INFO = 2             <定位失败，由于设备仅扫描到单个wifi，不能精准的计算出位置信息。
  /// ERROR_CODE_FAILURE_LOCATION_PARAMETER = 3    <获取到的请求参数为空，可能获取过程中出现异常,可以通过AMapLocation.getLocationDetail()获取详细信息。
  /// ERROR_CODE_FAILURE_CONNECTION = 4            <网络连接异常，多为网络情况差，链路不通导致，请检查设备网络是否通畅。
  /// ERROR_CODE_FAILURE_PARSER = 5                <返回的XML格式错误，解析失败。
  /// ERROR_CODE_FAILURE_LOCATION = 6              <定位服务返回定位失败，如果出现该异常，请查看description
  /// ERROR_CODE_FAILURE_AUTH = 7                  <KEY建权失败，请仔细检查key绑定的sha1值与apk签名sha1值是否对应。
  /// ERROR_CODE_UNKNOWN = 8                       <其他错误，Android exception通用错误，请查看description
  /// ERROR_CODE_FAILURE_INIT = 9                  <定位初始化时出现异常，请重新启动定位。
  /// ERROR_CODE_SERVICE_FAIL = 10                 <定位服务启动失败，请检查是否配置service并且manifest中service标签是否配置在application标签内
  /// ERROR_CODE_FAILURE_CELL = 11                 <定位时的基站信息错误，请检查是否安装SIM卡，设备很有可能连入了伪基站网络。
  /// ERROR_CODE_FAILURE_LOCATION_PERMISSION = 12  <缺少定位权限,请检查是否配置定位权限,并在安全软件和设置中给应用打开定位权限，请在设备的设置中开启app的定位权限。
  /// ERROR_CODE_FAILURE_NOWIFIANDAP = 13          <网络定位失败，请检查设备是否插入sim卡、开启移动网络或开启了wifi模块
  /// ERROR_CODE_FAILURE_NOENOUGHSATELLITES = 14   <卫星定位失败，可用卫星数不足
  /// ERROR_CODE_FAILURE_SIMULATION_LOCATION = 15  <定位位置可能被模拟
  /// ERROR_CODE_AIRPLANEMODE_WIFIOFF = 18         <定位失败，飞行模式下关闭了WIFI开关，请关闭飞行模式或者打开WIFI开关
  /// ERROR_CODE_NOCGI_WIFIOFF = 19                <定位失败，没有检查到SIM卡，并且关闭了WIFI开关，请打开WIFI开关或者插入SIM卡
  /// ERROR_CODE_FAILURE_COARSE_LOCATION = 20      <定位失败，模糊权限下定位异常
  /// ERROR_CODE_NO_COMPENSATION_CACHE = 33
  ///
  /// ios下:
  /// LOCATION_SUCCESS = 0                         <定位成功
  /// AMapLocationErrorUnknown = 1,                <未知错误
  /// AMapLocationErrorLocateFailed = 2,           <定位错误
  /// AMapLocationErrorReGeocodeFailed  = 3,       <逆地理错误
  /// AMapLocationErrorTimeOut = 4,                <超时
  /// AMapLocationErrorCanceled = 5,               <取消
  /// AMapLocationErrorCannotFindHost = 6,         <找不到主机
  /// AMapLocationErrorBadURL = 7,                 <URL异常
  /// AMapLocationErrorNotConnectedToInternet = 8, <连接异常
  /// AMapLocationErrorCannotConnectToHost = 9,    <服务器连接失败
  /// AMapLocationErrorRegionMonitoringFailure=10, <地理围栏错误
  /// AMapLocationErrorRiskOfFakeLocation = 11,    <存在虚拟定位风险
  /// AMapLocationErrorNoFullAccuracyAuth = 12,    <精确定位权限异常
  final int? errorCode;

  /// 错误信息
  /// ios 错误信息查看(https://lbs.amap.com/api/webservice/guide/tools/info)
  final String? errorInfo;

  /// ios 设备才有的错误信息
  final Map<dynamic, dynamic>? userInfo;

  Map<String, dynamic> toMap() =>
      {'errorCode': errorCode, 'errorInfo': errorInfo, 'userInfo': userInfo};
}

class AMapLocation {
  static AMapLocation mapToLocation(Map<dynamic, dynamic> map) {
    if (_isIOS) {
      return AMapLocationForIOS.fromMap(map);
    } else if (_isAndroid) {
      return AMapLocationForAndroid.fromMap(map);
    }
    return AMapLocation.fromMap(map);
  }

  AMapLocation.fromMap(Map<dynamic, dynamic> map)
      : speed = map['speed'] as double?,
        altitude = map['altitude'] as double?,
        adCode = map['adCode'] as String?,
        aoiName = map['aoiName'] as String?,
        city = map['city'] as String?,
        cityCode = map['cityCode'] as String?,
        country = map['country'] as String?,
        district = map['district'] as String?,
        poiName = map['poiName'] as String?,
        province = map['province'] as String?,
        street = map['street'] as String?,
        address =
            map['address'] as String? ?? map['formattedAddress'] as String?,
        streetNum = map['streetNum'] as String? ?? map['number'] as String?,
        latitude = map['latitude'] as double?,
        longitude = map['longitude'] as double?,
        floor = map['floor']?.toString(),
        bearing = map['bearing'] as double? ?? map['course'] as double?,
        timestamp = map['timestamp'] as double?,
        error = AMapLocationError.fromMap(map);

  /// ios 连续定位 错误信息 请使用 [onLocationFailed]
  /// ios 单次定位 android 单次定位和连续定位 错误信息 这里都有
  final AMapLocationError? error;

  /// 高德纬度
  final double? latitude;

  /// 高德经度
  final double? longitude;

  /// 海拔高度(单位：米)
  final double? altitude;

  /// 获取当前速度(单位：米/秒)
  final double? speed;

  /// 室内定位的楼层信息
  final String? floor;

  /// 方向角(单位：度） 默认值：0.0
  /// 取值范围：【0，360】，其中0度表示正北方向，90度表示正东，180度表示正南，270度表示正西
  /// 在android上:
  /// 当定位类型不是GPS时，可以通过 [AMapLocationOptionForAndroid.sensorEnable] 控制是否返回方向角，
  /// 当设置为true时会通过手机传感器获取方向角,如果手机没有对应的传感器会返回0.0 注意：
  /// 定位类型为GPS时，方向角指的是运动方向
  /// 定位类型不是GPS时，方向角指的是手机朝向
  final double? bearing;

  /// 在iOS[AMapLocationOptionForIOS.withReGeocode]==false以下字段没有数据，需要数据请设置为true
  /// 以下数据在iOS属于逆地理信息

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

  /// 兴趣面名称
  final String? aoiName;

  /// 兴趣点名称
  final String? poiName;

  /// 区域编码
  final String? adCode;

  /// 地址信息
  final String? address;

  /// 定位时间
  final double? timestamp;

  Map<String, dynamic> toMapForPlatform() {
    if (this is AMapLocationForAndroid) {
      return (this as AMapLocationForAndroid).toMap();
    } else if (this is AMapLocationForIOS) {
      return (this as AMapLocationForIOS).toMap();
    }
    return toMap();
  }

  Map<String, dynamic> toMap() => {
        'error': error?.toMap(),
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'altitude': altitude,
        'adCode': adCode,
        'aoiName': aoiName,
        'city': city,
        'cityCode': cityCode,
        'country': country,
        'district': district,
        'poiName': poiName,
        'province': province,
        'street': street,
        'address': address,
        'streetNum': streetNum,
        'floor': floor,
        'bearing': bearing,
        'timestamp': timestamp,
      };
}

class AMapLocationOptionNotificationForAndroid {
  

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
        'gpsFirst': gpsFirst,
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
    this.locationTimeout = 10,
    this.reGeocodeTimeout = 5,
    this.withReGeocode = false,
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

  /// 定位是否返回逆地理信息，默认false。
  final bool withReGeocode;

  /// 逆地址语言类型，默认是[GeoLanguage.none]
  final GeoLanguage reGeocodeLanguage;

  /// 检测是否存在虚拟定位风险，默认为NO，不检测。
  ///  注意:设置为YES时，单次定位通过 errorInfo 给出虚拟定位风险提示；
  ///  连续定位通过 []方法的
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
        'withReGeocode': withReGeocode,
        'reGeocodeLanguage': reGeocodeLanguage.index,
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
enum GPSAccuracyStatus {
  bad,
  good,
  unknown;

  static GPSAccuracyStatus getStatus(int? i) {
    switch (i) {
      case -1:
        return GPSAccuracyStatus.unknown;
      case 1:
        return GPSAccuracyStatus.bad;
      case 0:
        return GPSAccuracyStatus.good;
      default:
        return GPSAccuracyStatus.unknown;
    }
  }
}

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

/// ios定位精度
enum CLLocationAccuracy {
  /// 最好的,米级
  kCLLocationAccuracyBest,

  /// 十米
  kCLLocationAccuracyNearestTenMeters,

  /// 百米
  kCLLocationAccuracyHundredMeters,

  /// 一公里
  kCLLocationAccuracyKilometer,

  /// 三公里
  kCLLocationAccuracyThreeKilometers,

  /// 定位精度最好的导航
  kCLLocationAccuracyBestForNavigation;
}
