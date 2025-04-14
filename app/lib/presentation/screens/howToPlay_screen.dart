import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class HowToPlayScreen extends StatefulWidget {
  final PresentationController presentationController;

  const HowToPlayScreen({Key? key, required this.presentationController});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState(presentationController);
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  late PresentationController _presentationController;

  _HowToPlayScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(title: const Text('How to Play')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              '1. Do this...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '2. Then do that...',
              style: TextStyle(fontSize: 16),
            ),
            // Add more steps, images, videos, etc.
          ],
        ),
      ),
    );
  }
}
