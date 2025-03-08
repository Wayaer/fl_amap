import 'package:example/src/coordinate_converter_page.dart';
import 'package:example/src/geo_fence_page.dart';
import 'package:example/src/loaction_page.dart';
import 'package:fl_amap/fl_amap.dart';
import 'package:fl_extended/fl_extended.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      navigatorKey: FlExtended().navigatorKey,
      scaffoldMessengerKey: FlExtended().scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'FlAMap',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
          appBar: AppBar(title: const Text('高德定位')), body: const App())));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    bool isInit = false;
    return Universal(
        width: double.infinity,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedText(
              onPressed: () async {
                isInit = await FlAMap().setAMapKey(
                    iosKey: '7d3261c06027bdc87aca547c99ad5b2f',
                    // iosKey: 'e0e98395277890e48caa0c4bed423ead',
                    androidKey: '77418e726d0eefc0ac79a8619b5f4d97',
                    isAgree: true,
                    isContains: true,
                    isShow: true);
                showToast('高德地图ApiKey设置$isInit');
              },
              text: '设置高德key'),
          ElevatedText(
              onPressed: () {
                if (!isInit) {
                  showToast('请先设置高德key');
                  return;
                }
                push(const AMapLocationPage());
              },
              text: '高德定位功能'),
          ElevatedText(
              onPressed: () {
                if (!isInit) {
                  showToast('请先设置高德key');
                  return;
                }
                push(const AMapGeoFencePage());
              },
              text: '高德地理围栏功能'),
          ElevatedText(
              onPressed: () {
                push(const CoordinateConverterPage());
              },
              text: '坐标转换器'),
        ]);
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
