import 'package:example/geo_fence_page.dart';
import 'package:example/loaction_page.dart';
import 'package:example/map_view_page.dart';
import 'package:fl_amap_map/fl_amap_map.dart';
import 'package:fl_extended/fl_extended.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setAMapKey(
          iosKey: '7d3261c06027bdc87aca547c99ad5b2f',
          androidKey: '77418e726d0eefc0ac79a8619b5f4d97',
          isAgree: true,
          isContains: true,
          isShow: true)
      .then((value) {
    debugPrint('高德地图ApiKey设置$value');
  });
  runApp(MaterialApp(
      navigatorKey: FlExtended().navigatorKey,
      scaffoldMessengerKey: FlExtended().scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      title: 'FlAMap',
      home: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('高德地图')),
        body: Universal(
            width: double.infinity,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedText(
                  onPressed: () => showCupertinoModalPopup<dynamic>(
                      context: context,
                      builder: (_) => const AMapLocationPage()),
                  text: '高德定位功能'),
              ElevatedText(
                  onPressed: () => showCupertinoModalPopup<dynamic>(
                      context: context,
                      builder: (_) => const AMapGeoFencePage()),
                  text: '高德地理围栏功能'),
              ElevatedText(onPressed: pushMapViewPage, text: '高德地图'),
            ]));
  }

  /// 获取定位权限
  Future<void> pushMapViewPage() async {
    if (!await getPermission(Permission.location)) {
      showToast('未获取到定位权限');
      return;
    }
    push(const MapViewPage());
  }
}

class ElevatedText extends StatelessWidget {
  const ElevatedText({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed, child: Text(text));
}

Future<bool> getPermission(Permission permission) async {
  final PermissionStatus status = await permission.request();
  if (!status.isGranted) {
    await openAppSettings();
    return await permission.request().isGranted;
  }
  return status.isGranted;
}
