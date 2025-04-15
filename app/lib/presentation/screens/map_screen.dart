import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  static const initialCameraPosition = CameraPosition(
    target: LatLng(41.3858,  2.0757300),
    zoom: 16
  );

  late GoogleMapController _googleMapController;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
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
          GoogleMap(
            myLocationButtonEnabled: true,
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
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

  Widget centerCamera() {
    return FloatingActionButton(
      backgroundColor: Color.fromARGB(255, 206, 179, 254),
      foregroundColor: Colors.black,
      onPressed: () => _googleMapController.animateCamera(
        // esto se deberia cambiar por la location del user
        CameraUpdate.newCameraPosition(initialCameraPosition),
      ),
      child: const Icon(Icons.center_focus_strong),
    );
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