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