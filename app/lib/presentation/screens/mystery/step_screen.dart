import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class StepScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String mysteryId;

  const StepScreen({
    super.key,  
    required this.presentationController,
    required this.mysteryId
  });

  @override
  State<StepScreen> createState() => _StepScreenState(presentationController);
}

class _StepScreenState extends State<StepScreen> {
  late PresentationController _presentationController;

  _StepScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  late Future<String> _mysteryIntroduction;

  @override
  void initState() {
    super.initState();
    _mysteryIntroduction = _presentationController.getIntroduction(widget.mysteryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      appBar: AppBar(title: Text('introduction'.tr())),
      body: Column (
        children: [
          SizedBox(height: 16),
          FutureBuilder<String>(
            future: _mysteryIntroduction,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('error_introduction'.tr());
              }
              return Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Text(
                  snapshot.data!, 
                  style: TextStyle(fontSize: 18),
                )
              );
            },
          ),
          SizedBox(height: 16),
          Text(
            'go_to_location'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            )
          ),
          SizedBox(height: 16),
          goToMap()
        ]
      ),
    );
  }

  Widget goToMap(){
    return ElevatedButton(
      onPressed: () {
        _presentationController.startedRouteScreen(context, "NWjKzu7Amz2AXJLZijQL");
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 206, 179, 254),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text('go_map'.tr()),
    );
  }

}
