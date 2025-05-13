import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:sign_in_button/sign_in_button.dart";
import "package:easy_localization/easy_localization.dart";
import 'package:app/presentation/presentation_controller.dart';

class Login extends StatefulWidget {
  final PresentationController presentationController;

  const Login({super.key, required this.presentationController});

  @override
  State<Login> createState() => _Login(presentationController);
}

class _Login extends State<Login> {
  
  late PresentationController _presentationController;

  late FirebaseAuth auth = FirebaseAuth.instance;

  _Login(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //Comprovar si ja hi ha una sessio iniciada
      _presentationController.checkLoggedInUser(context);
    });
  }

  //Construccio de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loginLayout(),
    );
  }

  //Layout de login
  Widget _loginLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('welcome_txt'.tr(),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        SizedBox(height: 70),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            image: DecorationImage(
              //Substituir esta imagen por el logo de la app
              image: AssetImage('assets/loginpicture.png'),
              fit: BoxFit.cover,
            )
          ),
        ),
        SizedBox(height: 70),
        _googleSignInButton(),
      ],
    );
  }

  //Botó de login
  Widget _googleSignInButton() {
    return Center(child: SizedBox(
      height: 50,
      child: SignInButton(
        Buttons.google,
        onPressed: () {
          _handleGoogleSignIn();
        },
        text: 'google_access'.tr(),
        padding: EdgeInsets.all(10.0),
      )
    ));
  }
 
 //Inici de sessio
  Future<void> _handleGoogleSignIn() async {
    await _presentationController.handleGoogleSignIn(context);
  }

}