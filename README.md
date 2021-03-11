高德地图定位flutter组件。

目前实现获取定位和监听定位功能。


1、申请一个key
http://lbs.amap.com/api/ios-sdk/guide/create-project/get-key

直接在dart文件中设置key

# ios
2、在info.plist中增加:
```
<key>NSLocationWhenInUseUsageDescription</key>
<string>要用定位</string>
```

## 开始使用
 
1.设置key
```dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool key = await setKeyWithAMap(
      iosKey: 'e0e98395277890e48caa0c4bed423ead',
      androidKey: '77418e726d0eefc0ac79a8619b5f4d97');
  if (key != null && key) print('高德地图ApiKey设置成功');
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false, title: 'FlAMap', home: Home()));
}

```

2.初始化定位参数
```dart

  Future<void> get init async {
    /// 获取权限
    if (getPermissions) return;

    /// 初始化AMap
    final bool data = await initWithAMap(AMapLocationOption());
    if (data != null && data) {
      show('初始化成功');
    }
  }


```

3.单次获取定位
```dart
  Future<void> get getLocation async {
     /// 务必先初始化 并获取权限
    if (getPermissions) return;
    AMapLocation location =  await getLocationWithAMap(true);

  }

```

4.开启定位变化监听
```dart

  Future<void> startLocationState() async {
     /// 务必先初始化 并获取权限
    if (getPermissions) return;
    final bool data =
        await startLocationWithAMap(onLocationChange: (AMapLocation location) {
      locationState.value = location;
      text.value = '位置更新$i次';
    });
   print((data == null || !data) ? '开启成功' : '开启失败');
  }

```
5.关闭定位变化监听
```dart

   stopLocationWithAMap

```

6.关闭定位系统

```dart

  @override
  void dispose() {
    super.dispose();
    disposeWithAMap;
  }
   
```