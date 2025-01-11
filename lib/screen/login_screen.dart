import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_1/data/firebase/firebase_auth.dart';
import 'package:instagram_1/util/exception.dart';
import 'package:instagram_1/widgets/navigation.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback show;

  const LoginScreen(this.show, {super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  FocusNode email_F = FocusNode();
  final password = TextEditingController();
  FocusNode password_F = FocusNode();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    email.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("POST HIVE"),
        backgroundColor: Color.fromARGB(255, 103, 89, 94),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(width: 96, height: 100),
            Center(
              child: Image.asset('images/ph1.png'),
            ),
            SizedBox(height: 120),
            Textfild(email, email_F, 'Email', Icons.email),
            SizedBox(height: 15),
            Textfild(password, password_F, 'Password', Icons.lock),
            SizedBox(height: 15),
            forget(),
            SizedBox(height: 15),
            login(),
            SizedBox(height: 15),
            Have()
          ],
        ),
      ),
    );
  }

  Widget Have() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Don't have account?  ",
            style: TextStyle(
              fontSize: 20,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          GestureDetector(
            onTap: widget.show,
            child: Text(
              "Sign up ",
              style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 238, 214, 211),
                  //  color: Color.fromARGB(255, 232, 180, 184),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget login() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () async {
          try {
            await Authentication()
                .Login(email: email.text, password: password.text);
            if (mounted) {
              // Check if the widget is still mounted before navigating
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const Navigations_Screen()),
              );
            }
          } on exceptions catch (e) {
            if (mounted) {
              // Check if the widget is still mounted before showing the SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 103, 89, 94),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Login',
            style: TextStyle(
              fontSize: 23,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Padding forget() {
    return Padding(
      padding: EdgeInsets.only(left: 230),
      child: GestureDetector(
        onTap: () async {
          await showForgotPasswordDialog(context);
        },
        child: Text(
          'Forgot password?',
          style: TextStyle(
            fontSize: 15,
            color: Color.fromARGB(255, 238, 214, 211),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> showForgotPasswordDialog(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address to receive a password reset link.',
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Password reset link sent to $email')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter an email address')),
                  );
                }
              },
              child: Text('Send Link'),
            ),
          ],
        );
      },
    );
  }

  Padding Textfild(TextEditingController controll, FocusNode focusNode,
      String typename, IconData icon) {
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
          controller: controll,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: typename,
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
