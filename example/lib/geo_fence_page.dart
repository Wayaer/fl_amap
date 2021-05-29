import 'dart:io';

import 'package:amap/main.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_amap/fl_amap.dart';

class AMapGeoFencePage extends StatefulWidget {
  const AMapGeoFencePage({Key? key}) : super(key: key);

  @override
  _AMapGeoFencePageState createState() => _AMapGeoFencePageState();
}

class _AMapGeoFencePageState extends State<AMapGeoFencePage> {
  late ValueNotifier<String> text = ValueNotifier<String>('未初始化');
  bool isInitGeoFence = false;

  late ValueNotifier<AMapGeoFenceModel?> geoFenceState =
      ValueNotifier<AMapGeoFenceModel?>(null);

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

  /// 初始化地理围栏
  Future<void> get initGeoFence async {
    if (!await getPermissions) return;
    final bool data = await initAMapGeoFence(GeoFenceActivateAction.stayed);
    if (data) {
      isInitGeoFence = true;
      show('初始化地理围栏:$data');
    }
  }

  bool isInit() {
    if (!isInitGeoFence) {
      show('请先调用 => initAMapGeoFence');
    }
    return isInitGeoFence;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('高德地理围栏')),
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
              const Text('高德地理围栏', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () => initGeoFence,
                        child: const Text('initAMapGeoFence')),
                    ElevatedButton(
                        onPressed: () {
                          if (!isInit()) return;
                          disposeAMapGeoFence();
                          isInitGeoFence = false;
                          show('未初始化');
                        },
                        child: const Text('disposeAMapGeoFence')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final AMapPoiModel model = AMapPoiModel(
                              keyword: '首开广场',
                              poiType: '写字楼',
                              city: '北京',
                              size: 1,
                              customId: '000FATE23（考勤打卡）');
                          final bool state =
                              await addAMapGeoFenceWithPOI(model);
                          show('addAMapGeoFenceWithPOI : $state');
                        },
                        child: const Text('添加POI围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final LatLong latLong =
                              LatLong(30.651411, 103.998638);
                          final AMapLatLongModel model = AMapLatLongModel(
                              latLong: latLong,
                              keyword: '颐和雅居',
                              poiType: '',
                              customId: '000FATE23（考勤打卡）',
                              size: 10,
                              aroundRadius: 10);

                          final bool state =
                              await addAMapGeoFenceWithLatLong(model);
                          show('addAMapGeoFenceWithLatLong : $state');
                        },
                        child: const Text('添加经纬度围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state = await addAMapGeoFenceWithDistrict(
                              keyword: '海淀区', customId: '000FATE23（考勤打卡）');
                          show('addAMapGeoFenceWithDistrict : $state');
                        },
                        child: const Text('添加行政区划围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final LatLong latLong =
                              LatLong(39.941949, 116.435497);
                          final bool state = await addAMapCircleGeoFence(
                              latLong: latLong,
                              radius: 10,
                              customId: '000FATE23（考勤打卡）');
                          show('addAMapCircleGeoFence : $state');
                        },
                        child: const Text('添加圆形围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state =
                              await addAMapCustomGeoFence(latLongs: <LatLong>[
                            LatLong(39.933921, 116.372927),
                            LatLong(39.907261, 116.376532),
                            LatLong(39.900611, 116.418161),
                            LatLong(39.941949, 116.435497),
                          ], customId: '000FATE23（考勤打卡）');
                          show('addAMapCustomGeoFence : $state');
                        },
                        child: const Text('添加多边形围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state = await startAMapGeoFenceChange(
                              onGeoFenceChange: (AMapGeoFenceModel geoFence) {
                            geoFenceState.value = geoFence;
                          });
                          show('startAMapGeoFenceChange : $state');
                        },
                        child: const Text('开启围栏状态监听')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state = await stopAMapGeoFenceChange();
                          show('stopAMapGeoFenceChange : $state');
                        },
                        child: const Text('关闭围栏状态监听')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state = await removeAMapAllGeoFence();
                          show('removeAMapAllGeoFence : $state');
                        },
                        child: const Text('删除所有地理围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state =
                              await removeAMapGeoFenceWithCustomID('');
                          show('removeAMapGeoFenceWithCustomID : $state');
                        },
                        child: const Text('删除指定地理围栏'))
                  ]),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ValueListenableBuilder<AMapGeoFenceModel?>(
                      valueListenable: geoFenceState,
                      builder: (_, AMapGeoFenceModel? value, __) => Text(
                          'customID : ${value?.customID}\n'
                          'type : ${value?.type}\n'
                          'status : ${value?.status}\n'
                          'fenceId : ${value?.fenceId}\n',
                          style: const TextStyle(fontSize: 15))))
            ])),
      ));

  void show(String str) {
    text.value = str;
  }

  @override
  void dispose() {
    super.dispose();
    disposeAMapGeoFence();
  }
}
