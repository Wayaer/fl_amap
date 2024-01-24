part of '../fl_amap_map.dart';

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
