import 'package:flutter/material.dart';
import 'package:spotify_clone/views/home.dart';
import 'package:spotify_clone/views/library.dart';
import 'package:spotify_clone/views/profile.dart';

class Tabbar extends StatefulWidget {
  @override
  _TabbarState createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            this._selectedTab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
         
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_rupee_outlined),
            label: "Premium",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: Stack(
        children: [
          renderView(
            0,
            HomeView(),
          ),
          
          renderView(
            1,
            PremiumAdPage(),
          ),
          renderView(
            2,
            ProfileView(),
          ),
        ],
      ),
    );
  }

  Widget renderView(int tabIndex, Widget view) {
    return IgnorePointer(
      ignoring: _selectedTab != tabIndex,
      child: Opacity(
        opacity: _selectedTab == tabIndex ? 1 : 0,
        child: view,
      ),
    );
  }
}
