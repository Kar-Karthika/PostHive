import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instagram_1/screen/add_post_screen.dart';
import 'package:instagram_1/screen/add_reels_screen.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

int _currentIndex = 0;

class _AddScreenState extends State<AddScreen> {
  late PageController pageController;
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
    return 
   Scaffold(
        backgroundColor: Color.fromARGB(255, 164, 147, 147),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
          backgroundColor: Color.fromARGB(255, 103, 89, 94),
          elevation: 0,
          title: const Text(
            'New Post and Reels',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ),
        body: SafeArea(
          child: Stack(
          
            alignment: Alignment.bottomCenter,
            children: [
              PageView(
                controller: pageController,
                onPageChanged: onPageChanged,
                children: const [
                  AddReelsScreen(),
                  AddPostScreen(),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: 10.h,
                right: _currentIndex == 0 ? 100.w : 150.w,
                child: Container(
                  width: 120.w,
                  height: 30.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          navigationTapped(0);
                        },
                        child: Text(
                          'Reels',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                _currentIndex == 0 ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          navigationTapped(1);
                        },
                        child: Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color:
                                _currentIndex == 1 ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    
  }
}
