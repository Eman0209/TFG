import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  final PresentationController presentationController;

  const MapPage({Key? key, required this.presentationController});

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

  @override
  void initState(){
    super.initState();
    getLocationUpdates();
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
          ? const Center(
              child: Text("Loading..."),
            )
          : GoogleMap(
            onMapCreated: ((GoogleMapController controller) => _mapController.complete(controller)),
            initialCameraPosition: CameraPosition( 
              target: currentP!,
              zoom: 16
            ),
            markers: {
              Marker(
                markerId: MarkerId("_currentLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: currentP!
              ),
            },
          ),
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
          hintText: 'Search routes...',
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
          const Center(
            child: Text("Loading..."),
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
          cameraToPosition(currentP!);
        });
      }
    });

  }

  Widget startAndInfoButtonsWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            // Your Start logic here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 206, 179, 254),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Start'),
        ),
        ElevatedButton(
          onPressed: () {
            // Your Info logic here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 206, 179, 254),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text('Info'),
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
        _presentationController.mapScreen(context);
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