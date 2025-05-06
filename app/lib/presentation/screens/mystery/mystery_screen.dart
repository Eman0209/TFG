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

  @override
  void initState() {
    super.initState();
    _routeTitle = _presentationController.getMysteryTitle(widget.routeId);
    _stepsFuture = _presentationController.getCompletedSteps(widget.mysteryId);
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
          FutureBuilder<String>(
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
          ),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9, 
            child: Divider(
              thickness: 2,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
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
            ),
          )
        ]
      ),
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
