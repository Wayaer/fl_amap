import 'package:fl_amap_map/fl_amap_map.dart';
import 'package:flutter/material.dart';

class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  AMapController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('高德地图')),
        body: AMapView(
            options: const AMapOptions(
                mapType: MapType.standardNight,
                showCompass: false,
                showMapText: true,
                showTraffic: false,
                showUserLocation: true,
                showUserLocationButton: false,
                latLng: LatLng(30.572961, 104.066301)),
            onCreateController: (AMapController controller) {
              this.controller = controller;
              controller.setTrackingMode(TrackingMode.none);
              controller.addListener();
            }));
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
