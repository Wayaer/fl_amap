import 'package:example/main.dart';
import 'package:fl_amap/fl_amap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

class AMapLocationPage extends StatefulWidget {
  const AMapLocationPage({Key? key}) : super(key: key);

  @override
  State<AMapLocationPage> createState() => _AMapLocationPageState();
}

class _AMapLocationPageState extends State<AMapLocationPage> {
  late ValueNotifier<String> text = ValueNotifier<String>('未初始化');
  late ValueNotifier<AMapLocation?> locationState =
      ValueNotifier<AMapLocation?>(null);

  int i = 0;

  /// 获取定位权限
  Future<bool> get getPermissions async {
    if (!await getPermission(Permission.location)) {
      show('未获取到定位权限');
      return false;
    }
    return true;
  }

  Future<void> getLocation() async {
    if (!await getPermissions) return;
    locationState.value = await FlAMapLocation().getLocation(true);
  }

  /// 初始化定位
  Future<void> initLocation() async {
    if (!await getPermissions) return;

    /// 初始化AMap
    final bool data = await FlAMapLocation().initialize(AMapLocationOption());
    show('初始化定位:$data');
  }

  @override
  Widget build(BuildContext context) => ExtendedScaffold(
          appBar: AppBar(title: const Text('高德地图定位')),
          isScroll: true,
          padding: const EdgeInsets.all(8.0),
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
                  ElevatedText(onPressed: initLocation, text: 'initialize'),
                  ElevatedText(
                      onPressed: () {
                        FlAMapLocation().dispose();
                        locationState.value = null;
                        i = 0;
                        show('未初始化');
                      },
                      text: 'dispose'),
                  ElevatedText(onPressed: getLocation, text: '直接获取定位'),
                  ElevatedText(onPressed: startLocationState, text: '开启监听定位'),
                  ElevatedText(
                      onPressed: () {
                        text.value = '定位监听关闭';
                        locationState.value = null;
                        i = 0;
                        FlAMapLocation().stopLocation();
                      },
                      text: '关闭监听定位'),
                ]),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: ValueListenableBuilder<AMapLocation?>(
                    valueListenable: locationState,
                    builder: (_, AMapLocation? value, __) => Text(
                        getLocationStr(value),
                        style: const TextStyle(fontSize: 15))))
          ]);

  Future<void> startLocationState() async {
    if (!await getPermissions) return;
    final bool data = await FlAMapLocation().startLocationChanged(
        onLocationChanged: (AMapLocation location) {
      locationState.value = location;
      i += 1;
      text.value = '位置更新$i次';
    });
    show((!data) ? '开启失败' : '开启成功');
  }

  void show(String str) {
    text.value = str;
  }

  @override
  void dispose() {
    super.dispose();
    FlAMapLocation().dispose();
  }

  String getLocationStr(AMapLocation? loc) {
    if (loc != null) {
      if (loc.isSuccess ?? false) {
        if (loc.hasAddress ?? false) {
          return '定位成功: \n时间${loc.timestamp ?? ''}\n经纬度:${loc.latLng?.latitude ?? ''} ${loc.latLng?.longitude ?? ''}\n地址:${loc.formattedAddress ?? ''}\n城市:${loc.city ?? ''}\n省:${loc.province ?? ''}';
        } else {
          return '定位成功: \n时间${loc.timestamp ?? ''}\n经纬度:${loc.latLng?.latitude ?? ''}'
              '  ${loc.latLng?.longitude ?? ''}';
        }
      } else {
        return '定位失败: \n错误:{code=${loc.code ?? ''},\ndescription=${loc.description ?? ''}';
      }
    }
    return '无法定位';
  }
}
