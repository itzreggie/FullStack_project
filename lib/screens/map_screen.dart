// I am using Mapbox Maps Flutter SDK version 2.8.0.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import '../widgets/location_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static _MapScreenState? _instance;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  mp.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  bool _hasLocationPermission = false;
  bool _initialLocationRequested = false;
  
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
    userPositionStream?.cancel();
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

            Positioned(
              bottom: 30,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LocationButton(mapboxMapController: mapboxMapController),
                ],
              ),
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

    // Check if we have location permission
    _hasLocationPermission = await _checkLocationPermission();

    if (_hasLocationPermission) {
      // Permission already granted - go directly to user location
      await _requestLocationAndCenter();
    } else {
      // No permission - set initial camera to maximum zoom out (world view)
      mapboxMapController?.setCamera(
        mp.CameraOptions(
          pitch: 0.0, // Flat view for world overview
          bearing: 0.0,
          zoom: 1.0, // Maximum zoom out
        ),
      );

      // Automatically trigger location request after showing world view
      if (!_initialLocationRequested) {
        _initialLocationRequested = true;
        // Small delay to ensure map is fully loaded
        await Future.delayed(const Duration(milliseconds: 500));
        await _requestLocationAndCenter();
      }
    }
  }

  Future<bool> _checkLocationPermission() async {
    final permission = await gl.Geolocator.checkPermission();
    final serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();

    return serviceEnabled &&
        (permission == gl.LocationPermission.whileInUse ||
            permission == gl.LocationPermission.always);
  }

  Future<void> _requestLocationAndCenter() async {
    if (mapboxMapController == null) return;

    try {
      // Check permission before trying to get location
      final permission = await gl.Geolocator.checkPermission();

      if (permission == gl.LocationPermission.denied ||
          permission == gl.LocationPermission.deniedForever) {
        final hasPermission = await _requestLocationPermission();
        if (!hasPermission) return;
      }

      // Check if location services are enabled
      final serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Permission granted - get location and animate
      final position = await gl.Geolocator.getCurrentPosition(
        desiredAccuracy: gl.LocationAccuracy.high,
      );

      // Update location component settings to DISABLE the default blue/white puck
      await mapboxMapController!.location.updateSettings(
        mp.LocationComponentSettings(
          enabled: false, // Important: disable default location puck
          pulsingEnabled: false, // Disable pulsing effect
        ),
      );

      // Animate to user's location with same animation as location button
      mapboxMapController!.flyTo(
        mp.CameraOptions(
          center: mp.Point(
            coordinates: mp.Position(position.longitude, position.latitude),
          ),
          zoom: 15.0,
          bearing: 0.0,
          pitch: 60.0,
        ),
        mp.MapAnimationOptions(duration: 2000),
      );

      // Start position tracking AFTER the map has loaded and camera is set
      await Future.delayed(const Duration(milliseconds: 1000));
      _setupPositionTracking();

      setState(() {
        _hasLocationPermission = true;
      });
    } catch (e) {
      debugPrint('Error requesting location: $e');
    }
  }

  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show dialog to user about enabling location services
      _showLocationServiceDialog();
      return false;
    }

    // Check current permission status
    permission = await gl.Geolocator.checkPermission();

    if (permission == gl.LocationPermission.denied) {
      // Request permission - this will show Android permission dialog
      permission = await gl.Geolocator.requestPermission();

      if (permission == gl.LocationPermission.denied) {
        // Permission denied by user
        _showPermissionDeniedDialog();
        return false;
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      // Permissions are permanently denied
      _showPermissionPermanentlyDeniedDialog();
      return false;
    }

    // Permission granted but don't animate to location yet
    if (permission == gl.LocationPermission.whileInUse) {
      // First show background permission dialog 
      await _showBackgroundLocationDialog();
      // Now animate to location after user has responded to dialog
      _animateToUserLocation();
    } else if (permission == gl.LocationPermission.always) {
      // Already has background permission, animate directly
      _animateToUserLocation();
    }

    // Permission granted
    return true;
  }

  Future<void> _animateToUserLocation() async {
    try {
      // Get the user's current location
      final position = await gl.Geolocator.getCurrentPosition(
        desiredAccuracy: gl.LocationAccuracy.high,
      );

      // Animate camera to user's location with the same animation as location button
      mapboxMapController?.flyTo(
        mp.CameraOptions(
          pitch: 60.0,
          bearing: 0.0,
          zoom: 18.0,
          center: mp.Point(
            coordinates: mp.Position(position.longitude, position.latitude),
          ),
        ),
        mp.MapAnimationOptions(duration: 3000), // Same 3-second animation
      );
    } catch (e) {
      debugPrint('Error animating to user location: $e');
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'This app needs location services to show your position on the map. Please enable location services in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to show your position on the map. You can grant permission in the app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Try requesting permission again
                final hasPermission = await _requestLocationPermission();
                if (hasPermission) {
                  mapboxMapController?.location.updateSettings(
                    mp.LocationComponentSettings(
                      enabled: true,
                      pulsingEnabled: true,
                    ),
                  );
                  _setupPositionTracking();
                }
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Location permissions are permanently denied. Please enable them in your device settings to use location features.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Open app settings
                await gl.Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBackgroundLocationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Allow background location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'For better experience, please allow the location to be used all the time in the settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          // On Android, we need to take users to settings for background permission
                          await gl.Geolocator.openAppSettings();
                        },
                        child: const Text('Go to settings'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _setupPositionTracking() async {
    gl.LocationSettings locationSettings = const gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 1, // Reduced to 1 meter for very frequent updates
    );

    userPositionStream?.cancel();
    userPositionStream =
        gl.Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((gl.Position? position) {
          if (position != null && mapboxMapController != null) {
            debugPrint(
              'New position received: ${position.latitude}, ${position.longitude}',
            );
          }
        });
    debugPrint('Position tracking setup complete');
  }
}
