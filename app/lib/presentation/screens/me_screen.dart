import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';

class PerfilPage extends StatefulWidget {
  final PresentationController presentation_controller;

  const PerfilPage({Key? key, required this.presentation_controller});

  @override
  State<PerfilPage> createState() => _PerfilPageState(presentation_controller);
}

class _PerfilPageState extends State<PerfilPage> {
  late PresentationController _presentationController;
  int _selectedIndex = 2;

  _PerfilPageState(PresentationController presentation_controller) {
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
          Text("Mee Screen",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          SizedBox(height: 70)
          ]
      )
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