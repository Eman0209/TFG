import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import 'package:app/presentation/presentation_controller.dart';

class Signup extends StatefulWidget {

  final PresentationController presentation_controller;

  const Signup({Key? key, required this.presentation_controller}) : super(key: key);

  @override
  _SignupState createState() => _SignupState(presentation_controller);
}

class _SignupState extends State<Signup> {
  final TextEditingController usernameController = TextEditingController();

  late PresentationController _presentationController;

  late User? user;

  _SignupState(PresentationController presentation_controller) {
    _presentationController = presentation_controller;
    user = presentation_controller.getUser();
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      body: _signupScreen(context),
    );
  }

  Widget _signupScreen(BuildContext context) {
    return Scaffold();
  }
}