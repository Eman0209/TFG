import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/data/firebase_options.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/screens/login.dart';
import 'package:app/presentation/screens/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialice Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final presentationController = PresentationController();
  await presentationController.initialice();

  runApp(MyApp(presentationController: presentationController));
}

class MyApp extends StatefulWidget {

  final PresentationController presentationController;

  MyApp({Key? key, required this.presentationController}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState(presentationController);
}

class _MyAppState extends State<MyApp> {
  late PresentationController _presentationController; 
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  _MyAppState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  @override
  void initState() {
    super.initState();
    // Llamar a userLogged al inicio
    userLogged();
  }

  void userLogged() {
    User? currentUser = _auth.currentUser;
    setState(() {
      _isLoggedIn = currentUser != null;
      _selectedIndex = _isLoggedIn ? _selectedIndex : 4; // Si no está logueado, selecciona el índice 4
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Scaffold(
        body: _isLoggedIn
            ? MapPage(presentation_controller: _presentationController)
            : Login(presentation_controller: _presentationController),
      ),
    );
  }
}