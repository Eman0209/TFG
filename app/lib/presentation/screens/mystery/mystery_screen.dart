import 'package:app/domain/models/steps.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/custom_appbar.dart';

class MysteryScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  final String mysteryId;

  const MysteryScreen({
    super.key, 
    required this.presentationController,
    required this.routeId,
    required this.mysteryId,
  });

  @override
  State<MysteryScreen> createState() => _MysteryScreenState(presentationController, routeId, mysteryId);
}

class _MysteryScreenState extends State<MysteryScreen> {
  late PresentationController _presentationController;
  late String _routeId;
  int _selectedIndex = 1;

  _MysteryScreenState(PresentationController presentationController, String routeId, String mysteryId) {
    _presentationController = presentationController;
    _routeId = routeId;
  }

  late Future<List<StepData?>> _stepsFuture;
  late Future<String> _routeTitle;
  
  bool isFinished = false;
  late Future<int> _stepsLength;

  @override
  void initState() {
    super.initState();
    _routeTitle = _presentationController.getMysteryTitle(widget.routeId);
    _stepsFuture = _presentationController.getCompletedSteps(widget.mysteryId);
    _stepsLength = _presentationController.getLengthOfSteps(widget.mysteryId);
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          title(),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9, 
            child: Divider(
              thickness: 2,
              color: Colors.grey.shade400,
            ),
          ),
          steps(),
          const SizedBox(height: 8),
          if (isFinished) 
            finalizePopUp(),
          const SizedBox(height: 80),
        ]
      ),
    floatingActionButton: isFinished
      ?
        finalizeButton()
      : null
    );
  }

  Widget title() {
    return FutureBuilder<String>(
      future: _routeTitle,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('error_title'.tr());
        }
        return Text(
          snapshot.data!, 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center
        );
      },
    );
  }

  Widget steps() {
    return Expanded(
      child: FutureBuilder<List<StepData?>>(
        future: _stepsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('error_steps'.tr()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('mystery_not_started'.tr()));
          }

          final steps = snapshot.data!;

          return FutureBuilder<int>(
            future: _stepsLength,
            builder: (context, lengthSnapshot) {
              if (lengthSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (lengthSnapshot.hasError) {
                return Center(child: Text('error_length'.tr()));
              }

              final stepsLength = lengthSnapshot.data ?? 0;

              if (!isFinished && steps.length >= stepsLength) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    isFinished = true;
                  });
                });
              }
              
              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: steps.length,
                separatorBuilder: (_, __) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [        
                        Column(
                          children: [
                            Icon(Icons.check_circle, color: Colors.black),
                            if (index != steps.length - 1)
                              Expanded(
                                child: Container(width: 2, color: Colors.grey.shade400),
                              ),
                          ],
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step!.title, 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16
                                )
                              ),
                              SizedBox(height: 4),
                              Text(
                                step.resum, 
                                style: TextStyle(color: Colors.grey[700])
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget finalizePopUp() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column (
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row (
            children: [
              Icon(
                Icons.sentiment_satisfied_alt,
                color: Colors.deepPurple
              ),
              SizedBox(width: 12),
              Text(
                'finished'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepPurple,
                ),
              ),
            ]
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
              child:
                Text('finished_congrats'.tr()),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _presentationController.addDoneRoute(context, widget.routeId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 206, 179, 254),
            ),
            child: Text('close_route'.tr()),                   
          )
        ],
      ),
    );
  }

  Widget finalizeButton() {
    return ElevatedButton(
      onPressed: () {
        // afegir funcio que canvii a una nova pista 
        
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 206, 179, 254),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text('start_new_track'.tr()),
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  
    switch (index) {
      case 0:
        _presentationController.startedRouteScreen(context, _routeId);
        break;
      case 1:
        //_presentationController.misteriScreen(context, _routeId, "VZQmKDgsmyLp5oaKsICZ");
        break;
      default:
        break;
    }
  }

}
