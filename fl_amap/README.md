高德地图定位flutter组件。

目前实现获取定位和监听定位功能。

1、申请一个key
http://lbs.amap.com/api/ios-sdk/guide/create-project/get-key

直接在dart文件中设置key

# ios

1. 在info.plist中增加:

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>要用定位</string>
```

如果ios定位没有返回逆地理信息,添加一下内容

```
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
		<key>NSAllowsArbitraryLoadsForMedia</key>
		<true/>
		<key>NSAllowsArbitraryLoadsInWebContent</key>
		<true/>
		/// 解决ios HTTP 警告，需要添加的
        <key>NSExceptionDomains</key>
            <dict>
                <key>restios.amap.com/key>
                <dict>
                    <key>NSExceptionAllowsInsecureHTTPLoads</key>
                    <true/>
                    <key>NSIncludesSubdomains</key>
                    <true/>
                    <key>NSExceptionMinimumTLSVersion</key>
                    <string>TLSv1.2</string>
                </dict>
            </dict>
	</dict>
```

2. iOS 9及以上版本使用后台定位功能, 需要保证"Background Modes"中的"Location updates"处于选中状态

3.使用地理围栏

iOS14及以上版本使用地理围栏功能，需要在plist中配置NSLocationTemporaryUsageDescriptionDictionary字典描述，
且添加自定义Key描述地理围栏的使用场景，此描述会在申请临时精确定位权限的弹窗中展示。
该回调触发条件：拥有定位权限，但是没有获得精确定位权限的情况下，会触发该回调。此方法实现调用申请临时精确定位权限API即可；

** 需要注意，在iOS9及之后版本的系统中，如果您希望程序在后台持续检测围栏触发行为，需要保证manager的
allowsBackgroundLocationUpdates 为 YES，
设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。

# android

- `android/src/main/AndroidManifest.xml` 添加以下内容 具体参考 `example`

```xml

<manifest>
  <application>
    /// 需要配置的
    <meta-data android:name="com.amap.api.v2.apikey" android:value="您的Key" />
  </application>
</manifest>

```

## 开始使用

## 高德定位功能

- 设置key

```dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool key = await setAMapKey(
          iosKey: 'ios key',
          androidKey: 'android key');

  if (key != null && key) print('高德地图ApiKey设置成功');

  runApp(MaterialApp(title: 'FlAMap', home: Home()));
}

```

- 初始化定位参数

```dart
  Future<void> initialize() async {
  /// 获取权限
  if (getPermissions) return;

  /// 初始化AMap
  final bool data = await FlAMapLocation().initialize();
  if (data) {
    show('初始化成功');
  }
}

```

- 单次获取定位

```dart
  Future<void> getLocation() async {
  /// 务必先初始化 并获取权限
  if (getPermissions) return;
  AMapLocation location = await FlAMapLocation().getLocation();
  if (isAndroid) {
    AMapLocation is AMapLocationForAndroid;
  }
  if (isIOS) {
    AMapLocation is AMapLocationForIOS;
  }
}

```

- 开启定位变化监听

```dart
  Future<void> startLocationChange() async {
  /// 务必先初始化 并获取权限
  FlAMapLocation().addListener(

    /// 连续定位回调 android & ios 均支持
      onLocationChanged: (AMapLocation? location) {
        locationState.value = location;
      },

      /// ios连续定位 错误监听 仅在ios中生效
      onLocationFailed: (AMapLocationError? error) {
        text.value = 'ios 连续定位错误：${error?.toMap()}';
      },

      /// 监听设备朝向变化 仅在ios中生效
      onHeadingChanged: (AMapLocationHeading? heading) {
        headingState.value = heading;
      },

      /// 监听权限状态变化 仅在ios中生效
      onAuthorizationChanged: (int? status) {
        text.value = 'ios 权限状态变化：$status';
      });
}

```

- 关闭定位变化监听

```dart
  void stopLocation() {
  FlAMapLocation().stopLocation();
}
```

- 关闭定位服务

```dart
  void dispose() {
  FlAMapLocation().dispose();
}
```

- 开启前台任务 仅支持android 8.0 +
  如需开启前台任务需要添加以下配置 至 `android/src/main/AndroidManifest.xml` 具体参考 `example`

```xml

<manifest>
    /// 需要添加的权限
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <application>
        /// 需要配置的服务
        <service android:exported="false" android:foregroundServiceType="location" android:name="com.amap.api.location.APSService" />
    </application>
</manifest>
```

```dart

void enableBackgroundLocation() {
  FlAMapLocation().enableBackgroundLocation(
      AMapNotificationForAndroid(
          notificationId: 999,
          title: '我在定位',
          content: '我正在定位',
          channelId: 'channelId',
          channelName: 'name',
          lightColor: Colors.red));
}
```

- 关闭前台任务 仅支持android

```dart
  void disableBackgroundLocation() {
  FlAMapLocation().disableBackgroundLocation();
}
```

- 设备是否支持方向识别 仅支持ios

```dart
  void headingAvailable() async {
  final result = await location.headingAvailable();
}
```

- 开始获取设备朝向 仅支持ios

```dart
  void startUpdatingHeading() async {
  await location.startUpdatingHeading();
}
```

- 停止获取设备朝向 仅支持ios

```dart
  void stopUpdatingHeading() async {
  await location.stopUpdatingHeading();
}
```

- 停止设备朝向校准显示 仅支持ios

```dart
  void dismissHeadingCalibrationDisplay() async {
  await location.dismissHeadingCalibrationDisplay();
}
```

## 高德地理围栏功能

- 初始化地理围栏

```dart

Future<void> get initialize async {
  final bool data = await FlAMapGeoFence().initialize(GeoFenceActivateAction.stayed);
  if (data) {
    show('初始化地理围栏:$data');
  }
}

```

- 关闭围栏服务

```dart
  void dispose() {
  super.dispose();
  FlAMapGeoFence().dispose();
}
```

- 根据POI添加围栏

```dart
  Future<void> addPOI() async {
  final AMapPoiModel model = AMapPoiModel(
      keyword: '首开广场',
      poiType: '写字楼',
      city: '北京',
      size: 1,
      customId: '000FATE23（考勤打卡）');
  final bool state = await FlAMapGeoFence().addPOI(model);
}
```

- 根据坐标关键字添加围栏

```dart
  Future<void> addLatLng() async {
  final LatLng latLng = LatLng(39.933921, 116.372927);
  final AMapLatLngModel model = AMapLatLngModel(
      latLng: latLng,
      keyword: '首开广场',
      poiType: '',
      customId: '000FATE23（考勤打卡）',
      size: 20,
      aroundRadius: 1000);
  final bool state = await FlAMapGeoFence().addLatLng(model);
}
```

- 添加行政区划围栏

```dart
  Future<void> addDistrict() async {
  final bool state = await FlAMapGeoFence().addDistrict(
      keyword: '海淀区', customId: '000FATE23（考勤打卡）');
}
```

- 添加圆形围栏

```dart
  Future<void> addCircle() async {
  final LatLng latLng = LatLng(30.651411, 103.998638);
  final bool state = await FlAMapGeoFence().addCircle(
      latLng: latLng,
      radius: 10,
      customId: '000FATE23（考勤打卡）');
}
```

- 添加多边形围栏

```dart
  Future<void> addCustom() async {
  final bool state = await FlAMapGeoFence().addCustom(latLngs: <LatLng>[
    LatLng(39.933921, 116.372927),
    LatLng(39.907261, 116.376532),
    LatLng(39.900611, 116.418161),
    LatLng(39.941949, 116.435497),
  ], customId: '000FATE23（考勤打卡）');
}
```

- 获取所有围栏信息

```dart
  Future<void> getAll() async {
  /// 传入 customID 获取指定标识的围栏信息 仅支持ios
  final List<AMapGeoFenceModel> data = await FlAMapGeoFence().getAll();
}
```

- 删除地理围栏

```dart
  Future<void> remove() async {
  /// 传入 customID 删除指定标识的围栏
  /// 不传 删除所有围栏
  final bool state = await FlAMapGeoFence().remove();
}
```

- 暂停监听围栏

```dart
  Future<void> pause() async {
  /// 传入 customID 暂停指定标识的围栏
  /// 不传 暂停所有围栏
  final bool state = await FlAMapGeoFence().pause();
}
```

- 开始监听围栏

```dart
  Future<void> start() async {
  /// 传入 customID 开始指定标识的围栏
  /// 不传 开始所有围栏
  final bool state = await FlAMapGeoFence().start();
}
```