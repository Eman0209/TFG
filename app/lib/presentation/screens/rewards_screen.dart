import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class RewardsScreen extends StatefulWidget {
  final PresentationController presentationController;

  const RewardsScreen({Key? key, required this.presentationController});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState(presentationController);
}

class _RewardsScreenState extends State<RewardsScreen> {
  late PresentationController _presentationController;

  _RewardsScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(title: const Text('Rewards')),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Rewards Screen",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            SizedBox(height: 70)
            ]
        ),
    );
  }

}