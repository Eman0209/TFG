import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';

class DonePage extends StatefulWidget {
  final PresentationController presentationController;

  const DonePage({super.key, required this.presentationController});

  @override
  State<DonePage> createState() => _DonePageState(presentationController);
}

class _DonePageState extends State<DonePage> {
  late PresentationController _presentationController;
  int _selectedIndex = 1;

  _DonePageState(PresentationController presentationController) {
    _presentationController = presentationController;
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
          Text("Done Routes Screen",
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