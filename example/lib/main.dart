import 'package:example/geo_fence_page.dart';
import 'package:example/loaction_page.dart';
import 'package:fl_amap/fl_amap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_waya/flutter_waya.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool key = await setAMapKey(
      iosKey: 'e0e98395277890e48caa0c4bed423ead',
      androidKey: '77418e726d0eefc0ac79a8619b5f4d97',
      isAgree: true,
      isContains: true,
      isShow: true);
  debugPrint('高德地图ApiKey设置$key');
  runApp(const ExtendedWidgetsApp(title: 'FlAMap', home: App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExtendedScaffold(
        appBar: AppBar(title: const Text('高德地图')),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedText(
              onPressed: () => showCupertinoModalPopup<dynamic>(
                  context: context, builder: (_) => const AMapLocationPage()),
              text: '高德定位功能'),
          ElevatedText(
              onPressed: () => showCupertinoModalPopup<dynamic>(
                  context: context, builder: (_) => const AMapGeoFencePage()),
              text: '高德地理围栏功能'),
        ]);
  }
}

class ElevatedText extends StatelessWidget {
  const ElevatedText({Key? key, required this.text, required this.onPressed})
      : super(key: key);

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
