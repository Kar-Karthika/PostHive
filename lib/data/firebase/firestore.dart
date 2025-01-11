import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:instagram_1/data/model/usermodel.dart';
import 'package:instagram_1/util/exception.dart';

import 'package:uuid/uuid.dart';

class FirebaseRealtimeService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser({
    required String email,
    required String username,
    required String bio,
    required String profile,
  }) async {
    try {
      await _dbRef.child('users').child(_auth.currentUser!.uid).set({
        'email': email,
        'username': username,
        'bio': bio,
        'profileImage': profile,
        'followers': [],
        'following': [],
      });
      print("User Added");
      return true;
    } catch (e) {
      print("Failed to add user: $e");
      return false;
    }
  }

  Future<Usermodel> getUser({String? UID}) async {
    try {
      // Fetch user data from Realtime Database
      final snapshot = await _dbRef
          .child('users')
          .child(UID ?? _auth.currentUser!.uid)
          .get();

      // Ensure the snapshot exists
      if (!snapshot.exists) {
        throw exceptions("User not found in the database.");
      }

      // Extract and return user data
      final userData = snapshot.value as Map<dynamic, dynamic>;
      return Usermodel(
        userData['bio'] ?? '',
        userData['email'] ?? '',
        List<String>.from(userData['followers'] ?? []),
        List<String>.from(userData['following'] ?? []),
        userData['profileImage'] ?? '',
        userData['username'] ?? '',
      );
    } catch (e) {
      throw exceptions("Failed to fetch user: $e");
    }
  }

  Future<bool> createPost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    try {
      String uid = Uuid().v4();
      DateTime timestamp = DateTime.now();
      Usermodel user = await getUser();

      await _dbRef.child('posts').child(uid).set({
        'postImage': postImage,
        'username': user.username,
        'profileImage': user.profileImage,
        'caption': caption,
        'location': location,
        'uid': _auth.currentUser!.uid,
        'postId': uid,
        'like': [],
        'time': timestamp.toIso8601String(),
      });
      return true;
    } catch (e) {
      throw exceptions('Failed to create post: $e');
    }
  }

  Future<bool> createReels({
    required String video,
    required String caption,
  }) async {
    try {
      String uid = Uuid().v4();
      DateTime timestamp = DateTime.now();
      Usermodel user = await getUser();

      await _dbRef.child('reels').child(uid).set({
        'reelsvideo': video,
        'username': user.username,
        'profileImage': user.profileImage,
        'caption': caption,
        'uid': _auth.currentUser!.uid,
        'postId': uid,
        'like': [],
        'time': timestamp.toIso8601String(),
      });
      return true;
    } catch (e) {
      throw exceptions('Failed to create reels: $e');
    }
  }

  Future<bool> addComment({
    required String comment,
    required String type,
    required String postId,
  }) async {
    try {
      String commentId = Uuid().v4();
      Usermodel user = await getUser();

      await _dbRef
          .child(type)
          .child(postId)
          .child('comments')
          .child(commentId)
          .set({
        'comment': comment,
        'username': user.username,
        'profileImage': user.profileImage,
        'CommentUid': commentId,
      });
      return true;
    } catch (e) {
      throw exceptions('Failed to add comment: $e');
    }
  }

  Future<String> toggleLike({
    required String postId,
    required String uid,
    required Map<String, dynamic> likes,
    required int currentLikeCount,
  }) async {
    try {
      final postRef =
          FirebaseDatabase.instance.ref().child('posts').child(postId);

      // Update the likes map
      await postRef.update({
        'likes': likes,
        'likeCount':
            likes.length, // Update the like count based on the likes map
      });

      return 'success';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      // Update the user data in the "users" collection
      await _dbRef.child('users').child(uid).update(data);

      // Update user data in posts
      DatabaseReference postsRef = _dbRef.child('posts');
      DataSnapshot postsSnapshot = await postsRef.get();
      if (postsSnapshot.exists) {
        Map<dynamic, dynamic> posts =
            postsSnapshot.value as Map<dynamic, dynamic>;
        for (var entry in posts.entries) {
          if (entry.value['uid'] == uid) {
            Map<String, dynamic> postUpdateData = {};
            if (data.containsKey('username')) {
              postUpdateData['username'] = data['username'];
            }
         
            if (data.containsKey('profileImage')) {
              postUpdateData['profileImage'] = data['profileImage'];
            }

            if (postUpdateData.isNotEmpty) {
              await postsRef.child(entry.key).update(postUpdateData);
            }
          }
        }
      }

      // Update user data in reels
      DatabaseReference reelsRef = _dbRef.child('reels');
      DataSnapshot reelsSnapshot = await reelsRef.get();
      if (reelsSnapshot.exists) {
        Map<dynamic, dynamic> reels =
            reelsSnapshot.value as Map<dynamic, dynamic>;
        for (var entry in reels.entries) {
          if (entry.value['uid'] == uid) {
            Map<String, dynamic> reelUpdateData = {};
            if (data.containsKey('username')) {
              reelUpdateData['username'] = data['username'];
            }
            
            if (data.containsKey('profileImage')) {
              reelUpdateData['profileImage'] = data['profileImage'];
            }

            if (reelUpdateData.isNotEmpty) {
              await reelsRef.child(entry.key).update(reelUpdateData);
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to update user data across posts and reels: $e');
    }
  }

  Stream<DatabaseEvent> getUserPosts(String uid) {
    return _dbRef.child('posts').orderByChild('uid').equalTo(uid).onValue;
  }

  Future<void> toggleFollow({required String uid}) async {
    try {
      final currentUserRef =
          _dbRef.child('users').child(_auth.currentUser!.uid);
      final targetUserRef = _dbRef.child('users').child(uid);

      final currentUserSnapshot = await currentUserRef.get();
      final following = List<dynamic>.from(
          (currentUserSnapshot.value as Map<dynamic, dynamic>)['following'] ??
              []);

      if (following.contains(uid)) {
        // Unfollow
        await currentUserRef.child('following').child(uid).remove();
        await targetUserRef
            .child('followers')
            .child(_auth.currentUser!.uid)
            .remove();
      } else {
        // Follow
        await currentUserRef.child('following').child(uid).set(true);
        await targetUserRef
            .child('followers')
            .child(_auth.currentUser!.uid)
            .set(true);
      }
    } catch (e) {
      throw exceptions('Failed to toggle follow: $e');
    }
  }

  // Function to delete a post
  Future<void> deletePost(String uid, String postId) async {
    try {
      // Reference to the specific post in the database
      final postRef = _dbRef.child('posts/$postId');

      // Check if the post belongs to the current user
      final postSnapshot = await postRef.get();
      if (postSnapshot.exists) {
        // Delete the post from the database
        await postRef.remove();
      } else {
        throw Exception("Post does not belong to the user.");
      }
    } catch (e) {
      throw Exception("Failed to delete post: $e");
    }
  }

  // Function to update a post's information
  Future<void> updatePost(
      String uid, String postId, Map<String, dynamic> updatedData) async {
    try {
      // Reference to the specific post in the database
      final postRef = _dbRef.child('posts/$postId');

      // Check if the post belongs to the current user
      final postSnapshot = await postRef.get();
      if (postSnapshot.exists) {
        // Update the post in the database
        await postRef.update(updatedData);
      } else {
        throw Exception("Post does not belong to the user.");
      }
    } catch (e) {
      throw Exception("Failed to update post: $e");
    }
  }
}
