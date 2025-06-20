import 'package:app/presentation/screens/user/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/data/datasources/mystery_datasource.dart';
import 'package:app/data/datasources/rewards_datasource.dart';
import 'package:app/data/datasources/routes_datasource.dart';
import 'package:app/data/datasources/user_datasource.dart';
import 'package:app/domain/models/routes.dart';
import 'package:app/domain/models/steps.dart';
import 'package:app/domain/controllers/user_controller.dart';
import 'package:app/domain/controllers/routes_controller.dart';
import 'package:app/domain/controllers/rewards_controller.dart';
import 'package:app/domain/controllers/mystery_controller.dart';
import 'package:app/presentation/screens/map_screen.dart';
import 'package:app/presentation/screens/me_screen.dart';
import 'package:app/presentation/screens/done_routes.dart';
import 'package:app/presentation/screens/user/signup.dart';
import 'package:app/presentation/screens/user/edit_user_screen.dart';
import 'package:app/presentation/screens/user/rewards_screen.dart';
import 'package:app/presentation/screens/user/how_to_play_screen.dart';
import 'package:app/presentation/screens/info_route_screen.dart';
import 'package:app/presentation/screens/mystery/route_screen.dart';
import 'package:app/presentation/screens/mystery/mystery_screen.dart';
import 'package:app/presentation/screens/mystery/introduction_screen.dart';
import 'package:app/presentation/screens/mystery/activities/fifth_activity.dart';
import 'package:app/presentation/screens/mystery/activities/final_screen.dart';
import 'package:app/presentation/screens/mystery/activities/first_activity.dart';
import 'package:app/presentation/screens/mystery/activities/fourth_activity.dart';
import 'package:app/presentation/screens/mystery/activities/ra_activity.dart';
import 'package:app/presentation/screens/mystery/activities/second_activity.dart';
import 'package:app/presentation/screens/mystery/activities/third_activity.dart';
import 'package:app/presentation/screens/mystery/step_screen.dart';

class PresentationController {
  
  late final FirebaseRoutesDatasource routesDatasource;
  late final RoutesController routesController;
  late final FirebaseUserDatasource userDatasource;
  late final UserController userController;
  late final FirebaseRewardsDatasource rewardsDatasource;
  late final RewardsController rewardsController;
  late final FirebaseMysteryDatasource mysteryDatasource;
  late final MysteryController mysteryController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  late List<RouteData> routesUser;
  late final List<Widget> _pages = [];

  late Locale? _language = const Locale('en');
  Locale? get language => _language;

  final Logger _logger = Logger('PresentationController');
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  PresentationController() {
    final firestore = FirebaseFirestore.instance;

    routesDatasource = FirebaseRoutesDatasource(firestore);
    routesController = RoutesController(routesDatasource);

    userDatasource = FirebaseUserDatasource( 
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      googleSignIn: GoogleSignIn()
    );
    userController = UserController(userDatasource);

    rewardsDatasource = FirebaseRewardsDatasource(firestore);
    rewardsController = RewardsController(rewardsDatasource);

    mysteryDatasource = FirebaseMysteryDatasource(firestore);
    mysteryController = MysteryController(mysteryDatasource);
  }

  Future<void> initialice() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = currentUser;
    }

    _pages.addAll([
      MapPage(presentationController: this),
      DonePage(presentationController: this),
      PerfilPage(presentationController: this),
    ]);

    _loadLanguage();
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

  void logout(BuildContext context) async {
    await _auth.signOut();
    try {
      await _googleSignIn.disconnect(); 
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
    }

    Future.delayed(const Duration(seconds: 1), () {
      mostrarLogin(context);
    });
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _logger.warning("Login cancelado por el usuario.");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final bool userExists = await userController.accountExists(userCredential.user);
      _user = userCredential.user;

      if (!userExists) {
        mostrarSignup(context);
      } else {
        mapScreen(context);
      }
    } catch (e) {
      _logger.severe('Login con Google falló: $e');
    }
  }

  void changeLanguage(Locale? lang, BuildContext context) async {
    _language = lang;
    context.setLocale(lang!);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', lang.languageCode);
   _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _language = Locale(languageCode);
    }
  }

  Future<List<Map<String, dynamic>>> getTrophies() async {
    if(_language == Locale('en')) {
      return rewardsController.fetchTrophies('en');
    }
    else if(_language == Locale('es')) {
      return rewardsController.fetchTrophies('es');
    }
    else {
      return rewardsController.fetchTrophies('ca');
    }
  }

  Future<List<String>> getMyOwnTrophies() async {
    return rewardsController.fetchMyOwnTrophies(_user!);
  }

  Future<void> addUserTrophy(String trophyId) async {
    await rewardsController.addUserTrophy(_user!, trophyId);
  }

  Future<List<RouteData>> getUserDoneRoutes() async {
    List<String> doneRoutes = await routesController.fetchDoneRoutes(_user);
    List<RouteData> infoRoutes = [];
    for (String routeId in doneRoutes) {
      RouteData? routeInfo = await getRouteData(routeId);
      infoRoutes.add(routeInfo!);
    }  
    return infoRoutes;
  }

  void addStardtedRoute(BuildContext context, String routeId) async {
    await routesController.addStardtedRoute(_user, routeId);
  }

  void deleteStartedRoute(BuildContext context, String routeId) async {
    await routesController.deleteStartedRoute(_user, routeId);
  }

  Future<bool> isRouteStarted(String routeId) async {
    return await routesController.isRouteStarted(_user, routeId);
  }

  Future<bool> isRouteDone(String routeId) async {
    return await routesController.isRouteFinished(_user, routeId);
  }

  void addDoneRoute(BuildContext context, String routeId, Duration timeSpent) async {
    await routesController.addDoneRoute(_user, routeId, timeSpent);
    // aqui se pueden ver las categorias de la ruta y se añade el reward correspondiente
    RouteData? routeInfo = await getRouteData(routeId);
    if (routeInfo!.category == "hystory") {
      await addUserTrophy("BrK3LP4sD9i6MWCAjksn");
    } else if (routeInfo.category == "phantom") {
      await addUserTrophy("BEgCnA6mXMZAccR9lzRi");
    } else if (routeInfo.category == "modern") {
      await addUserTrophy("5MbItqeOAMZhla3RYkyA");
    } else if (routeInfo.category == "espiritual") {
      await addUserTrophy("7PCCHmDRP9GTsaN0gKot");
    }
    doneRoutesScreen(context);
  }

  Future<List<RouteData?>> getAllRoutesData(BuildContext context) async {
    if(_language == Locale('en')) {
      return routesController.fetchAllRoutesData('en');
    }
    else if(_language == Locale('es')) {
      return routesController.fetchAllRoutesData('es');
    }
    else {
      return routesController.fetchAllRoutesData('ca');
    }
  }

  Future<RouteData?> getRouteData(String routeId) async {
    if(_language == Locale('en')) {
      return routesController.fetchRouteData(routeId, 'en');
    }
    else if(_language == Locale('es')) {
      return routesController.fetchRouteData(routeId, 'es');
    }
    else {
      return routesController.fetchRouteData(routeId, 'ca');
    }
  }

  
  Future<List<PointLatLng>> getRoutesPoints(BuildContext context) async {
    List<RouteData?> routes = await getAllRoutesData(context);

    List<String> addresses = routes
      .where((route) => route != null)
      .expand((route) => route!.path)
      .toList();

    List<LatLng> directions = await routesController.getRouteCoordinatesFromNames(addresses);
    
    List<PointLatLng> points = directions
      .map((loc) => PointLatLng(loc.latitude, loc.longitude))
      .toList();

    return points;
  }
  
  Future<String> getRouteId() async {
    return "NWjKzu7Amz2AXJLZijQL";
  }

  Future<String> getMysteryId(String routeId) async {
    RouteData? data;
    if(_language == Locale('en')) {
       data = await routesController.fetchRouteData(routeId, 'en');
    }
    else if(_language == Locale('es')) {
      data = await routesController.fetchRouteData(routeId, 'es');
    }
    else {
      data = await routesController.fetchRouteData(routeId, 'ca');
    }
    return data!.mysteryId;
  }

  Future<String> getMysteryTitle(String routeId) async {
    RouteData? data;
    if(_language == Locale('en')) {
       data = await routesController.fetchRouteData(routeId, 'en');
    }
    else if(_language == Locale('es')) {
      data = await routesController.fetchRouteData(routeId, 'es');
    }
    else {
      data = await routesController.fetchRouteData(routeId, 'ca');
    }
    return data!.name;
  }

  Future<String> getIntroduction(String mysteryId) async {
    String? intro;
    if(_language == Locale('en')) {
      intro = await mysteryController.fetchIntroduction(mysteryId, 'en');
    }
    else if(_language == Locale('es')) {
      intro = await mysteryController.fetchIntroduction(mysteryId, 'es');
    }
    else {
      intro = await mysteryController.fetchIntroduction(mysteryId, 'ca');
    }
    return intro!;
  }

  Future<StepData?> getStepInfo(String mysteryId, int order) {
    if(_language == Locale('en')) {
      return mysteryController.fetchStepInfo(mysteryId, order, 'steps_en');
    }
    else if(_language == Locale('es')) {
      return mysteryController.fetchStepInfo(mysteryId, order, 'steps_es');
    }
    else {
      return mysteryController.fetchStepInfo(mysteryId, order, 'steps');
    }
  }

  Future<List<StepData>> getCompletedSteps(String mysteryId) {
    if(_language == Locale('en')) {
      return mysteryController.fetchCompletedSteps(_user!, mysteryId, 'steps_en');
    }
    else if(_language == Locale('es')) {
      return mysteryController.fetchCompletedSteps(_user!, mysteryId, 'steps_es');
    }
    else {
      return mysteryController.fetchCompletedSteps(_user!, mysteryId, 'steps');
    }
  }

  Future<int> getLengthOfSteps(String mysteryId) {
    return mysteryController.fetchLengthOfSteps(mysteryId);
  }

  Future<String> getNextstep(String mysteryId, int order) async {
    StepData? step = await getStepInfo(mysteryId, order);
    return step!.nextStep;
  }

  Future<Duration> getRouteDuration(String routeId) async {
    Duration? duration = await routesController.fetchRouteDuration(_user!, routeId);
    return duration!;
  }

  Future<Duration> getStartedRouteDuration(String routeId) async {
    Duration? duration = await routesController.fetchStartedRouteDuration(_user!, routeId);
    return duration!;
  }

  Future<void> updateStartedRouteDuration(String routeId, Duration timeSpent) async {
    await routesController.updateStartedRouteDuration(_user!, routeId, timeSpent);
  }

  Future<void> addDoneStep(String mysteryId, int order) async {
    await mysteryController.addDoneStep(_user!, mysteryId, order);
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RouteInfoScreen(
              routeId: routeId,
              fromCompletedScreen: completedScreen, 
              presentationController: this),
      ),
    );
  }

  void startedRouteScreen(BuildContext context, String routeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          RouteScreen(presentationController: this, routeId: routeId),
      ),
    );
  }

  void mysteryScreen(BuildContext context, String routeId, String mysteryId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          MysteryScreen(presentationController: this, routeId: routeId, mysteryId: mysteryId,),
      ),
    );
  }

  void introductionScreen(BuildContext context, String mysteryId, String routeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          IntroScreen(presentationController: this, mysteryId: mysteryId, routeId: routeId),
      ),
    );
  }

  void stepScreen(BuildContext context, String mysteryId, String routeId, int stepOrder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          StepScreen(presentationController: this, mysteryId: mysteryId, routeId: routeId, stepOrder: stepOrder),
      ),
    );
  }

  void activityScreen(BuildContext context, String routeId, String mysteryId, int stepOrder) {
    if (stepOrder == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            TranslationPuzzleScreen(presentationController: this, routeId: routeId, mysteryId: mysteryId, stepOrder: stepOrder),
        ),
      );
    }
    if (stepOrder == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            PlumbingGameScreen(presentationController: this, routeId: routeId, mysteryId: mysteryId, stepOrder: stepOrder),
        ),
      );
    }
    if (stepOrder == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            HeraldicPuzzleScreen(presentationController: this, routeId: routeId, mysteryId: mysteryId, stepOrder: stepOrder),
        ),
      );
    }
    if (stepOrder == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            MapReconstructionGame(presentationController: this, routeId: routeId, mysteryId: mysteryId, stepOrder: stepOrder),
        ),
      );
    }
    if (stepOrder == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            CryptogramGame(presentationController: this, routeId: routeId, mysteryId: mysteryId, stepOrder: stepOrder, language: _language!, game: 5),
        ),
      );
    }
    if (stepOrder == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            CryptogramGame(presentationController: this, routeId: routeId, mysteryId: mysteryId, stepOrder: stepOrder, language: _language!, game: 6),
        ),
      );
    }
    if (stepOrder == 7) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            ArCoreScreen(presentationController: this, routeId: routeId, mysteryId: mysteryId, stepOrder: stepOrder),
        ),
      );
    }
    if (stepOrder == 8) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
            FinalScreen(presentationController: this, routeId: routeId, mysteryId: mysteryId, stepOrder: stepOrder),
        ),
      );
    }
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

  void mostrarLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Login(presentationController: this),
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