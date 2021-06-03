import 'dart:io';

import 'package:amap/main.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_amap/fl_amap.dart';

class AMapLocationPage extends StatefulWidget {
  const AMapLocationPage({Key? key}) : super(key: key);

  @override
  _AMapLocationPageState createState() => _AMapLocationPageState();
}

class _AMapLocationPageState extends State<AMapLocationPage> {
  bool isInitLocation = false;

  late ValueNotifier<String> text = ValueNotifier<String>('未初始化');
  late ValueNotifier<AMapLocation?> locationState =
      ValueNotifier<AMapLocation?>(null);

  int i = 0;

  /// 获取定位权限
  Future<bool> get getPermissions async {
    if (Platform.isIOS) {
      if (!await requestPermissions(Permission.locationWhenInUse, '获取定位权限') ||
          !await requestPermissions(Permission.locationWhenInUse, '获取定位权限')) {
        show('未获取到定位权限');
        return false;
      }
      return true;
    } else if (Platform.isAndroid) {
      if (!await requestPermissions(Permission.location, '获取定位权限') ||
          !await requestPermissions(Permission.phone, '获取定位权限')) {
        show('未获取到定位权限');
        return false;
      }
      return true;
    }
    return false;
  }

  Future<void> get getLocation async {
    if (!isInitLocation) {
      show('请先初始化定位');
      return;
    }
    if (!await getPermissions) return;
    locationState.value = await getAMapLocation(true);
  }

  /// 初始化定位
  Future<void> get initLocation async {
    if (!await getPermissions) return;

    /// 初始化AMap
    final bool? data = await initAMapLocation(AMapLocationOption());
    if (data != null && data) {
      isInitLocation = true;
      show('初始化定位:$data');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('高德地图定位')),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              const SizedBox(height: 10),
              ValueListenableBuilder<String>(
                  valueListenable: text,
                  builder: (_, String value, __) =>
                      Text(value, style: const TextStyle(fontSize: 20))),
              const SizedBox(height: 20),
              const Text('高德定位', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () => initLocation,
                        child: const Text('initAMapLocation')),
                    ElevatedButton(
                        onPressed: () {
                          disposeAMapLocation();
                          locationState.value = null;
                          isInitLocation = false;
                          i = 0;
                          show('未初始化');
                        },
                        child: const Text('disposeAMapLocation')),
                    ElevatedButton(
                        onPressed: () => getLocation,
                        child: const Text('直接获取定位')),
                    ElevatedButton(
                        onPressed: startLocationState,
                        child: const Text('开启监听定位')),
                    ElevatedButton(
                        onPressed: () {
                          if (!isInitLocation) {
                            show('请先初始化定位');
                            return;
                          }
                          text.value = '定位监听关闭';
                          locationState.value = null;
                          i = 0;
                          stopAMapLocation();
                        },
                        child: const Text('关闭监听定位')),
                  ]),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ValueListenableBuilder<AMapLocation?>(
                      valueListenable: locationState,
                      builder: (_, AMapLocation? value, __) => Text(
                          getLocationStr(value),
                          style: const TextStyle(fontSize: 15))))
            ])),
      ));

  Future<void> startLocationState() async {
    if (!isInitLocation) {
      show('请先初始化定位');
      return;
    }
    if (!await getPermissions) return;
    final bool? data = await startAMapLocationChange(
        onLocationChange: (AMapLocation location) {
      locationState.value = location;
      i += 1;
      text.value = '位置更新$i次';
    });
    show((data == null || !data) ? '开启失败' : '开启成功');
  }

  void show(String str) {
    text.value = str;
  }

  @override
  void dispose() {
    super.dispose();
    disposeAMapLocation();
  }

  String getLocationStr(AMapLocation? loc) {
    if (loc != null) {
      if (loc.isSuccess ?? false) {
        if (loc.hasAddress ?? false) {
          return '定位成功: \n时间${loc.timestamp ?? ''}\n经纬度:${loc.latLong?.latitude ?? ''} ${loc.latLong?.longitude ?? ''}\n地址:${loc.formattedAddress ?? ''}\n城市:${loc.city ?? ''}\n省:${loc.province ?? ''}';
        } else {
          return '定位成功: \n时间${loc.timestamp ?? ''}\n经纬度:${loc.latLong?.latitude ?? ''}'
              '  ${loc.latLong?.longitude ?? ''}';
        }
      } else {
        return '定位失败: \n错误:{code=${loc.code ?? ''},\ndescription=${loc.description ?? ''}';
      }
    }
    return '正在定位';
  }
}