PostHive📸
PostHive is a social media app inspired by Instagram. Built with Flutter for the frontend and Firebase for backend services, it enables users to share posts, update profiles, and interact with others in real time.

Features ✨
User Authentication: 
•	Sign up with email and password.
•	Login and logout functionality.
•	Forgot password support.
User Profiles:
•	Update profile picture and bio.
•	View other users' profiles.
•	View liked posts
Posts:
•	Upload images with captions.
•	Update and Delete the post
•	View a feed of all users' posts.
•	Like and comment on posts.
Reels:
•	Upload videos with captions.
•	View a feed of all users' reels
Realtime Updates:
•	Posts and comments update in real-time using Firebase Realtime Database.

Tech Stack 🛠️
  Frontend
•	Flutter - Cross-platform UI toolkit.
  Backend
•	Firebase Authentication - Secure user authentication.
•	Firebase Realtime Database - Store and sync app data in real time.
•	Cloudinary - Store user-uploaded images.
 
Setup Instructions 🚀
  Prerequisites
    Install Flutter and ensure it's correctly set up.
    Install Firebase CLI and authenticate it with your Google account.
    Create a new Firebase project at Firebase Console.
  Install Dependencies:
    bash Copy code
        flutter pub get
  Set Up Firebase:
      Add your Firebase project to the app.
      Download the google-services.json file for Android and place it in android/app/.
      Download the GoogleService-Info.plist file for iOS and place it in ios/Runner/.
      Configure Firebase in Flutter: Update the firebase_options.dart file or initialize Firebase in your main.dart file:

Firebase Configuration 🔥
  Enable Authentication:
•	Go to Firebase Console → Authentication → Sign-in method.
•	Enable Email/Password authentication.
  Enable Realtime Database:
•	Go to Firebase Console → Realtime Database → Create Database.
•	Set the database rules to:
            json
            Copy code
                  {
                    "rules": {
                    ".read": "auth != null",
                    ".write": "auth != null"
                     }
                  }

 

Future Enhancements 🛠️
•	Add chat functionality.
•	Push notifications for likes, comments, and followers.


