import 'package:app/domain/models/domain_controller.dart';
import 'package:app/domain/models/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/presentation/screens/map_screen.dart';
import 'package:app/presentation/screens/me_screen.dart';
import 'package:app/presentation/screens/done_routes.dart';
import 'package:app/presentation/screens/login.dart';


// Aqui aniran totes les funcions de mostrar screens
class PresentationController {
  final controladorDomini = ControladorDomini();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? _user;
  late List<Routes> routesUser;
  late final List<Widget> _pages = [];

  Future<void> initialice2() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = currentUser;
    }

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




  void mapScreen (BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapPage(presentation_controller: this),
      ),
    );
  }

}