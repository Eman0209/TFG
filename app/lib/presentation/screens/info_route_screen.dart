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

        if (!fromCompletedScreen) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F4FF),
            appBar: _buildAppBar(context),
            body: _buildBody(route.name, route.description, Duration(seconds: route.duration), route.path),
            floatingActionButton: _buildFloatingButton(route.name),
          );
        }
      
        return FutureBuilder<Duration>(
          future: _presentationController.getRouteDuration(routeId),
          builder: (context, durationSnapshot) {
            if (durationSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final duration = durationSnapshot.data ?? Duration.zero;

            if (duration < Duration(minutes: 30)) {
              _presentationController.addUserTrophy("Pu52xSz71yaQtE3JquXs");
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF8F4FF),
              appBar: _buildAppBar(context),
              body: _buildBody(route.name, route.description, duration, route.path),
              floatingActionButton: _buildFloatingButton(route.name),
            );
          },
        );
      },
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
        'info_route'.tr(),
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
    );
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Widget _buildBody(String name, String description, Duration duration, List<String> path) {
    final formattedDuration = formatDuration(duration);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: ListView(
        children: [
          _buildTextSection('name'.tr(), name),
          _buildTextSection('description'.tr(), description),
          if (fromCompletedScreen)
            _buildTextSection(
              'finished_in'.tr(),
              'finished_message'.tr(namedArgs: {'duration': formattedDuration})
            )
          else
            _buildTextSection(
              'time'.tr(),
              'last_message'.tr(namedArgs: {'duration': formattedDuration})
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
          String shareText = 'share_text'.tr(namedArgs: {'routeName': routeName});
          Share.share(shareText);
        },
        backgroundColor: const Color.fromARGB(255, 206, 179, 254),
        child: const Icon(Icons.share),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: ElevatedButton(
          onPressed: () async {
            final isStarted = await _presentationController.isRouteStarted(routeId);
            final isFinished = await _presentationController.isRouteDone(routeId);
            String mysteryId = await _presentationController.getMysteryId(routeId);
            
            if (isStarted) {
              // Show popup
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('route_started'.tr()),
                    content: Text('route_started_explanation'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('ok'.tr()),
                      ),
                    ],
                  );
                },
              );
              _presentationController.mysteryScreen(context, routeId, mysteryId);
            } else if(isFinished) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('route_completed'.tr()),
                  content: Text('route_completed_explanation'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('ok'.tr()),
                    ),
                  ],
                ),
              );
            } else {     
              _presentationController.introductionScreen(context, mysteryId, routeId);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 206, 179, 254),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Text('start'.tr()),
          ),
        ),
      );
    }
  }

}