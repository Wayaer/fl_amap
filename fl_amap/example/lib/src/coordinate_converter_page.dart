import 'package:example/main.dart';
import 'package:fl_amap/fl_amap.dart';
import 'package:fl_extended/fl_extended.dart';
import 'package:flutter/material.dart';

class CoordinateConverterPage extends StatefulWidget {
  const CoordinateConverterPage({super.key});

  @override
  State<CoordinateConverterPage> createState() =>
      _CoordinateConverterPageState();
}

class _CoordinateConverterPageState extends State<CoordinateConverterPage> {
  LatLng? otherLatLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('高德地理围栏')),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: children),
        ));
  }

  TextEditingController latitudeController =
      TextEditingController(text: '39.950842');
  TextEditingController longitudeController =
      TextEditingController(text: '116.360072');

  CoordType coordType = CoordType.baidu;

  List<Widget> get children => [
        Row(children: [
          TextField(
                  controller: longitudeController,
                  decoration: InputDecoration(hintText: 'longitude'))
              .expanded,
          20.widthBox,
          TextField(
            controller: latitudeController,
            decoration: InputDecoration(hintText: 'latitude'),
          ).expanded,
        ]),
        20.heightBox,
        PopupMenuButton<CoordType>(
            initialValue: coordType,
            onSelected: (value) {
              coordType = value;
            },
            child: Universal(
                mainAxisSize: MainAxisSize.min,
                direction: Axis.horizontal,
                padding: EdgeInsets.symmetric(vertical: 10),
                children: [
                  Text('转换类型：${coordType.name}'),
                  10.widthBox,
                  Icon(Icons.arrow_circle_down_rounded)
                ]),
            itemBuilder: (_) => CoordType.values
                .builder((e) => PopupMenuItem(value: e, child: Text(e.name)))),
        ElevatedText(text: '转换', onPressed: convert),
        if (otherLatLng != null)
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('转换后的坐标：\n${otherLatLng?.toMap()}',
                  textAlign: TextAlign.center)),
      ];

  convert() async {
    final latitude = double.tryParse(latitudeController.text);
    final longitude = double.tryParse(longitudeController.text);
    if (latitude == null || longitude == null) {
      showToast('请输入正确的经纬度');
      return;
    }
    final result = await FlAMapLocation()
        .coordinateConverter(LatLng(latitude, longitude), coordType);
    if (result == null) {
      showToast('转换失败');
      return;
    }
    switch (result.code) {
      case null:
        break;
      case CoordinateConverterResultCode.success:
        if (result.latLng != null) {
          otherLatLng = result.latLng;
          setState(() {});
        }
        break;
      case CoordinateConverterResultCode.exception:
        if (result.message != null) {
          showToast(result.message!);
        }
        break;
    }
  }
}
