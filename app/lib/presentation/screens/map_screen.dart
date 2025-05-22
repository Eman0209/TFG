import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';
import 'package:app/presentation/widgets/custom_google_map.dart';

class MapPage extends StatefulWidget {
  final PresentationController presentationController;

  const MapPage({super.key, required this.presentationController});

  @override
  State<MapPage> createState() => _MapPageState(presentationController);
}

class _MapPageState extends State<MapPage> {
  late PresentationController _presentationController;
  int _selectedIndex = 0;

  _MapPageState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  final Location _locationController = Location();
  LatLng? currentP; 

  final Set<Polyline> _polylines = {};

  //Map<PolylineId, Polyline> polylines = {};

  LatLng? _selectedPoint;
  bool _showButtons = false;

  @override
  void initState(){
    super.initState();
    getLocationUpdates();/*.then(
      (_) => {
        getPolylinePoints().then((coordinates) => {
          print(coordinates),
          generatePolylineFromPoints(coordinates)
        }),
      }
    );*/
    _setPolyline();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
      body: Stack( 
        children: [ 
          currentP == null 
          ? Center(
              child: Text('carrega'.tr(),)
            )
          : maps(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: searchWidget(context)
                ),
              ],
            ),
          ),
          Positioned(
            top: 110,
            right: 20,
            child: centerCamera()
          ),
          if (_showButtons) 
            Positioned(
              bottom: 10, 
              left: 20,
              right: 60,
              child: startAndInfoButtonsWidget()
            ),
        ]  
      ),
    );
  }

  Widget maps() {
    return CustomGoogleMap(
      currentPosition: currentP!,
      polylines: _polylines,
      mapControllerCompleter: _mapController,
      onPolylineTap: (tapped, selected) {
        setState(() {
          _selectedPoint = selected;
          _showButtons = selected != null;
        });
      },
    );
  }

  // Pensar si al final final lo implemento
  Widget searchWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  Future<void> cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos, 
      zoom: 16
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }
  
  Widget centerCamera() {
    return FloatingActionButton(
      backgroundColor: Color.fromARGB(255, 206, 179, 254),
      foregroundColor: Colors.black,
      onPressed: () async {
        if (currentP == null) {
          Center(
            child: Text('carrega'.tr()),
          );
        }
        final controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: currentP!,
              zoom: 16
            )
          ),
        );
      },
      child: const Icon(Icons.center_focus_strong),
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
          //cameraToPosition(currentP!);
        });
      }
    });
  }
  
  /*
  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> routePoints = await _presentationController.getRoutesPoints();

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
      googleApiKey: "",
      request: request,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      );
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;

  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly"); //might have diferent id for each polyline
    Polyline polyline = Polyline(
      polylineId: id, 
      color: Colors.deepPurple, 
      points: polylineCoordinates,
      width: 8
    );
    setState(() {
      polylines[id] = polyline;
    });
  }*/

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

  Widget startAndInfoButtonsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () async {
            String routeId = await _presentationController.getRouteId();
            String mysteryId = await _presentationController.getMysteryId(routeId);
            final isStarted = await _presentationController.isRouteStarted(routeId);
            final isFinished = await _presentationController.isRouteDone(routeId);
            
            if (isStarted) {
              // Show popup
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('route_started'.tr()),
                    content: Text('route_started_explanation'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
              _presentationController.mysteryScreen(context, routeId, mysteryId);
            } else if(isFinished) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('route_completed'.tr()),
                  content: Text('route_completed_explanation'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } else {     
              _presentationController.introductionScreen(context, mysteryId, routeId);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 206, 179, 254),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text('start'.tr()),
        ),
        ElevatedButton(
          onPressed: () async {
            String routeId = await _presentationController.getRouteId();
            _presentationController.infoRoute(context, false, routeId);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 206, 179, 254),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text('info'.tr()),
        ),
      ],
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  
    switch (index) {
      case 0:
        //_presentationController.mapScreen(context);
        break;
      case 1:
          _presentationController.doneRoutesScreen(context);
        break;
      case 2:
         _presentationController.meScreen(context);
        break;
      default:
        break;
    }
  }
}