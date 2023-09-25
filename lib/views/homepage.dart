// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps/providers/map_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:permission_handler/permission_handler.dart';

LatLng lahore = const LatLng(31.5204, 74.3587);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    final mapProvider = Provider.of<MapTypeProvider>(context, listen: false);

    if (status.isGranted) {
      // Permission granted, you can now use location services

      mapProvider.updateCurrentLocation();
    } else if (status.isDenied) {
      // Permission denied
      // You might want to show a dialog explaining why you need the permission
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, open app settings
      openAppSettings();
    }
  }

  void initState() {
    super.initState();
    final mapProvider = Provider.of<MapTypeProvider>(context, listen: false);

    requestLocationPermission();
    mapProvider.updateCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapTypeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            trafficEnabled: true,
            //  Provider.of<MapTypeProvider>(context, listen: true)
            //     .isTrafficLayerEnabled,
            mapType: Provider.of<MapTypeProvider>(context, listen: true)
                .currentMapType,
            initialCameraPosition:
                Provider.of<MapTypeProvider>(context, listen: true)
                    .currentPosition,
            // CameraPosition(
            //   target: lahore,
            //   zoom: 12.0,
            // ),
            markers: {
              if (mapProvider.marker != null)
                mapProvider.marker!, // Your existing marker(s)
              if (mapProvider.currentPosition != null)
                Marker(
                  infoWindow: InfoWindow(
                      title: mapProvider.currentPosition.target.toString()),
                  markerId: const MarkerId('user_location'),
                  position: mapProvider.currentPosition.target,
                  icon: BitmapDescriptor
                      .defaultMarker, // Use the custom icon here
                ),
            },
            onTap: (LatLng position) {
              mapProvider.addOrUpdateMarker(
                  position,
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  'Destination');
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: FloatingActionButton(
                onPressed: () => {
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(
                      0.0,
                      10.0,
                      10.0,
                      10.0,
                    ),
                    items: <PopupMenuEntry<MapType>>[
                      const PopupMenuItem<MapType>(
                        value: MapType.normal,
                        child: Text('Normal'),
                      ),
                      const PopupMenuItem<MapType>(
                        value: MapType.satellite,
                        child: Text('Satellite'),
                      ),
                      const PopupMenuItem<MapType>(
                        value: MapType.terrain,
                        child: Text('Terrain'),
                      ),
                      // const PopupMenuItem<MapType>(
                      //   value: MapType.normal, // Add a new option for traffic
                      //   child: Text('Traffic'),
                      // ),
                    ],
                  ).then((value) {
                    if (value != null) {
                      // Handle the selected map type
                      Provider.of<MapTypeProvider>(context, listen: false)
                          .setMapType(value);
                    }
                  })
                },
                // print('button pressed'),
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.map,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                onPressed: () => {mapProvider.updateCurrentLocation()},
                // print('button pressed'),
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.location_history,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
