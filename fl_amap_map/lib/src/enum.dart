part of '../fl_amap_map.dart';

enum GenFenceType {
  /// 圆形地理围栏
  circle,

  /// 多边形地理围栏
  custom,

  /// 兴趣点（POI）地理围栏
  poi,

  /// 行政区划地理围栏
  district
}

enum GenFenceStatus {
  /// 未知
  none,

  /// 在范围内
  inside,

  /// 在范围外
  outside,

  ///  停留(在范围内超过10分钟)
  stayed
}

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

///  android网络传输http还是https协议
enum AMapLocationProtocol { http, https }

///  android 逆地理位置信息的语言
enum GeoLanguage { none, zh, en }

///  android 定位模式
enum AMapLocationMode {
  /// 低功耗
  batterySaving,

  /// 仅使用设备
  deviceSensors,

  /// 高精度
  heightAccuracy
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

enum MapType {
  /// 普通地图 ios 0 android 1
  standard,

  /// 卫星地图 ios 1 android 2
  satellite,

  /// 黑夜地图 ios 2 android 3
  standardNight,

  /// 导航模式 ios 3 android 4
  navi,

  /// 公交模式 ios 4 android 5
  bus,
}

enum MapLanguage { chinese, english }

enum TrackingMode {
  /// 不追踪用户的location更新
  none,

  /// 定位一次，且将视角移动到地图中心点。
  locate,

  /// 连续定位、且将视角移动到地图中心点，定位蓝点跟随设备移动。（1秒1次定位）
  follow,

  /// 连续定位、且将视角移动到地图中心点，地图依照设备方向旋转，定位点会跟随设备移动。（1秒1次定位）
  /// 仅支持 Android
  followRotate,

  /// 连续定位、且将视角移动到地图中心点，定位点依照设备方向旋转，并且会跟随设备移动。（1秒1次定位）默认执行此种模式。
  /// 仅支持 Android
  followLocationRotate,

  /// 连续定位、蓝点不会移动到地图中心点，定位点依照设备方向旋转，并且蓝点会跟随设备移动。
  /// 仅支持 Android
  followLocationRotateNoCenter,

  /// 连续定位、蓝点不会移动到地图中心点，地图依照设备方向旋转，并且蓝点会跟随设备移动。
  /// 仅支持 Android
  followRotateNoCenter,

  /// 追踪用户的location与heading更新
  /// 仅支持 IOS
  followWithHeading,
}
