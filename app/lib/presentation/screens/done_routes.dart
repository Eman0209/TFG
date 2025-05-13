import 'package:app/domain/models/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';

class DonePage extends StatefulWidget {
  final PresentationController presentationController;

  const DonePage({super.key, required this.presentationController});

  @override
  State<DonePage> createState() => _DonePageState(presentationController);
}

class _DonePageState extends State<DonePage> {
  late PresentationController _presentationController;
  int _selectedIndex = 1;

  _DonePageState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  late Future<List<RouteData>> _doneRoutesFuture;

  bool _trophyGiven = false;

  @override
  void initState() {
    super.initState();
    _doneRoutesFuture = _presentationController.getUserDoneRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
      body: FutureBuilder<List<RouteData>>(
        future: _doneRoutesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading routes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No routes completed'));
          }

          final routes = snapshot.data!;

          if (routes.length >= 1 && routes.length <= 4 && !_trophyGiven) {
            _trophyGiven = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _presentationController.addUserTrophy("ET0rOLRFFZJlAJQhMbSa");
            });
          } else if (routes.length >= 5 && !_trophyGiven) {
            _trophyGiven = true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _presentationController.addUserTrophy("shdnjm4R4LeMPwBTZrvH");
            });
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: routes.length,
                  separatorBuilder: (_, __) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: 1,
                            color: Colors.grey, 
                          ),
                        ],
                      ),
                    ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(routes[index].name),
                      trailing: IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {
                          _presentationController.infoRoute(context, true, routes[index].id);
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
            ],
          );
        },
      )
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Text(
        'done_routes'.tr(),
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  
    switch (index) {
      case 0:
        _presentationController.mapScreen(context);
        break;
      case 1:
          _presentationController.doneRoutesScreen(context);
        break;
      case 2:
         _presentationController.meScreen(context);
        break;
      default:
        break;
    }
  }
}