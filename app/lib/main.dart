import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app/data/firebase_options.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/screens/user/login.dart';
import 'package:app/presentation/screens/map_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialice Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final presentationController = PresentationController();
  await presentationController.initialice();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', ''), Locale('es', ''), Locale('ca', '')], 
      path: 'assets/lang', 
      fallbackLocale: Locale('en', ''), 
      child: MyApp(presentationController: presentationController),
    ),   
  );
}

class MyApp extends StatefulWidget {

  final PresentationController presentationController;

  const MyApp({Key? key, required this.presentationController}) : super(key: key);

  @override
  State <MyApp> createState() => _MyAppState(presentationController);
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
    // Check if a user is already logged
    userLogged();
  }

  void userLogged() {
    User? currentUser = _auth.currentUser;
    setState(() {
      _isLoggedIn = currentUser != null;
      _selectedIndex = _isLoggedIn ? _selectedIndex : 4; // If it's not logged, index 4
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      supportedLocales: EasyLocalization.of(context)!.supportedLocales,
      localizationsDelegates: [
        EasyLocalization.of(context)!.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: _isLoggedIn
            ? MapPage(presentationController: _presentationController)
            : Login(presentationController: _presentationController),
      ),
    );
  }
}