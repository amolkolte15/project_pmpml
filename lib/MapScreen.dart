import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:polyline_animation_v1/polyline_animation_v1.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic>? fromPlace;
  final Map<String, dynamic>? toPlace;

  const MapScreen({
    Key? key,
    this.fromPlace,
    this.toPlace,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final PolylineAnimator _animator = PolylineAnimator();
  final Set<Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  bool _isLoading = true;
  Map<String, dynamic>? _routeData;
  MapType _currentMapType = MapType.normal; // Default map type

  @override
  void initState() {
    super.initState();
    if (widget.fromPlace != null && widget.toPlace != null) {
      _loadRouteData();
    }
  }

  Future<void> _loadRouteData() async {
    try {
      final String response = await rootBundle.loadString('lib/service/data.json');
      final data = await json.decode(response);
      final routes = List<Map<String, dynamic>>.from(data['routes']);
      
      // Find route matching from and to places
      final fromName = widget.fromPlace!['name'];
      final toName = widget.toPlace!['name'];
      
      for (var route in routes) {
        if ((route['start'] == fromName && route['end'] == toName) ||
            (route['start'] == toName && route['end'] == fromName)) {
          setState(() {
            _routeData = Map<String, dynamic>.from(route);
          });
          break;
        }
      }
      
      // If no exact route found, use the first route for demo
      if (_routeData == null && routes.isNotEmpty) {
        setState(() {
          _routeData = Map<String, dynamic>.from(routes[0]);
        });
      }
      
      _createMarkersAndPolyline();
    } catch (e) {
      print("Error loading route data: $e");
    }
  }

  void _createMarkersAndPolyline() {
    if (_routeData == null) return;
    
    final stops = List<Map<String, dynamic>>.from(_routeData!['stops']);
    final List<LatLng> polylinePoints = [];
    
    // Add markers for each stop
    for (var i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final marker = Marker(
        markerId: MarkerId('stop_$i'),
        position: LatLng(stop['latitude'], stop['longitude']),
        infoWindow: InfoWindow(
          title: stop['name'],
          snippet: i == 0 ? 'Start' : i == stops.length - 1 ? 'End' : 'Stop',
        ),
        icon: i == 0 || i == stops.length - 1 
            ? BitmapDescriptor.defaultMarkerWithHue(
                i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      _markers.add(marker); // Add marker to the Set
      polylinePoints.add(LatLng(stop['latitude'], stop['longitude']));
    }
    
    // Start polyline animation
    _startPolylineAnimation(polylinePoints);
    _centerMapOnRoute(polylinePoints); // Center the map on the route
  }

  void _startPolylineAnimation(List<LatLng> points) {
    _animator.animatePolyline(
      points,
      'polyline_id',
      Colors.blue,
      const Color.fromARGB(255, 164, 207, 240),
      _polylines,
      () {
        setState(() {});
      },
    );
  }

  void _centerMapOnRoute(List<LatLng> routeCoordinates) {
    if (routeCoordinates.isNotEmpty) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          routeCoordinates.map((latLng) => latLng.latitude).reduce((a, b) => a < b ? a : b),
          routeCoordinates.map((latLng) => latLng.longitude).reduce((a, b) => a < b ? a : b),
        ),
        northeast: LatLng(
          routeCoordinates.map((latLng) => latLng.latitude).reduce((a, b) => a > b ? a : b),
          routeCoordinates.map((latLng) => latLng.longitude).reduce((a, b) => a > b ? a : b),
        ),
      );

      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50)); // Adjust padding as needed
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;
    
    for (final latLng in list) {
      if (minLat == null || latLng.latitude < minLat) minLat = latLng.latitude;
      if (maxLat == null || latLng.latitude > maxLat) maxLat = latLng.latitude;
      if (minLng == null || latLng.longitude < minLng) minLng = latLng.longitude;
      if (maxLng == null || latLng.longitude > maxLng) maxLng = latLng.longitude;
    }
    
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_routeData != null) {
      _createMarkersAndPolyline();
    }
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: false,
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue, Colors.pink], // Gradient from blue to pink
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent.withOpacity(0.2),
      elevation: 1,
      title: const Text(
        'Map', // Changed title to "Map"
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.map,color: Colors.white),
          onPressed: _onMapTypeButtonPressed, // Keep the existing action
        ),
      ],
    ),
  ),
),
      body: Column(
        children: [
          
          // Map Container
          Container(
            
            height: 500, // Set a fixed height for the map
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              markers: _markers, // Use the Set of markers
              polylines: _polylines.values.toSet(),
              initialCameraPosition: const CameraPosition(
                target: LatLng(18.5308, 73.8473), // Default to Shivaji Nagar
                zoom: 14,
              ),
              mapType: _currentMapType, // Set the map type here
            ),
          ),
          
          // Card for route details
          if (_routeData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Route ${_routeData!['route_number']}: ${_routeData!['route_name']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Distance: ${_routeData!['total_distance']} km',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Estimated Time: ${_routeData!['estimated_time']} minutes',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Fare: ₹${_routeData!['total_fare']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Frequency: Every ${_routeData!['frequency']} minutes',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Operating Hours: ${_routeData!['start_time']} - ${_routeData!['end_time']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}