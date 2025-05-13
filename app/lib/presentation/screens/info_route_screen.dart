import 'package:app/domain/models/routes.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class RouteInfoScreen extends StatefulWidget {
  final PresentationController presentationController;
  final bool fromCompletedScreen;
  final String routeId;

  const RouteInfoScreen({
    super.key,
    required this.presentationController,
    required this.routeId,
    required this.fromCompletedScreen,
  });

  @override
  State<RouteInfoScreen> createState() => _RouteInfoScreenState(presentationController, routeId, fromCompletedScreen);
}

class _RouteInfoScreenState extends State<RouteInfoScreen> {
  late PresentationController _presentationController;
  late String routeId;
  late bool fromCompletedScreen;

  _RouteInfoScreenState(PresentationController presentationController, String route, bool completed) {
    _presentationController = presentationController;
    routeId = route;
    fromCompletedScreen = completed;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RouteData?> (
      future: _presentationController.getRouteData(routeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(child: Text('route_not_found'.tr())),
          );
        }

        final route = snapshot.data!;
      
      return Scaffold( 
        backgroundColor: const Color(0xFFF8F4FF),
        appBar: _buildAppBar(context),
        body: _buildBody(route.name, route.description, route.duration, route.path),
        floatingActionButton: _buildFloatingButton(route.name),
      );
    });
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
        'info_route'.tr(),
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(String name, String description, int duration, List<String> path) {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: ListView(
              children: [
                _buildTextSection('name'.tr(), name),
                _buildTextSection('description'.tr(), description),
                if (fromCompletedScreen)
                  // Especificar lo de minutos o horas
                  _buildTextSection(
                    'finished_in'.tr(),
                    'finished_message'.tr(namedArgs: {'duration': duration.toString()})
                  )
                else
                  // Especificar lo de minutos o horas
                  _buildTextSection(
                    'time'.tr(),
                    'last_message'.tr(namedArgs: {'duration': duration.toString()})
                  ),
                _buildPath(path),
                const SizedBox(height: 40),
              ],
            ),
          );
  }

  Widget _buildTextSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
            )
          ),
        ],
      ),
    );
  }

  String formatLocation(String location) {
    return location.split(',').first;
  }

  Widget _buildPath(List<String> path) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'route'.tr() , 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          )
        ),
        const SizedBox(height: 8),
        for (int i = 0; i < path.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formatLocation(path[i]), 
                  style: const TextStyle(fontSize: 16),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              )
            ],
          ),
          if (i < path.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Icon(Icons.arrow_downward, size: 18),
            ),
        ],
      ],
    );
  }

  Widget _buildFloatingButton(String routeName) {
    if (fromCompletedScreen) {
      return FloatingActionButton(
        onPressed: () {
          //final shareText = 'I just completed the mystery route: $routeName! 🕵️‍♂️🔍 Try it out too!';
          String shareText = 'share_text'.tr(namedArgs: {'routeName': routeName});
          Share.share(shareText);
        },
        backgroundColor: const Color(0xFFECE3FF),
        child: const Icon(Icons.share),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: ElevatedButton(
          onPressed: () {
            // Modificar el string 
            _presentationController.stepScreen(context, "VZQmKDgsmyLp5oaKsICZ");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFECE3FF),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Text('start'.tr()),
          ),
        ),
      );
    }
  }

}