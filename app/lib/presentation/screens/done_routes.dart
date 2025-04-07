import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class DonePage extends StatefulWidget {
  final PresentationController presentation_controller;

  const DonePage({Key? key, required this.presentation_controller});

  @override
  State<DonePage> createState() => _DonePageState(presentation_controller);
}

class _DonePageState extends State<DonePage> {
  late PresentationController _presentationController;

  _DonePageState(PresentationController presentation_controller) {
    _presentationController = presentation_controller;
  }

  @override
  Widget build(BuildContext context) {
    return Text('done routes');
  }
}