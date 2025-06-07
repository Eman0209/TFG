import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class HowToPlayScreen extends StatefulWidget {
  final PresentationController presentationController;

  const HowToPlayScreen({super.key, required this.presentationController});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(title: Text('howToPlay'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'how_to_play_1_title'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'how_to_play_1_body'.tr(),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            Text(
              'how_to_play_2_title'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'how_to_play_2_body'.tr(),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            Text(
              'how_to_play_3_title'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'how_to_play_3_body'.tr(),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            Text(
              'how_to_play_4_title'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'how_to_play_4_body'.tr(),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            Text(
              'how_to_play_5_title'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'how_to_play_5_body'.tr(),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),

            Text(
              'how_to_play_tips_title'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'how_to_play_tips_body'.tr(),
              style: TextStyle(fontSize: 16),
            ),
          ],
        )
      ),
    );
  }
}
