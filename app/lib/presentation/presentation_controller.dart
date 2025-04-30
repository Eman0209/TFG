import 'package:app/data/datasources/rewards_datasource.dart';
import 'package:app/data/datasources/routes_datasource.dart';
import 'package:app/data/datasources/user_datasource.dart';
import 'package:app/presentation/screens/mystery_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/presentation/screens/map_screen.dart';
import 'package:app/presentation/screens/me_screen.dart';
import 'package:app/presentation/screens/done_routes.dart';
import 'package:app/presentation/screens/signup.dart';
import 'package:app/presentation/screens/edit_user_screen.dart';
import 'package:app/presentation/screens/rewards_screen.dart';
import 'package:app/presentation/screens/how_to_play_screen.dart';
import 'package:app/presentation/screens/info_route_screen.dart';
import 'package:app/presentation/screens/route_screen.dart';
import 'package:app/domain/models/routes.dart';
import 'package:app/domain/controllers/user_controller.dart';
import 'package:app/domain/controllers/routes_controller.dart';
import 'package:app/domain/controllers/rewards_controller.dart';


// Functions to see the screens
class PresentationController {
  
  late final FirebaseRoutesDatasource routesDatasource;
  late final RoutesController routesController;
  late final FirebaseUserDatasource userDatasource;
  late final UserController userController;
  late final FirebaseRewardsDatasource rewardsDatasource;
  late final RewardsController rewardsController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  late List<RouteData> routesUser;
  late final List<Widget> _pages = [];

  late Locale? _language = const Locale('en');
  Locale? get language => _language;

  final Logger _logger = Logger('PresentationController');

  PresentationController() {
    final firestore = FirebaseFirestore.instance;

    routesDatasource = FirebaseRoutesDatasource(firestore);
    routesController = RoutesController(routesDatasource);

    userDatasource = FirebaseUserDatasource( 
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
    userController = UserController(userDatasource);

    rewardsDatasource = FirebaseRewardsDatasource(firestore);
    rewardsController = RewardsController(rewardsDatasource);
  }

  Future<void> initialice() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = currentUser;
    }

    // esto sera para pillar las rutas hechas de los users
    if (userLogged()) {
      //routesUser = await controladorDomini.getUserRoutes(_user!.uid);
    }

    _pages.addAll([
      MapPage(presentationController: this),
      DonePage(presentationController: this),
      PerfilPage(presentationController: this),
    ]);
  }

  bool userLogged() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = currentUser;
      return true;
    } else {
      return false;
    }
  }

  FirebaseAuth getFirebaseAuth() {
    return _auth;
  }

  void setUser(User? event) async {
    _user = event;
  }

  User? getUser() {
    return _user;
  }

  void createUser(String username, BuildContext context) async {
    userController.createUser(_user, username);
    mapScreen(context);
    //una vez creado el user que quiero hacer? Mostrar el mapa?
  }

  void editUsername(String username, BuildContext context) async {
    userController.editUsername(_user, username);
    meScreen(context);
  }

  void checkLoggedInUser(BuildContext context) {
    // Obtains the identified user at the moment if it exists
    User? currentUser = _auth.currentUser;
  
    // If the user exists, put it in _user and go to mapScreen
    if (currentUser != null) {
      _user = currentUser;
      mapScreen(context);
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithProvider(googleAuthProvider);
      bool userExists = await userController.accountExists(userCredential.user);
      _user = userCredential.user;
      // If there is no user of the google account, move to a signup screen
      if (!userExists) {
        mostrarSignup(context);
      }
      // Otherwise move to map screen
      else {
        mapScreen(context);
      }
    } catch (error) {
      //buscar si esto lo puedo cambiar por un log o algos
      _logger.severe('An error occurred: $error');
    }
  }

  /*
  // Quiero obligar a que el username sea unique?
  Future<bool> usernameUnique(String username) {
    return userController.usernameUnique(username);
  }
  */

  void changeLanguage(Locale? lang, BuildContext context) async {
    _language = lang;
    context.setLocale(lang!);
   _loadLanguage();
  }

  // Es necesario guardar el language en el controlador?
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _language = Locale(languageCode);
    }
  }

  Future<List<Map<String, dynamic>>> getTrophies() async {
    return rewardsController.fetchTrophies();
  }

  Future<List<RouteData?>> getAllRoutesData() async {
    return routesController.fetchAllRoutesData();
  }

  Future<RouteData?> getRouteData(String routeId) async {
    return routesController.fetchRouteData(routeId);
  }

  /*
  Future<List<PointLatLng>> getRoutesPoints() async {
    List<RouteData?> routes = await getAllRoutesData();

    List<String> addresses = routes
      .where((route) => route != null)
      .expand((route) => route!.path)
      .toList();

    List<LatLng> directions = await routesController.getRouteCoordinatesFromNames(addresses);
    
    List<PointLatLng> points = directions
      .map((loc) => PointLatLng(loc.latitude, loc.longitude))
      .toList();

    return points;

    // Convertir direcciones a coordenadas
    //List<LatLng> directions = await routesController.getRouteCoordinatesFromNames(addresses);

    //return directions;
  }
  */
  Future<List<LatLng>> getRoutesPoints() async {
    List<RouteData?> routes = await getAllRoutesData();

    List<String> addresses = routes
      .where((route) => route != null)
      .expand((route) => route!.path)
      .toList();

    // Convertir direcciones a coordenadas
    List<LatLng> directions = await routesController.getRouteCoordinatesFromNames(addresses);

    return directions;
  }

  /* ------------------------------ Screens ------------------------------ */
  
  // Move to the signup screen
  void mostrarSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Signup(presentationController: this),
      ),
    );
  }

  // Move to the map screen
  void mapScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapPage(presentationController: this),
      ),
    );
  }

  // Move to the information screen
  void infoRoute(BuildContext context, bool completedScreen, String routeId) {
    //aqui se tendra que revisar que este en el listado de rutas completadas para enviar el isCompleted true
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            // He d'aconseguir el id de la ruta un cop fagi el display al mapa
            RouteInfoScreen(
              routeId: routeId,
              fromCompletedScreen: completedScreen, 
              presentationController: this),
      ),
    );
  }

  void startRoute(BuildContext context, String routeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          RouteScreen(presentationController: this),
      ),
    );
  }

  void misteriScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          MysteryScreen(presentationController: this),
      ),
    );
  }

  // Move to the done routes screen
  void doneRoutesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DonePage(presentationController: this),
      ),
    );
  }

  // Move to the me screen
  void meScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PerfilPage(presentationController: this),
      ),
    );
  }

  // Move to the edit user screen
  void editUserScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditUserScreen(presentationController: this),
      ),
    );
  }

  // Move to the rewards screen
  void rewardsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RewardsScreen(presentationController: this),
      ),
    );
  }

  // Move to the how to play screen
  void howToPlayScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HowToPlayScreen(presentationController: this),
      ),
    );
  }
  
}