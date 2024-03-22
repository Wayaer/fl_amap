part of '../../fl_amap_map.dart';

typedef EventHandlerAMapLocation = void Function(AMapLocation location);

class FlAMapLocation {
  factory FlAMapLocation() => _singleton ??= FlAMapLocation._();

  FlAMapLocation._();

  static FlAMapLocation? _singleton;

  bool _isInitialize = false;

  ///  初始化定位
  ///  @param options 启动系统所需选项
  Future<bool> initialize(AMapLocationOption option) async {
    if (!_supportPlatform) return false;
    final bool? isInit =
        await _channel.invokeMethod('initLocation', option.toMap());
    if (isInit == true) _isInitialize = isInit!;
    return isInit ?? false;
  }

  ///  直接获取定位
  ///  @param needsAddress 是否需要详细地址信息 默认false
  Future<AMapLocation?> getLocation([bool needsAddress = false]) async {
    if (!_supportPlatform || !_isInitialize) return null;
    final Map<dynamic, dynamic>? location =
        await _channel.invokeMethod('getLocation', needsAddress);
    if (location == null) return null;
    return AMapLocation.fromMap(location);
  }

  /// 销毁定位参数
  Future<bool> dispose() async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod('disposeLocation');
    return state ?? false;
  }

  /// 启动监听位置改变
  Future<bool> startLocationChanged(
      {EventHandlerAMapLocation? onLocationChanged}) async {
    if (!_supportPlatform || !_isInitialize) return false;
    final bool? state = await _channel.invokeMethod<bool?>('startLocation');
    if (state != null && state) {
      _channel.setMethodCallHandler((MethodCall call) async {
        switch (call.method) {
          case 'updateLocation':
            if (onLocationChanged == null) return;
            if (call.arguments == null) return;
            final Map<dynamic, dynamic> argument =
                call.arguments as Map<dynamic, dynamic>;
            return onLocationChanged(AMapLocation.fromMap(argument));
        }
      });
    }
    return state ?? false;
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
}

class AMapLocationQualityReport {
  AMapLocationQualityReport(
      {this.wifiAble,
      this.gpsSatellites,
      this.gpsStatus,
      this.adviseMessage,
      this.netUseTime,
      this.networkType});

  static const int ok = 0;
  static const int noGpsProvider = 1;
  static const int off = 2;
  static const int modeSaving = 3;
  static const int noGpsPermission = 4;

  final bool? wifiAble;

  final int? gpsStatus;

  final int? gpsSatellites;

  final String? networkType;

  /// 整数部分为秒，浮点部分为毫秒
  final double? netUseTime;

  final String? adviseMessage;
}

class AMapLocationOption {
  /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///
  ///   以下属性为android特有
  /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///

  AMapLocationOption({
    this.locationMode = AMapLocationMode.batterySaving,
    this.gpsFirst = false,

    /// 30有点长，特殊情况才需要这么长，改成5
    this.httpTimeOut = 5000,
    this.interval = 2000,
    this.needsAddress = true,

    /// 默认为单次定位
    this.onceLocation = true,
    this.onceLocationLatest = true,
    this.locationProtocol = AMapLocationProtocol.http,
    this.sensorEnable = false,
    this.wifiScan = true,
    this.locationCacheEnable = true,
    this.allowsBackgroundLocationUpdates = false,

    /// 精度越高，时间越久
    this.desiredAccuracy =
        CLLocationAccuracy.kCLLocationAccuracyNearestTenMeters,
    this.locatingWithReGeocode = false,

    /// 注意这里的单位为秒
    this.locationTimeout = 2,
    this.pausesLocationUpdatesAutomatically = false,

    /// 注意ios的时间单位是秒
    this.reGeocodeTimeout = 2,
    this.detectRiskOfFakeLocation = false,
    this.distanceFilter = -1.0,
    this.geoLanguage = GeoLanguage.none,
  });

  /// 可选，设置定位模式，可选的模式有高精度、仅设备、仅网络。默认为高精度模式
  /// 默认 [AMapLocationMode.BatterySaving]
  final AMapLocationMode locationMode;

  /// 可选，设置是否gps优先，只在高精度模式下有效。默认关闭
  final bool gpsFirst;

  /// 可选，设置网络请求超时时间(ms)。默认为5秒。在仅设备模式下无效
  final int httpTimeOut;

  /// 可选，设置定位间隔(ms)。默认为2秒
  final int interval;

  /// 可选，设置是否返回逆地理地址信息。默认是true
  final bool needsAddress;

  /// 可选，设置是否单次定位。默认是 true
  final bool onceLocation;

  /// 可选，设置是否等待wifi刷新，默认为true.如果设置为true,会自动变为单次定位，持续定位时不要使用
  final bool onceLocationLatest;

  /// 可选， 设置网络请求的协议。可选HTTP或者HTTPS。默认为HTTP
  final AMapLocationProtocol locationProtocol;

  /// 可选，设置是否使用传感器。默认是false
  final bool sensorEnable;

  /// 可选，设置是否开启wifi扫描。默认为true，如果设置为false会同时停止主动刷新，停止以后完全依赖于系统刷新，定位位置可能存在误差
  final bool wifiScan;

  /// 可选，设置是否使用缓存定位，默认为true
  final bool locationCacheEnable;

  /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///
  /// 以下属性为ios特有
  /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///
  /// 设定期望的定位精度。单位米，默认为 [CLLocationAccuracy.kCLLocationAccuracyNearestTenMeters]。
  /// 定位服务会尽可能去获取满足desiredAccuracy的定位结果，但不保证一定会得到满足期望的结果。
  /// 注意：设置为kCLLocationAccuracyBest或kCLLocationAccuracyBestForNavigation时，
  /// 单次定位会在达到locationTimeout设定的时间后，将时间内获取到的最高精度的定位结果返回。
  ///
  final CLLocationAccuracy desiredAccuracy;

  /// 指定定位是否会被系统自动暂停。默认为NO。
  final bool pausesLocationUpdatesAutomatically;

  /// 是否允许后台定位。默认为NO。只在iOS 9.0及之后起作用。设置为YES的时候必须保证
  /// Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
  /// 由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
  final bool allowsBackgroundLocationUpdates;

  /// 指定单次定位超时时间,默认为2s。最小值是2s。
  ///  注意单次定位请求前设置。
  ///  注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)后开始计算。
  final int locationTimeout;

  /// 指定单次定位逆地理超时时间,默认为2s。最小值是2s。注意单次定位请求前设置。
  final int reGeocodeTimeout;

  /// 连续定位是否返回逆地理信息，默认NO。
  final bool locatingWithReGeocode;

  /// 检测是否存在虚拟定位风险，默认为NO，不检测。
  ///  注意:设置为YES时，单次定位通过 AMapLocatingCompletionBlock 的
  ///  error给出虚拟定位风险提示；
  ///  连续定位通过 amapLocationManager:didFailWithError: 方法的
  ///  error给出虚拟定位风险提示。
  ///  error格式为error.domain==AMapLocationErrorDomain;
  ///  error.code==AMapLocationErrorRiskOfFakeLocation;
  final bool detectRiskOfFakeLocation;

  /// 设定定位的最小更新距离。单位米，默认为 kCLDistanceFilterNone，表示只要检测到设备位置发生变化就会更新位置信息。
  final double distanceFilter;

  static const double kCLDistanceFilterNone = -1.0;

  /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///
  ///  以下为通用属性
  /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///
  /// 可选，设置逆地理信息的语言，默认值为默认语言（根据所在地区选择语言)
  final GeoLanguage geoLanguage;

  String get getLocationProtocol =>
      locationProtocol == AMapLocationProtocol.http ? 'HTTP' : 'HTTPS';

  String getGeoLanguage() {
    switch (geoLanguage) {
      case GeoLanguage.none:
        return 'DEFAULT';
      case GeoLanguage.en:
        return 'EN';
      case GeoLanguage.zh:
        return 'ZH';
    }
  }

  String getLocationMode() {
    switch (locationMode) {
      case AMapLocationMode.heightAccuracy:
        return 'Hight_Accuracy';
      case AMapLocationMode.batterySaving:
        return 'Battery_Saving';
      case AMapLocationMode.deviceSensors:
        return 'Device_Sensors';
    }
  }

  String getDesiredAccuracy() {
    switch (desiredAccuracy) {
      case CLLocationAccuracy.kCLLocationAccuracyBest:
        return 'kCLLocationAccuracyBest';
      case CLLocationAccuracy.kCLLocationAccuracyHundredMeters:
        return 'kCLLocationAccuracyHundredMeters';
      case CLLocationAccuracy.kCLLocationAccuracyKilometer:
        return 'kCLLocationAccuracyKilometer';
      case CLLocationAccuracy.kCLLocationAccuracyNearestTenMeters:
        return 'kCLLocationAccuracyNearestTenMeters';
      case CLLocationAccuracy.kCLLocationAccuracyThreeKilometers:
        return 'kCLLocationAccuracyThreeKilometers';
    }
  }

  Map<String, dynamic>? toMap() {
    if (_isAndroid) {
      return <String, dynamic>{
        'locationMode': getLocationMode(),
        'gpsFirst': gpsFirst,
        'httpTimeOut': httpTimeOut,
        'interval': interval,
        'needsAddress': needsAddress,
        'onceLocation': onceLocation,
        'onceLocationLatest': onceLocationLatest,
        'locationProtocol': getLocationProtocol,
        'sensorEnable': sensorEnable,
        'wifiScan': wifiScan,
        'locationCacheEnable': locationCacheEnable,
        'geoLanguage': getGeoLanguage()
      };
    } else if (_isIOS) {
      return <String, dynamic>{
        'allowsBackgroundLocationUpdates': allowsBackgroundLocationUpdates,
        'desiredAccuracy': getDesiredAccuracy(),
        'locatingWithReGeocode': locatingWithReGeocode,
        'locationTimeout': locationTimeout,
        'pausesLocationUpdatesAutomatically':
            pausesLocationUpdatesAutomatically,
        'reGeocodeTimeout': reGeocodeTimeout,
        'detectRiskOfFakeLocation': detectRiskOfFakeLocation,
        'distanceFilter': distanceFilter,
        'geoLanguage': getGeoLanguage()
      };
    }
    return null;
  }
}
