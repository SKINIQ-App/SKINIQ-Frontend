// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skiniq/screen/diary/diary_screen.dart';
import 'package:skiniq/screen/home/home_screen.dart';
import 'package:skiniq/screen/profile/profile_screen.dart';

class MainTabViewScreen extends StatefulWidget {
  final String username; // Add username parameter
  const MainTabViewScreen({super.key, required this.username});

  @override
  State<MainTabViewScreen> createState() => _MainTabViewScreenState();
}

class _MainTabViewScreenState extends State<MainTabViewScreen> with SingleTickerProviderStateMixin {
  late TabController controller;
  int selectTab = 0;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      setState(() {
        selectTab = controller.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/img/Background1.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: TabBarView(
                controller: controller,
                children: [
                  const HomeScreen(),
                  DiaryScreen(username: widget.username), // Pass username
                  ProfileScreen(username: widget.username), // Pass username
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: selectTab,
            onTap: (index) {
              controller.animateTo(index);
              setState(() {
                selectTab = index;
              });
            },
            selectedItemColor: const Color.fromARGB(255, 198, 232, 189),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.book, size: 28), label: "Diary"),
              BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }
}