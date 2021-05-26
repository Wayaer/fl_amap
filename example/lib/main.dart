import 'package:amap/geo_fence_page.dart';
import 'package:amap/loaction_page.dart';
import 'package:fl_amap/fl_amap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool? key = await setAMapKey(
      iosKey: 'e0e98395277890e48caa0c4bed423ead',
      androidKey: '77418e726d0eefc0ac79a8619b5f4d97');
  if (key != null && key) print('高德地图ApiKey设置成功');
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, title: 'FlAMap', home: App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('高德地图')),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    onPressed: () => showCupertinoModalPopup<dynamic>(
                        context: context,
                        builder: (_) => const AMapLocationPage()),
                    child: const Text('高德定位功能')),
                ElevatedButton(
                    onPressed: () => showCupertinoModalPopup<dynamic>(
                        context: context,
                        builder: (_) => const AMapGeoFencePage()),
                    child: const Text('高德地理围栏功能')),
              ]),
        ));
  }
}

Future<bool> requestPermissions(Permission permission, String text) async {
  final PermissionStatus status = await permission.status;
  if (status != PermissionStatus.granted) {
    final Map<Permission, PermissionStatus> statuses =
        await <Permission>[permission].request();
    if (!(statuses[permission] == PermissionStatus.granted)) {
      openAppSettings();
    }
    return statuses[permission] == PermissionStatus.granted;
  }
  return true;
}
