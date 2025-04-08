import 'package:app/domain/models/domain_controller.dart';
import 'package:app/domain/models/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/screens/map_screen.dart';
import 'package:app/presentation/screens/me_screen.dart';
import 'package:app/presentation/screens/done_routes.dart';
import 'package:app/presentation/screens/signup.dart';
import 'package:app/presentation/screens/login.dart';


// Aqui aniran totes les funcions de mostrar screens
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

    // Nombre de las clases de las pantallas principales de la app
    _pages.addAll([
      MapPage(presentation_controller: this),
      DonePage(presentation_controller: this),
      PerfilPage(presentation_controller: this),
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

  /*
  void createUser(String username, BuildContext context) async {
    domainController.createUser(_user, username);
    //mostrarPerfil(context);
    //una vez creado el user que quiero hacer? Mostrar el mapa?
  }*/

  void handleSignIn(BuildContext context) async {
    final userCredential = await domainController.signInWithGoogle();

    if (userCredential != null) {
      final user = userCredential.user;
      final username = user?.displayName ?? 'Anonymous';

      // Optional: show a message or navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as $username')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed')),
      );
    }
  }

  void checkLoggedInUser(BuildContext context) {
    //Obte l'usuari autentificat en el moment si existeix
    User? currentUser = _auth.currentUser;
    print(currentUser);

    //Si existeix l'usuari, estableix l'usuari de l'estat i redirigeix a la pantalla principal
    if (currentUser != null) {
      _user = currentUser;
      mapScreen(context);
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      print("Handleando signin");
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      final UserCredential userCredential =
          await _auth.signInWithProvider(_googleAuthProvider);
      bool userExists =
          await domainController.accountExists(userCredential.user);
      print("User ");
      print(userExists);
      print(" ");
      _user = userCredential.user;
      //Si no hi ha un usuari associat al compte de google, redirigir a la pantalla de registre
      if (!userExists) {
        mostrarSignup(context);
      }
      //Altrament redirigir a la pantalla principal de l'app
      else {
        mapScreen(context);
      }
    } catch (error) {
      print(error);
    }
  }

  /*
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
        builder: (context) => Signup(presentation_controller: this),
      ),
    );
  }

  // Move to the map screen
  void mapScreen (BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapPage(presentation_controller: this),
      ),
    );
  }

  // Move to the done routes screen
  void doneRoutesScreen (BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DonePage(presentation_controller: this),
      ),
    );
  }

  // Move to the me screen
  void meScreen (BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PerfilPage(presentation_controller: this),
      ),
    );
  }
}