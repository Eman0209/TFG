import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class IntroScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String mysteryId;
  final String routeId;

  const IntroScreen({
    super.key,  
    required this.presentationController,
    required this.mysteryId,
    required this.routeId
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState(presentationController);
}

class _IntroScreenState extends State<IntroScreen> {
  late PresentationController _presentationController;

  _IntroScreenState(PresentationController presentationController) {
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
      body: Center (
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _mysteryIntroduction,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('error_introduction'.tr());
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    snapshot.data!, 
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'go_to_location'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            goToMap()
          ]
        ),
      )
    );
  }

  Widget goToMap(){
    return ElevatedButton(
      onPressed: () async {
        _presentationController.addStardtedRoute(context, widget.routeId);
        _presentationController.startedRouteScreen(context, widget.routeId);
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
