import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_1/auth/auth_screen.dart';
import 'package:instagram_1/data/firebase/storage.dart';
import 'package:instagram_1/data/firebase/firestore.dart';
import 'package:instagram_1/data/model/usermodel.dart';
import 'package:instagram_1/util/imagepicker.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final StorageMethod _storageMethod = StorageMethod();
  final FirebaseRealtimeService _dbService = FirebaseRealtimeService();
  late Future<Usermodel> userDataFuture;
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;
  bool _isEditprofile = false;

  Future<void> updateProfilePhoto() async {
    final picker = ImagePickerr();
    final pickedFile = await picker.uploadImage(' gallery');

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        final url = await _storageMethod.uploadFileToStorage("profileImage", file);
        final uniqueUrl =
            "$url?timestamp=${DateTime.now().millisecondsSinceEpoch}";

        await _dbService
            .updateUserData(widget.uid, {'profileImage': uniqueUrl});

        setState(() {
          userDataFuture = _dbService.getUser(); // Refresh user data
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile picture updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload profile photo: $e")),
        );
      }
    }
  }

  Future<void> saveProfileChanges() async {
    if (_usernameController.text.isNotEmpty && _bioController.text.isNotEmpty) {
      try {
        await _dbService.updateUserData(widget.uid, {
          'username': _usernameController.text,
          'bio': _bioController.text,
        });
        setState(() {
          _isEditing = false;
          userDataFuture = _dbService.getUser(); // Refresh user data
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save changes: $e")),
        );
      }
    }
  }

  // Function to delete post
  Future<void> deletePost(String postId) async {
    try {
      await _dbService.deletePost(widget.uid, postId);
      setState(() {
        userDataFuture = _dbService.getUser(); // Refresh user data
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete post: $e")),
      );
    }
  }

  // Function to edit post
  Future<void> editPost(String postId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        final url = await _storageMethod.uploadFileToStorage("posts", file);
        final uniqueUrl =
            "$url?timestamp=${DateTime.now().millisecondsSinceEpoch}";

        await _dbService
            .updatePost(widget.uid, postId, {'postImage': uniqueUrl});
        setState(() {
          userDataFuture = _dbService.getUser(); // Refresh user data
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post updated successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update post: $e")),
        );
      }
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    userDataFuture = _dbService.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 103, 89, 94),
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: FutureBuilder<Usermodel>(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No user data found.'));
          }

          final user = snapshot.data!;
          _usernameController.text = user.username;
          _bioController.text = user.bio;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(197, 255, 255, 255),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await updateProfilePhoto();
                      
                        },
                        child: CircleAvatar(
                          radius: 60,
                          foregroundColor: Colors.black,
                          backgroundImage:
                              // ignore: unnecessary_null_comparison
                              user.profileImage != null && user.profileImage.isNotEmpty
                                  ? NetworkImage(user.profileImage)
                                  : null,
                          backgroundColor: Colors.grey[300],
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(85, 85, 50, 70),
                            child: const Icon(Icons.add_a_photo,
                                color: Color.fromARGB(255, 0, 0, 0), size: 30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isEditing
                          ? TextField(
                              style: TextStyle(color: Colors.black),
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username:',
                                labelStyle: TextStyle(
                                    color: Colors.black, fontSize: 25),
                              ),
                            )
                          : Text(
                              user.username,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                      const SizedBox(height: 10),
                      _isEditing
                          ? TextField(
                              style: TextStyle(color: Colors.black),
                              controller: _bioController,
                              decoration: const InputDecoration(
                                  labelText: 'Bio',
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 25)),
                            )
                          : Text(
                              user.bio,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _infoTile(
                            title: "Followers",
                            value: '${user.followers.length}',
                          ),
                          _infoTile(
                            title: "Following",
                            value: '${user.following.length}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit Button
                const SizedBox(height: 16),
                _isEditing
                    ? ElevatedButton(
                        onPressed: saveProfileChanges,
                        child: const Text("Save Changes",
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255))),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),

                // Posts Section
                const SizedBox(height: 15),
                const Text(
                  "Your Posts",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 15),
                StreamBuilder(
                  stream: _dbService.getUserPosts(widget.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (snapshot.data == null ||
                        (snapshot.data! as DatabaseEvent).snapshot.value ==
                            null) {
                      return const Center(child: Text("No posts to display."));
                    }

                    final postsMap = Map<String, dynamic>.from(
                        (snapshot.data! as DatabaseEvent).snapshot.value
                            as Map);
                    final posts = postsMap.values.toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return GestureDetector(
                          onLongPress: () {
                            _showPostOptions(context, post['postId']);
                          },
                          child: Image.network(post['postImage'],
                              fit: BoxFit.cover),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile({required String title, required String value}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
              fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ],
    );
  }

  // Show post options (edit or delete)
  void _showPostOptions(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Post Options",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                editPost(postId);
              },
              child: const Text(
                "Edit Post",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deletePost(postId);
              },
              child: const Text(
                "Delete Post",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
