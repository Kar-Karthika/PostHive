import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instagram_1/data/firebase/firestore.dart';
import 'package:instagram_1/data/firebase/storage.dart';
import 'package:video_player/video_player.dart';

class ReelsEditeScreen extends StatefulWidget {
  File videoFile;
  ReelsEditeScreen(this.videoFile, {super.key});

  @override
  State<ReelsEditeScreen> createState() => _ReelsEditeScreenState();
}

class _ReelsEditeScreenState extends State<ReelsEditeScreen> {
  final caption = TextEditingController();
  late VideoPlayerController controller;
  bool Loading = false;
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true);
        controller.setVolume(1.0);
        controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: false,
        title: Text(
          'New Reels',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Loading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.black,
              ))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  children: [
                    SizedBox(height: 3.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: SizedBox(
                          width: 250.w,
                          height: 250.h,
                          child: controller.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                )
                              : const CircularProgressIndicator()),
                    ),
                    SizedBox(height: 15.h),
                    SizedBox(
                      height: 50,
                      width: 280.w,
                      child: TextField(
                        controller: caption,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Write a caption ...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 45.h,
                          width: 150.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            'Save draft',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              Loading = true;
                            });
                            String reelsUrl = await StorageMethod()
                                .uploadFileToStorage('Reels', widget.videoFile);
                            await FirebaseRealtimeService().createReels(
                                video: reelsUrl, caption: caption.text);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 45.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
