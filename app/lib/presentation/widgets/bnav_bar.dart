import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTabChange,
  }) : super(key: key);

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
        tabs: const [
          GButton(
            text: "Route",
            textStyle: TextStyle(fontSize: 14, color: Colors.black),
            icon: Icons.location_on_sharp,
          ),
          GButton(
            text: "Done",
            textStyle: TextStyle(fontSize: 14, color: Colors.black),
            icon: Icons.task_alt_rounded,
          ),
          GButton(
            text: "Me",
            textStyle: TextStyle(fontSize: 14, color: Colors.black),
            icon: Icons.account_circle,
          ),
        ],
      ),
    );
  }
}