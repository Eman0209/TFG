import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;


class SimpleArCoreView extends StatefulWidget {
  const SimpleArCoreView({super.key});

  @override
  State<SimpleArCoreView> createState() => _SimpleArCoreViewState();
}

class _SimpleArCoreViewState extends State<SimpleArCoreView> {
  late ArCoreController arCoreController;

  @override
  void initState() {
    super.initState();
    checkArCoreAvailability();
  }

  void checkArCoreAvailability() async {
    bool arCoreAvailable = await ArCoreController.checkArCoreAvailability();
    bool arServicesInstalled = await ArCoreController.checkIsArCoreInstalled();

    if (!arCoreAvailable || !arServicesInstalled) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('ARCore no disponible'),
          content: const Text('Este dispositivo no soporta AR o los servicios de ARCore no están instalados.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    final material = ArCoreMaterial(color: Colors.red);
    final sphere = ArCoreSphere(materials: [material], radius: 0.1);

    // Position the sphere 1.5 meters in front of the camera (on the z-axis)
    final node = ArCoreNode(
      shape: sphere,
      position: Vector3(0, 0, -1.5),
    );

    // Add the node right away, without any tap
    arCoreController.addArCoreNode(node);

    // Optional: still keep tap handler if you want
    arCoreController.onPlaneTap = _handleOnPlaneTap;
  }


  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;

    final material = ArCoreMaterial(color: Colors.blue);
    final sphere = ArCoreSphere(materials: [material], radius: 0.1);

    final node = ArCoreNode(
      shape: sphere,
      position: hit.pose.translation,
      rotation: hit.pose.rotation,
    );

    arCoreController.addArCoreNodeWithAnchor(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple ARCore Example')),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enablePlaneRenderer: true,
      ),
    );
  }
}
