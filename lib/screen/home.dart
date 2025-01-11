import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instagram_1/data/firebase/firestore.dart';
import 'package:instagram_1/data/firebase/storage.dart';
import 'package:instagram_1/screen/chatscreen.dart';
import 'package:instagram_1/screen/liked_posts.dart';
import 'package:instagram_1/util/imagepicker.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController commentController = TextEditingController();
  final ImagePickerr _imageHandler = ImagePickerr();
  final TextEditingController captionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  bool isLoading = false;
  void _captureMedia({required bool isPhoto}) async {
    File? mediaFile = await _imageHandler.uploadImage(
      'camera',
    );

    if (mediaFile != null) {
      final file = File(mediaFile.path);

      // Show dialog for entering caption and location
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(isPhoto ? 'New Photo Post' : 'New Video Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: captionController,
                decoration: InputDecoration(labelText: 'Caption'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String caption = captionController.text.trim();
                String location = locationController.text.trim();
                setState(() {
                  isLoading = true; // Indicates the loading state
                });
                if (caption.isNotEmpty && location.isNotEmpty) {
                  try {
                    String postUrl =
                        await StorageMethod().uploadFileToStorage('post', file);

                    // Save post details in Realtime Database
                    await FirebaseRealtimeService().createPost(
                      postImage: postUrl,
                      caption: captionController.text,
                      location: locationController.text,
                    );

                    // ignore: use_build_context_synchronously
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
                }

                captionController.clear();
                locationController.clear();
                // ignore: use_build_context_synchronously
                //  Navigator.of(context).pop();
              },
              child: Text('Post'),
            ),
            TextButton(
              onPressed: () {
                captionController.clear();
                locationController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Chatscreen()),
    );
  }

  void _openLike() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LikedPostsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 103, 89, 94),
        centerTitle: true,
        elevation: 0,
        title: SizedBox(
          width: 105.w,
          height: 28.h,
          child: Opacity(
            opacity: 1.0,
            child: Image.asset(
              'images/ph1.png',
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.camera_alt,
          ),
          onPressed: () async => _captureMedia(isPhoto: true),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_border_outlined,
              size: 25,
            ),
            onPressed: _openLike,
          ),
          SizedBox(
            width: 5,
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline),
            onPressed: _openChat,
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref()
            .child('posts')
            .orderByChild('time')
            .onValue, // Listening to changes
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text('No posts available.'));
          }

          // Safely handle data conversion
          Map<dynamic, dynamic> posts = {};
          try {
            posts = Map<dynamic, dynamic>.from(
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
          } catch (e) {
            return Center(child: Text('Error: Invalid data format.'));
          }

          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var postData = posts.values.elementAt(index);
                    var profileImage =
                        postData['profileImage']?.toString() ?? '';
                    var username =
                        postData['username']?.toString() ?? 'Unknown';
                    var imageUrl = postData['postImage']?.toString() ?? '';
                    var description =
                        postData['caption']?.toString() ?? 'No Description';
                    var postTime =
                        postData['time']?.toString() ?? 'Unknown Time';
                    DateTime parsedTime = DateTime.parse(postTime);

// Format the date and time
                    String formattedTime =
                        "${parsedTime.year}-${parsedTime.month.toString().padLeft(2, '0')}-${parsedTime.day.toString().padLeft(2, '0')} ${parsedTime.hour.toString().padLeft(2, '0')}:${parsedTime.minute.toString().padLeft(2, '0')}:${parsedTime.second.toString().padLeft(2, '0')}";
                    var likes = postData['likes'] ?? {};
                    var likeCount = postData['likeCount'] ?? 0;

                    // Track the liked state locally for the specific post
                    bool isLiked = likes
                        .containsKey(FirebaseAuth.instance.currentUser!.uid);

                    return Card(
                      color: const Color.fromARGB(231, 238, 214, 211),
                      margin: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 15.w,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile and username
                            Row(
                              children: [
                                if (profileImage.isNotEmpty)
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(profileImage),
                                    radius: 20.r,
                                  )
                                else
                                  CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 232, 180, 184),
                                    radius: 20.r,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                SizedBox(width: 10.w),
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            // Post Image
                            if (imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Image.network(
                                  imageUrl,
                                  // width: double.infinity,
                                  // height: 200.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            SizedBox(height: 2.h),
                            // Post Description
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            // Post Time
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            // Action Buttons: Like, Comment, Share
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite // Red heart when liked
                                        : Icons
                                            .favorite_border, // White heart when not liked
                                    color: isLiked
                                        ? Colors.red // Red color when liked
                                        : Colors
                                            .black, // Default color (black) when not liked
                                  ),
                                  onPressed: () async {
                                    // Get the current user ID
                                    String uid =
                                        FirebaseAuth.instance.currentUser!.uid;

                                    // Safely handle the 'likes' field; use an empty map as the default
                                    Map<String, dynamic> likes =
                                        Map<String, dynamic>.from(
                                            postData['likes'] ?? {});

                                    // Track the current like count
                                    int currentLikeCount =
                                        postData['likeCount'] ?? 0;

                                    // Toggle the 'isLiked' state locally
                                    setState(() {
                                      isLiked =
                                          !isLiked; // Toggle the isLiked state
                                    });

                                    // Add or remove like in the local 'likes' map
                                    if (isLiked) {
                                      likes[uid] = true; // Add like
                                    } else {
                                      likes.remove(uid); // Remove like
                                    }

                                    // Update the like count based on the 'likes' map
                                    int newLikeCount = likes.length;

                                    // Call the toggleLike function to add/remove the user's like and update like count in Firebase
                                    String result =
                                        await FirebaseRealtimeService()
                                            .toggleLike(
                                      postId: postData['postId'], // Post ID
                                      uid: uid, // User ID
                                      likes: likes, // Current likes map
                                      currentLikeCount:
                                          currentLikeCount, // Current like count
                                    );

                                    // If the update was successful, update the local data
                                    if (result == 'success') {
                                      setState(() {
                                        postData['likes'] =
                                            likes; // Update the 'likes' field locally
                                        postData['likeCount'] =
                                            newLikeCount; // Update the like count locally
                                      });
                                    } else {
                                      // Handle error if something goes wrong
                                      print('Error: $result');
                                    }
                                  },
                                ),
                                Text(
                                  '$likeCount likes',
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 0, 0, 0)),
                                ),
                                SizedBox(width: 20.w),
                                IconButton(
                                  icon: Icon(
                                    Icons.comment_outlined,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  onPressed: () {
                                    // Comment functionality
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Add a Comment'),
                                        content: TextField(
                                          controller: commentController,
                                          decoration: InputDecoration(
                                            hintText: 'Write a comment...',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              String comment =
                                                  commentController.text.trim();
                                              if (comment.isNotEmpty) {
                                                await FirebaseDatabase.instance
                                                    .ref()
                                                    .child(
                                                        'posts/${postData['postId']}/comments')
                                                    .push()
                                                    .set({'comment': comment});
                                              }
                                              commentController.clear();
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Post'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Text('Comment',
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 0, 0, 0))),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.share_outlined,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    if (description != null &&
                                        username != null) {
                                      String content =
                                          '$username\n$description';

                                      if (imageUrl != null &&
                                          imageUrl!.isNotEmpty) {
                                        Share.share(
                                            content + '\n\nImage: $imageUrl');
                                      } else {
                                        Share.share(content);
                                      }
                                    } else {
                                      print('No post data available to share!');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: posts.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
