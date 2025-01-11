import 'dart:io';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_1/screen/reels_edite_screen.dart';

class AddReelsScreen extends StatefulWidget {
  const AddReelsScreen({super.key});

  @override
  State<AddReelsScreen> createState() => _AddReelsScreenState();
}

class _AddReelsScreenState extends State<AddReelsScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _file;

  Future<void> _pickVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _file = File(pickedFile.path);
        });
        //  Navigate to Reels Edit Screen after selecting a video
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ReelsEditeScreen(_file!),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking video: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      // appBar: AppBar(
      //   backgroundColor: Color.fromARGB(255, 103, 89, 94),
      //   centerTitle: false,
      //   title: const Text(
      //     'New Reels',
      //     style: TextStyle(color: Color.fromARGB(200, 255, 255, 255)),
      //   ),
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 400,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _file != null
                      ? Icon(
                          Icons.video_library,
                          size: 50.sp,
                          color: const Color.fromARGB(255, 23, 24, 25),
                        )
                      : Center(
                          child: Icon(
                            Icons.add,
                            size: 50.sp,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: _pickVideo,
                child: const Text(
                  "Choose a Video",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
