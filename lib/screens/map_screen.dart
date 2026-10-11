// I am using Mapbox Maps Flutter SDK version 2.8.0.

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static _MapScreenState? _instance;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  mp.MapboxMap? mapboxMapController;
  
  // Get current style URI based on time
  String _getCurrentStyleUri() {
    final now = DateTime.now();
    final hour = now.hour; // 0-23 format

    if (hour >= 7 && hour < 12) {
      // 7:00-11:59 - Day
      return "mapbox://styles/reggie88/cmb27dqr100ht01sd2vrmc4uy?fresh=true";
    } else if (hour >= 12 && hour < 17) {
      // 12:00-16:59 - Dawn
      return "mapbox://styles/reggie88/cmb28mvuo00h201r4g0s71ji2?fresh=true";
    } else if (hour >= 17 && hour < 20) {
      // 17:00-19:59 - Dusk
      return "mapbox://styles/reggie88/cmb28o5py00gs01scewx2d393?fresh=true";
    } else {
      // 20:00-6:59 - Night
      return "mapbox://styles/reggie88/cmb2hf23r00gv01qx1kra2j8j?fresh=true"; 
    }
  }

  @override
  void initState() {
    super.initState();
    MapScreen._instance = this;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          mp.MapWidget(
            key: ValueKey(_getCurrentStyleUri()),
            styleUri: _getCurrentStyleUri(),
            cameraOptions: mp.CameraOptions(
              center: mp.Point(coordinates: mp.Position(0, 0)),
              zoom: 1.0,
            ),
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
    );
  }

  void _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      mapboxMapController = controller;
    });

    // Set camera bounds with maximum zoom limit
    await mapboxMapController?.setBounds(
      mp.CameraBoundsOptions(
        maxZoom: 19.0,
        // minZoom is not set, so users can zoom out freely
      ),
    );

    // Move logo and other UI elements first
    mapboxMapController?.logo.updateSettings(
      mp.LogoSettings(
        position: mp.OrnamentPosition.TOP_RIGHT,
        marginLeft: 1000,
        marginTop: 40,
        marginRight: 0,
        marginBottom: 10,
      ),
    );

    mapboxMapController?.attribution.updateSettings(
      mp.AttributionSettings(
        position: mp.OrnamentPosition.TOP_RIGHT,
        marginTop: 40,
        marginLeft: 1000,
        clickable: true,
      ),
    );

    mapboxMapController?.compass.updateSettings(
      mp.CompassSettings(
        position: mp.OrnamentPosition.TOP_RIGHT,
        marginRight: 16,
        marginTop: 50,
        enabled: true,
      ),
    );

    mapboxMapController?.scaleBar.updateSettings(
      mp.ScaleBarSettings(
        position: mp.OrnamentPosition.BOTTOM_LEFT,
        marginLeft: 16,
        marginBottom: 16,
        enabled: true,
      ),
    );

    // Set initial camera to maximum zoom out (world view)
    mapboxMapController?.setCamera(
      mp.CameraOptions(
        pitch: 0.0, // Flat view for world overview
        bearing: 0.0,
        zoom: 1.0, // Maximum zoom out
      ),
    );
  }
}
