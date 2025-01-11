import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_1/screen/addscreen.dart';
import 'package:instagram_1/screen/explore.dart';
import 'package:instagram_1/screen/home.dart';
import 'package:instagram_1/screen/profilescreen.dart';
import 'package:instagram_1/screen/reelsscreen.dart';
import 'package:uuid/uuid.dart';

class Navigations_Screen extends StatefulWidget {
  const Navigations_Screen({super.key});

  @override
  State<Navigations_Screen> createState() => _Navigations_ScreenState();
}

int _currentIndex = 0;

class _Navigations_ScreenState extends State<Navigations_Screen> {
  late PageController pageController;
 // final FirebaseAuth _auth = FirebaseAuth.instance;
  String uid = Uuid().v4();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 103, 89, 94),
        iconSize: 25,
        selectedIconTheme: IconThemeData(
          size: 30,
        ),
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Color.fromARGB(255, 232, 180, 184),
        unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        currentIndex: _currentIndex,
        onTap: navigationTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.camera,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.video_collection_rounded,
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          HomeScreen(),
          ExploreScreen(),
          AddScreen(),
          ReelScreen(),
          ProfileScreen(
            uid: FirebaseAuth.instance.currentUser?.uid ?? '',
          ),
        ],
      ),
    );
  }
}
