import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/domain/models/steps.dart';

class StepScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String mysteryId;
  final String routeId;
  final int stepOrder;

  const StepScreen({
    super.key,  
    required this.presentationController,
    required this.mysteryId,
    required this.routeId,
    required this.stepOrder,
  });

  @override
  State<StepScreen> createState() => _StepScreenState(presentationController);
}

class _StepScreenState extends State<StepScreen> {
  late PresentationController _presentationController;

  _StepScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StepData?>(
      future: _presentationController.getStepInfo(widget.mysteryId, widget.stepOrder),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('error_step'.tr()));
        }

        final step = snapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F4FF),
          appBar: _buildAppBar(context),
          body: buildStepContent(step),
          floatingActionButton: startGame(),
        );
      }
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'new_track'.tr(),
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
    );
  }

  Widget buildStepContent(StepData step) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'narration'.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            step.narration,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 24),
          Text(
            'instructions'.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            step.instructions,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget startGame() {
    return ElevatedButton(
      onPressed: () {
        _presentationController.activityScreen(context, widget.routeId, widget.mysteryId, widget.stepOrder+1);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 206, 179, 254),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text('start_game'.tr()),
    );
  }

}