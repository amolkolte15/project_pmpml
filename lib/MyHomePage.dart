import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  double _latitude = 0.0;
  double _longitude = 0.0;
  late GoogleMapController _mapController;
  Marker _marker = Marker(
    markerId: MarkerId('initialMarker'),
    position: LatLng(0, 0),
  );

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _setupListeners();
  }

  void _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }
  }

  void _setupListeners() {
    _databaseReference.child('LAT').onValue.listen((event) {
      final lat = event.snapshot.value as num?;
      if (lat != null) {
        setState(() {
          _latitude = lat.toDouble();
          _updateMarker();
        });
      }
    });
    _databaseReference.child('LNG').onValue.listen((event) {
      final lng = event.snapshot.value as num?;
      if (lng != null) {
        setState(() {
          _longitude = lng.toDouble();
          _updateMarker();
        });
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarker();
  }

  void _updateMarker() {
    _marker = Marker(
      markerId: MarkerId('gpsMarker'),
      position: LatLng(_latitude, _longitude),
      infoWindow: InfoWindow(
        title: 'Current Location',
        snippet: 'Latitude: $_latitude, Longitude: $_longitude',
      ),
    );
    if (_mapController != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_latitude, _longitude),
          15,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS Tracker'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        markers: {_marker},
        initialCameraPosition: CameraPosition(
          target: LatLng(_latitude, _longitude),
          zoom: 15,
        ),
      ),
    );
  }
}




