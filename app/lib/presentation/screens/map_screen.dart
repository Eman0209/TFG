import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';

class MapPage extends StatefulWidget {
  final PresentationController presentation_controller;

  const MapPage({Key? key, required this.presentation_controller});

  @override
  State<MapPage> createState() => _MapPageState(presentation_controller);
}

class _MapPageState extends State<MapPage> {
  late PresentationController _presentationController;
  int _selectedIndex = 0;

  _MapPageState(PresentationController presentation_controller) {
    _presentationController = presentation_controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Map Screen",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            SizedBox(height: 70)
            ]
        ),
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