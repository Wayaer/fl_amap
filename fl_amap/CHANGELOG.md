## 3.0.2

* 更新 android sdk版本

## 3.0.1

* 修改ios默认定位精度为十米级，和上个版本一致
* 修改ios默认获取逆地理位置

## 3.0.0

* 设置定位参数，返回定位信息均添加详细文档说明，且数据完整
* 区分`android`和`ios`
  的返回定位信息，返回数据均有不同,且数据完整，`AMapLocation`、`AMapLocationForIOS`、`AMapLocationForAndroid`
* 区分`android`和`ios`
  的定位参数配置，可进行多次配置更新，`AMapLocationOptionForIOS`、`AMapLocationOptionForAndroid`
* `android`支持设置前台任务服务，保证后台定位常驻，使用`enableBackgroundLocation`
  和`disableBackgroundLocation`开启和关闭
* `ios`添加 `headingAvailable`(设备是否支持方向识别)、`startUpdatingHeading`(
  开始获取设备朝向)、`stopUpdatingHeading`(停止获取设备朝向)、`dismissHeadingCalibrationDisplay`(
  停止设备朝向校准显示)

## 2.5.3

* Upgrade the Android AMap locating SDK
* Add `namespace` in Android

## 2.5.1

* Fixed issues on ios

## 2.5.0

* Modify some nouns

## 2.3.1+1

* Upgrade gradle version

## 2.1.0

* Upgrade the Android AMap locating SDK
* Compatible with flutter 3.0.0

## 2.0.0

* Upgrade the Android AMap locating SDK to 5.6.0
* To upgrade the ios AMap SDK to 2.8.0, run the `pod update` command to update the SDK to 2.8.0
* Add SDK compliance use scheme [AMap doc](https://lbs.amap.com/news/sdkhgsy)

## 1.2.0

* Change IOS OC to swift
* Simplify geofencing services
* Fix bugs

## 1.1.0

* Remove instance , direct initialization
* Update gradle version
* Update kotlin version

## 1.0.0

* Add Singleton Pattern
* Upgrade Android Gradle
* Upgrade Android AMap SDK version

## 0.2.1

* Upgrade Android AMap SDK version
* Add platform restrictions

## 0.2.0

* Add AMapGeoFence

## 0.1.3

* Update Android com.android.tools.build:gradle version
* Replace jcenter() to mavenCentral()

## 0.1.2

* Add Android proguard rules

## 0.1.1

* Normative approach
* Fix bugs
* Modify APIs
* Android add consumer-rules.pro

## 0.0.6

* Example update to 2.12.1
* Update dart version to 2.12.1

## 0.0.3

* Support single location
* Support location monitoring