import 'package:flutter/material.dart';
import 'package:app/presentation/presentation_controller.dart';

class EditUserScreen extends StatefulWidget {
  final PresentationController presentationController;

  const EditUserScreen({Key? key, required this.presentationController});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState(presentationController);
}

class _EditUserScreenState extends State<EditUserScreen> {
  late PresentationController _presentationController;
  final TextEditingController _usernameController = TextEditingController();
  String _username = '';

  _EditUserScreenState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  @override
  void initState() {
    super.initState();
    // Initialize with an existing username if needed
    _usernameController.text = _username;
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 1), 
              const Text(
                "Edita el teu nom d'usuari",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Modifica la teva informació",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                decoration: InputDecoration(
                  hintText: "Nom d'usuari",
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: const Color.fromARGB(255, 223, 211, 246),
                  filled: true,
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveUsername,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text(
                  "Desar canvis",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const Spacer(flex: 3), // Optional: adds breathing room below
            ],
          ),
        ),
      ),
    );
  }

  void _saveUsername() {
    // Here you can add validation or save the username logic
    if (_usernameController.text.isNotEmpty) {
      setState(() {
        _username = _usernameController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username updated to: $_username')),
      );
      //aqui se llamaria al update
      _presentationController.editUsername(_username, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username cannot be empty!')),
      );
    }
  }

}