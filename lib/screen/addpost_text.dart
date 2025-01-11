import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instagram_1/data/firebase/firestore.dart';
import 'package:instagram_1/data/firebase/storage.dart';

class AddPostTextScreen extends StatefulWidget {
  final File _file;
  AddPostTextScreen(this._file, {super.key});

  @override
  State<AddPostTextScreen> createState() => _AddPostTextScreenState();
}

class _AddPostTextScreenState extends State<AddPostTextScreen> {
  final caption = TextEditingController();
  final location = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      appBar: AppBar(
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
          backgroundColor: Color.fromARGB(255, 103, 89, 94),
          elevation: 0,
          title: const Text(
            'New post',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    isLoading = true; // Indicates the loading state
                  });
                  try {
                    // Call the Cloudinary upload function and get the image URL
                    String postUrl = await StorageMethod()
                        .uploadFileToStorage('post', widget._file);

                    // Save post details in Realtime Database
                    await FirebaseRealtimeService().createPost(
                      postImage: postUrl,
                      caption: caption.text,
                      location: location.text,
                    );

                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error uploading post: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error uploading post: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: Text(
                  'Share',
                  style: TextStyle(color: Color.fromARGB(255, 232, 180, 184), fontSize: 15.sp),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      child: Row(
                        children: [
                          Container(
                            width: 50.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              image: DecorationImage(
                                image: FileImage(widget._file),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 280.w,
                            height: 60.h,
                            child: TextField(
                              controller: caption,
                              decoration: const InputDecoration(
                                hintText: 'Write a caption ...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: SizedBox(
                        width: 280.w,
                        height: 30.h,
                        child: TextField(
                          controller: location,
                          decoration: const InputDecoration(
                            hintText: 'Add location',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
