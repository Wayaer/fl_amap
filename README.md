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
2. iOS 9及以上版本使用后台定位功能, 需要保证"Background Modes"中的"Location updates"处于选中状态

3.使用地理围栏

iOS14及以上版本使用地理围栏功能，需要在plist中配置NSLocationTemporaryUsageDescriptionDictionary字典描述，
且添加自定义Key描述地理围栏的使用场景，此描述会在申请临时精确定位权限的弹窗中展示。
该回调触发条件：拥有定位权限，但是没有获得精确定位权限的情况下，会触发该回调。此方法实现调用申请临时精确定位权限API即可；

** 需要注意，在iOS9及之后版本的系统中，如果您希望程序在后台持续检测围栏触发行为，需要保证manager的 allowsBackgroundLocationUpdates 为 YES，
设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。

## 开始使用
 
1.设置key
```dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool key = await setAMapKey(
      iosKey: 'ios key',
      androidKey: 'android key');

  if (key != null && key) print('高德地图ApiKey设置成功');

  runApp(MaterialApp(
      debugShowCheckedModeBanner: false, title: 'FlAMap', home: Home()));
}

```

2.初始化定位参数
```dart

  Future<void> init() async {
    /// 获取权限
    if (getPermissions) return;

    /// 初始化AMap
    final bool data = await initAMap(AMapLocationOption());
    if (data != null && data) {
      show('初始化成功');
    }
  }


```

3.单次获取定位
```dart
  Future<void> getLocation() async {
     /// 务必先初始化 并获取权限
    if (getPermissions) return;
    AMapLocation location =  await getAMapLocation(true);

  }

```

4.开启定位变化监听
```dart

  Future<void> startLocationState() async {
     /// 务必先初始化 并获取权限
    if (getPermissions) return;
    final bool data =
        await startAMapLocationChange(onLocationChange: (AMapLocation location) {
      locationState.value = location;
      text.value = '位置更新$i次';
    });
   print((data == null || !data) ? '开启成功' : '开启失败');
  }

```
5.关闭定位变化监听
```dart

  void stop(){

     stopAMapLocation();

  }


```

6.关闭定位系统

```dart

  void dispose() {
    super.dispose();
    disposeAMap();
  }
   
```