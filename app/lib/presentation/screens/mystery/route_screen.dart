import 'dart:async';
import 'package:app/consts.dart';
import 'package:app/presentation/screens/mystery/time_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/custom_appbar.dart';
import 'package:app/presentation/widgets/custom_google_map.dart';

class RouteScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  
  const RouteScreen({
    super.key, 
    required this.presentationController,
    required this.routeId
  });

  @override
  State<RouteScreen> createState() => _RouteScreenState(presentationController, routeId);
}

class _RouteScreenState extends State<RouteScreen> {
  late PresentationController _presentationController;
  late String _routeId;
  int _selectedIndex = 0;

  _RouteScreenState(PresentationController presentationController, String routeId) {
    _presentationController = presentationController;
    _routeId = routeId;
  }

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final Location _locationController = Location();
  LatLng? currentP; 

  Map<PolylineId, Polyline> polylines = {};

  bool _showAlert = false;

  final TimerService _timerService = TimerService();

  @override
  void initState(){
    super.initState();
    getLocationUpdates().then(
      (_) => {
        getPolylinePoints().then((coordinates) => {
          generatePolylineFromPoints(coordinates)
        }),
      }
    );
    _timerService.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopNavigationBar(
        onTabChange: (index) {
          _onTabChange(index);
        },
        selectedIndex: _selectedIndex,
      ),
      body: Stack( 
        children: [ 
          currentP == null 
          ? Center(
              child: Text('carrega'.tr(),)
            )
          : maps(),
          if (_showAlert) alertPopUp()
        ]
      )
    );
  }

  Widget maps() {
    return CustomGoogleMap(
      currentPosition: currentP!,
      polylines: Set<Polyline>.of(polylines.values),
      mapControllerCompleter: _mapController,
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      } 
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        setState(() {
          currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          checkProximity(currentLocation.latitude!, currentLocation.longitude!);
          cameraToPosition(currentP!);
        });
      }
    });
  }

  Future<void> cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos, 
      zoom: 16
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> routePoints = await _presentationController.getRoutesPoints(context);

    final request = PolylineRequest(
      origin: routePoints.first,
      destination: routePoints.last,
      mode: TravelMode.walking,
      wayPoints: routePoints
          .sublist(1, routePoints.length - 1)
          .map((point) => PolylineWayPoint(location: '${point.latitude},${point.longitude}'))
          .toList(),
    );
    
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: request,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
    } else {
      debugPrint(result.errorMessage);
    }
    return polylineCoordinates;

  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly"); 
    Polyline polyline = Polyline(
      polylineId: id, 
      color: Colors.deepPurple, 
      points: polylineCoordinates,
      width: 8
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<double> calculateDistance(double lat1, double lon1, double lat2, double lon2) async {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<void> checkProximity(double userLat, double userLon) async {
    List<LatLng> waypoints = [];
    for (var polyline in Set<Polyline>.of(polylines.values)) {
      waypoints.addAll(polyline.points);
    }

    for (var waypoint in waypoints) {
      double distance = await calculateDistance(userLat, userLon, waypoint.latitude, waypoint.longitude);
      
      if (distance <= 50.0) {
        setState(() {
          _showAlert = true;
        });
        break;
      }
    }
  }

  Widget alertPopUp() {
    return Positioned(
      top: 120,
      left: 24,
      right: 24,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepPurple[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade400,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_active_outlined,
              color: Colors.deepPurple),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'alert'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('close_track'.tr()),
                  SizedBox(height: 8),
                  Text('go_mystery_screent'.tr()),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      String mysteryId = await _presentationController.getMysteryId(_routeId);
                      await _timerService.persistElapsedTime(_presentationController, _routeId);
                      _presentationController.mysteryScreen(context, _routeId, mysteryId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 206, 179, 254),
                    ),
                    child: Text('follow_track'.tr()),                   
                  )
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showAlert = false;
                });
              },
            )
          ]
        )
      )
    );
  }

  Future<void> _onTabChange(int index) async {
    setState(() {
      _selectedIndex = index;
    });
  
    switch (index) {
      case 0:
        //_presentationController.startRoute(context, _routeId);
        break;
      case 1:
        String mysteryId = await _presentationController.getMysteryId(_routeId);
        await _timerService.persistElapsedTime(_presentationController, _routeId);
        _presentationController.mysteryScreen(context, _routeId, mysteryId);
        break;
      default:
        break;
    }
  }

}
