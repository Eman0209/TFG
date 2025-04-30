import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/custom_appbar.dart';

class RouteScreen extends StatefulWidget {
  final PresentationController presentationController;

  const RouteScreen({Key? key, required this.presentationController});

  @override
  State<RouteScreen> createState() => _RouteScreenState(presentationController);
}

class _RouteScreenState extends State<RouteScreen> {
  late PresentationController _presentationController;
  int _selectedIndex = 0;

  _RouteScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
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
      body: Text("Map screen")
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  
    switch (index) {
      case 0:
        //_presentationController.startRoute(context, "NWjKzu7Amz2AXJLZijQL");
        break;
      case 1:
        _presentationController.misteriScreen(context);
        break;
      default:
        break;
    }
  }
}
