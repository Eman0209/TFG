import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomTopNavigationBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(int) onTabChange;
  final int selectedIndex;

  CustomTopNavigationBar({required this.onTabChange, required this.selectedIndex});

  @override
  _CustomTopNavigationBarState createState() => _CustomTopNavigationBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _CustomTopNavigationBarState extends State<CustomTopNavigationBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      initialIndex: _currentIndex, 
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFD7C4FA),
          bottom: TabBar(
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.deepPurple,
            indicatorWeight: 2,
            tabs: [
              Tab(text: 'map'.tr()),      
              Tab(text: 'mistery'.tr()),  
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onTabChange(index); 
            },
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Map View')),
            Center(child: Text('Mystery View')),
          ],
        ),
      ),
    );
  }
}
