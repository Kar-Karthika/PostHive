import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instagram_1/data/firebase/firebase_auth.dart';
import 'package:instagram_1/util/exception.dart';
import 'package:instagram_1/util/imagepicker.dart';
import 'package:instagram_1/widgets/navigation.dart';

class SigninScreen extends StatefulWidget {
  final VoidCallback show;
  const SigninScreen(this.show, {super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final email = TextEditingController();
  FocusNode email_F = FocusNode();
  final password = TextEditingController();
  FocusNode password_F = FocusNode();
  final bio = TextEditingController();
  FocusNode bio_F = FocusNode();
  final username = TextEditingController();
  FocusNode username_F = FocusNode();
  final passwordConfirm = TextEditingController();
  FocusNode passwordConfirm_F = FocusNode();
  File? _imageFile;

  @override
  void dispose() {
    super.dispose();
    email.dispose();
    password.dispose();
    bio.dispose();
    username.dispose();
    passwordConfirm.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("POST HIVE"),
        backgroundColor: Color.fromARGB(255, 103, 89, 94),
      ),
      resizeToAvoidBottomInset:
          true, // Allow screen adjustment when keyboard opens
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              child: Column(
                children: [
                  SizedBox(width: 50, height: 50),
                  Center(
                    child: Image.asset(
                      'images/ph1.png',
                      height: 100,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Profile Picture
                  Center(
                    child: InkWell(
                      onTap: () async {
                        File? imageFile = await ImagePickerr()
                            .uploadImage('gallery'); // or 'camera'

                        if (imageFile != null) {
                          setState(() {
                            _imageFile = imageFile;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 36.r,
                        backgroundColor: Colors.grey,
                        child: _imageFile == null
                            ? CircleAvatar(
                                radius: 34.r,
                                backgroundImage: AssetImage('images/p1.png'),
                                backgroundColor: Colors.grey.shade200,
                              )
                            : CircleAvatar(
                                radius: 34.r,
                                backgroundImage: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ).image,
                                backgroundColor: Colors.grey.shade200,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            // Scrollable area for text fields and button
            Column(
              children: [
                _buildTextField(
                    email, email_F, 'Email', Icons.email, TextInputAction.next),
                SizedBox(height: 15),
                _buildTextField(username, username_F, 'Username', Icons.person,
                    TextInputAction.next),
                SizedBox(height: 15),
                _buildTextField(
                    bio, bio_F, 'Bio', Icons.abc, TextInputAction.next),
                SizedBox(height: 15),
                _buildTextField(password, password_F, 'Password', Icons.lock,
                    TextInputAction.next,),
                SizedBox(height: 15),
                _buildTextField(passwordConfirm, passwordConfirm_F,
                    'Confirm Password', Icons.lock, TextInputAction.done,),
                SizedBox(height: 15),
                // Sign In Button
                _signinButton(),
                SizedBox(height: 15),
                // Have an account? Text
                _haveAccount(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _haveAccount() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Do you have account?  ",
            style: TextStyle(
              fontSize: 20,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          GestureDetector(
            onTap: widget.show,
            child: Text(
              "Login ",
              style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 238, 214, 211),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signinButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () async {
          try {
            await Authentication().Signup(
              email: email.text,
              password: password.text,
              username: username.text,
              passwordConfirme: passwordConfirm.text,
              bio: bio.text,
              profile: _imageFile ?? File(''),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const Navigations_Screen()),
            );
          } on exceptions catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 103, 89, 94),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              fontSize: 23,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, FocusNode focusNode,
      String label, IconData icon, TextInputAction action) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextField(
          style: TextStyle(fontSize: 18, color: Colors.black),
          controller: controller,
          focusNode: focusNode,
          textInputAction: action,
          onEditingComplete: () {
            if (action == TextInputAction.next) {
              FocusScope.of(context)
                  .nextFocus(); // Move to the next focusable field
            } else {
              FocusScope.of(context)
                  .unfocus(); // Dismiss the keyboard when done
            }
          },
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: Icon(
              icon,
              color: focusNode.hasFocus ? Colors.black : Colors.grey[600],
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 2,
                color: Color.fromARGB(255, 103, 89, 94),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 2,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
