import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/screens/mystery/time_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FinalScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  final String mysteryId;
  final int stepOrder;
  
  const FinalScreen({
    super.key,
    required this.presentationController,
    required this.routeId,
    required this.mysteryId,
    required this.stepOrder,
  });

  @override
  State<FinalScreen> createState() => _FinalScreenState(presentationController);
}

class _FinalScreenState extends State<FinalScreen> {
  late PresentationController _presentationController;

  _FinalScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  final TimerService _timerService = TimerService();

  late Future<List<String>> _optionsFuture;

  @override
  void initState() {
    super.initState();
    _timerService.start();
    _optionsFuture = _loadOptions();
  }

  Future<List<String>> _loadOptions() async {
    String nextStep = await _presentationController.getNextstep(
      widget.mysteryId,
      widget.stepOrder - 1,
    );

    return nextStep.split('~');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<String>>(
        future: _optionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.length != 2) {
            return Center(child: Text('error_options'.tr()));
          }

          final options = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('decide_option'.tr(), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _showPopup(options[0]),
                  child: Text('decision_1'.tr(), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () { 
                    _presentationController.addUserTrophy("gkfgRiFCNPHANMyLYOZD");
                    _showPopup(options[1]);
                  },
                  child: Text('decision_2'.tr(), textAlign: TextAlign.center),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPopup(String selectedOption) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(selectedOption),
        actions: [
          TextButton(
            onPressed: () async {
              await _presentationController.addDoneStep(widget.mysteryId, widget.stepOrder-1);
              await _timerService.persistElapsedTime(_presentationController, widget.routeId);
              _presentationController.mysteryScreen(context, widget.routeId, widget.mysteryId);
            },
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }
  
}