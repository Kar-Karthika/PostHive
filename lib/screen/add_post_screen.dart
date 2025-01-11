import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instagram_1/screen/addpost_text.dart';
import 'package:instagram_1/util/imagepicker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final ImagePickerr _picker = ImagePickerr();
  File? _selectedFile;

  Future<void> _pickImage() async {
    try {
      final File? pickedFile = await _picker.uploadImage(
        'gallery',
      );
      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
 backgroundColor: Color.fromARGB(255, 164, 147, 147),
        elevation: 0,
        title: const Text(
          'New Post',
          style: TextStyle(color: Color.fromARGB(192, 255, 255, 255),fontSize: 25),
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () {
                  if (_selectedFile != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddPostTextScreen(_selectedFile!),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please select an image first.")),
                    );
                  }
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                      fontSize: 25.sp,
                      fontWeight:FontWeight.bold,
                      color:  Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200.w,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.add_photo_alternate,
                            size: 50.sp,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                
                onPressed: _pickImage,
                child: const Text(
                  "Select Image",
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
