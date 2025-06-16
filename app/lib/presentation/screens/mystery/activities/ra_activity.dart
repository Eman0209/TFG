import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:easy_localization/easy_localization.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/screens/mystery/time_service.dart';

class ArCoreScreen extends StatefulWidget {
  final PresentationController presentationController;
  final String routeId;
  final String mysteryId;
  final int stepOrder;
  
  const ArCoreScreen({
    super.key,
    required this.presentationController,
    required this.routeId,
    required this.mysteryId,
    required this.stepOrder
  });

  @override
  State<ArCoreScreen> createState() => _ArCoreScreenState(presentationController);
}

class _ArCoreScreenState extends State<ArCoreScreen> {
  late PresentationController _presentationController;

  _ArCoreScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  final TimerService _timerService = TimerService();

  late ArCoreController arCoreController;

  bool showButton = false;
  bool _showAr = true;
  bool _disposed = false;

  final List<String> correctOrder = [
    "red_sphere",
    "green_sphere",
    "blue_sphere",
    "yellow_sphere",
    "purple_sphere",
    "orange_sphere"
  ];

  final List<String> tappedOrder = [];
  final Map<String, Vector3> nodePositions = {};

  @override
  void initState() {
    super.initState();
    checkArCoreAvailability();
    _timerService.start();
  }

  void checkArCoreAvailability() async {
    bool arCoreAvailable = await ArCoreController.checkArCoreAvailability();
    bool arServicesInstalled = await ArCoreController.checkIsArCoreInstalled();

    if (!arCoreAvailable || !arServicesInstalled) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('arcore_no_available'.tr()),
          content: Text('arcore_error'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ok'.tr()),
            )
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    safeDisposeAR();
    super.dispose();
  }

  void safeDisposeAR() {
    if (!_disposed) {
      _disposed = true;
      try {
        arCoreController.dispose();
      } catch (e) {
        debugPrint("Error disposing ARCore: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        safeDisposeAR();
        return true;
      },
      child: Scaffold(
      body: Stack(
        children: [
          if (_showAr)
            ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
              enablePlaneRenderer: true,
            ),
          if (showButton)
            Positioned(
              bottom: 50,
              left: 50,
              right: 50,
              child: ElevatedButton(
                onPressed: () async {
                  _presentationController.addDoneStep(widget.mysteryId, widget.stepOrder-1);
                  await _timerService.persistElapsedTime(_presentationController, widget.routeId);
                  String nextStep = await _presentationController.getNextstep(widget.mysteryId, widget.stepOrder-1);
                  finalPopUp(nextStep);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 206, 179, 254),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                ),
                child: Text('get_info'.tr()),
              ),
            ),
        ]
      )
    ));
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addSpheres();
    arCoreController.onNodeTap = _handleNodeTap;
  }

  Future<void> _addSpheres () async {
    final material = ArCoreMaterial(color: Colors.red);
    final sphere = ArCoreSphere(materials: [material], radius: 0.05);
    final node = ArCoreNode(
      name: "red_sphere",
      shape: sphere,
      position: Vector3(0, 1, -1.5),
    );
    nodePositions["red_sphere"] = Vector3(0, 1, -1.5);

    final material2 = ArCoreMaterial(color: Colors.green);
    final sphere2 = ArCoreSphere(materials: [material2], radius: 0.05);
    final node2 = ArCoreNode(
      name: "green_sphere", 
      shape: sphere2,
      position: Vector3(0.5, 0.5, -1.5),
    );
    nodePositions["green_sphere"] = Vector3(0.5, 0.5, -1.5);

    final material3 = ArCoreMaterial(color: Colors.blue);
    final sphere3 = ArCoreSphere(materials: [material3], radius: 0.05);
    final node3 = ArCoreNode(
      name: "blue_sphere",
      shape: sphere3,
      position: Vector3(-0.5, -1, -1.5),
    );
    nodePositions["blue_sphere"] = Vector3(-0.5, -1, -1.5);

    final node4 = ArCoreNode(
      name: "yellow_sphere",
      shape: ArCoreSphere(materials: [ArCoreMaterial(color: Colors.yellow)], radius: 0.05),
      position: Vector3(1.5, 0.5, -2.0),
    );
    nodePositions["yellow_sphere"] = Vector3(1.5, 0.5, -2.0);

    final node5 = ArCoreNode(
      name: "purple_sphere",
      shape: ArCoreSphere(materials: [ArCoreMaterial(color: Colors.purple)], radius: 0.05),
      position: Vector3(-1.5, -0.2, -2.5),
    );
    nodePositions["purple_sphere"] = Vector3(-1.5, -0.2, -2.5);

    final node6 = ArCoreNode(
      name: "orange_sphere",
      shape: ArCoreSphere(materials: [ArCoreMaterial(color: Colors.orange)], radius: 0.05),
      position: Vector3(0.0, 1.2, -3.0),
    );
    nodePositions["orange_sphere"] = Vector3(0.0, 1.2, -3.0);

    await arCoreController.addArCoreNode(node);
    await arCoreController.addArCoreNode(node2);
    await arCoreController.addArCoreNode(node3);
    await arCoreController.addArCoreNode(node4);
    await arCoreController.addArCoreNode(node5);
    await arCoreController.addArCoreNode(node6);
  }

  void _handleNodeTap(String nodeName) async {
    if (tappedOrder.contains(nodeName)) return;

    final expectedNode = correctOrder[tappedOrder.length];

    if (nodeName != expectedNode) {
      final expectedPosition = correctOrder.indexOf(nodeName) + 1;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('incorrect_order'.tr()),
          content: RichText (
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(text: 'sphere_number'.tr()),
                TextSpan(
                  text: "$expectedPosition",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'sphere_phrase'.tr()),
              ] 
            ),
          ),
          actions: [
            TextButton(
              onPressed: () { 
                Navigator.of(context).pop();
                resetGame();
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 179, 254),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('ok'.tr()),
            ),
          ],
        ),
      );
      return;
    }

    tappedOrder.add(nodeName);

    final position = nodePositions[nodeName] ?? Vector3.zero();
    final grayMaterial = ArCoreMaterial(color: Colors.grey);
    final newSphere = ArCoreSphere(materials: [grayMaterial], radius: 0.05);

    final updatedNode = ArCoreNode(
      name: nodeName,
      shape: newSphere,
      position: position,
    );

    await arCoreController.removeNode(nodeName: nodeName);
    await arCoreController.addArCoreNode(updatedNode);
    
    if (tappedOrder.length == correctOrder.length) {
      setState(() {
        showButton = true;
      });
    }
  }

  Future<void> resetGame() async {
    tappedOrder.clear();
    showButton = false;

    for (final name in correctOrder) {
      await arCoreController.removeNode(nodeName: name);
      await arCoreController.removeNode(nodeName: '${name}_sphere');
    }

    await _addSpheres();
    
    setState(() {});
  }

  void finalPopUp(String nextStep) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('completed_enigma'.tr()),
          content: Text(nextStep),
          actions: [
            TextButton(
              onPressed: () {
                safeDisposeAR();
                Navigator.of(context).pop();
                _presentationController.mysteryScreen(context, widget.routeId, widget.mysteryId);
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 206, 179, 254),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('continue'.tr()),
            ),
          ],
        );
      },
    );
  }
  
}
