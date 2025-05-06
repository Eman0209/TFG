import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
      ),
      child: GNav(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        backgroundColor: const Color.fromARGB(255, 206, 179, 254),
        color: Colors.black,
        activeColor: Colors.black,
        tabBackgroundColor: const Color.fromARGB(255, 231, 217, 255),
        gap: 4,
        onTabChange: (index) {
          onTabChange(index);
        },
        selectedIndex: currentIndex,
        tabs: [
          GButton(
            text: 'ruta'.tr(),
            textStyle: TextStyle(fontSize: 14, color: Colors.black),
            icon: Icons.location_on_sharp,
          ),
          GButton(
            text: 'done'.tr(),
            textStyle: TextStyle(fontSize: 14, color: Colors.black),
            icon: Icons.task_alt_rounded,
          ),
          GButton(
            text: 'me'.tr(),
            textStyle: TextStyle(fontSize: 14, color: Colors.black),
            icon: Icons.account_circle,
          ),
        ],
      ),
    );
  }
}