import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class MapTypeProvider with ChangeNotifier {
  MapType _currentMapType = MapType.normal;
  bool _isTrafficLayerEnabled = true;
  MapType get currentMapType => _currentMapType;
  bool get isTrafficLayerEnabled => _isTrafficLayerEnabled;
  Marker? _marker;

  CameraPosition get currentPosition => _currentPosition;
  Marker? get marker => _marker;
  LatLng userLocation = LatLng(31.5204, 74.3587);

  // Marker? get userlocation => userlocation;
  CameraPosition _currentPosition =
      const CameraPosition(target: LatLng(31.5204, 74.3587), zoom: 11.0);

  void setMapType(MapType mapType) {
    _currentMapType = mapType;
    notifyListeners();
  }

  void setTrafficLayer(bool enabled) {
    _isTrafficLayerEnabled = !_isTrafficLayerEnabled;
    notifyListeners();
  }

  //.................................addOrUpdateMarker....................................................//
  void addOrUpdateMarker(LatLng position, String markerId, String title) {
    if (_marker != null) {
//......................... If a marker exists, update its position....................................//
      _marker = _marker!.copyWith(
        positionParam: position,
      );
    }
    //...............................If a marker does not exists......................................//
    else {
      _marker = Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarker);
    }
    notifyListeners();
  }

//.......................................Remove marker....................................................//
  void removeMarker() {
    _marker = null;
    notifyListeners();
  }

//.........................get current location..............................//
  Future<LatLng> getCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return LatLng(31.5204, 74.3587);
    }
  }

//.........................update the current location..........................//
  Future<void> updateCurrentLocation() async {
    userLocation = await getCurrentLocation();
    if (userLocation != null) {
      _currentPosition = CameraPosition(target: userLocation, zoom: 14.0);
      notifyListeners();
    }
  }
}
