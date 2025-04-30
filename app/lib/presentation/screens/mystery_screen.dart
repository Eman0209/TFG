import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/custom_appbar.dart';

class MysteryScreen extends StatefulWidget {
  final PresentationController presentationController;

  const MysteryScreen({Key? key, required this.presentationController});

  @override
  State<MysteryScreen> createState() => _MysteryScreenState(presentationController);
}

class _MysteryScreenState extends State<MysteryScreen> {
  late PresentationController _presentationController;
  int _selectedIndex = 1;

  _MysteryScreenState(PresentationController presentationController) {
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
      body: Text("Mistery screen")
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  
    switch (index) {
      case 0:
        _presentationController.startRoute(context, "NWjKzu7Amz2AXJLZijQL");
        break;
      case 1:
        //_presentationController.misteriScreen(context);
        break;
      default:
        break;
    }
  }
}
