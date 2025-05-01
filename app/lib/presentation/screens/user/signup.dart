import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:easy_localization/easy_localization.dart";
import 'package:app/presentation/presentation_controller.dart';

class Signup extends StatefulWidget {

  final PresentationController presentationController;

  const Signup({Key? key, required this.presentationController}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState(presentationController);
}

class _SignupState extends State<Signup> {
  final TextEditingController usernameController = TextEditingController();

  late PresentationController _presentationController;

  late User? user;

  _SignupState(PresentationController presentationController) {
    _presentationController = presentationController;
    user = presentationController.getUser();
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 60.0),
                  Text(
                    'create_account'.tr(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'add_info'.tr(),
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  TextField(
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'username'.tr(),
                      contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: const Color.fromARGB(255, 223, 211, 246),
                      filled: true,
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 20),
                ],
              ),
              Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: ElevatedButton(
                    onPressed: () {
                      createUser();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple
                    ),
                    child: Text(
                      'create_account'.tr(),
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createUser() async {
    //if (await _presentationController.usernameUnique(usernameController.text)) {
      _presentationController.createUser(usernameController.text, context);
    //}
    /*else {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Ja hi ha un usuari amb aquest username'),
          backgroundColor: Colors.red,
        ),
      );
    }*/
  }

}