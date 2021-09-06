import 'dart:io';

import 'package:amap/main.dart';
import 'package:fl_amap/fl_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class AMapGeoFencePage extends StatefulWidget {
  const AMapGeoFencePage({Key? key}) : super(key: key);

  @override
  _AMapGeoFencePageState createState() => _AMapGeoFencePageState();
}

class _AMapGeoFencePageState extends State<AMapGeoFencePage> {
  late ValueNotifier<String> text = ValueNotifier<String>('未初始化');
  bool isInitGeoFence = false;
  String customID = 'TestCustomID';

  ValueNotifier<AMapGeoFenceStatusModel?> geoFenceState =
      ValueNotifier<AMapGeoFenceStatusModel?>(null);
  ValueNotifier<dynamic> json = ValueNotifier<dynamic>(null);

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
    final bool data =
        await FlAMapGeoFence().initialize(GeoFenceActivateAction.stayed);
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
        height: double.infinity,
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
                        child: const Text('initialize')),
                    ElevatedButton(
                        onPressed: () {
                          if (!isInit()) return;
                          FlAMapGeoFence().dispose();
                          isInitGeoFence = false;
                          show('未初始化');
                        },
                        child: const Text('dispose')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final AMapPoiModel model = AMapPoiModel(
                              keyword: '首开广场',
                              poiType: '写字楼',
                              city: '北京',
                              size: 1,
                              customID: customID);
                          final bool state =
                              await FlAMapGeoFence().addPOI(model);
                          show('addPOI : $state');
                        },
                        child: const Text('添加POI围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final LatLong latLong = LatLong(30.651011, 103.99506);
                          final AMapLatLongModel model = AMapLatLongModel(
                              latLong: latLong,
                              keyword: '四川省妇幼儿童医院',
                              poiType: '',
                              customID: customID,
                              size: 20,
                              aroundRadius: 1000);
                          final bool state =
                              await FlAMapGeoFence().addLatLong(model);
                          print('添加经纬度围栏 $state');
                          show('addLatLong : $state');
                        },
                        child: const Text('添加经纬度围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state = await FlAMapGeoFence()
                              .addDistrict(keyword: '海淀区', customID: customID);
                          show('addDistrict : $state');
                        },
                        child: const Text('添加行政区划围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final LatLong latLong =
                              LatLong(30.651411, 103.998638);
                          final bool state = await FlAMapGeoFence().addCircle(
                              latLong: latLong, radius: 10, customID: customID);
                          show('addCircle : $state');
                        },
                        child: const Text('添加圆形围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state = await FlAMapGeoFence()
                              .addCustom(latLongs: <LatLong>[
                            LatLong(39.933921, 116.372927),
                            LatLong(39.907261, 116.376532),
                            LatLong(39.900611, 116.418161),
                            LatLong(39.941949, 116.435497),
                          ], customID: customID);
                          show('addCustom : $state');
                        },
                        child: const Text('添加多边形围栏')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final List<AMapGeoFenceModel> data =
                              await FlAMapGeoFence().getAll();
                          if (data.isEmpty) {
                            json.value = '没有添加围栏信息';
                          } else {
                            json.value = data
                                .map((AMapGeoFenceModel e) => e.toMap())
                                .toList();
                          }
                        },
                        child: const Text('获取所有围栏信息')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state = await FlAMapGeoFence()
                              .registerService(onGeoFenceChange:
                                  (AMapGeoFenceStatusModel geoFence) {
                            print(geoFence.toMap());
                            print('围栏变化监听');
                            geoFenceState.value = geoFence;
                          });
                          show('registerService : $state');
                        },
                        child: const Text('开启监听服务')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state =
                              await FlAMapGeoFence().unregisterService();
                          show('unregisterService : $state');
                        },
                        child: const Text('关闭监听服务')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state =
                              await FlAMapGeoFence().resume(customID: customID);
                          show('resume : $state');
                        },
                        child: const Text('开始围栏监听')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state =
                              await FlAMapGeoFence().pause(customID: customID);
                          show('pause : $state');
                        },
                        child: const Text('暂停围栏监听')),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isInit()) return;
                          final bool state = await FlAMapGeoFence().remove();
                          show('remove : $state');
                          json.value = '没有添加围栏信息';
                        },
                        child: const Text('删除所有地理围栏')),
                  ]),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ValueListenableBuilder<AMapGeoFenceStatusModel?>(
                      valueListenable: geoFenceState,
                      builder: (_, AMapGeoFenceStatusModel? value, __) => Text(
                          'customID : ${value?.customID}\n'
                          '围栏类型 type : ${getType(value?.type)}\n'
                          '围栏状态 status : ${getStatus(value?.status)}\n'
                          '围栏ID fenceID : ${value?.fenceID}\n',
                          style: const TextStyle(fontSize: 15)))),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ValueListenableBuilder<dynamic>(
                      valueListenable: json,
                      builder: (_, dynamic value, __) {
                        if (value is Map) return JsonParse(value);
                        if (value is List) return JsonParse.list(value);
                        return Text(value.toString());
                      }))
            ])),
      ));

  String getType(int? type) {
    switch (type) {
      case 0:
        return '圆形地理围栏';
      case 1:
        return '多边形地理围栏';
      case 2:
        return '(POI）地理围栏';
      case 3:
        return '行政区划地理围栏';
      default:
        return '未知类型';
    }
  }

  String getStatus(int? status) {
    switch (status) {
      case 1:
        return '在范围内';
      case 2:
        return '在范围外';
      case 3:
        return '停留(在范围内超过10分钟)';
      default:
        return '未知状态';
    }
  }

  void show(String str) {
    text.value = str;
  }

  @override
  void dispose() {
    super.dispose();
    FlAMapGeoFence().remove();
    FlAMapGeoFence().dispose();
  }
}
