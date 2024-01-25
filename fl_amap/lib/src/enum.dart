part of '../fl_amap.dart';

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


