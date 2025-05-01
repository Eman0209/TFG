import 'dart:async';
import 'package:flutter/material.dart';
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
    Key? key, 
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

  final Set<Polyline> _polylines = {};

  @override
  void initState(){
    super.initState();
    getLocationUpdates();
    _setPolyline();
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
          // Si quiero añadir algun boton mas a la pantalla o algo añadir aqui
        ]
      )
    );
  }

  Widget maps() {
    return CustomGoogleMap(
      currentPosition: currentP!,
      polylines: _polylines,
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

   Future<void> _setPolyline() async {
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        points: await _presentationController.getRoutesPoints(),
        color: Colors.deepPurple,
        width: 5,
      ),
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  
    switch (index) {
      case 0:
        //_presentationController.startRoute(context, _routeId);
        break;
      case 1:
        _presentationController.misteriScreen(context, _routeId, "VZQmKDgsmyLp5oaKsICZ");
        break;
      default:
        break;
    }
  }

}
