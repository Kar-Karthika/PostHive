import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LikedPostsScreen extends StatefulWidget {
  const LikedPostsScreen({Key? key}) : super(key: key);

  @override
  _LikedPostsScreenState createState() => _LikedPostsScreenState();
}

class _LikedPostsScreenState extends State<LikedPostsScreen> {
  final _databaseRef = FirebaseDatabase.instance.ref();
  late Future<List<Map<String, dynamic>>> likedPostsFuture;

  @override
  void initState() {
    super.initState();
    likedPostsFuture = getLikedPosts();
  }

  Future<List<Map<String, dynamic>>> getLikedPosts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return [];

      final userSnapshot =
          await _databaseRef.child('users').child(currentUser.uid).get();
      if (userSnapshot.exists) {
       // final userData = userSnapshot.value as Map<dynamic, dynamic>;

        final postsSnapshot = await _databaseRef.child('posts').get();
        if (postsSnapshot.exists) {
          final postsData = postsSnapshot.value as Map<dynamic, dynamic>;

          final likedPosts = postsData.values
              .where((post) {
                final likes = post['likes'];
                if (likes != null) {
                  if (likes is Map) {
                    // If 'likes' is a map, check if currentUser.uid is a key in the map
                    return likes.containsKey(currentUser.uid);
                  } else if (likes is List) {
                    // If 'likes' is a list, check if currentUser.uid is in the list
                    return likes.contains(currentUser.uid);
                  }
                }
                return false;
              })
              .toList()
              .map((post) => Map<String, dynamic>.from(post))
              .toList();

          return likedPosts;
        }
      }
      return [];
    } catch (e) {
      print("Failed to fetch liked posts: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 164, 147, 147),
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: const Color.fromARGB(180, 255, 255, 255)),
        title: const Text(
          'Liked Posts',
          style: TextStyle(color: const Color.fromARGB(180, 255, 255, 255)),
        ),
        backgroundColor: Color.fromARGB(255, 103, 89, 94),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: likedPostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No liked posts.'));
          }

          final likedPosts = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(5),
            itemCount: likedPosts.length,
            itemBuilder: (context, index) {
              final post = likedPosts[index];

              return GestureDetector(
                onTap: () {
                  // Navigate to PostScreen with the post data
                },
                child: Card(
                  margin: const EdgeInsets.all(20),
                  color: Colors.grey.shade100,
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 1,
                      children: [
                        Image.network(post['postImage'],
                            height: 400, width: 500, fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            post['caption'] ?? 'No caption',
                            style: const TextStyle(
                                fontSize: 25,
                                letterSpacing: 5,
                                wordSpacing: 4,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                        Text(
                          '  Posted by: ${post['username']}',
                          style: TextStyle(
                              letterSpacing: 5,
                              wordSpacing: 4,
                              color: const Color.fromARGB(255, 34, 102, 136)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
