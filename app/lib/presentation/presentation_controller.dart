import 'package:app/domain/models/domain_controller.dart';
import 'package:app/domain/models/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/screens/map_screen.dart';
import 'package:app/presentation/screens/me_screen.dart';
import 'package:app/presentation/screens/done_routes.dart';
import 'package:app/presentation/screens/signup.dart';
import 'package:app/presentation/screens/editUser_screen.dart';
import 'package:app/presentation/screens/rewards_screen.dart';
import 'package:app/presentation/screens/howToPlay_screen.dart';
//import 'package:app/presentation/screens/login.dart';


// Functions to see the screens
class PresentationController {
  final domainController = DomainController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  late List<Routes> routesUser;
  late final List<Widget> _pages = [];

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
    domainController.createUser(_user, username);
    mapScreen(context);
    //una vez creado el user que quiero hacer? Mostrar el mapa?
  }

  void editUsername(String username, BuildContext context) async {
    domainController.editUsername(_user, username);
    meScreen(context);
    //una vez creado el user que quiero hacer? Mostrar el mapa?
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
      bool userExists = await domainController.accountExists(userCredential.user);
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
      print(error);
    }
  }

  /*
  // Quiero obligar a que el username sea unique?
  Future<bool> usernameUnique(String username) {
    return domainController.usernameUnique(username);
  }
  */

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