import 'dart:async';
import 'dart:io';

import 'package:fl_amap/fl_amap.dart';
import 'package:flutter/services.dart';

typedef EventHandlerAMapLocation = void Function(AMapLocation location);

///  android网络传输http还是https协议
enum AMapLocationProtocol { http, https }

///  android 逆地理位置信息的语言
enum GeoLanguage { none, zh, en }

///  android 定位模式
enum AMapLocationMode {
  /// 低功耗
  BatterySaving,

  /// 仅使用设备
  DeviceSensors,

  /// 高精度
  HeightAccuracy
}

///  ios定位精度
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
  kCLLocationAccuracyThreeKilometers
}

///  初始化定位
///  @param options 启动系统所需选项
Future<bool> initAMapLocation(AMapLocationOption option) async {
  if (!supportPlatform) return false;
  final bool? isInit =
      await channel.invokeMethod('initLocation', option.toMap());
  return isInit ?? false;
}

///  直接获取定位
///  @param needsAddress 是否需要详细地址信息 默认false
Future<AMapLocation?> getAMapLocation([bool needsAddress = false]) async {
  if (!supportPlatform) return null;
  final Map<dynamic, dynamic>? location =
      await channel.invokeMethod('getLocation', needsAddress);
  if (location == null) return null;
  return AMapLocation.fromMap(location);
}

/// 销毁定位参数
Future<bool> disposeAMapLocation() async {
  if (!supportPlatform) return false;
  final bool? state = await channel.invokeMethod('disposeLocation');
  return state ?? false;
}

/// 启动监听位置改变
Future<bool> startAMapLocationChange(
    {EventHandlerAMapLocation? onLocationChange}) async {
  if (!supportPlatform) return false;
  final bool? state = await channel.invokeMethod<bool?>('startLocation');
  if (state != null && state) {
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'updateLocation':
          if (onLocationChange == null) return;
          if (call.arguments == null) return;
          final Map<dynamic, dynamic> argument =
              call.arguments as Map<dynamic, dynamic>;
          return onLocationChange(AMapLocation.fromMap(argument));
      }
    });
  }
  return false;
}

///  停止监听位置改变
Future<bool> stopAMapLocation() async {
  if (!supportPlatform) return false;
  final bool? state = await channel.invokeMethod('stopLocation');
  return state ?? false;
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

class AMapLocation {
  AMapLocation(
      {this.description,
      this.code,
      this.timestamp,
      this.speed,
      this.altitude,
      this.latLong,
      this.accuracy,
      this.adCode,
      this.aoiName,
      this.city,
      this.cityCode,
      this.country,
      this.district,
      this.formattedAddress,
      this.number,
      this.poiName,
      this.provider,
      this.province,
      this.street,
      this.locationType,
      this.success});

  factory AMapLocation.fromMap(Map<dynamic, dynamic> map) {
    final double? latitude = map['latitude'] as double?;
    final double? longitude = map['longitude'] as double?;
    LatLong? latLong;
    if (latitude != null && longitude != null)
      latLong = LatLong(latitude, longitude);
    return AMapLocation(
      description: map['description'] as String?,
      code: map['code'] as int?,
      latLong: latLong,
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
      locationType: map['locationType'] as int?,
      success: map['success'] as bool?,
    );
  }

  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? timestamp;
  final LatLong? latLong;
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
  final int? code;

  ///  描述
  final String? description;

  /// 这个字段用来判断有没有定位成功，在ios下，有可能获取到了经纬度，但是详细地址没有获取到，
  /// 这个情况下，值也为true
  final bool? success;

  ///  以下属性为android特有
  final String? provider;

  final int? locationType;

  ///  是否成功，单纯从经纬度来判断
  ///  code > 0 ,有可能是逆地理位置有错误，那么这个时候仍然是成功的
  bool? get isSuccess => success;

  ///  是否有详细地址
  bool? get hasAddress => formattedAddress != null;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'accuracy': accuracy,
        'description': description,
        'code': code,
        'timestamp': timestamp,
        'speed': speed,
        'altitude': altitude,
        'latLong': latLong == null ? null : latLong!.toMap(),
        'adCode': adCode,
        'aoiName': aoiName,
        'poiName': poiName,
        'city': city,
        'cityCode': cityCode,
        'country': country,
        'district': district,
        'formattedAddress': formattedAddress,
        'number': number,
        'provider': provider,
        'province': province,
        'street': street,
        'locationType': locationType,
        'success': success,
      };
}

class AMapLocationOption {
  /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///
  ///   以下属性为android特有
  /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///

  AMapLocationOption({
    this.locationMode = AMapLocationMode.BatterySaving,
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
      default:
        return 'unknown';
    }
  }

  String getLocationMode() {
    switch (locationMode) {
      case AMapLocationMode.HeightAccuracy:
        return 'Hight_Accuracy';
      case AMapLocationMode.BatterySaving:
        return 'Battery_Saving';
      case AMapLocationMode.DeviceSensors:
        return 'Device_Sensors';
      default:
        return 'unknown';
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
      default:
        return 'unknown';
    }
  }

  Map<String, dynamic>? toMap() {
    if (Platform.isAndroid) {
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
    } else if (Platform.isIOS) {
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
