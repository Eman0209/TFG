import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/presentation/presentation_controller.dart';
import 'package:app/presentation/widgets/bnav_bar.dart';

class PerfilPage extends StatefulWidget {
  final PresentationController presentationController;

  const PerfilPage({super.key, required this.presentationController});

  @override
  State<PerfilPage> createState() => _PerfilPageState(presentationController);
}

class _PerfilPageState extends State<PerfilPage> {
  late PresentationController _presentationController;
  int _selectedIndex = 2;

  _PerfilPageState(PresentationController presentationController) {
    _presentationController = presentationController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'me'.tr(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              icon: Icons.emoji_events_outlined,
              text: 'rewards'.tr(),
              onTap: () {
                _presentationController.rewardsScreen(context);
              }
            ),
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.language,
              text: 'language'.tr(),
              onTap: () {
                _showLanguagePicker(context);
              }
            ),
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.person_outline,
              text: 'editUser'.tr(),
              onTap: () {
                _presentationController.editUserScreen(context);
              }
            ),
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.warning_amber_outlined,
              text: 'logout'.tr(),
               onTap: () {
                _presentationController.logout(context);
              }
            ),
            const SizedBox(height: 10),
            _buildMenuItem(
              icon: Icons.warning_amber_outlined,
              text: 'howToPlay'.tr(),
               onTap: () {
                _presentationController.howToPlayScreen(context);
              }
            ),
            const Divider(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('english'.tr()),
            onTap: () {
              Navigator.pop(context); 
              changeLanguage(Locale('en'));
            },
          ),
          ListTile(
            title: Text('spanish'.tr()),
            onTap: () {
              Navigator.pop(context);
              changeLanguage(Locale('es'));
            },
          ),
          ListTile(
            title: Text('catalan'.tr()),
            onTap: () {
              Navigator.pop(context);
              changeLanguage(Locale('ca'));
            },
          ),
        ],
      ),
    );
  }

  void changeLanguage(Locale locale) {
    _presentationController.changeLanguage(locale, context);
    Navigator.of(context).pop();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('restart_for_changes'.tr()),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  
    switch (index) {
      case 0:
        _presentationController.mapScreen(context);
        break;
      case 1:
          _presentationController.doneRoutesScreen(context);
        break;
      case 2:
         _presentationController.meScreen(context);
        break;
      default:
        break;
    }
  }
}