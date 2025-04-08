import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class MapPage extends StatefulWidget {
  final PresentationController presentation_controller;

  const MapPage({Key? key, required this.presentation_controller});

  @override
  State<MapPage> createState() => _MapPageState(presentation_controller);
}

class _MapPageState extends State<MapPage> {
  late PresentationController _presentationController;

  _MapPageState(PresentationController presentation_controller) {
    _presentationController = presentation_controller;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Map Screen",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        SizedBox(height: 70)
        ]
    );
  }
}