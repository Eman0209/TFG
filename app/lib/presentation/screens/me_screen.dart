import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class PerfilPage extends StatefulWidget {
  final PresentationController presentation_controller;

  const PerfilPage({Key? key, required this.presentation_controller});

  @override
  State<PerfilPage> createState() => _PerfilPageState(presentation_controller);
}

class _PerfilPageState extends State<PerfilPage> {
  late PresentationController _presentationController;

  _PerfilPageState(PresentationController presentation_controller) {
    _presentationController = presentation_controller;
  }

  @override
  Widget build(BuildContext context) {
    return Text('me');
  }
}