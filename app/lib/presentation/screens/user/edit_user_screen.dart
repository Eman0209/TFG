import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/presentation/presentation_controller.dart';

class EditUserScreen extends StatefulWidget {
  final PresentationController presentationController;

  const EditUserScreen({super.key, required this.presentationController});

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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 1), 
              Text(
                'editNameUser'.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'modifyInfo'.tr(),
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                decoration: InputDecoration(
                  hintText: 'username'.tr(),
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
              Container(
                padding: const EdgeInsets.only(top: 30, left: 3),
                child:
                ElevatedButton(
                  onPressed: _saveUsername,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 206, 179, 254),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'saveChanges'.tr(),
                    style: TextStyle(fontSize: 16),
                  ),
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
    if (_usernameController.text.isNotEmpty) {
      setState(() {
        _username = _usernameController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('username_updated'.tr(args: [_username]))),
      );
      // Calls to the update function
      _presentationController.editUsername(_username, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('username_empty'.tr())),
      );
    }
  }

}