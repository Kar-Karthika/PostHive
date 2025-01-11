import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:instagram_1/data/firebase/storage.dart';
import 'package:instagram_1/util/exception.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
//  Future<void> Login({required String email, required String password}) async {
//     try {
//       await _firebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       print("User logged in successfully");
//     } on FirebaseAuthException catch (e) {
//       print("Error during login: ${e.message}");
//       throw e;  // Rethrow to handle in UI (for displaying error messages)
//     }
//   }
  Future<void> Login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw exceptions('The email address is badly formatted.');
        case 'user-disabled':
          throw exceptions(
              'The user corresponding to the given email has been disabled.');
        case 'user-not-found':
          throw exceptions('No user corresponding to the given email.');
        case 'wrong-password':
          throw exceptions('Incorrect password provided.');
        default:
          throw exceptions(e.message ?? 'An unexpected error occurred.');
      }
    } catch (e) {
      throw exceptions('An unexpected error occurred.');
    }
  }

  Future<void> Signup({
    required String email,
    required String password,
    required String passwordConfirme,
    required String username,
    required String bio,
    required File profile,
  }) async {
    String profileURL = '';
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (password == passwordConfirme) {
          // Create user with email and password
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

          String uid = userCredential.user!.uid;

          // Upload profile image to Firebase Storage
          if (profile.path.isNotEmpty) {
            profileURL =
                await StorageMethod().uploadFileToStorage('Profile', profile);
          } else {
            profileURL =
                'https://firebasestorage.googleapis.com/v0/b/instagram-8a227.appspot.com/o/person.png?alt=media&token=c6fcbe9d-f502-4aa1-8b4b-ec37339e78ab';
          }

          // Store user data in Realtime Database
          await _dbRef.child('users').child(uid).set({
            'email': email,
            'username': username,
            'bio': bio,
            'profile': profileURL,
          });
        } else {
          throw exceptions('Password and confirm password should be the same.');
        }
      } else {
        throw exceptions('Please fill in all the fields.');
      }
    } on FirebaseAuthException catch (e) {
      throw exceptions(e.message ?? 'Signup failed.');
    }
  }
}
