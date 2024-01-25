import 'package:example/main.dart';
import 'package:fl_amap/fl_amap.dart';
import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class AMapLocationPage extends StatefulWidget {
  const AMapLocationPage({super.key});

  @override
  State<AMapLocationPage> createState() => _AMapLocationPageState();
}

class _AMapLocationPageState extends State<AMapLocationPage> {
  late ValueNotifier<String> text = ValueNotifier('未初始化');
  late ValueNotifier<AMapLocation?> locationState = ValueNotifier(null);
  late ValueNotifier<AMapLocationHeading?> headingState = ValueNotifier(null);
  final location = FlAMapLocation();

  /// 获取定位权限
  Future<bool> get getPermissions async {
    if (!await getPermission(Permission.location)) {
      text.value = '未获取到定位权限';
      return false;
    }
    return true;
  }

  final androidOption = AMapLocationOptionForAndroid(
      beiDouFirst: true,
      sensorEnable: true,
      locationMode: AMapLocationMode.heightAccuracy);
  final iosOption = AMapLocationOptionForIOS(withReGeocode: true);

  /// 初始化定位
  Future<void> initLocation() async {
    if (!await getPermissions) return;

    /// 初始化AMap
    final bool data = await location.initialize();
    text.value = '初始化定位:$data';
  }

  @override
  void initState() {
    super.initState();
    location.addListener(onLocationChanged: (AMapLocation? location) {
      locationState.value = location;
    }, onLocationFailed: (AMapLocationError? error) {
      text.value = 'ios 连续定位错误：${error?.toMap()}';
    }, onHeadingChanged: (AMapLocationHeading? heading) {
      headingState.value = heading;
    }, onAuthorizationChanged: (int? status) {
      text.value = 'ios 权限状态变化：$status';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('高德定位')),
      body: Universal(
          isScroll: true,
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.withOpacity(0.3)),
                child: ValueListenableBuilder<String>(
                    valueListenable: text,
                    builder: (_, String value, __) => Text(value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18)))),
            const SizedBox(height: 10),
            Wrap(
                runSpacing: 10,
                spacing: 10,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  ElevatedText(onPressed: initLocation, text: 'initialize'),
                  ElevatedText(
                      onPressed: () {
                        location.dispose();
                        locationState.value = null;
                        text.value = '未初始化';
                      },
                      text: 'dispose'),
                  ElevatedText(onPressed: getLocation, text: '直接获取定位'),
                  ElevatedText(onPressed: startLocationState, text: '开启监听定位'),
                  ElevatedText(
                      onPressed: () {
                        text.value = '定位监听关闭';
                        locationState.value = null;
                        location.stopLocation();
                      },
                      text: '关闭监听定位'),
                  if (TargetPlatform.iOS == defaultTargetPlatform) ...[
                    ElevatedText(
                        onPressed: () async {
                          final result = await location.headingAvailable();
                          text.value = 'ios 设备是否支持方向识别：$result';
                        },
                        text: '设备是否支持方向识别'),
                    ElevatedText(
                        onPressed: () async {
                          final result = await location.startUpdatingHeading();
                          text.value = 'ios 开始获取设备朝向 $result';
                        },
                        text: '开始获取设备朝向'),
                    ElevatedText(
                        onPressed: () async {
                          final result = await location.stopUpdatingHeading();
                          headingState.value = null;
                          text.value = 'ios 停止获取设备朝向 $result';
                        },
                        text: '停止获取设备朝向'),
                    ElevatedText(
                        onPressed: () async {
                          final result =
                              await location.dismissHeadingCalibrationDisplay();
                          text.value = 'ios 停止设备朝向校准显示 $result';
                        },
                        text: '停止设备朝向校准显示'),
                  ],
                ]),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: ValueListenableBuilder<AMapLocation?>(
                    valueListenable: locationState,
                    builder: (_, AMapLocation? value, __) {
                      return value == null
                          ? const Text('暂无定位信息')
                          : JsonParse(value.toMapForPlatform());
                    })),
            if (TargetPlatform.iOS == defaultTargetPlatform)
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ValueListenableBuilder<AMapLocationHeading?>(
                      valueListenable: headingState,
                      builder: (_, AMapLocationHeading? value, __) {
                        return value == null
                            ? const Text('暂无Heading信息')
                            : JsonParse(value.toMap());
                      })),
          ]));

  Future<void> getLocation() async {
    if (!await getPermissions) return;
    text.value = '单次定位获取';
    locationState.value = null;
    locationState.value = await location.getLocation(
        optionForAndroid: androidOption, optionForIOS: iosOption);
  }

  Future<void> startLocationState() async {
    if (!await getPermissions) return;
    locationState.value = null;
    final bool data = await FlAMapLocation().startLocation(
        optionForAndroid: androidOption, optionForIOS: iosOption);
    text.value = '开启连续定位${!data ? '失败' : '成功'}';
  }

  @override
  void dispose() {
    super.dispose();
    location.dispose();
    text.dispose();
  }
}
